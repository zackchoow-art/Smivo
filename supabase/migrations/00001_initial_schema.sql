-- ============================================================
-- Smivo Marketplace — Initial Database Schema
-- ============================================================
-- Generated from: lib/data/models/*.dart + lib/data/repositories/*.dart
-- Follows: .agent/rules/project-brief.md database design principles
--
-- Every table has: id (uuid), created_at, updated_at
-- All tables have RLS enabled with granular policies
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 0. Helper: auto-update updated_at on every row change
-- ────────────────────────────────────────────────────────────

create or replace function public.handle_updated_at()
returns trigger
language plpgsql
security definer
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;


-- ════════════════════════════════════════════════════════════
-- 1. user_profiles
-- ════════════════════════════════════════════════════════════
-- 1:1 with auth.users. Created on first login / signup.
-- The id column references the Supabase Auth user id.

create table public.user_profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text        not null,
  display_name text,
  avatar_url  text,
  school      text        not null default 'Smith College',
  is_verified boolean     not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger user_profiles_updated_at
  before update on public.user_profiles
  for each row execute function public.handle_updated_at();

-- Indexes
create index idx_user_profiles_email on public.user_profiles(email);

-- RLS
alter table public.user_profiles enable row level security;

-- Anyone can read profiles (needed for seller info on listings)
create policy "Profiles are publicly readable"
  on public.user_profiles for select
  using (true);

-- Users can insert their own profile
create policy "Users can create their own profile"
  on public.user_profiles for insert
  with check (auth.uid() = id);

-- Users can update only their own profile
create policy "Users can update their own profile"
  on public.user_profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);


-- ════════════════════════════════════════════════════════════
-- 2. listings
-- ════════════════════════════════════════════════════════════

create table public.listings (
  id                  uuid primary key default gen_random_uuid(),
  seller_id           uuid        not null references public.user_profiles(id) on delete cascade,
  title               text        not null,
  description         text,
  category            text        not null
    check (category in ('furniture','electronics','instruments','books','clothing','sports','other')),
  price               numeric(10,2) not null check (price >= 0),
  transaction_type    text        not null
    check (transaction_type in ('sale','rental')),
  status              text        not null default 'active'
    check (status in ('active','inactive','sold','rented')),
  view_count          integer     not null default 0,
  save_count          integer     not null default 0,
  inquiry_count       integer     not null default 0,
  allow_pickup_change boolean     not null default false,
  rental_daily_price  numeric(10,2),
  rental_weekly_price numeric(10,2),
  rental_monthly_price numeric(10,2),
  is_pinned           boolean     not null default false,
  pinned_days         integer,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create trigger listings_updated_at
  before update on public.listings
  for each row execute function public.handle_updated_at();

-- Indexes (match repository query patterns)
create index idx_listings_seller    on public.listings(seller_id);
create index idx_listings_status    on public.listings(status);
create index idx_listings_category  on public.listings(category);
create index idx_listings_created   on public.listings(created_at desc);

-- RLS
alter table public.listings enable row level security;

-- Anyone (including anonymous) can read active listings
-- Sellers can also see their own non-active listings
create policy "Active listings are publicly readable"
  on public.listings for select
  using (status = 'active' or auth.uid() = seller_id);

-- Authenticated users can create listings
create policy "Authenticated users can create listings"
  on public.listings for insert
  with check (auth.uid() = seller_id);

-- Sellers can update their own listings
create policy "Sellers can update their own listings"
  on public.listings for update
  using (auth.uid() = seller_id)
  with check (auth.uid() = seller_id);

-- Sellers can delete their own listings
create policy "Sellers can delete their own listings"
  on public.listings for delete
  using (auth.uid() = seller_id);


-- ════════════════════════════════════════════════════════════
-- 3. listing_images
-- ════════════════════════════════════════════════════════════

create table public.listing_images (
  id          uuid primary key default gen_random_uuid(),
  listing_id  uuid        not null references public.listings(id) on delete cascade,
  image_url   text        not null,
  sort_order  integer     not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger listing_images_updated_at
  before update on public.listing_images
  for each row execute function public.handle_updated_at();

-- Indexes
create index idx_listing_images_listing on public.listing_images(listing_id);

-- RLS
alter table public.listing_images enable row level security;

-- Anyone can read images (they accompany public listings)
create policy "Listing images are publicly readable"
  on public.listing_images for select
  using (true);

-- Only the listing owner can insert images
create policy "Listing owner can insert images"
  on public.listing_images for insert
  with check (
    auth.uid() = (
      select seller_id from public.listings where id = listing_id
    )
  );

-- Only the listing owner can update images
create policy "Listing owner can update images"
  on public.listing_images for update
  using (
    auth.uid() = (
      select seller_id from public.listings where id = listing_id
    )
  );

-- Only the listing owner can delete images
create policy "Listing owner can delete images"
  on public.listing_images for delete
  using (
    auth.uid() = (
      select seller_id from public.listings where id = listing_id
    )
  );


-- ════════════════════════════════════════════════════════════
-- 4. saved_listings
-- ════════════════════════════════════════════════════════════

create table public.saved_listings (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid        not null references public.user_profiles(id) on delete cascade,
  listing_id  uuid        not null references public.listings(id) on delete cascade,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),

  -- Each user can save a listing only once
  unique (user_id, listing_id)
);

create trigger saved_listings_updated_at
  before update on public.saved_listings
  for each row execute function public.handle_updated_at();

-- Indexes
create index idx_saved_listings_user on public.saved_listings(user_id);

-- RLS
alter table public.saved_listings enable row level security;

-- Users can only see their own saved listings
create policy "Users can read their own saves"
  on public.saved_listings for select
  using (auth.uid() = user_id);

-- Users can save listings
create policy "Users can save listings"
  on public.saved_listings for insert
  with check (auth.uid() = user_id);

-- Users can unsave listings
create policy "Users can unsave listings"
  on public.saved_listings for delete
  using (auth.uid() = user_id);


-- ════════════════════════════════════════════════════════════
-- 5. orders
-- ════════════════════════════════════════════════════════════

create table public.orders (
  id                          uuid primary key default gen_random_uuid(),
  listing_id                  uuid        not null references public.listings(id) on delete restrict,
  buyer_id                    uuid        not null references public.user_profiles(id) on delete cascade,
  seller_id                   uuid        not null references public.user_profiles(id) on delete cascade,
  order_type                  text        not null
    check (order_type in ('sale','rental')),
  status                      text        not null default 'pending'
    check (status in ('pending','confirmed','completed','cancelled')),
  rental_start_date           timestamptz,
  rental_end_date             timestamptz,
  return_confirmed_at         timestamptz,
  transaction_snapshot_url    text,
  delivery_confirmed_by_buyer  boolean    not null default false,
  delivery_confirmed_by_seller boolean    not null default false,
  delivery_photo_url          text,
  delivery_note               text,
  total_price                 numeric(10,2) not null check (total_price >= 0),
  school                      text        not null default 'Smith College',
  created_at                  timestamptz not null default now(),
  updated_at                  timestamptz not null default now()
);

create trigger orders_updated_at
  before update on public.orders
  for each row execute function public.handle_updated_at();

-- Indexes (match repository query: or('buyer_id.eq.$userId,seller_id.eq.$userId'))
create index idx_orders_buyer   on public.orders(buyer_id);
create index idx_orders_seller  on public.orders(seller_id);
create index idx_orders_listing on public.orders(listing_id);
create index idx_orders_created on public.orders(created_at desc);

-- RLS
alter table public.orders enable row level security;

-- Buyer or seller can read their own orders
create policy "Participants can read their orders"
  on public.orders for select
  using (auth.uid() = buyer_id or auth.uid() = seller_id);

-- Authenticated buyers can create orders
create policy "Buyers can create orders"
  on public.orders for insert
  with check (auth.uid() = buyer_id);

-- Buyer or seller can update order (e.g. confirm, cancel)
create policy "Participants can update orders"
  on public.orders for update
  using (auth.uid() = buyer_id or auth.uid() = seller_id)
  with check (auth.uid() = buyer_id or auth.uid() = seller_id);


-- ════════════════════════════════════════════════════════════
-- 6. chat_rooms
-- ════════════════════════════════════════════════════════════

create table public.chat_rooms (
  id              uuid primary key default gen_random_uuid(),
  listing_id      uuid        not null references public.listings(id) on delete cascade,
  buyer_id        uuid        not null references public.user_profiles(id) on delete cascade,
  seller_id       uuid        not null references public.user_profiles(id) on delete cascade,
  last_message_at     timestamptz,
  unread_count_buyer  integer     not null default 0,
  unread_count_seller integer     not null default 0,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),

  -- One chat room per listing+buyer+seller combination
  unique (listing_id, buyer_id, seller_id)
);

create trigger chat_rooms_updated_at
  before update on public.chat_rooms
  for each row execute function public.handle_updated_at();

-- Indexes (match repository query: or('buyer_id.eq.$userId,seller_id.eq.$userId'))
create index idx_chat_rooms_buyer  on public.chat_rooms(buyer_id);
create index idx_chat_rooms_seller on public.chat_rooms(seller_id);

-- RLS
alter table public.chat_rooms enable row level security;

-- Only participants can see their chat rooms
create policy "Participants can read their chat rooms"
  on public.chat_rooms for select
  using (auth.uid() = buyer_id or auth.uid() = seller_id);

-- Authenticated users can create chat rooms (buyer initiates)
create policy "Authenticated users can create chat rooms"
  on public.chat_rooms for insert
  with check (auth.uid() = buyer_id or auth.uid() = seller_id);

-- Participants can update (e.g. last_message_at)
create policy "Participants can update chat rooms"
  on public.chat_rooms for update
  using (auth.uid() = buyer_id or auth.uid() = seller_id);


-- ════════════════════════════════════════════════════════════
-- 7. messages
-- ════════════════════════════════════════════════════════════

create table public.messages (
  id           uuid primary key default gen_random_uuid(),
  chat_room_id uuid        not null references public.chat_rooms(id) on delete cascade,
  sender_id    uuid        not null references public.user_profiles(id) on delete cascade,
  content      text        not null,
  message_type text        not null default 'text'
    check (message_type in ('text','image','system')),
  image_url    text,
  is_read      boolean     not null default false,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create trigger messages_updated_at
  before update on public.messages
  for each row execute function public.handle_updated_at();

-- Indexes (match repository query: eq('chat_room_id', chatRoomId).order('created_at'))
create index idx_messages_room    on public.messages(chat_room_id, created_at);
create index idx_messages_sender  on public.messages(sender_id);

-- RLS
alter table public.messages enable row level security;

-- Only participants of the chat room can read messages
create policy "Chat participants can read messages"
  on public.messages for select
  using (
    auth.uid() in (
      select buyer_id from public.chat_rooms where id = chat_room_id
      union
      select seller_id from public.chat_rooms where id = chat_room_id
    )
  );

-- Only participants can send messages
create policy "Chat participants can send messages"
  on public.messages for insert
  with check (
    auth.uid() = sender_id
    and auth.uid() in (
      select buyer_id from public.chat_rooms where id = chat_room_id
      union
      select seller_id from public.chat_rooms where id = chat_room_id
    )
  );

-- Recipient can mark messages as read
create policy "Recipients can update messages"
  on public.messages for update
  using (
    auth.uid() in (
      select buyer_id from public.chat_rooms where id = chat_room_id
      union
      select seller_id from public.chat_rooms where id = chat_room_id
    )
  );


-- ════════════════════════════════════════════════════════════
-- 8. Realtime — enable for messages table (chat)
-- ════════════════════════════════════════════════════════════

alter publication supabase_realtime add table public.messages;


-- ════════════════════════════════════════════════════════════
-- 9. Storage Buckets
-- ════════════════════════════════════════════════════════════

-- Create storage buckets for images
insert into storage.buckets (id, name, public)
values
  ('listing-images', 'listing-images', true),
  ('avatars', 'avatars', true);

-- Storage RLS: anyone can read public buckets
create policy "Public read for listing images"
  on storage.objects for select
  using (bucket_id = 'listing-images');

create policy "Public read for avatars"
  on storage.objects for select
  using (bucket_id = 'avatars');

-- Authenticated users can upload to listing-images (path must start with their uid)
create policy "Authenticated upload to listing-images"
  on storage.objects for insert
  with check (
    bucket_id = 'listing-images'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Users can upload their own avatars
create policy "Users can upload their own avatar"
  on storage.objects for insert
  with check (
    bucket_id = 'avatars'
    and auth.role() = 'authenticated'
  );

-- Users can update their own files
create policy "Users can update their own files"
  on storage.objects for update
  using (auth.uid() = owner)
  with check (auth.uid() = owner);

-- Users can delete their own files
create policy "Users can delete their own files"
  on storage.objects for delete
  using (auth.uid() = owner);


-- ════════════════════════════════════════════════════════════
-- 10. Auto-create user_profile on signup (trigger)
-- ════════════════════════════════════════════════════════════
-- When a new user signs up via Supabase Auth, automatically
-- insert a row in user_profiles so the app always has a profile.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.user_profiles (id, email, school)
  values (
    new.id,
    new.email,
    'Smith College'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
