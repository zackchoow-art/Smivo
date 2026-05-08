# T3: 商品详情页照片全屏浏览/滑动/保存 + 聊天图片同功能

## 任务目标
1. 创建一个通用的全屏图片浏览组件，支持：
   - 点击缩略图后全屏查看
   - 左右滑动切换多张图片
   - 双指缩放
   - 保存图片到相册
2. 在商品详情页（sale 和 rent）的图片轮播上接入此组件
3. 在聊天记录中的图片（非违规图片）上接入此组件

## 执行边界
### 允许修改的文件：
- 新建 `app/lib/shared/widgets/fullscreen_image_viewer.dart`
- `app/lib/features/listing/widgets/listing_image_carousel.dart`
- `app/lib/features/chat/screens/chat_room_screen.dart`（仅图片消息点击部分）

### 严禁修改的文件：
- 任何 provider 文件
- 任何 repository 文件
- 任何 model 文件
- 任何 admin/ 目录文件
- 任何 supabase/ 目录文件
- `app/lib/features/listing/screens/listing_detail_screen.dart`（本任务不改）

### 允许修改的配置文件：
- `app/pubspec.yaml`（添加依赖）
- `app/ios/Runner/Info.plist`（如需添加相册权限描述）
- `app/android/app/src/main/AndroidManifest.xml`（如需添加存储权限）

## 实现步骤

### 1. 添加依赖
在 `pubspec.yaml` 中添加（如果尚未存在）：
- `photo_view: ^0.15.0`（图片缩放）
- 使用 `image_gallery_saver_plus` 或 `gal`（保存图片到相册，选支持 Flutter 3.x+ 的）
- `dio: ^5.0.0`（下载图片用，如果未安装）
- `permission_handler`（请求存储/相册权限，如果未安装）

运行 `cd /Users/george/smivo/app && flutter pub get`

### 2. 创建 fullscreen_image_viewer.dart
```dart
// 功能要求：
// - 接受 List<String> imageUrls 和 int initialIndex
// - 使用 PageView + PhotoView 实现左右滑动 + 缩放
// - 顶部显示 "X / N" 页码指示器
// - 右上角显示保存按钮（下载图标）
// - 点击保存时请求权限 → 下载图片 → 保存到相册 → 显示 SnackBar
// - 背景为黑色半透明，支持下拉关闭
// - 调用方式：通过 Navigator.push(MaterialPageRoute(fullscreenDialog: true, ...))
```

### 3. 修改 listing_image_carousel.dart
- 在 PageView.builder 的每个图片上包裹 GestureDetector
- onTap 时打开 FullscreenImageViewer，传入所有图片 URL 和当前 index
- 注意：被 moderation 标记为 rejected 的图片不应该允许全屏查看

### 4. 修改 chat_room_screen.dart
- 找到图片消息的渲染位置
- 在图片上添加 GestureDetector → onTap 打开 FullscreenImageViewer
- 收集当前聊天中所有图片消息的 URL，传入 viewer 以支持左右滑动
- 注意：被审核标记的违规图片不应该出现在 viewer 的图片列表中

### 5. 平台权限配置
- iOS: 在 Info.plist 中添加 `NSPhotoLibraryAddUsageDescription`（如未添加）
- Android: 确认 AndroidManifest.xml 有 WRITE_EXTERNAL_STORAGE（API < 29）

## 验证要求
执行以下命令确保 0 错误：
```bash
cd /Users/george/smivo/app && flutter pub get && flutter analyze
```

## 执行报告
完成后将执行报告写入文件：`docs/bug修复/tasks/T3_report.md`

报告内容包括：
1. 新建/修改了哪些文件
2. 添加了哪些依赖包及版本
3. 全屏浏览器的 API 设计
4. flutter analyze 的输出结果
5. 是否有平台特定的注意事项
