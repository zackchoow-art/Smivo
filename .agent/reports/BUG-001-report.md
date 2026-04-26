# BUG-001 执行报告

## 1. 修改详情

修改了 `lib/features/orders/providers/rental_extension_provider.dart` 文件，调整了异步操作成功后状态赋值与 Provider 失效的顺序。

### 1.1 requestExtension 方法
- **修改前**：先 `invalidate`，再设置 `state = data(null)`
- **修改后**：先设置 `state = data(null)`，再 `invalidate`

### 1.2 approveExtension 方法
- **修改前**：先执行 3 个 `invalidate`，再设置 `state = data(null)`
- **修改后**：先设置 `state = data(null)`，再执行 3 个 `invalidate`

### 1.3 rejectExtension 方法
- **修改前**：先 `invalidate`，再设置 `state = data(null)`
- **修改后**：先设置 `state = data(null)`，再 `invalidate`

## 2. 修改前后对比 (Diff)

```diff
--- lib/features/orders/providers/rental_extension_provider.dart
+++ lib/features/orders/providers/rental_extension_provider.dart
@@ -39,8 +39,8 @@
         priceDiff: priceDiff,
         newTotal: newTotal,
       );
-      ref.invalidate(orderExtensionsProvider(orderId));
-      state = const AsyncValue.data(null);
+      state = const AsyncValue.data(null);
+      ref.invalidate(orderExtensionsProvider(orderId));
     } catch (e, st) {
       state = AsyncValue.error(e, st);
     }
@@ -51,10 +51,10 @@
     try {
       await ref.read(rentalExtensionRepositoryProvider).approveExtension(extensionId);
+      state = const AsyncValue.data(null);
       // Refresh both extensions list and order detail (dates/price updated)
       ref.invalidate(orderExtensionsProvider(orderId));
       ref.invalidate(orderDetailProvider(orderId));
       ref.invalidate(allOrdersProvider);
-      state = const AsyncValue.data(null);
     } catch (e, st) {
       state = AsyncValue.error(e, st);
     }
@@ -65,8 +65,8 @@
     try {
       await ref.read(rentalExtensionRepositoryProvider).rejectExtension(extensionId, note: note);
-      ref.invalidate(orderExtensionsProvider(orderId));
-      state = const AsyncValue.data(null);
+      state = const AsyncValue.data(null);
+      ref.invalidate(orderExtensionsProvider(orderId));
     } catch (e, st) {
       state = AsyncValue.error(e, st);
     }
```

## 3. 验证结果

执行命令：`flutter analyze`
输出结果：
```
Analyzing smivo...
No issues found! (ran in 1.8s)
```

## 4. 结论

通过将 `state` 的赋值操作提前到 `ref.invalidate` 之前，解决了因 Widget 重建导致 Notifier 被 dispose 后仍尝试赋值引发的 `Bad state: Future already completed` 错误。代码现已符合任务要求且通过静态分析。
