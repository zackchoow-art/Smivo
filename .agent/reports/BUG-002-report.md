# BUG-002 执行报告

## 1. 修改详情

修改了 `lib/features/orders/widgets/rental_extension_card.dart` 文件，增加了对待处理（pending）请求的检查逻辑。

### 1.1 逻辑调整
- 在 `data` 回调中增加了 `hasPending` 变量，用于判断当前订单是否存在 `status == 'pending'` 的租期变更请求。
- 修改了显示“调整租期”按钮及 UI 的条件判断，增加了 `!hasPending` 限制。
- 顺便修复了原代码中多余的闭合括号（`]`），确保代码结构整洁。

## 2. 修改前后对比 (Diff)

```diff
--- lib/features/orders/widgets/rental_extension_card.dart
+++ lib/features/orders/widgets/rental_extension_card.dart
@@ -95,10 +95,12 @@
                 );
               }
 
+              final hasPending = extensions.any((ext) => ext.status == 'pending');
+
               return Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   ...extensions.map((ext) => _buildExtensionItem(context, ref, ext)),
-                  if (widget.isBuyer && widget.order.rentalStatus == 'active') ...[
+                  if (widget.isBuyer && widget.order.rentalStatus == 'active' && !hasPending) ...[
                     if (!_isAdjusting)
                       OutlinedButton(
                         onPressed: () => setState(() => _isAdjusting = true),
@@ -109,8 +111,6 @@
                     else
                       _buildAdjustmentUI(context),
                   ],
-                  ],
-                ],
               );
             },
           ),
```

## 3. 验证结果

执行命令：`flutter analyze`
输出结果：
```
Analyzing smivo...
No issues found! (ran in 2.0s)
```

## 4. 结论

通过引入 `hasPending` 检查，现在当买家有一个待处理的租期变更请求时，系统将自动隐藏“调整租期”的入口。这有效防止了买家重复提交请求，确保了业务流程的唯一性和准确性。同时，代码结构也得到了优化。
