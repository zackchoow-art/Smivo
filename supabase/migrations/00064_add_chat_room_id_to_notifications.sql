-- ============================================================
-- Add chat_room_id to notifications for context-aware suppression
-- ============================================================

ALTER TABLE public.notifications 
  ADD COLUMN IF NOT EXISTS chat_room_id uuid REFERENCES public.chat_rooms(id) ON DELETE CASCADE;

-- Update the new message notification trigger to populate this field
CREATE OR REPLACE FUNCTION public.notify_new_message()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_room RECORD;
  v_recipient_id uuid;
  v_sender_name text;
  v_listing_title text;
  v_related_order_id uuid;
  v_email_enabled boolean;
BEGIN
  -- 获取聊天室信息
  SELECT cr.buyer_id, cr.seller_id, cr.listing_id
  INTO v_room
  FROM public.chat_rooms cr
  WHERE cr.id = NEW.chat_room_id;

  -- 确定接收方 (对方)
  IF NEW.sender_id = v_room.buyer_id THEN
    v_recipient_id := v_room.seller_id;
  ELSE
    v_recipient_id := v_room.buyer_id;
  END IF;

  -- 获取发送者名称
  SELECT coalesce(display_name, 'Someone') INTO v_sender_name
  FROM public.user_profiles WHERE id = NEW.sender_id;

  -- 获取商品标题
  SELECT coalesce(title, 'an item') INTO v_listing_title
  FROM public.listings WHERE id = v_room.listing_id;

  -- 查找关联订单 (可选，用于点击跳转)
  SELECT id INTO v_related_order_id
  FROM public.orders
  WHERE listing_id = v_room.listing_id
    AND ((buyer_id = v_room.buyer_id AND seller_id = v_room.seller_id)
      OR (buyer_id = v_room.seller_id AND seller_id = v_room.buyer_id))
  ORDER BY created_at DESC
  LIMIT 1;

  -- 检查 email 偏好
  SELECT coalesce(email_notifications_enabled, true)
  INTO v_email_enabled
  FROM public.user_profiles WHERE id = v_recipient_id;

  -- 创建通知 (包含 chat_room_id)
  INSERT INTO public.notifications
    (user_id, type, title, body, related_order_id, chat_room_id, action_type, action_url, email_queued)
  VALUES (
    v_recipient_id,
    'new_message',
    'New message from ' || v_sender_name,
    CASE
      WHEN NEW.image_url IS NOT NULL THEN v_sender_name || ' sent a photo for "' || v_listing_title || '"'
      ELSE coalesce(left(NEW.content, 100), 'New message') || ' — "' || v_listing_title || '"'
    END,
    v_related_order_id,
    NEW.chat_room_id,                  -- 存入聊天室 ID
    'route',
    '/chats/' || NEW.chat_room_id::text,
    coalesce(v_email_enabled, true)
  );

  RETURN NEW;
END;
$$;
