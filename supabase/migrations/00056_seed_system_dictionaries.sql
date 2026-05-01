-- Migration 00056: Seed system_dictionaries with business config data
--
-- Replaces the concept of "workflow keyword fields" with configurable
-- business data that admins can freely add/edit:
-- category, condition, pickup_location, review_tag, system_url

-- Clear any existing seed data to avoid duplicates
DELETE FROM public.system_dictionaries
WHERE dict_type IN ('category','condition','pickup_location','review_tag','system_url');

-- ── Product Categories ──────────────────────────────────────────────────────
INSERT INTO public.system_dictionaries (dict_type, dict_key, dict_value, description, display_order, is_active)
VALUES
  ('category', 'furniture',    'Furniture',    'Desks, chairs, shelves, etc.',          1, true),
  ('category', 'electronics',  'Electronics',  'Laptops, phones, tablets, etc.',        2, true),
  ('category', 'instruments',  'Instruments',  'Musical instruments and accessories',   3, true),
  ('category', 'books',        'Books',        'Textbooks, novels, study guides',       4, true),
  ('category', 'clothing',     'Clothing',     'Apparel, shoes, accessories',           5, true),
  ('category', 'sports',       'Sports',       'Sports equipment and gear',             6, true),
  ('category', 'other',        'Other',        'Items not listed in other categories',  7, true);

-- ── Item Conditions ─────────────────────────────────────────────────────────
INSERT INTO public.system_dictionaries (dict_type, dict_key, dict_value, description, display_order, is_active)
VALUES
  ('condition', 'new',       'New',       'Brand new, never used',               1, true),
  ('condition', 'like_new',  'Like New',  'Barely used, no visible wear',        2, true),
  ('condition', 'good',      'Good',      'Minor signs of use, fully functional', 3, true),
  ('condition', 'fair',      'Fair',      'Visible wear, still functional',       4, true),
  ('condition', 'poor',      'Poor',      'Heavily used, may need repair',        5, true);

-- ── Pickup Locations (Smith College example) ─────────────────────────────────
INSERT INTO public.system_dictionaries (dict_type, dict_key, dict_value, description, display_order, is_active)
VALUES
  ('pickup_location', 'campus_center',  'Campus Center',    'Main campus center lobby',      1, true),
  ('pickup_location', 'library',        'Neilson Library',  'Library main entrance',         2, true),
  ('pickup_location', 'student_union',  'Student Union',    'Student union building',        3, true),
  ('pickup_location', 'dining_hall',    'Dining Hall',      'Chase Dining Hall entrance',    4, true),
  ('pickup_location', 'dorm_lobby',     'Dorm Lobby',       'To be arranged with seller',   5, true);

-- ── Review Tags ──────────────────────────────────────────────────────────────
INSERT INTO public.system_dictionaries (dict_type, dict_key, dict_value, description, display_order, is_active)
VALUES
  ('review_tag', 'on_time',         'On Time',          'Item delivered or returned on time',  1, true),
  ('review_tag', 'as_described',    'As Described',     'Item matched the description',        2, true),
  ('review_tag', 'good_condition',  'Good Condition',   'Item in great physical condition',    3, true),
  ('review_tag', 'responsive',      'Responsive',       'Quick to respond to messages',        4, true),
  ('review_tag', 'easy_pickup',     'Easy Pickup',      'Convenient and smooth pickup',        5, true),
  ('review_tag', 'trustworthy',     'Trustworthy',      'Safe and trustworthy transaction',    6, true);

-- ── System URLs ──────────────────────────────────────────────────────────────
INSERT INTO public.system_dictionaries (dict_type, dict_key, dict_value, description, display_order, is_active)
VALUES
  ('system_url', 'website',          'https://smivo.io',                                       'Official website',                           1, true),
  ('system_url', 'privacy_policy',   'https://smivo.io/privacy-policy',                        'Privacy policy page',                        2, true),
  ('system_url', 'terms_of_service', 'https://smivo.io/terms',                                 'Terms of service page',                      3, true),
  ('system_url', 'support',          'https://smivo.io/support',                               'User support / help center',                 4, true),
  ('system_url', 'safety',           'https://smivo.io/safety',                                'Campus safety guidelines',                   5, true),
  ('system_url', 'zero_tolerance',   'https://smivo.io/safety#zero-tolerance',                 'Zero tolerance policy (shown at signup)',     6, true),
  ('system_url', 'app_store',        'https://apps.apple.com/app/smivo',                       'iOS App Store listing',                      7, true),
  ('system_url', 'google_play',      'https://play.google.com/store/apps/details?id=com.smivo','Android Google Play listing',                8, true);
