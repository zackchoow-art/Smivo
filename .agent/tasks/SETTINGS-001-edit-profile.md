# SETTINGS-001: Edit Profile 连接真实数据

## 目标
将 Edit Profile 页面从硬编码数据改为连接 Supabase 真实用户数据。

## 修改文件
1. `lib/features/settings/providers/profile_provider.dart` — 重写
2. `lib/features/settings/screens/edit_profile_screen.dart` — 重写

## 不要修改的文件
- ❌ `lib/features/profile/providers/profile_provider.dart` — 这是 onboarding 用的，不要动
- ❌ `lib/data/repositories/profile_repository.dart` — 已有所需方法
- ❌ `lib/data/models/user_profile.dart` — 不需要改
- ❌ `lib/core/utils/image_upload_service.dart` — 直接使用

## 需求详细

### 1. 重写 `settings/providers/profile_provider.dart`

**删除现有的 `ProfileForm` provider**（硬编码 Map），替换为一个新的 provider，复用已有的 `lib/features/profile/providers/profile_provider.dart` 中的 `profileProvider`。

实际上不需要新 provider。Edit Profile 页面应直接使用已有的：
- `profileProvider`（来自 `lib/features/profile/providers/profile_provider.dart`）— 读取/更新 profile
- 不再需要 `settings/providers/profile_provider.dart` 中的 `ProfileForm`

**新增 settings provider 文件内容**（替换原有）：
```dart
// 这个文件可以保留为空，或直接删除 ProfileForm，因为不再需要。
// Edit Profile 直接使用 features/profile/providers/profile_provider.dart
```

或者更好的做法：**将文件内容清空/简化**，只保留最小内容（一个 `// unused` 注释或 .gitkeep），因为不再需要独立的 settings profile provider。

**最简方案**：直接在 `edit_profile_screen.dart` 中 import `features/profile/providers/profile_provider.dart` 的 `profileProvider`。

### 2. 重写 `edit_profile_screen.dart`

**改为 `ConsumerStatefulWidget`**（需要 TextEditingController）。

#### 2a. 头像区域
- 显示当前用户的 `profile.avatarUrl`（用 `NetworkImage`）
- 无头像时显示 `Icons.person` 默认图标
- 点击编辑图标调用 `ImageUploadService().pickAndCropImage(context, isAvatar: true)`
- 选择图片后调用 `ref.read(profileProvider.notifier).updateAvatar(File(xFile.path))`
- **跨平台关键**：Web 上 `dart:io File` 不可用。已有的 `profile_setup_screen.dart` 使用 `dart:io File`。参考 `evidence_photo_section.dart` 看它如何处理。

**Web 兼容方案**：
由于 `ProfileRepository.uploadAvatar()` 接受 `dart:io File`，在 Web 上不可用。
**解决方案**：在 `ProfileRepository` 中**添加**一个 `uploadAvatarBytes` 方法（接受 `Uint8List` + `fileName`），同时保留原有的 `uploadAvatar` 方法。

但根据约束不修改 ProfileRepository... 那就在 screen 层处理：
- 使用 `ImageUploadService().pickAndCropImage()` 获取 `XFile`
- 用 `xFile.readAsBytes()` 读取 `Uint8List`
- **需要新增** `ProfileRepository.uploadAvatarBytes(String userId, Uint8List bytes, String fileName)` 方法

**允许修改的额外文件**：`lib/data/repositories/profile_repository.dart` — 仅允许添加 `uploadAvatarBytes` 方法，不修改现有方法。

```dart
/// Upload avatar from bytes (cross-platform, works on Web)
Future<String> uploadAvatarBytes(String userId, Uint8List bytes, String fileName) async {
  try {
    final filePath = '$userId-${DateTime.now().millisecondsSinceEpoch}-$fileName';
    await _client.storage.from('avatars').uploadBinary(
      filePath, bytes,
      fileOptions: const supabase.FileOptions(upsert: true),
    );
    return _client.storage.from('avatars').getPublicUrl(filePath);
  } on supabase.StorageException catch (e) {
    throw AppException.storage('Failed to upload avatar: ${e.message}', e);
  }
}
```

然后在 screen 中：
```dart
final xFile = await ImageUploadService().pickAndCropImage(context, isAvatar: true);
if (xFile != null) {
  final bytes = await xFile.readAsBytes();
  final fileName = xFile.name;
  final url = await ref.read(profileRepositoryProvider).uploadAvatarBytes(userId, bytes, fileName);
  // Update profile with new avatar URL
  await ref.read(profileProvider.notifier).updateDisplayName(...); // or a new method
}
```

**更简单的做法**：在 `Profile` notifier 中添加一个 `updateAvatarFromBytes` 方法。

**允许修改的额外文件**：
- `lib/data/repositories/profile_repository.dart` — 添加 `uploadAvatarBytes` 方法
- `lib/features/profile/providers/profile_provider.dart` — 添加 `updateAvatarFromBytes` 方法

#### 2b. 邮箱 + 验证状态
- 显示 `profile.email`（只读）
- 显示 `profile.isVerified` 状态（Verified / Not Verified）
- "Change Email" 按钮移除或灰显（Phase 2+）

#### 2c. 表单字段
- **只保留 Display Name**（因为数据库中没有 fullName/major/gradYear）
- 用 `TextEditingController` 初始化为 `profile.displayName`
- 移除 Major 字段
- 移除 Graduation Year 下拉框

#### 2d. Save 按钮
- 调用 `ref.read(profileProvider.notifier).updateDisplayName(newName)`
- 保存成功后显示 SnackBar "Profile updated" + `context.pop()`
- 保存失败显示 error SnackBar

#### 2e. 加载状态
- 整个页面用 `profileProvider` 的 `AsyncValue.when()` 包裹
- loading 时显示 `CircularProgressIndicator`
- error 时显示错误信息

### 3. 处理 `settings/providers/profile_provider.dart`

将文件内容替换为：
```dart
// NOTE: Edit Profile now uses the shared profileProvider from
// lib/features/profile/providers/profile_provider.dart.
// This file is kept for backward compatibility of imports.
```

或者如果有其他地方 import 了这个文件，需要搜索确认。

## 验证步骤

```bash
cd /Users/george/smivo && flutter analyze
```

## 执行报告

写入：`.agent/reports/SETTINGS-001-report.md`
