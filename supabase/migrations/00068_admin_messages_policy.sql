-- Migration 00064: Add admin RLS policies for chat and messages
-- Description: Allows platform sysadmins to read chat_rooms and messages for moderation context.

DROP POLICY IF EXISTS "Admins can view all chat rooms" ON public.chat_rooms;
CREATE POLICY "Admins can view all chat rooms"
  ON public.chat_rooms FOR SELECT
  USING (public.is_platform_sysadmin());

DROP POLICY IF EXISTS "Admins can view all messages" ON public.messages;
CREATE POLICY "Admins can view all messages"
  ON public.messages FOR SELECT
  USING (public.is_platform_sysadmin());
