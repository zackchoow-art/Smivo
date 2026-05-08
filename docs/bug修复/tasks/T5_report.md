# T5 执行报告：全局图片审核组件重构

**执行时间**: 2026-05-08  
**验证命令**: `cd /Users/george/smivo/app && flutter analyze`  
**分析结果**: ✅ 0 errors（39 info/warning 均为任务前预存，与本次改动无关）

---

## 子目标完成状态

| 编号 | 目标 | 状态 |
|------|------|------|
| 1 | 读取平台审核模式 provider | ✅ 完成 |
| 2 | 重构 ModerationAwareImage | ✅ 完成 |
| 3 | 修复 Chat 崩溃 | ✅ 完成 |
| 4 | 全局替换 Image.network | ✅ 完成 |
| 5 | Flagged 商品详情页模糊 | ✅ 完成（通过 carousel 接入） |

---

## 修改文件清单

### 新功能 / 重构

| 文件 | 变更摘要 |
|------|---------|
| `app/lib/core/providers/moderation_provider.dart` | 新增 ImageModerationMode provider，从 system_configs 表读取 image_moderation_mode 字段，默认 'blur' |
| `app/lib/shared/widgets/moderation_aware_image.dart` | 新增 onTap 参数；支持 auto_reject（不加载+显示移除文字）和 blur（模糊+图标）两种模式 |

### Chat 崩溃修复

| 文件 | 变更摘要 |
|------|---------|
| `app/lib/features/chat/screens/chat_room_screen.dart` | 移除包裹 ModerationAwareImage 的 GestureDetector，改为使用 onTap 参数；违规图片自动屏蔽点击 |

### 全局替换 Image.network（用户内容图片）

| 文件 | 替换数量 |
|------|---------|
| `features/home/widgets/flat_featured_listing_card.dart` | 1 处 |
| `features/home/widgets/ikea_featured_listing_card.dart` | 1 处 |
| `features/home/widgets/flat_grid_listing_card.dart` | 1 处 |
| `features/home/widgets/ikea_grid_listing_card.dart` | 1 处 |
| `features/seller/widgets/ikea_seller_order_card.dart` | 4 处 |
| `features/seller/widgets/flat_seller_order_card.dart` | 4 处 |
| `features/listing/widgets/listing_image_carousel.dart` | 1 处（移除 ImageFiltered 组合） |

---

## 关键设计决策

### 1. onTap 参数
违规图片内部拦截点击（不转发 onTap），消除了 Chat 中外层 GestureDetector 和内部违规判断不同步的崩溃根因。

### 2. 双层审核（carousel）
- DB 层：`ListingImage.moderationStatus == 'rejected'` → onTap null + 文字遮罩
- AI 日志层：`flaggedImageUrlsProvider` → ModerationAwareImage 内部 blur/reject

### 3. 代码生成
`dart run build_runner build` 成功生成新 ImageModerationMode provider 的 .g.dart 文件。

### 4. 未替换的 Image.network（有意保留）
- settings/ 下的反馈/举报截图预览（非平台审核对象）
- orders/ 下的交割证据照片（双方上传，不经 AI 审核）
- seller/screens/ 下的复杂屏幕（listing 图片已在 carousel 层审核）
- buyer/ 卡片（订单图片来自已审核的 listing）

---

## flutter analyze 结果

39 issues found (0 errors). 所有 issue 均为任务执行前预存问题，与 T5 改动无关。
