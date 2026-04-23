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

-- 1. 订单证据（依赖 orders）
TRUNCATE public.order_evidence CASCADE;

-- 2. 通知（依赖 orders）
TRUNCATE public.notifications CASCADE;

-- 3. 订单
TRUNCATE public.orders CASCADE;

-- 4. 聊天消息（依赖 chat_rooms）
TRUNCATE public.messages CASCADE;

-- 5. 聊天室（依赖 listings + user_profiles）
TRUNCATE public.chat_rooms CASCADE;

-- 6. 收藏 & 浏览
TRUNCATE public.saved_listings CASCADE;
TRUNCATE public.listing_views CASCADE;

-- 7. 商品图片（依赖 listings）
TRUNCATE public.listing_images CASCADE;

-- 8. 商品
TRUNCATE public.listings CASCADE;

-- ─── 验证 ───────────────────────────────────────────────────

SELECT 'order_evidence' AS tbl, count(*) FROM public.order_evidence
UNION ALL SELECT 'notifications', count(*) FROM public.notifications
UNION ALL SELECT 'orders', count(*) FROM public.orders
UNION ALL SELECT 'messages', count(*) FROM public.messages
UNION ALL SELECT 'chat_rooms', count(*) FROM public.chat_rooms
UNION ALL SELECT 'saved_listings', count(*) FROM public.saved_listings
UNION ALL SELECT 'listing_views', count(*) FROM public.listing_views
UNION ALL SELECT 'listing_images', count(*) FROM public.listing_images
UNION ALL SELECT 'listings', count(*) FROM public.listings
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
