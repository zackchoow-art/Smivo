# SETTINGS-002: System Settings 精简 + Help 搜索

## 修改文件

1. `lib/features/settings/screens/system_settings_screen.dart`
2. `lib/features/settings/screens/help_screen.dart`
3. `lib/features/settings/providers/settings_provider.dart`

## 不要修改的文件
- ❌ 不修改任何其他文件
- ❌ 不修改 `help_provider.dart`

## 需求 1：System Settings 精简

### 删除 Dark Mode 开关
- 删除 `SettingToggleRow` for Dark Mode（第 36-38 行）
- 删除对应的 `ref.watch(darkModeStateProvider)` 引用

### 删除 Data Usage 和 Privacy 开关
- 删除 `SettingToggleRow` for Data Usage（第 95-97 行）
- 删除 `SettingToggleRow` for Privacy Settings（第 99-101 行）
- 删除 "Network & Privacy" 标题和分割线
- 删除对应的 `ref.watch` 引用

### 保留的内容
- App Theme 切换器（Teal / IKEA Flat）✅
- Language 占位卡片 ✅

### settings_provider.dart 清理
- 删除 `DarkModeState` provider
- 删除 `DataUsageState` provider
- 删除 `PrivacySettingsState` provider
- 保留所有 Notification 相关的 providers

### 最终页面结构
```
标题: System Settings

Display 区域:
  - App Theme 切换器 (Teal / IKEA Flat)
  - Language 占位 (English US)
```

## 需求 2：Help 搜索功能

### 当前问题
搜索框存在但没有过滤逻辑。

### 实现
在 `help_screen.dart` 中：

1. 将 `HelpScreen` 从 `ConsumerWidget` 改为 `ConsumerStatefulWidget`（需要 TextEditingController 或用 `onChanged` + state）
2. 添加搜索状态变量
3. 搜索时过滤 FAQ 列表：
```dart
final allFaqs = ref.watch(helpFaqsProvider);
final filteredFaqs = _searchQuery.isEmpty
  ? allFaqs
  : allFaqs.where((faq) {
      final query = _searchQuery.toLowerCase();
      return faq.question.toLowerCase().contains(query) ||
             faq.answer.toLowerCase().contains(query);
    }).toList();
```
4. 搜索框添加清除按钮
5. 无搜索结果时显示 "No matching questions found"

## 严格边界
- ❌ 不修改 `help_provider.dart`
- ❌ 不修改 `setting_toggle_row.dart`
- ❌ 不修改 `setting_card_container.dart`
- ❌ 不修改 `notification_settings_screen.dart`

## 验证步骤

```bash
cd /Users/george/smivo && flutter analyze
```

需要重新生成 provider 代码：
```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
```

## 执行报告

写入：`.agent/reports/SETTINGS-002-report.md`
