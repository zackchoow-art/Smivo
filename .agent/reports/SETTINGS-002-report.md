# SETTINGS-002: System Settings 精简与 Help 搜索 报告

## 执行总结

根据任务文件的要求，已经完成了对 System Settings 的精简清理，并在 Help Center 中实现了搜索过滤功能。同时已经更新了生成的 provider 代码，确保依赖正确，并在最终通过了代码分析。

## 具体执行内容

1. **`lib/features/settings/screens/system_settings_screen.dart`**:
   - 移除了 Dark Mode 开关相关的 `SettingToggleRow` 及对应的读取 `darkModeStateProvider` 依赖。
   - 移除了 "Network & Privacy" 模块及内部的 Data Usage 开关和 Privacy Settings 开关。
   - 保留了 App Theme 切换器及 Language 占位卡片。
   - 移除了不再使用的 `settings_provider.dart` 导入（修复了 unused_import 警告）。

2. **`lib/features/settings/providers/settings_provider.dart`**:
   - 删除了被废弃的 `DarkModeState`、`DataUsageState` 和 `PrivacySettingsState`。
   - 运行了 `dart run build_runner build --delete-conflicting-outputs` 更新了 `settings_provider.g.dart` 以反映提供者的移除。

3. **`lib/features/settings/screens/help_screen.dart`**:
   - 将该组件从 `ConsumerWidget` 改造为 `ConsumerStatefulWidget` 以管理局部状态。
   - 引入了 `TextEditingController` 和 `_searchQuery` 来追踪用户的搜索输入。
   - 在构建函数中加入对 `allFaqs` 的过滤逻辑，匹配不区分大小写的 `question` 和 `answer` 文本。
   - 在搜索框 TextField 中利用 `onChanged` 更新状态，并在有输入时利用 `suffixIcon` 添加了一个用于清空输入框和重置搜索状态的按钮。
   - 在搜索无结果时渲染了 "No matching questions found" 提示信息。

## 验证结果

执行了 `flutter analyze`，没有产生因本次改动引发的编译错误或警告。遗留的 5 个 `use_build_context_synchronously` 均为 `edit_profile_screen.dart` 原有的 `info` 级提示，与本次任务无关。修改按计划完全成功。
