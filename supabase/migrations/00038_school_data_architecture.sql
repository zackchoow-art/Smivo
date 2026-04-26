-- ============================================================
-- Smivo — Multi-School Data Architecture Restructuring
-- ============================================================
-- Phase 1: Non-destructive additions only.
-- Extends schools, creates school_admins, school_categories,
-- school_conditions, system_dictionaries, adds school_id to faqs,
-- and seeds default data for Smith College.
-- ============================================================

-- ─── 1. Extend schools table ──────────────────────────────────

ALTER TABLE public.schools
  ADD COLUMN IF NOT EXISTS address         text,
  ADD COLUMN IF NOT EXISTS city            text,
  ADD COLUMN IF NOT EXISTS state           text,
  ADD COLUMN IF NOT EXISTS zip_code        text,
  ADD COLUMN IF NOT EXISTS country         text DEFAULT 'US',
  ADD COLUMN IF NOT EXISTS latitude        double precision,
  ADD COLUMN IF NOT EXISTS longitude       double precision,
  ADD COLUMN IF NOT EXISTS timezone        text DEFAULT 'America/New_York',
  ADD COLUMN IF NOT EXISTS website_url     text,
  ADD COLUMN IF NOT EXISTS description     text,
  ADD COLUMN IF NOT EXISTS student_count   integer,
  ADD COLUMN IF NOT EXISTS cover_image_url text;

-- Seed Smith College geo data
UPDATE public.schools SET
  address       = '10 Elm Street',
  city          = 'Northampton',
  state         = 'MA',
  zip_code      = '01063',
  country       = 'US',
  latitude      = 42.3181,
  longitude     = -72.6389,
  timezone      = 'America/New_York',
  website_url   = 'https://www.smith.edu',
  description   = 'A private liberal arts college for women in Northampton, Massachusetts.',
  student_count = 2500
WHERE slug = 'smith';


-- ─── 2. school_admins (many-to-many) ──────────────────────────

CREATE TABLE IF NOT EXISTS public.school_admins (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id  uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  user_id    uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  role       text NOT NULL DEFAULT 'admin'
    CHECK (role IN ('super_admin', 'admin', 'moderator')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, user_id)
);

CREATE TRIGGER school_admins_updated_at
  BEFORE UPDATE ON public.school_admins
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.school_admins ENABLE ROW LEVEL SECURITY;

-- Admins can read admin list for their school
CREATE POLICY "School admins readable by platform admins"
  ON public.school_admins FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

CREATE POLICY "Platform admins can manage school_admins"
  ON public.school_admins FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );


-- ─── 3. school_categories ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.school_categories (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id     uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  slug          text NOT NULL,
  name          text NOT NULL,
  icon          text,
  display_order integer NOT NULL DEFAULT 0,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, slug)
);

CREATE TRIGGER school_categories_updated_at
  BEFORE UPDATE ON public.school_categories
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_school_categories_school
  ON public.school_categories(school_id, display_order)
  WHERE is_active = true;

ALTER TABLE public.school_categories ENABLE ROW LEVEL SECURITY;

-- Everyone can read active categories
CREATE POLICY "Active categories are publicly readable"
  ON public.school_categories FOR SELECT
  USING (is_active = true);

-- Admins can manage categories
CREATE POLICY "Admins can manage school_categories"
  ON public.school_categories FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );


-- ─── 4. school_conditions ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.school_conditions (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id     uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  slug          text NOT NULL,
  name          text NOT NULL,
  description   text,
  display_order integer NOT NULL DEFAULT 0,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, slug)
);

CREATE TRIGGER school_conditions_updated_at
  BEFORE UPDATE ON public.school_conditions
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_school_conditions_school
  ON public.school_conditions(school_id, display_order)
  WHERE is_active = true;

ALTER TABLE public.school_conditions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Active conditions are publicly readable"
  ON public.school_conditions FOR SELECT
  USING (is_active = true);

CREATE POLICY "Admins can manage school_conditions"
  ON public.school_conditions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );


-- ─── 5. system_dictionaries ───────────────────────────────────

CREATE TABLE IF NOT EXISTS public.system_dictionaries (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  dict_type     text NOT NULL,
  dict_key      text NOT NULL,
  dict_value    text NOT NULL,
  description   text,
  extra         jsonb,
  display_order integer NOT NULL DEFAULT 0,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (dict_type, dict_key)
);

CREATE TRIGGER system_dictionaries_updated_at
  BEFORE UPDATE ON public.system_dictionaries
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.system_dictionaries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Dictionaries are publicly readable"
  ON public.system_dictionaries FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage system_dictionaries"
  ON public.system_dictionaries FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );


-- ─── 6. Add school_id to faqs ─────────────────────────────────

ALTER TABLE public.faqs
  ADD COLUMN IF NOT EXISTS school_id uuid REFERENCES public.schools(id) ON DELETE CASCADE;

-- Existing FAQs remain global (school_id = NULL)


-- ─── 7. Seed default data for Smith College ───────────────────

-- Categories
INSERT INTO public.school_categories (school_id, slug, name, icon, display_order)
SELECT s.id, v.slug, v.name, v.icon, v.display_order
FROM (VALUES
  ('furniture',    'Furniture',    'chair',         1),
  ('electronics',  'Electronics',  'devices',       2),
  ('instruments',  'Instruments',  'music_note',    3),
  ('books',        'Books',        'menu_book',     4),
  ('clothing',     'Clothing',     'checkroom',     5),
  ('sports',       'Sports',       'sports_soccer', 6),
  ('other',        'Other',        'more_horiz',   99)
) AS v(slug, name, icon, display_order)
CROSS JOIN public.schools s
WHERE s.slug = 'smith'
ON CONFLICT (school_id, slug) DO NOTHING;

-- Conditions
INSERT INTO public.school_conditions (school_id, slug, name, description, display_order)
SELECT s.id, v.slug, v.name, v.description, v.display_order
FROM (VALUES
  ('new',      'New',       'Brand new, never used',                    1),
  ('like_new', 'Like New',  'Used once or twice, no visible wear',      2),
  ('good',     'Good',      'Some signs of use, fully functional',      3),
  ('fair',     'Fair',      'Noticeable wear, still works',             4),
  ('poor',     'Poor',      'Heavy wear, may need repair',              5)
) AS v(slug, name, description, display_order)
CROSS JOIN public.schools s
WHERE s.slug = 'smith'
ON CONFLICT (school_id, slug) DO NOTHING;


-- ─── 8. Seed system dictionaries ──────────────────────────────

INSERT INTO public.system_dictionaries (dict_type, dict_key, dict_value, description, extra, display_order)
VALUES
  -- Order statuses
  ('order_status', 'pending',   'Pending',   'Waiting for seller to respond',              '{"icon": "schedule",          "color": "#D97706"}', 1),
  ('order_status', 'confirmed', 'Confirmed', 'Seller accepted, awaiting delivery',         '{"icon": "check_circle",      "color": "#059669"}', 2),
  ('order_status', 'completed', 'Completed', 'Transaction finished successfully',          '{"icon": "task_alt",          "color": "#7C3AED"}', 3),
  ('order_status', 'cancelled', 'Cancelled', 'Order was cancelled by buyer or seller',     '{"icon": "cancel",            "color": "#DC2626"}', 4),
  ('order_status', 'missed',    'Missed',    'Another buyer''s offer was accepted',        '{"icon": "event_busy",        "color": "#6B7280"}', 5),

  -- Rental statuses
  ('rental_status', 'active',           'Active',           'Rental period is in progress',          '{"icon": "play_circle",       "color": "#059669"}', 1),
  ('rental_status', 'return_requested', 'Return Requested', 'Buyer has requested to return',         '{"icon": "assignment_return", "color": "#D97706"}', 2),
  ('rental_status', 'returned',         'Returned',         'Item has been returned to seller',       '{"icon": "inventory",         "color": "#0891B2"}', 3),
  ('rental_status', 'deposit_refunded', 'Deposit Refunded', 'Seller has refunded the deposit',       '{"icon": "payments",          "color": "#7C3AED"}', 4),

  -- Listing statuses
  ('listing_status', 'active',   'Active',   'Listed and visible to buyers',    '{"icon": "visibility",  "color": "#059669"}', 1),
  ('listing_status', 'reserved', 'Reserved', 'Has an active order in progress', '{"icon": "lock",        "color": "#D97706"}', 2),
  ('listing_status', 'sold',     'Sold',     'Item has been sold',              '{"icon": "sell",        "color": "#6B7280"}', 3),
  ('listing_status', 'rented',   'Rented',   'Item is currently rented out',    '{"icon": "event_note",  "color": "#0891B2"}', 4),
  ('listing_status', 'delisted', 'Delisted', 'Removed from marketplace',        '{"icon": "block",       "color": "#DC2626"}', 5),

  -- Transaction types
  ('transaction_type', 'sale',   'Sale',   'One-time purchase',              '{"icon": "shopping_cart"}', 1),
  ('transaction_type', 'rental', 'Rental', 'Time-limited rental agreement',  '{"icon": "date_range"}',   2),

  -- Notification types
  ('notification_type', 'order_placed',      'Order Placed',      'A new order was submitted',          NULL, 1),
  ('notification_type', 'order_accepted',    'Order Accepted',    'Your offer was accepted',            NULL, 2),
  ('notification_type', 'order_cancelled',   'Order Cancelled',   'An order was cancelled',             NULL, 3),
  ('notification_type', 'order_completed',   'Order Completed',   'Transaction completed successfully', NULL, 4),
  ('notification_type', 'order_missed',      'Order Missed',      'Another offer was accepted',         NULL, 5),
  ('notification_type', 'rental_extension',  'Rental Extension',  'Rental extension request',           NULL, 6),
  ('notification_type', 'rental_reminder',   'Rental Reminder',   'Rental period ending soon',          NULL, 7)
ON CONFLICT (dict_type, dict_key) DO NOTHING;


-- ─── 9. seed_school_defaults RPC ──────────────────────────────

CREATE OR REPLACE FUNCTION public.seed_school_defaults(p_school_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- Default categories
  INSERT INTO public.school_categories (school_id, slug, name, icon, display_order)
  VALUES
    (p_school_id, 'furniture',    'Furniture',    'chair',         1),
    (p_school_id, 'electronics',  'Electronics',  'devices',       2),
    (p_school_id, 'instruments',  'Instruments',  'music_note',    3),
    (p_school_id, 'books',        'Books',        'menu_book',     4),
    (p_school_id, 'clothing',     'Clothing',     'checkroom',     5),
    (p_school_id, 'sports',       'Sports',       'sports_soccer', 6),
    (p_school_id, 'other',        'Other',        'more_horiz',   99)
  ON CONFLICT (school_id, slug) DO NOTHING;

  -- Default conditions
  INSERT INTO public.school_conditions (school_id, slug, name, description, display_order)
  VALUES
    (p_school_id, 'new',      'New',       'Brand new, never used',                1),
    (p_school_id, 'like_new', 'Like New',  'Used once or twice, no visible wear',  2),
    (p_school_id, 'good',     'Good',      'Some signs of use, fully functional',  3),
    (p_school_id, 'fair',     'Fair',      'Noticeable wear, still works',         4),
    (p_school_id, 'poor',     'Poor',      'Heavy wear, may need repair',          5)
  ON CONFLICT (school_id, slug) DO NOTHING;

  -- Default pickup locations
  INSERT INTO public.pickup_locations (school_id, name, display_order)
  VALUES
    (p_school_id, 'Campus Center',              1),
    (p_school_id, 'Main Library',               2),
    (p_school_id, 'Student Union',              3),
    (p_school_id, 'Other (specify in chat)',    99);

  -- Copy global FAQs as school-specific
  INSERT INTO public.faqs (school_id, category, question, answer, display_order)
  SELECT p_school_id, category, question, answer, display_order
  FROM public.faqs
  WHERE school_id IS NULL;
END;
$$;
