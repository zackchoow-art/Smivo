-- 1. 更新 notifications.type 约束，新增 'new_message'
ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check CHECK (
    type = ANY (ARRAY[
      'order_placed', 'order_accepted', 'order_cancelled',
      'order_delivered', 'order_completed',
      'rental_reminder', 'rental_extension',
      'new_message', 'system'
    ])
  );

-- 2. 创建触发函数
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

  -- 创建通知
  INSERT INTO public.notifications
    (user_id, type, title, body, related_order_id, action_type, action_url, email_queued)
  VALUES (
    v_recipient_id,
    'new_message',
    'New message from ' || v_sender_name,
    CASE
      WHEN NEW.image_url IS NOT NULL THEN v_sender_name || ' sent a photo for "' || v_listing_title || '"'
      ELSE coalesce(left(NEW.content, 100), 'New message') || ' — "' || v_listing_title || '"'
    END,
    v_related_order_id,
    'route',                              -- 使用 route action_type
    '/chats/' || NEW.chat_room_id::text,       -- 跳转到聊天室
    coalesce(v_email_enabled, true)
  );

  RETURN NEW;
END;
$$;

-- 3. 绑定触发器
-- 确保在绑定前移除同名旧触发器，以防多次执行
DROP TRIGGER IF EXISTS on_new_message_notify ON public.messages;
CREATE TRIGGER on_new_message_notify
  AFTER INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.notify_new_message();
