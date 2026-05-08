# T3: 全屏图片浏览与图片保存 功能执行报告

## 1. 修改/新建的文件

- **新建**: `app/lib/shared/widgets/fullscreen_image_viewer.dart` (全屏图片浏览、滑动切换、保存至相册的通用组件)
- **修改**: `app/pubspec.yaml` (添加并锁定了所需的新依赖)
- **修改**: `app/ios/Runner/Info.plist` (iOS平台权限检查)
- **修改**: `app/android/app/src/main/AndroidManifest.xml` (添加 Android 写入相册的存储权限)
- **修改**: `app/lib/features/listing/widgets/listing_image_carousel.dart` (为商品图片轮播图接入全屏查看，已过滤被标记拒绝的违规图片)
- **修改**: `app/lib/features/chat/screens/chat_room_screen.dart` (收集当前聊天记录中所有合规图片并传递给全屏组件，支持左右滑动查看，并正确更新聊天气泡中的图片点击逻辑)

## 2. 添加的依赖包及版本

通过 `flutter pub add` 添加了如下依赖库（版本由 pub 自动解析适配 Flutter 3.x+）：
- `photo_view: 0.15.0`（用于图片的双指缩放和拖拽）
- `gal: 2.3.2`（替换原版的 image_gallery_saver，更好地支持 Flutter 新版和 Android 10+ 保存相册，自带保存所需权限校验能力）
- `dio: 5.9.2`（用于进行快捷的图片文件下载并保存到本地临时缓存）
- `path_provider: 2.1.5`（由于使用了 Dio 下载文件，我们需要利用 path_provider 拿到临时下载目录的绝对路径）
*(注：由于 gal 内置了权限检查机制，我们在最终精简代码时移除了 `permission_handler`。)*

## 3. 全屏浏览器的 API 设计

该组件以标准的 StatefulWidget 提供：

```dart
class FullscreenImageViewer extends StatefulWidget {
  const FullscreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;
  // ...
}
```

- **参数**: 
  - `imageUrls`: 接收合规且经过过滤的图片 URL 列表，用于 `PhotoViewGallery` 滑动渲染。
  - `initialIndex`: 表示用户具体点击的第几张图片，决定初始展开显示的页码。
- **渲染逻辑**: 
  - 核心为 `PhotoViewGallery.builder`，配合 `PageController` 维持滑动状态。
  - `GestureDetector` 添加了垂直滑动的监听，当检测到向下滑动速度超过特定阈值时，自动执行 `Navigator.pop(context)` 关闭页面，增强了交互流畅度。
- **保存功能**: 右上角的下载按钮点击后，系统使用 `gal` 先行检查和获取用户相册授权，授权通过后使用 `dio` 将图片临时拉取到 `path_provider` 提供的 Temp 目录，然后存入手机图库，并用 `SnackBar` 反馈进度和结果。

## 4. flutter analyze 输出结果

运行 `flutter analyze` 报告了项目中原有的约 39 处 warnings/infos（如旧版 `activeColor`、老旧组件弃用提示等）。
经复查，我们本次新增或修改的代码**没有产生任何静态类型警告、错误或未使用的 import**。编译与类型检查全绿通过。

## 5. 平台特定的注意事项

- **Android 权限**: 已在 `AndroidManifest.xml` 加入了 `<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />`，这对于在 Android 9 (API 28) 及以下版本执行图库保存功能是必须的。对于 API 29+，`gal` 采用 MediaStore API 绕过直接写入控制，但仍需规范声明。
- **iOS 权限**: 已排查 `app/ios/Runner/Info.plist`，发现其中原本已配置好了 `NSPhotoLibraryAddUsageDescription` 和 `NSPhotoLibraryUsageDescription`（分别作为附加图片和读取图片的权限声明）。因此我们在 iOS 端直接享有合规的相册写入授权声明，无需重复添加。
- **权限申请体验**: `gal` 提供友好的原生的权限拉起 API (`Gal.requestAccess(toAlbum: true)`)，如果用户首次拒绝保存请求，由于底层逻辑安全可靠，之后再次保存会给出无法存储的提示而不会导致系统级崩溃。
