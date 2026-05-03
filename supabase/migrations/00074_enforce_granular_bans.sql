-- Migration 00074: Enforce granular bans and account freeze across app tables

-- 1. Enforce on `listings` (listing_ban, account_freeze)
DROP POLICY IF EXISTS "Authenticated users can create listings" ON public.listings;
CREATE POLICY "Authenticated users can create listings"
  ON public.listings FOR INSERT
  WITH CHECK (
    auth.uid() = seller_id
    AND NOT public.is_user_restricted(auth.uid(), 'listing_ban')
    AND NOT public.is_user_restricted(auth.uid(), 'account_freeze')
  );

DROP POLICY IF EXISTS "Sellers can update their own listings" ON public.listings;
CREATE POLICY "Sellers can update their own listings"
  ON public.listings FOR UPDATE
  USING (auth.uid() = seller_id)
  WITH CHECK (
    auth.uid() = seller_id
    AND NOT public.is_user_restricted(auth.uid(), 'listing_ban')
    AND NOT public.is_user_restricted(auth.uid(), 'account_freeze')
  );

-- 2. Enforce on `content_reports` (feedback_ban, account_freeze)
DROP POLICY IF EXISTS "Users can insert own reports" ON public.content_reports;
CREATE POLICY "Users can insert own reports"
  ON public.content_reports FOR INSERT
  TO authenticated
  WITH CHECK (
    reporter_id = auth.uid()
    AND NOT public.is_user_restricted(auth.uid(), 'feedback_ban')
    AND NOT public.is_user_restricted(auth.uid(), 'account_freeze')
  );

-- 3. Enforce on `user_feedbacks` (feedback_ban, account_freeze)
DROP POLICY IF EXISTS "Users can insert own feedbacks" ON public.user_feedbacks;
CREATE POLICY "Users can insert own feedbacks"
  ON public.user_feedbacks FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    AND NOT public.is_user_restricted(auth.uid(), 'feedback_ban')
    AND NOT public.is_user_restricted(auth.uid(), 'account_freeze')
  );

-- 4. Add account_freeze to `messages` policy (chat_mute was added in 00073)
DROP POLICY IF EXISTS "Chat participants can send messages" ON public.messages;
CREATE POLICY "Chat participants can send messages"
  ON public.messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND auth.uid() IN (
      SELECT buyer_id FROM public.chat_rooms WHERE id = chat_room_id
      UNION
      SELECT seller_id FROM public.chat_rooms WHERE id = chat_room_id
    )
    AND NOT public.is_user_restricted(auth.uid(), 'chat_mute')
    AND NOT public.is_user_restricted(auth.uid(), 'account_freeze')
  );
