# 深度链接修复执行报告

## 执行时间
2026-05-07 12:35 (Local Time)

## 修改文件清单
| # | 文件路径 | 改动摘要 |
|---|---------|---------|
| 1 | `website/.well-known/apple-app-site-association` | 将 appID 修正为 `DKWKX97U49.com.smivo.app` |
| 2 | `app/lib/core/constants/app_constants.dart` | 将 `appBundleId` 修正为 `com.smivo.app` |
| 3 | `app/ios/Runner/Info.plist` | 注册 `smivo` URL Scheme 并启用 Flutter 深度链接 |
| 4 | `app/pubspec.yaml` | 添加 `flutter_web_plugins` 依赖 |
| 5 | `app/lib/main.dart` | 启用 `usePathUrlStrategy()` 移除 URL 中的 # 符号 |
| 6 | `.github/workflows/flutter_web_deploy.yml` | 添加 `404.html` fallback 步骤以支持 SPA 路由 |
| 7 | `website/.well-known/assetlinks.json` | 将 `package_name` 修正为 `com.smivo.app` |

## 每步执行结果

### 步骤 1：修正 AASA 文件
- 状态：✅ 完成
- 改动详情：修正了 Bundle ID，确保 iOS Universal Links 指向正确的 App。

### 步骤 2：修正 App 常量
- 状态：✅ 完成
- 改动详情：将 `appBundleId` 从 `com.smivo` 改为 `com.smivo.app`，与商店配置一致。

### 步骤 3：注册 URL Scheme
- 状态：✅ 完成
- 改动详情：在 `Info.plist` 中添加了 `smivo://` 协议支持，用于第三方登录和链接跳转。

### 步骤 4：启用 Path URL Strategy
- 状态：✅ 完成
- 改动详情：
    - 已在 `pubspec.yaml` 添加依赖。
    - 已在 `main.dart` 调用 `usePathUrlStrategy()`。
    - 已在 GitHub Actions 中配置 `404.html` 兜底方案。

### 步骤 5：检查 Android App Links
- 状态：✅ 完成
- 改动详情：发现 `assetlinks.json` 存在且 `package_name` 为旧值 `com.smivo`，已将其修正为 `com.smivo.app`。

### 步骤 6：验证
- 状态：✅ 完成
- 改动详情：执行了多项自动化校验。

## 验证结果
- **flutter analyze**: ✅ 通过 (发现 37 个现有警告/提示，主要为未使用变量和弃用成员，非本次改动引入)
- **AASA JSON 校验**: ✅ 通过 (合法 JSON)
- **Info.plist 校验**: ✅ 通过 (合法 XML)
- **YAML 校验**: ⚠️ 跳过 (运行环境缺少 `yaml` 模块，但已手动确认配置块语法正确)
- **assetlinks.json 校验**: ✅ 通过 (合法 JSON)

## 未完成项（需人工操作）
- [ ] **登录 Supabase Dashboard** → Authentication → URL Configuration
  - 确保 Redirect URLs 包含：`https://smivo.io/auth/callback`
  - 确保 Redirect URLs 包含：`smivo://auth/callback`
- [ ] **推送 website/ 到 Vercel** 触发部署 (特别是 `.well-known` 目录)
- [ ] **推送 app/ 到 main** 触发 GitHub Actions 重新构建 Flutter Web (激活 404 兜底)
- [ ] **在真机上重新安装 App** (`flutter run`)，iOS 才会重新注册 URL Scheme 和 Universal Links

## 遗留问题
- 无异常。所有指定改动均已按计划完成。
