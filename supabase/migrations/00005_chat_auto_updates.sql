-- ============================================================
-- Smivo — Chat Auto-Updates
-- ============================================================
-- When a message is inserted:
-- 1. Update chat_rooms.last_message_at to the new message's created_at
-- 2. Increment unread_count for the RECEIVING party
--    (buyer received if seller sent, and vice versa)
-- ============================================================

create or replace function public.handle_new_message()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_buyer_id uuid;
  v_seller_id uuid;
begin
  -- Fetch the chat room's buyer and seller
  select buyer_id, seller_id 
    into v_buyer_id, v_seller_id 
    from public.chat_rooms 
    where id = new.chat_room_id;

  if new.sender_id = v_buyer_id then
    -- Buyer sent → increment seller's unread count
    update public.chat_rooms
      set last_message_at = new.created_at,
          unread_count_seller = unread_count_seller + 1,
          updated_at = now()
      where id = new.chat_room_id;
  elsif new.sender_id = v_seller_id then
    -- Seller sent → increment buyer's unread count
    update public.chat_rooms
      set last_message_at = new.created_at,
          unread_count_buyer = unread_count_buyer + 1,
          updated_at = now()
      where id = new.chat_room_id;
  end if;
  
  return new;
end;
$$;

drop trigger if exists on_message_inserted on public.messages;

create trigger on_message_inserted
  after insert on public.messages
  for each row execute function public.handle_new_message();
