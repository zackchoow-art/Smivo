-- ============================================================
-- RPC: Efficient group chat unread counts (replaces N+1 queries)
-- ============================================================

CREATE OR REPLACE FUNCTION public.get_group_unread_counts(p_user_id uuid)
RETURNS TABLE(room_id uuid, unread_count bigint)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    m.room_id,
    count(gm.id) AS unread_count
  FROM public.group_chat_members m
  LEFT JOIN public.group_messages gm
    ON gm.room_id = m.room_id
    AND gm.sender_id != p_user_id
    AND gm.created_at > coalesce(m.last_read_at, m.joined_at)
  WHERE m.user_id = p_user_id
  GROUP BY m.room_id;
$$;
