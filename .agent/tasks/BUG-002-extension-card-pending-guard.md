# BUG-002: 租期调整提交后关闭界面 + pending 状态禁止新请求

## 需求

1. 买家点击 Submit Request 提交成功后，立即关闭调整界面（这一点已经通过 `_resetAdjustment()` 实现，但需要确认 BUG-001 修复后是否正常工作）
2. 当已有 pending 状态的请求时，隐藏 "Adjust Rental Period" 按钮，防止重复提交

## 修改文件

**只修改这一个文件：**
- `lib/features/orders/widgets/rental_extension_card.dart`

## 具体修改

在 `build` 方法的 `data: (extensions)` 回调中（约第 90-116 行），修改显示 "Adjust Rental Period" 按钮的条件：

**当前代码（约第 102 行）：**
```dart
if (widget.isBuyer && widget.order.rentalStatus == 'active') ...[
```

**修改为：**
```dart
final hasPending = extensions.any((ext) => ext.status == 'pending');
if (widget.isBuyer && widget.order.rentalStatus == 'active' && !hasPending) ...[
```

这样当存在 pending 状态的请求时，整个调整区域（包括按钮和调整 UI）都不会显示。

## 严格边界

- ❌ 不要修改任何其他文件
- ❌ 不要修改 `_submitRequest` 方法
- ❌ 不要修改 `_buildAdjustmentUI` 方法
- ❌ 不要修改 `_buildExtensionItem` 方法
- ❌ 不要修改任何 import
- ❌ 不要重命名任何变量或方法
- ❌ 不要修改按钮样式
- ❌ 不要添加新功能

## 验证步骤

```bash
cd /Users/george/smivo && flutter analyze
```

## 执行报告

写入：`.agent/reports/BUG-002-report.md`
