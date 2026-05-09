# T10: Android 兼容性调查报告

## 任务目标

全面调查 Smivo Flutter App 在 Android 平台上的兼容性问题，产出一份详细的调查报告。**此任务仅做调查分析，不修改任何代码。**

## 已知问题

**用户反馈**：在 Android 手机上，进入 Create Listing (Post) 页面，拍照或从图库选择照片后，打开剪裁组件时 app 崩溃退出。

## 调查范围

请系统性地检查以下所有模块在 Android 上的潜在问题，并将发现写入报告。

---

### 调查项 1：image_cropper 崩溃（已知问题，最高优先级）

**核心文件**：`app/lib/core/utils/image_upload_service.dart`

**涉及依赖**：
- `image_cropper: ^12.2.1`（实际锁定 12.2.1）
- 底层 Android 实现使用 **uCrop** 库

**调查要点**：
1. **UCropActivity 是否在 AndroidManifest.xml 中注册？**
   - `image_cropper` v12+ 的 Android 实现需要在 AndroidManifest 中声明 `com.yalantis.ucrop.UCropActivity`
   - 当前 `app/android/app/src/main/AndroidManifest.xml` 中 **没有** 这个声明 — 这很可能就是崩溃原因
   - 检查 `image_cropper` 的 README 和 changelog，确认 v12.2.1 是否需要手动声明 Activity
   - 注意：Flutter plugin 的 Activity 注册有两种方式：(a) plugin 自动在其 AndroidManifest 中声明，由 Gradle merge 进去；(b) 需要开发者手动在 app 的 manifest 中声明。需要确认 image_cropper v12 属于哪种情况。

2. **uCrop 需要 AppCompat/Material 主题**
   - uCrop Activity 的 Android 主题要求：它通常需要一个继承自 `Theme.AppCompat` 或 `Theme.MaterialComponents` 的主题
   - 当前 `styles.xml` 中，`LaunchTheme` 继承自 `@android:style/Theme.Light.NoTitleBar`，`NormalTheme` 也继承自非 AppCompat 主题
   - 如果 uCrop Activity 继承了这些主题，会因缺少 AppCompat 属性而崩溃
   - 需要检查 uCrop Activity 是否有自己的 theme 声明，或是否需要一个 `UCropTheme` 条目

3. **compileSdk / targetSdk 兼容性**
   - 当前 `build.gradle.kts` 中 `compileSdk = flutter.compileSdkVersion`，`minSdk = 26`
   - 确认 `image_cropper` v12.2.1 的 Android SDK 要求

4. **权限检查**
   - `WRITE_EXTERNAL_STORAGE` 已声明，但 Android 13+ (API 33) 已弃用，改用 `READ_MEDIA_IMAGES`
   - 检查 `image_picker` v1.2.1 是否在自身 manifest 中声明了必要的 `CAMERA` 和存储权限
   - `image_cropper` 是否需要额外权限声明

5. **调用代码审查**
   - `_cropImage()` 方法中 `AndroidUiSettings` 配置是否有已知的崩溃风险参数
   - 异步 context.mounted 检查是否充分

### 调查项 2：图片保存到相册（FullscreenImageViewer）

**核心文件**：`app/lib/shared/widgets/fullscreen_image_viewer.dart`

**涉及依赖**：
- `gal: ^2.3.2` — 保存图片到设备相册
- `dio: ^5.9.2` — 下载网络图片
- `path_provider: ^2.1.5` — 获取临时目录
- `permission_handler: ^12.0.1` — 在 pubspec 中声明但实际未 import 使用

**调查要点**：
1. `Gal.hasAccess(toAlbum: true)` 在 Android 13+ 的行为是否正确
2. `Gal.requestAccess()` 是否能正确弹出 Android 权限弹窗
3. `gal` 包的 AndroidManifest 权限要求（是否自动包含 `WRITE_EXTERNAL_STORAGE` / `READ_MEDIA_IMAGES`）
4. Android 的 Scoped Storage 限制是否影响 `Gal.putImage()` 的写入路径
5. `permission_handler` 在 pubspec.yaml 中存在但代码中未被 import — 是否遗漏了需要的权限请求逻辑

### 调查项 3：image_picker 拍照/选图

**核心文件**：`app/lib/core/utils/image_upload_service.dart`, `create_listing_provider.dart`, `chat_room_screen.dart`, `evidence_photo_section.dart`, `submit_feedback_screen.dart`, `edit_profile_screen.dart`, `profile_setup_screen.dart`

**调查要点**：
1. `image_picker: ^1.2.1` 在 Android 的 CAMERA intent 处理
2. Android 13+ `READ_MEDIA_IMAGES` vs `READ_EXTERNAL_STORAGE` 权限适配
3. `maxWidth: 1920, maxHeight: 1920, imageQuality: 80` — 是否存在极端情况导致 OOM
4. `ImageSource.camera` 在没有 `CAMERA` 权限声明时的行为

### 调查项 4：flutter_image_compress

**依赖**：`flutter_image_compress: ^2.4.0`

**调查要点**：
1. 确认此包在 Android 上是否需要额外配置
2. 在 pubspec 中声明但搜索未发现实际使用 — 检查是否有被间接使用或已遗弃

### 调查项 5：share_plus iPad/Android 兼容性

**依赖**：`share_plus: ^13.1.0`

**调查要点**：
1. Android 上 `SharePlus.instance.share()` vs 旧版 `Share.share()` API 兼容性
2. 检查是否有 deprecated API 调用

### 调查项 6：Android 文件 / 权限声明完整性审计

**核心文件**：`app/android/app/src/main/AndroidManifest.xml`

**当前声明的权限**：
- `WRITE_EXTERNAL_STORAGE` — **已声明**

**需要但可能缺失的权限**（需逐个确认）：
- `CAMERA` — image_picker 用相机时可能需要
- `READ_EXTERNAL_STORAGE` — image_picker 用图库时（Android < 13）
- `READ_MEDIA_IMAGES` — Android 13+ 替代 READ_EXTERNAL_STORAGE
- `INTERNET` — Android 默认隐式授予，但确认
- `ACCESS_NETWORK_STATE` — Supabase / Dio 网络请求

### 调查项 7：Android 主题兼容性

**核心文件**：`app/android/app/src/main/res/values/styles.xml`, `values-night/styles.xml`

**调查要点**：
1. `Theme.Light.NoTitleBar` / `Theme.Black.NoTitleBar` 是 Android 原生主题，不含 AppCompat 属性
2. 是否有 plugin（如 image_cropper 的 uCrop）需要 AppCompat 主题
3. 如果 plugin Activity 继承了 app 的主题，可能在打开时崩溃

### 调查项 8：Gradle / AGP 配置审查

**核心文件**：`app/android/build.gradle.kts`, `app/android/settings.gradle.kts`, `app/android/app/build.gradle.kts`

**调查要点**：
1. AGP 8.9.1 + Kotlin 2.1.0 的兼容性
2. 根 `build.gradle.kts` 中 `fixNamespace` 的 manifest `package` 属性清除逻辑 — 是否会误伤 plugin manifest
3. `android.enableJetifier=true` 是否仍然需要，或是否可能造成 artifact 冲突
4. `org.gradle.jvmargs=-Xmx8G` — 是否合理（CI/低内存设备编译时的影响）

### 调查项 9：OneSignal Push Notifications

**依赖**：`onesignal_flutter: ^5.5.1`

**调查要点**：
1. 是否在 AndroidManifest 中有 OneSignal 所需的 receiver/service 声明
2. Push notification 在 Android 13+ 需要 `POST_NOTIFICATIONS` 运行时权限 — 检查是否处理
3. 检查 `push_notification_provider.dart` 中的 Android 特定逻辑

### 调查项 10：其他已知 Android 兼容性风险

1. **app_links** — Deep linking 在 Android 上的配置是否完整（autoVerify, assetlinks.json）
2. **flutter_app_badger** — Android 上 badge count 支持有限（仅 Samsung/华为/小米等有 Launcher API）
3. **app_settings** — 打开系统设置页在不同 Android OEM 上的行为差异
4. **shake** — 摇一摇触发反馈功能在 Android 上的传感器权限
5. **flutter_slidable** — 滑动操作在 Android 上的触摸冲突检查

---

## 输出格式

将调查报告写入 `docs/bug修复/tasks/T10_report.md`，包含以下结构：

### 必须包含的内容

1. **摘要**：一句话概括发现的问题数量和严重程度
2. **关键发现表**：

| # | 模块 | 严重度 | 问题描述 | 根因分析 | 建议修复方案 |
|---|------|--------|---------|---------|------------|
| 1 | image_cropper | 🔴 Critical | ... | ... | ... |

严重度标准：
- 🔴 Critical：导致 app 崩溃或功能完全不可用
- 🟡 Warning：功能可能异常但不崩溃
- 🟢 Info：潜在风险或最佳实践建议

3. **每个问题的详细分析**：引用具体文件和代码行号
4. **建议修复优先级排序**

### 研究方法

- 阅读项目中的代码文件和配置文件
- 使用 `search_web` 查阅以下包在 Android 上的已知问题和配置要求：
  - `image_cropper` v12.2.1 Android setup guide
  - `image_picker` v1.2.1 Android permissions
  - `gal` v2.3.2 Android scoped storage
  - `onesignal_flutter` v5.5.1 Android 13+ POST_NOTIFICATIONS
- 交叉比对 AndroidManifest.xml 与各 plugin 的官方文档

---

## 执行约束

- **不修改任何代码**
- **不运行 flutter 命令**
- 仅做分析和报告
- 重点关注 image_cropper 崩溃问题（已知），同时扫描所有其他潜在风险
