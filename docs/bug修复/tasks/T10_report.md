# T10: Android 兼容性调查报告

## 1. 摘要

本次调查发现 Smivo Flutter App 在 Android 平台上存在多项严重的兼容性风险。最关键的问题是 **`image_cropper` 组件因缺少 Manifest 声明和主题不匹配导致 100% 崩溃**。此外，权限声明完整性（Camera、Android 13 媒体权限）以及 Deep Linking 的证书校验配置也存在致命缺陷，将导致核心业务流程在 Android 设备上大面积失效。

**风险统计**：
- 🔴 **Critical** (核心崩溃/功能中断): 5 项
- 🟡 **Warning** (功能受限/异常): 3 项
- 🟢 **Info** (最佳实践/优化建议): 2 项

---

## 2. 关键发现表

| # | 模块 | 严重度 | 问题描述 | 根因分析 | 建议修复方案 |
|---|------|--------|---------|---------|------------|
| 1 | **image_cropper** | 🔴 Critical | 打开剪裁界面时 App 立即崩溃退出 | `UCropActivity` 未在 Manifest 注册；且 App 使用了非 AppCompat 主题 | 在 Manifest 注册 `UCropActivity`，并添加专门的 AppCompat 裁剪主题 |
| 2 | **image_picker** | 🔴 Critical | 拍照功能在部分机型上无法启动或崩溃 | `AndroidManifest.xml` 中完全缺失 `CAMERA` 权限声明 | 添加 `<uses-permission android:name="android.permission.CAMERA" />` |
| 3 | **gal (图片保存)** | 🔴 Critical | Android 13+ 设备无法保存图片到相册 | 缺失 `READ_MEDIA_IMAGES` 权限声明，且代码中未处理 Android 13 运行时权限逻辑 | 添加新版媒体权限，并利用 `permission_handler` 在代码中做版本判断 |
| 4 | **app_links** | 🔴 Critical | 网页分享链接无法自动跳转 App | `assetlinks.json` 中的 SHA256 指纹为占位符，导致域名校验失败 | 替换为生产环境签名的真实 SHA256 指纹 |
| 5 | **权限完整性** | 🔴 Critical | 网络请求或存储访问可能被系统拦截 | 缺失 `INTERNET` (虽然默认开启但建议显式声明) 和 `ACCESS_NETWORK_STATE` | 在 Manifest 补齐网络状态及基础存储权限声明 |
| 6 | **OneSignal** | 🟡 Warning | Android 13+ 可能收不到推送通知 | 虽然 SDK 自动处理权限，但 `POST_NOTIFICATIONS` 的最佳实践（软引导）未落实 | 在 `PushNotificationManager` 中增加 Android 13 权限请求引导逻辑 |
| 7 | **Android 主题** | 🟡 Warning | 第三方 UI 插件外观异常或崩溃风险 | 全局主题继承自原生 `NoTitleBar`，缺少 Material/AppCompat 支持库属性 | 将 `NormalTheme` 更改为继承自 `Theme.MaterialComponents.Light.NoActionBar` |
| 8 | **Gradle 配置** | 🟡 Warning | 插件编译冲突风险 | `fixNamespace` 逻辑手动修改插件 Manifest，在 AGP 更新后可能产生不可预知影响 | 建议移除手动修改脚本，改用标准的命名空间管理方案 |
| 9 | **badger** | 🟢 Info | 桌面角标在大多数 Android 手机上无效 | Android 原生不支持桌面角标，插件仅支持特定 OEM (三星/华为) | 在 UI 或文档中说明 Android 角标支持的局限性 |
| 10 | **image_compress** | 🟢 Info | 依赖冗余风险 | `flutter_image_compress` 仅在反馈模块使用，常规上传未利用 | 评估是否将常规图片上传也接入压缩流程以节省带宽 |

---

## 3. 详细调查分析

### 3.1 image_cropper 崩溃 (🔴 Critical)
- **文件**: `app/android/app/src/main/AndroidManifest.xml`, `app/lib/core/utils/image_upload_service.dart`
- **分析**: 
  - `image_cropper` v12.2.1 底层使用 uCrop 库。根据官方要求，必须在 Manifest 的 `<application>` 标签内手动声明 `com.yalantis.ucrop.UCropActivity`。当前项目 **完全缺失** 此声明。
  - 此外，uCrop 的 Activity 要求使用 `Theme.AppCompat` 或其子主题。目前 `styles.xml` 中的 `LaunchTheme` 和 `NormalTheme` 继承自原生 `@android:style/Theme.Light.NoTitleBar`，会导致 inflate 异常崩溃。

### 3.2 存储与相机权限 (🔴 Critical)
- **文件**: `app/android/app/src/main/AndroidManifest.xml`
- **分析**:
  - **相机**: `image_picker` 调用 `ImageSource.camera` 时需要 `CAMERA` 权限。当前 Manifest 未声明，会导致部分 Android 设备拒绝启动相机。
  - **Android 13 媒体**: 对于保存图片功能（`gal` 插件），Android 13 (API 33)+ 不再认可 `WRITE_EXTERNAL_STORAGE`。必须声明 `READ_MEDIA_IMAGES`。
  - **代码逻辑**: `fullscreen_image_viewer.dart` 中仅调用了 `Gal.requestAccess()`，在 Android 13+ 上这可能不足以触发正确的系统弹窗。

### 3.3 Deep Linking (🔴 Critical)
- **文件**: `website/.well-known/assetlinks.json`
- **分析**:
  - `assetlinks.json` 中的 `sha256_cert_fingerprints` 值为 `"YOUR_SHA256_CERT_FINGERPRINT_HERE"`。
  - Android 系统在安装 App 时会尝试连接服务器校验此指纹。校验失败后，`autoVerify` 机制失效，点击 `smivo.io` 链接会直接跳转浏览器而不是打开 App，严重影响分享体验。

### 3.4 OneSignal 推送 (🟡 Warning)
- **文件**: `app/lib/core/providers/push_notification_provider.dart`
- **分析**:
  - Android 13 引入了 `POST_NOTIFICATIONS` 运行时权限。
  - 虽然 `onesignal_flutter` SDK 会尝试自动请求，但如果不结合 `In-App Messages` 做软引导，用户一旦在首次弹出时拒绝，后续将很难再次触达。代码中直接调用 `OneSignal.Notifications.requestPermission(true)` 属于“硬请求”，UX 较差。

---

## 4. 修复优先级建议

1.  **P0 (立即修复)**: 
    - 补全 `AndroidManifest.xml` 中的 `UCropActivity` 注册。
    - 补全 `CAMERA` 和 `READ_MEDIA_IMAGES` 权限。
    - 修改 `styles.xml` 为 AppCompat/Material 主题。
2.  **P1 (正式版前修复)**:
    - 更新 `assetlinks.json` 的 SHA256 指纹。
    - 在 `fullscreen_image_viewer.dart` 中集成 `permission_handler` 对 Android 13 进行适配。
3.  **P2 (持续优化)**:
    - 优化 OneSignal 的软引导流程。
    - 评估并清理 Gradle 中的 `fixNamespace` 逻辑。

---
**报告人**: Antigravity AI
**日期**: 2026-05-08
