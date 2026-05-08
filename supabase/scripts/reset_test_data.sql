-- ════════════════════════════════════════════════════════════
-- Smivo — Reset Test Data (Reusable)
-- ════════════════════════════════════════════════════════════
-- 清空所有业务数据，保留用户账号和架构。
-- 使用场景：测试前重置环境、demo 前清空数据。
--
-- ⚠️ 此脚本会删除所有商品、订单、聊天、通知等数据！
-- ⚠️ Storage bucket 中的文件需要在 Supabase Dashboard 手动清除。
-- ⚠️ 执行后必须重启 app（Stop + Run），否则 app 会显示缓存数据。
-- ════════════════════════════════════════════════════════════

-- 按外键依赖顺序删除（子表先删）

-- 1. 评价系统（依赖 orders, user_profiles）
TRUNCATE public.user_review_tag_links CASCADE;
TRUNCATE public.user_reviews CASCADE;

-- 2. 订单证据 & 租赁扩展（依赖 orders）
TRUNCATE public.rental_extensions CASCADE;
TRUNCATE public.order_evidence CASCADE;

-- 3. 通知（依赖 orders, chat_rooms, user_profiles）
TRUNCATE public.notifications CASCADE;

-- 4. 内容审核 & 举报
TRUNCATE public.backend_moderation_logs CASCADE;
TRUNCATE public.moderation_tasks CASCADE;
TRUNCATE public.moderation_queue CASCADE;
TRUNCATE public.moderation_drafts CASCADE;
TRUNCATE public.listing_moderation_notices CASCADE;
TRUNCATE public.content_reports CASCADE;

-- 5. 订单
TRUNCATE public.orders CASCADE;

-- 6. 聊天消息（依赖 chat_rooms）
TRUNCATE public.messages CASCADE;

-- 7. 聊天室（依赖 listings + user_profiles）
TRUNCATE public.chat_rooms CASCADE;

-- 8. 收藏 & 浏览
TRUNCATE public.saved_listings CASCADE;
TRUNCATE public.listing_views CASCADE;

-- 9. 商品图片（依赖 listings）
TRUNCATE public.listing_images CASCADE;

-- 10. 商品
TRUNCATE public.listings CASCADE;

-- 11. 用户相关数据
TRUNCATE public.user_blocks CASCADE;
TRUNCATE public.user_feedbacks CASCADE;
TRUNCATE public.contribution_ledger CASCADE;
TRUNCATE public.user_bans CASCADE;
TRUNCATE public.user_active_sessions CASCADE;
TRUNCATE public.user_heartbeats CASCADE;
TRUNCATE public.hourly_active_users CASCADE;
TRUNCATE public.user_saved_locations CASCADE;

-- 12. 推送任务
TRUNCATE public.push_jobs CASCADE;

-- 13. API 用量计数器（可选，重置为 0）
TRUNCATE public.image_moderation_usage CASCADE;

-- ─── 验证 ───────────────────────────────────────────────────

SELECT 'user_review_tag_links' AS tbl, count(*) FROM public.user_review_tag_links
UNION ALL SELECT 'user_reviews', count(*) FROM public.user_reviews
UNION ALL SELECT 'rental_extensions', count(*) FROM public.rental_extensions
UNION ALL SELECT 'order_evidence', count(*) FROM public.order_evidence
UNION ALL SELECT 'notifications', count(*) FROM public.notifications
UNION ALL SELECT 'backend_moderation_logs', count(*) FROM public.backend_moderation_logs
UNION ALL SELECT 'moderation_tasks', count(*) FROM public.moderation_tasks
UNION ALL SELECT 'content_reports', count(*) FROM public.content_reports
UNION ALL SELECT 'orders', count(*) FROM public.orders
UNION ALL SELECT 'messages', count(*) FROM public.messages
UNION ALL SELECT 'chat_rooms', count(*) FROM public.chat_rooms
UNION ALL SELECT 'saved_listings', count(*) FROM public.saved_listings
UNION ALL SELECT 'listing_views', count(*) FROM public.listing_views
UNION ALL SELECT 'listing_images', count(*) FROM public.listing_images
UNION ALL SELECT 'listings', count(*) FROM public.listings
UNION ALL SELECT 'user_blocks', count(*) FROM public.user_blocks
UNION ALL SELECT 'user_feedbacks', count(*) FROM public.user_feedbacks
UNION ALL SELECT 'user_bans', count(*) FROM public.user_bans
UNION ALL SELECT 'user_saved_locations', count(*) FROM public.user_saved_locations
UNION ALL SELECT 'push_jobs', count(*) FROM public.push_jobs
UNION ALL SELECT 'image_moderation_usage', count(*) FROM public.image_moderation_usage
UNION ALL SELECT 'user_profiles', count(*) FROM public.user_profiles;

-- ─── 执行后必做 ──────────────────────────────────────────────
-- 1. 在 Supabase Dashboard > Storage 中清空以下 bucket 的文件：
--    • listing-images
--    • order-files
--    • avatars (如需重置头像)
--
-- 2. 重启所有 app 实例（Xcode: Stop → Run）
--    Riverpod provider 会在重启后重新从 DB 拉取数据。
--    不重启的话 app 会继续显示内存中的旧缓存数据。
