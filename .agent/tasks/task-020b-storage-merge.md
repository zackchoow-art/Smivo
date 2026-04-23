# Task 020b: 合并交易文件 Storage Bucket（方案 A）

## 目标
将聊天图片和交货证据照片合并到一个统一的 `order-files` bucket，
按 orderId 分文件夹存储。商品照片（listing-images）保持不变。

## 最终存储结构

```
order-files/                     ← 新 bucket（替代 chat-images + order-evidence）
  {orderId}/
    chat/                        ← 聊天中发送的图片
      img_001.jpg
    evidence/                    ← 交货时拍的证据照片
      {uploaderId}/
        photo_001.jpg

listing-images/                  ← 保持不变
  {userId}/{listingId}/
    photo_001.jpg

avatars/                         ← 保持不变
  avatars/{userId}/
    avatar.jpg
```

## 前置检查

在开始修改前，Flash 必须先完整阅读以下文件，确认当前使用了哪些
bucket 名称和路径结构：

1. `lib/core/constants/app_constants.dart` — 所有 bucket 常量
2. `lib/data/repositories/storage_repository.dart` — 聊天图片上传
3. `lib/data/repositories/order_evidence_repository.dart` — 证据上传
4. `lib/features/chat/providers/chat_provider.dart` — 聊天中调用上传的地方
5. 搜索所有引用 `bucketChatImages` 和 `bucketOrderEvidence` 的代码

确认后再进行修改。

---

## Step 1: 创建 SQL migration

CREATE `supabase/migrations/00021_order_files_bucket.sql`:

```sql
-- ════════════════════════════════════════════════════════════
-- 00021: Unified Order Files Storage Bucket
--
-- Merges chat-images and order-evidence into a single
-- 'order-files' bucket organized by order ID.
-- Structure: {orderId}/chat/{fileName}
--            {orderId}/evidence/{uploaderId}/{fileName}
-- ════════════════════════════════════════════════════════════

-- Create unified bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('order-files', 'order-files', true)
ON CONFLICT (id) DO NOTHING;

-- Public read
CREATE POLICY "Public read for order files"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'order-files');

-- Authenticated upload
CREATE POLICY "Authenticated upload to order-files"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'order-files'
    AND auth.role() = 'authenticated'
  );
```

**⚠️ USER 需手动执行此 SQL。**
**⚠️ 不要执行之前的 00021_chat_images_bucket.sql（如果还没执行的话）。**

---

## Step 2: 更新 AppConstants

修改 `lib/core/constants/app_constants.dart`：

将：
```dart
  static const String bucketChatImages = 'chat-images';
  static const String bucketOrderEvidence = 'order-evidence';
```

替换为：
```dart
  static const String bucketOrderFiles = 'order-files';
```

删除 `bucketChatImages` 和 `bucketOrderEvidence` 两个常量。

---

## Step 3: 更新 storage_repository.dart 的聊天图片上传

修改 `lib/data/repositories/storage_repository.dart` 中的
`uploadChatMessageImage` 方法。

**关键变化**：
- bucket 从 `bucketChatImages` 改为 `bucketOrderFiles`
- 路径从 `chat/{chatRoomId}/{fileName}` 改为 `{orderId}/chat/{fileName}`
- 需要新增 `orderId` 参数

但注意：**聊天室不一定有关联订单**。买家可能还没下单就开始聊天了。
这种情况下用 `chatRoomId` 作为回退。

修改方法签名和实现：

```dart
  /// Uploads a chat message image and returns its public URL.
  ///
  /// If orderId is available, stores under order folder.
  /// Falls back to chatRoomId subfolder if no order exists yet.
  Future<String> uploadChatMessageImage({
    required String chatRoomId,
    required String fileName,
    required Uint8List fileBytes,
    String? orderId,
  }) async {
    try {
      // Prefer order-based path; fall back to chat room path
      final basePath = orderId != null
          ? '$orderId/chat/$fileName'
          : 'unlinked/$chatRoomId/$fileName';
      await _client.storage
          .from(AppConstants.bucketOrderFiles)
          .uploadBinary(basePath, fileBytes);
      return _client.storage
          .from(AppConstants.bucketOrderFiles)
          .getPublicUrl(basePath);
    } on StorageException catch (e) {
      throw AppStorageException(e.message, e);
    }
  }
```

**然后检查所有调用 `uploadChatMessageImage` 的地方**，确认是否需要
传入 `orderId`。搜索：
```bash
grep -rn "uploadChatMessageImage" lib/
```

如果调用处能获取到 orderId 就传入，获取不到就让它走 `unlinked/` 路径。

---

## Step 4: 更新 order_evidence_repository.dart 的证据上传

修改 `lib/data/repositories/order_evidence_repository.dart` 中的
`uploadEvidence` 方法。

**变化**：
- bucket 从 `bucketOrderEvidence` 改为 `bucketOrderFiles`
- 路径从 `{orderId}/{uploaderId}/{fileName}` 改为
  `{orderId}/evidence/{uploaderId}/{fileName}`

```dart
      // Upload to storage
      final path = '$orderId/evidence/$uploaderId/$fileName';
      await _client.storage
          .from(AppConstants.bucketOrderFiles)
          .uploadBinary(path, imageBytes);

      final imageUrl = _client.storage
          .from(AppConstants.bucketOrderFiles)
          .getPublicUrl(path);
```

---

## Step 5: 全局搜索并修复所有引用

运行以下搜索，确保没有遗漏：

```bash
grep -rn "bucketChatImages\|bucketOrderEvidence\|chat-images\|order-evidence" lib/
```

所有引用都必须替换为 `bucketOrderFiles` / `order-files`。

---

## Step 6: 运行 build_runner + analyze

```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
cd /Users/george/smivo && flutter analyze
```

---

## Step 7: 验证

确认以下文件已正确更新：
- [ ] `app_constants.dart` — 只有 `bucketOrderFiles`，没有旧常量
- [ ] `storage_repository.dart` — 使用 `bucketOrderFiles` + orderId 路径
- [ ] `order_evidence_repository.dart` — 使用 `bucketOrderFiles` + evidence 路径
- [ ] 无其他文件引用旧 bucket 名称

报告写入 `.agent/reports/report-020b.md`。
