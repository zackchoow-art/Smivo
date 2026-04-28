# T-005: iOS Native Configuration — Entitlements + Info.plist

## 任务目标

配置 iOS 项目以支持 Apple Push Notification service (APNs)，包括创建 entitlements 文件和更新 Info.plist。

## 执行边界

### ✅ 你必须做的

1. **创建 entitlements 文件**: `ios/Runner/Runner.entitlements`
2. **修改 Info.plist**: `ios/Runner/Info.plist` — 添加 `UIBackgroundModes`
3. **运行 flutter analyze 检查零错误**

### ❌ 你不许做的

- 不要修改 `lib/` 目录下的任何 Dart 文件
- 不要修改 `pubspec.yaml`
- 不要修改 `AppDelegate.swift`（OneSignal Flutter SDK 不需要修改 AppDelegate）
- 不要修改 `Podfile` 或运行 `pod install`
- 不要修改 Android 配置
- 不要修改 `project.pbxproj`（entitlements 需要通过 Xcode 手动关联，非代码任务）
- 不要删除任何现有配置

---

## 详细要求

### 1. 创建: `ios/Runner/Runner.entitlements`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>aps-environment</key>
	<string>development</string>
</dict>
</plist>
```

> NOTE: 发布到 App Store 时需要将 `development` 改为 `production`。这一步会在 Xcode Archive 时自动处理。

### 2. 修改: `ios/Runner/Info.plist`

在 `</dict>` 结束标签之前（第 79 行之前），添加以下内容：

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

这告诉 iOS 系统该 App 需要接收后台远程通知。

### 3. 验证

```bash
flutter analyze --no-fatal-infos
```

---

## 重要提醒

此任务只创建文件。用户还需要在 Xcode 中手动完成以下操作：
1. 打开 `ios/Runner.xcworkspace`
2. 选择 Runner target → Signing & Capabilities
3. 点击 `+ Capability` → 添加 `Push Notifications`
4. 确认 `Runner.entitlements` 已关联到 Build Settings

这些 Xcode 操作无法通过代码自动完成，用户会在总架构师的指导下单独处理。

---

## 执行报告

完成后，请将执行报告写入：
`/Users/george/smivo/.agent/tasks/push-notifications/T-005_report.md`

报告模板：

```markdown
# T-005 执行报告

## 完成状态: ✅ / ❌

## 修改文件清单
| 文件 | 操作 | 说明 |
|------|------|------|
| ... | 新建/修改 | ... |

## flutter analyze 结果
(粘贴输出)

## 遇到的问题
(如有)
```
