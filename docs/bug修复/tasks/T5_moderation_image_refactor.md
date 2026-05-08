# T5: 全局图片审核组件重构

## 任务目标
1. 修复 Chat 崩溃：AI 标记违规图片导致聊天界面崩溃
2. 重构 ModerationAwareImage：支持 Blur 和 Auto Reject 两种平台模式
3. 全局统一接入：所有用户图片使用 ModerationAwareImage
4. Flagged Items 商品详情页也要有模糊处理

## 执行边界
### 允许修改：
- `app/lib/shared/widgets/moderation_aware_image.dart`
- `app/lib/core/providers/moderation_provider.dart`
- `app/lib/core/utils/image_moderation_service.dart`
- `app/lib/features/chat/screens/chat_room_screen.dart`
- `app/lib/features/chat/widgets/chat_popup.dart`
- `app/lib/features/listing/widgets/listing_image_carousel.dart`
- `app/lib/features/listing/screens/listing_detail_screen.dart`
- `app/lib/features/seller/widgets/` 下的卡片组件
- `app/lib/features/listing/widgets/` 下的卡片组件
- `app/lib/features/home/` 下的商品卡片组件

### 严禁修改：model 文件、admin/ 目录、supabase/ 目录、router 文件

## 实现要点

### 1. 读取平台审核模式
在 moderation_provider.dart 新增 provider 读取 system_configs 中的 image moderation mode 配置（blur / auto_reject）。

### 2. 重构 ModerationAwareImage
- **Blur 模式**：模糊图片 + 显示违规概述 + 禁止点击
- **Auto Reject 模式**：不加载图片，显示 "This image has been removed for policy violation"
- 新增 `onTap` 参数（非违规图片的点击回调）

### 3. 修复 Chat 崩溃
将 chat_room_screen.dart 中的 Image.network 替换为 ModerationAwareImage，添加异常保护。

### 4. 全局替换
用 `grep -rn "Image.network" app/lib/` 搜索所有用户内容图片，替换为 ModerationAwareImage。

## 验证
```bash
cd /Users/george/smivo/app && flutter analyze
```

## 报告文件：`docs/bug修复/tasks/T5_report.md`
