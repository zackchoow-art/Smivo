# Task 022: Home 页返回崩溃修复

## 分配给: Flash
## 复杂度: ⭐⭐
## 可独立执行

## 问题描述
用户反馈：从其他页面返回 Home 页经常会崩溃。

## 调查步骤

### 1. 复现问题
在 Chrome 上运行 `flutter run -d chrome`，尝试以下路径：
- 从 Listing Detail 返回 Home
- 从 Order Detail 返回 Home
- 从 Chat 返回 Home
- 从 Settings 返回 Home
- 从 Seller Center 返回 Home

### 2. 查看 Console 错误
在 Chrome DevTools Console 中查找红色错误信息，重点关注：
- `setState() called after dispose()`
- `Looking up a deactivated widget's ancestor is unsafe`
- `'Null check operator used on a null value'`
- Provider 相关的 `ProviderScope` 错误

### 3. 常见原因排查

**可能原因 A: Provider 在 dispose 后被访问**
检查 `home_screen.dart` 和 `home_provider.dart`：
- 是否有 `ref.watch` 在 widget 已经 dispose 后触发
- 是否有 StreamSubscription 没有正确取消

**可能原因 B: GoRouter 导航冲突**
检查 `core/router/router.dart`：
- 是否有 `context.go` 和 `context.push` 混用导致栈异常
- 检查 redirect 逻辑是否在导航时触发了意外的重定向

**可能原因 C: Realtime Channel 重复订阅**
检查 HomeScreen 相关的 provider 是否订阅了 Realtime channel 并在 dispose 时正确取消

### 4. 修复
根据排查结果修复问题。

## 验证
```bash
flutter analyze
```
在 Chrome 上测试以上 5 种返回路径，确认不再崩溃。
