-- ============================================================
-- Smivo — System Notifications
-- ============================================================
-- User-facing notifications for order events, system messages, etc.
-- Separate from chat messages (which live in the messages table).
-- ============================================================

-- ─── Table ────────────────────────────────────────────────

create table public.notifications (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.user_profiles(id) on delete cascade,
  type        text not null
    check (type in (
      'order_placed',         -- seller: new order on your listing
      'order_accepted',       -- buyer: seller accepted
      'order_cancelled',      -- both: order was cancelled
      'order_delivered',      -- both: other party confirmed delivery
      'order_completed',      -- both: order finished (both confirmed)
      'system'                -- platform-wide announcements (future)
    )),
  title       text not null,
  body        text not null,
  is_read     boolean not null default false,
  related_order_id  uuid references public.orders(id) on delete cascade,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Indexes — common query: user's notifications ordered by recency
create index idx_notifications_user_created 
  on public.notifications(user_id, created_at desc);
create index idx_notifications_user_unread 
  on public.notifications(user_id, is_read) 
  where is_read = false;

-- ─── RLS ───────────────────────────────────────────────────

alter table public.notifications enable row level security;

-- Users can only read their own notifications
create policy "Users read their own notifications"
  on public.notifications for select
  using (auth.uid() = user_id);

-- Users can mark their own notifications as read (update is_read)
create policy "Users update their own notifications"
  on public.notifications for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Note: INSERT is done by database triggers (security definer),
-- so no INSERT policy is needed for authenticated users.

-- ─── Realtime ──────────────────────────────────────────────

alter publication supabase_realtime add table public.notifications;

-- ─── Order Event Triggers ──────────────────────────────────

-- When a new order is placed, notify the seller
create or replace function public.notify_order_placed()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_listing_title text;
begin
  select title into v_listing_title 
  from public.listings 
  where id = new.listing_id;

  insert into public.notifications (user_id, type, title, body, related_order_id)
  values (
    new.seller_id,
    'order_placed',
    'New order received',
    'Someone placed an order for "' || coalesce(v_listing_title, 'your listing') || '"',
    new.id
  );
  return new;
end;
$$;

create trigger on_order_placed
  after insert on public.orders
  for each row execute function public.notify_order_placed();

-- When order status changes, notify the appropriate party
create or replace function public.notify_order_status_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_listing_title text;
  v_title_snippet text;
begin
  -- Only act on status transitions
  if old.status is not distinct from new.status then
    return new;
  end if;

  select title into v_listing_title 
  from public.listings 
  where id = new.listing_id;
  v_title_snippet := coalesce(v_listing_title, 'your order');

  -- pending -> confirmed: notify buyer
  if old.status = 'pending' and new.status = 'confirmed' then
    insert into public.notifications (user_id, type, title, body, related_order_id)
    values (
      new.buyer_id,
      'order_accepted',
      'Order accepted',
      'The seller accepted your order for "' || v_title_snippet || '"',
      new.id
    );
  end if;

  -- any -> cancelled: notify both for transparency
  if new.status = 'cancelled' then
    insert into public.notifications (user_id, type, title, body, related_order_id)
    values 
      (new.buyer_id, 'order_cancelled', 'Order cancelled', 
       'Your order for "' || v_title_snippet || '" was cancelled', new.id),
      (new.seller_id, 'order_cancelled', 'Order cancelled', 
       'The order for "' || v_title_snippet || '" was cancelled', new.id);
  end if;

  -- any -> completed: notify both parties
  if new.status = 'completed' then
    insert into public.notifications (user_id, type, title, body, related_order_id)
    values 
      (new.buyer_id, 'order_completed', 'Order completed', 
       'Your order for "' || v_title_snippet || '" is complete', new.id),
      (new.seller_id, 'order_completed', 'Order completed', 
       'The order for "' || v_title_snippet || '" is complete', new.id);
  end if;

  return new;
end;
$$;

create trigger on_order_status_change
  after update of status on public.orders
  for each row execute function public.notify_order_status_change();

-- When one party confirms delivery, notify the other
create or replace function public.notify_delivery_confirmed()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_listing_title text;
  v_title_snippet text;
begin
  select title into v_listing_title 
  from public.listings 
  where id = new.listing_id;
  v_title_snippet := coalesce(v_listing_title, 'your order');

  -- buyer just confirmed
  if old.delivery_confirmed_by_buyer = false 
     and new.delivery_confirmed_by_buyer = true then
    insert into public.notifications (user_id, type, title, body, related_order_id)
    values (
      new.seller_id,
      'order_delivered',
      'Buyer confirmed delivery',
      'The buyer confirmed delivery for "' || v_title_snippet || '"',
      new.id
    );
  end if;

  -- seller just confirmed
  if old.delivery_confirmed_by_seller = false 
     and new.delivery_confirmed_by_seller = true then
    insert into public.notifications (user_id, type, title, body, related_order_id)
    values (
      new.buyer_id,
      'order_delivered',
      'Seller confirmed delivery',
      'The seller confirmed delivery for "' || v_title_snippet || '"',
      new.id
    );
  end if;

  return new;
end;
$$;

create trigger on_delivery_confirmation
  after update of delivery_confirmed_by_buyer, delivery_confirmed_by_seller 
  on public.orders
  for each row execute function public.notify_delivery_confirmed();
