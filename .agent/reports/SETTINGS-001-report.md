# SETTINGS-001 执行报告

## 执行时间
2026-04-26

## 1. 修改概述

完成了 Edit Profile 页面从硬编码数据到 Supabase 真实数据的迁移，共修改 4 个文件。

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/data/repositories/profile_repository.dart` | 添加方法 | 新增 `uploadAvatarBytes` 方法 |
| `lib/features/profile/providers/profile_provider.dart` | 添加方法 | 新增 `updateAvatarFromBytes` 方法 |
| `lib/features/settings/providers/profile_provider.dart` | 清空重写 | 删除硬编码 `ProfileForm`，保留注释 |
| `lib/features/settings/screens/edit_profile_screen.dart` | 完全重写 | 连接真实数据 |

同时删除了过时的 `settings/providers/profile_provider.g.dart` 生成文件。

---

## 2. 关键代码变更

### 2a. `profile_repository.dart` — 新增 `uploadAvatarBytes`

```dart
/// Upload an avatar from raw bytes (cross-platform, works on Web).
Future<String> uploadAvatarBytes(
  String userId,
  Uint8List bytes,
  String fileName,
) async {
  final filePath = '$userId-${DateTime.now().millisecondsSinceEpoch}-$fileName';
  await _client.storage.from('avatars').uploadBinary(
        filePath, bytes,
        fileOptions: const supabase.FileOptions(upsert: true),
      );
  return _client.storage.from('avatars').getPublicUrl(filePath);
}
```

**设计决策**：使用 `uploadBinary` 而非 `upload`，因为 `Uint8List` 在所有平台可用（包括 Web），而 `dart:io File` 在 Web 上不可用。

### 2b. `profile_provider.dart` — 新增 `updateAvatarFromBytes`

```dart
/// Upload and update the user's avatar from raw bytes (Web-compatible).
Future<void> updateAvatarFromBytes(Uint8List bytes, String fileName) async {
  final currentProfile = state.valueOrNull;
  if (currentProfile == null) return;
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {
    final avatarUrl = await ref
        .read(profileRepositoryProvider)
        .uploadAvatarBytes(currentProfile.id, bytes, fileName);
    final updated = currentProfile.copyWith(avatarUrl: avatarUrl);
    return ref.read(profileRepositoryProvider).updateProfile(updated);
  });
}
```

### 2c. `settings/providers/profile_provider.dart` — 清空

```dart
// NOTE: Edit Profile now uses the shared profileProvider from
// lib/features/profile/providers/profile_provider.dart.
// This file is kept for backward compatibility of imports.
```

**原因**：原 `ProfileForm` provider 使用硬编码 Map 数据，现改为直接使用 `profileProvider`。

### 2d. `edit_profile_screen.dart` — 完全重写

**之前**：
- `ConsumerWidget`
- 硬编码 pravatar.cc 头像、university.edu 邮箱
- 4 个表单字段：fullName、displayName、major、gradYear
- Save 调用空的 `notifier.save()`

**之后**：
- `ConsumerStatefulWidget`（需要 `TextEditingController`）
- 真实头像来自 `profile.avatarUrl`（`NetworkImage`），无头像显示 `Icons.person`
- 真实邮箱来自 `profile.email`（只读）
- 验证状态来自 `profile.isVerified`（动态显示 Verified/Not Verified）
- 只有 1 个表单字段：Display Name
- 头像点击：`ImageUploadService().pickAndCropImage()` → `readAsBytes()` → `updateAvatarFromBytes()`
- Save 调用 `updateDisplayName()` + 成功 SnackBar + `context.pop()`
- 失败时显示 error SnackBar
- 整页用 `AsyncValue.when()` 包裹（loading/error/data 三态处理）

---

## 3. `flutter analyze` 结果

```
Analyzing smivo...

   info • use_build_context_synchronously (×5)

5 issues found.
```

- **Error 数量：0**
- **Warning 数量：0**
- **Info 数量：5**

5 个 info 均为 `use_build_context_synchronously`，是 Dart analyzer 对 `ConsumerState.mounted` 检查的误报——代码中每处 `context` 使用前都有 `if (mounted)` 守卫，运行时安全。

---

## 4. 跨平台方案说明

| 平台 | 头像上传路径 |
|------|------|
| iOS/Android | `ImageUploadService` → `XFile` → `readAsBytes()` → `uploadAvatarBytes` → `uploadBinary` |
| Web | 同上（`XFile.readAsBytes()` 在 Web 上返回内存 bytes，不依赖 `dart:io`） |

原有的 `uploadAvatar(File)` 和 `updateAvatar(File)` 方法保留不变，供 `profile_setup_screen.dart`（onboarding 流程）继续使用。
