# BUG-001: 租期延期提交后 SnackBar 显示 "Bad state: Future already completed" 错误

## Bug 描述

在 Order Details 页面（租赁订单），买家提交租期延期申请后，数据库操作成功，但 SnackBar 弹出红色错误提示：
`Error: Bad state: Future already completed`

## 根因分析

`RentalExtensionActions` 是 `AutoDisposeAsyncNotifierProvider<void>`。在 `requestExtension()` 方法中：
1. 第 31 行：`state = const AsyncValue.loading()` — 设置 loading
2. 第 33-41 行：`createExtension()` 成功写入数据库
3. 第 42 行：`ref.invalidate(orderExtensionsProvider(orderId))` — 触发 widget rebuild
4. **问题**：`invalidate` 导致 widget 树重建，`AutoDispose` notifier 可能被 dispose/重建
5. 第 43 行：`state = const AsyncValue.data(null)` — 赋值到已被 dispose 的 notifier，抛出异常
6. 异常被 `catch (e, st)` 捕获（第 44 行），设置 `state = AsyncValue.error(e, st)`
7. `rental_extension_card.dart` 的 `_submitRequest` 方法在 catch 中显示了错误 SnackBar

## 修复方案

修改 `lib/features/orders/providers/rental_extension_provider.dart` 中的 `requestExtension` 方法。

### 方案：在 invalidate 之前设置 data 状态

将第 42-43 行的顺序调换：先设置 `state = data`，再 `invalidate`。这样即使 invalidate 触发重建，state 已经是成功状态了。

**修改前：**
```dart
ref.invalidate(orderExtensionsProvider(orderId));
state = const AsyncValue.data(null);
```

**修改后：**
```dart
state = const AsyncValue.data(null);
ref.invalidate(orderExtensionsProvider(orderId));
```

同时，对 `approveExtension` 和 `rejectExtension` 方法做同样的调整（预防同类问题）。

## 修改范围

**只修改这一个文件：**
- `lib/features/orders/providers/rental_extension_provider.dart`

### 严格边界
- ❌ 不要修改 `rental_extension_card.dart`
- ❌ 不要修改 `rental_order_detail_screen.dart`
- ❌ 不要修改 `rental_extension_repository.dart`
- ❌ 不要修改任何其他文件
- ❌ 不要添加新的 import
- ❌ 不要重命名任何变量或方法
- ❌ 不要修改方法签名
- ❌ 不要添加新功能

## 验证步骤

修改完成后，执行以下命令确认代码无错误：
```bash
cd /Users/george/smivo && flutter analyze
```

## 执行报告

完成后请将执行报告写入：
`.agent/reports/BUG-001-report.md`

报告内容包括：
1. 具体修改了哪些行
2. 修改前后的代码对比
3. `flutter analyze` 的输出结果
4. 是否有其他发现
