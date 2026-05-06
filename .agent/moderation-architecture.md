# Smivo 内容审核架构 (Content Moderation Architecture)

> 文档版本：2026-05-06
> 适用范围：app/ (Flutter) + supabase/ (Edge Functions + DB)

---

## 一、审核原则

1. **审核绝不阻断业务流程**：所有 AI 审核均为 fire-and-forget，异步执行，不影响用户操作响应速度。
2. **分层防御**：本地过滤（词库）→ 服务端 AI（Edge Function）→ 数据库层（可扩展）。
3. **最小干预原则**：只对公开 UGC（商品、聊天图片）做 AI 审核；内部运营数据（举报、反馈、摇一摇 Bug）不做 AI 审核。
4. **引擎可配置**：AI 引擎选择通过后台 `system_configs` 动态配置，无需改动 Flutter 代码。

---

## 二、各类内容的审核链路

### 2.1 发布新商品（Listing）

```
Flutter App
├── 本地文字过滤（createListingProvider）
│   └── applyContentFilter(title + description, sensitiveWordsProvider)
│       ├── 命中 block 词 → 拦截提交，提示用户
│       └── 命中 warn 词  → 提交成功，显示警告 SnackBar
│
└── 上传图片后（storageRepository.uploadListingImage）
    └── unawaited → ImageModerationService.moderateAsync()
        ├── 读 system_configs: backend_review.enabled
        │   └── false → 跳过
        └── 读 system_configs: ai_provider
            ├── 'google' → 调用 Edge Function: moderate-image-google
            └── 'openai' → 调用 Edge Function: moderate-image-openai

Supabase 服务端（DB Trigger）
└── listings INSERT → trigger_moderation_on_listing()
    └── 若 backend_review.enabled=true → INSERT moderation_tasks
        └── Webhook → moderate-content Edge Function
            ├── 读 system_configs: ai_provider / backend_review.mode
            ├── 执行文字 + 图片 AI 审核
            └── 写 backend_moderation_logs + 更新 listing moderation_status
```

**结果**：
- 图片违规 → `listing_images.moderation_status = 'rejected'`，`ModerationAwareImage` 模糊显示
- 商品整体违规 → `listings.moderation_status = 'pending_review'` 或 `'rejected'`，触发通知

---

### 2.2 发送聊天消息（文字）

```
Flutter App
└── 本地文字过滤（ChatMessages.sendMessage）
    └── applyContentFilter(content, sensitiveWordsProvider)
        ├── 命中 block 词 → 拦截发送，提示用户
        └── 命中 warn 词  → 发送成功，显示警告 SnackBar

Supabase 服务端
└── messages INSERT → trigger_moderation_on_message()
    └── message_type = 'text' → 不触发 moderation_tasks（文字仅本地过滤）
```

---

### 2.3 发送聊天图片

```
Flutter App
└── 上传图片（storageRepository.uploadChatMessageImage）
    └── ❌ 无任何客户端 AI 审核调用

    UI 渲染（ModerationAwareImage）
    └── 查询 backend_moderation_logs（result='fail', target_id=orderId/chatRoomId）
        └── 存在违规记录 → 模糊显示 + 违规标签覆盖
        └── 无违规记录  → 正常显示

Supabase 服务端（DB Trigger）
└── messages INSERT（message_type='image'）→ trigger_moderation_on_message()
    └── 若 backend_review.enabled=true → INSERT moderation_tasks
        └── Webhook → moderate-content Edge Function
            ├── 读 system_configs: ai_provider
            └── 执行图片 AI 审核 → 写 backend_moderation_logs
                └── imageFlagged=true → INSERT moderation_queue（供管理员复查）
```

---

### 2.4 用户举报（Report）

```
Flutter App
└── 直接 INSERT content_reports
    └── ❌ 无任何文字/图片 AI 审核

Supabase 服务端
└── 无 DB Trigger，无 Edge Function 调用
    └── 管理员在 admin.smivo.io 手动处理

未来扩展（只需数据库层，无需改 Flutter）
└── 如需 AI 审核：在 content_reports 表增加 DB Trigger
    → moderation_tasks → moderate-content（无需改 Flutter 代码）
```

---

### 2.5 用户反馈（Feedback）

```
Flutter App
└── 直接 INSERT user_feedbacks
    └── ❌ 无任何 AI 审核（内部数据，非公开 UGC）

    上传截图（storageRepository.uploadFeedbackImage）
    └── ❌ 无任何客户端 AI 审核调用

Supabase 服务端
└── 无 DB Trigger，无 Edge Function 调用

未来扩展（只需数据库层，无需改 Flutter）
└── 如需审核：仅在数据库层增加 Trigger，无需改任何 Flutter 代码
```

---

### 2.6 摇一摇 Bug 提交（Shake Feedback）

```
Flutter App（app.dart _ShakeWrapper）
└── 压缩截图 → storageRepository.uploadFeedbackImage
    └── ❌ 无 AI 审核（同 2.5）
└── feedbackRepository.submitFeedback
    └── 直接 INSERT user_feedbacks（type='bug', title='Shake Feedback'）

Supabase 服务端
└── 无 DB Trigger，无 Edge Function 调用
```

---

### 2.7 Order 证据照片（Evidence Photos）

```
Flutter App
└── 上传图片（storageRepository.uploadEvidenceImage）
    └── unawaited → ImageModerationService.moderateAsync()
        ├── 读 system_configs: backend_review.enabled / ai_provider
        └── 同 Listing 图片审核链路
```

---

## 三、AI 引擎配置（system_configs）

| 配置键 | 类型 | 说明 |
|--------|------|------|
| `backend_review.enabled` | boolean | 全局开关，`false` 时跳过所有服务端 AI 审核 |
| `backend_review.mode` | string | `sensitive_words` / `ai` / `both` |
| `ai_provider` | string | `google`（Google Vision）/ `openai`（OpenAI） |
| `ai_action_on_hit` | string | `flag`（标记审核）/ `reject`（直接拒绝）|
| `ai_moderation_enabled` | string | `true` 时对图片调用 AI（与 `backend_review.mode=ai` 配合）|

**改引擎只需在后台修改 `ai_provider`，Flutter App 无需改动、无需重新发布。**

---

## 四、Edge Functions 分工

| 函数名 | 触发方式 | 作用 |
|--------|---------|------|
| `moderate-image-google` | Flutter 客户端调用（listing_image, evidence） | Google Vision 图片审核，写 backend_moderation_logs |
| `moderate-image-openai` | Flutter 客户端调用（listing_image, evidence） | OpenAI 图片审核，写 backend_moderation_logs |
| `moderate-content` | DB Webhook（moderation_tasks INSERT） | 全能审核：文字+图片，读 system_configs，支持 listing/message/profile |

---

## 五、数据库记录层

| 表 | 写入方 | 用途 |
|----|--------|------|
| `backend_moderation_logs` | Edge Function | 详细审核结果记录，客户端读取用于图片模糊判断 |
| `moderation_tasks` | DB Trigger（SECURITY DEFINER） | 任务队列，Webhook 触发 `moderate-content` |
| `moderation_queue` | `moderate-content` Edge Function | 管理员工作队列，含 AI 标记理由 |

---

## 六、客户端 UI 渲染（ModerationAwareImage）

`ModerationAwareImage` widget 在渲染任意图片时：
1. 查询 `backend_moderation_logs` 中对应 `target_id`、`result='fail'` 的记录
2. 有违规记录 → 模糊显示 + 显示违规类型标签
3. 无违规记录 → 正常显示

此查询基于 session 缓存（`flaggedImageCacheProvider`），只在 session 启动时加载一次，不对每张图片单独查询。

---

## 七、已知待修复

- **TODO-001**：`moderate-image-google` / `moderate-image-openai` Edge Function 尚不直接读取 `system_configs`；引擎选择逻辑在 Flutter 的 `ImageModerationService` 中实现（调用哪个函数由客户端决定）。理想状态是有一个统一入口函数由服务端决定引擎，彻底解耦客户端。优先级 Low。
