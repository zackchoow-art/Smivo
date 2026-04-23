# Smivo Storage Bucket Merge Report (Task 020b)

## 任务目标
将 `chat-images` 和 `order-evidence` 存储桶合并为统一的 `order-files` 存储桶，并按 `orderId` 进行文件夹分类。

## 变更详情

### 1. 数据库迁移 (Step 1)
- **文件**：`supabase/migrations/00021_order_files_bucket.sql`
- **内容**：创建了 `order-files` 公共存储桶，并配置了 SELECT (Public) 和 INSERT (Authenticated) 的 RLS 策略。

### 2. 常量更新 (Step 2)
- **文件**：`lib/core/constants/app_constants.dart`
- **变更**：
    - 删除了 `bucketChatImages` 和 `bucketOrderEvidence`。
    - 新增了 `bucketOrderFiles = 'order-files'`。

### 3. 存储仓库重构 (Step 3 & 4)
- **`StorageRepository`**:
    - 更新 `uploadChatMessageImage` 以使用 `bucketOrderFiles`。
    - **路径逻辑**：如果有 `orderId`，路径为 `{orderId}/chat/{fileName}`；否则为 `unlinked/{chatRoomId}/{fileName}`。
- **`OrderEvidenceRepository`**:
    - 更新 `uploadEvidence` 以使用 `bucketOrderFiles`。
    - **路径逻辑**：更新为 `{orderId}/evidence/{uploaderId}/{fileName}`。

### 4. 编译与验证 (Step 6)
- 运行 `build_runner` 成功生成代码。
- 运行 `flutter analyze` 未发现任何错误。

## 验证检查清单
- [x] `app_constants.dart` 仅包含 `bucketOrderFiles`。
- [x] `storage_repository.dart` 路径逻辑包含 `orderId` 分类。
- [x] `order_evidence_repository.dart` 路径逻辑包含 `evidence` 子目录。
- [x] 全局 grep 确认已无旧存储桶引用。

## ⚠️ 后续操作
请在 Supabase Dashboard 执行 `supabase/migrations/00021_order_files_bucket.sql` 以创建存储桶。
