-- Migration 00135: Platform Functions — Dictionary & Config Seed Data
-- ═════════════════════════════════════════════════════════════════════
-- Purpose: Add new system_dictionaries entries for items currently
-- hardcoded in app/admin code so they can be managed via the
-- forthcoming Platform Functions admin page.
--
-- IMPORTANT: This migration is ADDITIVE only. It inserts new rows into
-- existing tables (system_dictionaries, system_configs, system_settings).
-- No existing rows or constraints are modified here. Constraint relaxation
-- happens in migration 00136.
--
-- Risk level: LOW — inserting new rows does not affect existing queries.
-- ═════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════
-- 1. Moderation Statuses → system_dictionaries
-- These mirror the CHECK constraint on listings.moderation_status.
-- ═══════════════════════════════════════════════════════
INSERT INTO public.system_dictionaries
  (dict_type, dict_key, dict_value, description, display_order, is_active, access_level, extra)
VALUES
  ('moderation_status', 'auto_approved',  'Auto Approved',  'Listing passed automated checks and is live immediately',  10, true, 'system', '{"icon":"check_circle","color":"#059669"}'),
  ('moderation_status', 'pending_review', 'Pending Review',  'Listing queued for manual admin review',                   20, true, 'system', '{"icon":"schedule","color":"#d97706"}'),
  ('moderation_status', 'approved',       'Approved',        'Listing manually approved by admin',                        30, true, 'system', '{"icon":"verified","color":"#059669"}'),
  ('moderation_status', 'rejected',       'Rejected',        'Listing rejected by admin — not published',                 40, true, 'system', '{"icon":"cancel","color":"#dc2626"}'),
  ('moderation_status', 'taken_down',     'Taken Down',      'Listing removed by admin after being live',                 50, true, 'system', '{"icon":"remove_circle","color":"#991b1b"}'),
  ('moderation_status', 'flagged',        'Flagged',         'Listing flagged by AI or users for review',                 60, true, 'system', '{"icon":"flag","color":"#ea580c"}')
ON CONFLICT (dict_type, dict_key) DO NOTHING;


-- ═══════════════════════════════════════════════════════
-- 2. Feedback Types → system_dictionaries
-- Currently hardcoded in app/lib/features/settings/screens/submit_feedback_screen.dart
-- and in user_feedbacks.type CHECK constraint.
-- ═══════════════════════════════════════════════════════
INSERT INTO public.system_dictionaries
  (dict_type, dict_key, dict_value, description, display_order, is_active, access_level, extra)
VALUES
  ('feedback_type', 'bug',             'Bug Report',       'Report a software bug or crash',              10, true, 'platform', NULL),
  ('feedback_type', 'improvement',     'Improvement',      'Suggest an improvement to existing features', 20, true, 'platform', NULL),
  ('feedback_type', 'feature_request', 'Feature Request',  'Request a new feature or capability',         30, true, 'platform', NULL),
  ('feedback_type', 'other',           'Other',            'General feedback that doesn''t fit other categories', 40, true, 'platform', NULL)
ON CONFLICT (dict_type, dict_key) DO NOTHING;


-- ═══════════════════════════════════════════════════════
-- 3. Report Types → system_dictionaries
-- Currently hardcoded in app/lib/shared/widgets/report_dialog.dart
-- and admin/src/lib/constants.ts REPORT_REASONS.
-- ═══════════════════════════════════════════════════════
INSERT INTO public.system_dictionaries
  (dict_type, dict_key, dict_value, description, display_order, is_active, access_level, extra)
VALUES
  ('report_type', 'spam',          'Spam or irrelevant',            'Content that is spam, advertising, or off-topic',    10, true, 'platform', NULL),
  ('report_type', 'harassment',    'Harassment or hate speech',     'Content that harasses, bullies, or promotes hatred',  20, true, 'platform', NULL),
  ('report_type', 'fraud',         'Scam or fraud',                 'Content that appears to be a scam or fraudulent',     30, true, 'platform', NULL),
  ('report_type', 'inappropriate', 'Inappropriate content',         'Content containing nudity, violence, or other NSFW material', 40, true, 'platform', NULL),
  ('report_type', 'nsfw',          'NSFW',                          'Explicit or adult content not suitable for the platform', 50, true, 'platform', NULL),
  ('report_type', 'other',         'Other',                         'Other reason not listed above',                       60, true, 'platform', NULL)
ON CONFLICT (dict_type, dict_key) DO NOTHING;


-- ═══════════════════════════════════════════════════════
-- 4. Report Resolutions → system_dictionaries
-- Similar to feedback_resolution but for user reports.
-- ═══════════════════════════════════════════════════════
INSERT INTO public.system_dictionaries
  (dict_type, dict_key, dict_value, description, display_order, is_active, access_level, extra)
VALUES
  ('report_resolution', 'action_taken',     'Action Taken',     'Report validated — action taken against reported user/content', 10, true, 'platform', '{"points":5,"reply":"Thank you for your report. We have taken action to address this issue."}'),
  ('report_resolution', 'warning_issued',   'Warning Issued',   'Report validated — warning issued to reported user',           20, true, 'platform', '{"points":3,"reply":"Thank you for reporting. A warning has been issued to the user."}'),
  ('report_resolution', 'no_violation',     'No Violation',     'Report reviewed — no policy violation found',                   30, true, 'platform', '{"points":1,"reply":"Thank you for your report. After review, we found no policy violations."}'),
  ('report_resolution', 'duplicate',        'Duplicate',        'This report duplicates a previously submitted report',          40, true, 'platform', '{"points":0,"reply":"This report has already been submitted and is being handled."}'),
  ('report_resolution', 'dismissed',        'Dismissed',        'Report dismissed — insufficient evidence or false report',      50, true, 'platform', '{"points":0,"reply":"After review, we could not verify the reported issue."}')
ON CONFLICT (dict_type, dict_key) DO NOTHING;


-- ═══════════════════════════════════════════════════════
-- 5. Punishment Types → system_dictionaries
-- Currently hardcoded as RESTRICTION_SCOPES in admin constants.
-- These mirror the CHECK constraint on user_bans.scope.
-- ═══════════════════════════════════════════════════════
INSERT INTO public.system_dictionaries
  (dict_type, dict_key, dict_value, description, display_order, is_active, access_level, extra)
VALUES
  ('punishment_type', 'chat_mute',       'Chat Mute',       'User cannot send chat messages. Other users see a muted notice.', 10, true, 'platform', '{"icon":"🔇","color":"#e67700","reply_template":"Your chat privileges have been temporarily suspended due to a policy violation. Duration: {{duration}}."}'),
  ('punishment_type', 'listing_ban',     'Listing Ban',     'User cannot create or edit listings.',                             20, true, 'platform', '{"icon":"🚫","color":"#c92a2a","reply_template":"Your listing privileges have been suspended due to a policy violation. Duration: {{duration}}."}'),
  ('punishment_type', 'feedback_ban',    'Feedback Ban',    'User cannot submit feedback to prevent abuse.',                    30, true, 'platform', '{"icon":"📝","color":"#5c7cfa","reply_template":"Your feedback submission privileges have been suspended due to misuse. Duration: {{duration}}."}'),
  ('punishment_type', 'account_freeze',  'Account Freeze',  'Full account suspension. User cannot log in.',                     40, true, 'platform', '{"icon":"❄️","color":"#495057","reply_template":"Your account has been suspended due to severe policy violations. Duration: {{duration}}. Contact support for appeal."}')
ON CONFLICT (dict_type, dict_key) DO NOTHING;


-- ═══════════════════════════════════════════════════════
-- 6. System Configs — New keys
-- ═══════════════════════════════════════════════════════

-- Auto-accept message template
INSERT INTO public.system_configs (config_key, config_value, description)
VALUES (
  'auto_accept_message.template',
  '"✅ Your offer for \"{{listing_title}}\" has been accepted! Feel free to coordinate pickup details here. You can view the order in your Buyer Center."',
  'Message template sent to buyer when seller accepts their offer. Supports {{listing_title}} placeholder.'
)
ON CONFLICT (config_key) DO NOTHING;

-- Content filter warn message (shown to users when warn word detected)
INSERT INTO public.system_configs (config_key, config_value, description)
VALUES (
  'content_filter.warn_message',
  '"Your message may contain language that violates our community guidelines. Please review before sending."',
  'Warning message shown to users when client-side word filter detects a warn-level word.'
)
ON CONFLICT (config_key) DO NOTHING;

-- Image moderation mode
INSERT INTO public.system_configs (config_key, config_value, description)
VALUES (
  'image_moderation_mode',
  '"auto"',
  'Controls how uploaded images are moderated. Options: auto (AI review all images), manual (queue for admin review), off (no image moderation).'
)
ON CONFLICT (config_key) DO NOTHING;

-- User report enabled toggle
INSERT INTO public.system_configs (config_key, config_value, description)
VALUES (
  'user_report.enabled',
  'true',
  'Master switch for user-facing report functionality. When false, report buttons are hidden in the app.'
)
ON CONFLICT (config_key) DO NOTHING;

-- Test user registration
INSERT INTO public.system_configs (config_key, config_value, description)
VALUES (
  'test_user.registration_enabled',
  'false',
  'When true, allows test user accounts to register without a valid .edu email domain.'
)
ON CONFLICT (config_key) DO NOTHING;

-- Test user login
INSERT INTO public.system_configs (config_key, config_value, description)
VALUES (
  'test_user.login_enabled',
  'false',
  'When true, allows test user accounts to log in regardless of email verification status.'
)
ON CONFLICT (config_key) DO NOTHING;


-- ═══════════════════════════════════════════════════════
-- 7. System Settings — New feature flags
-- ═══════════════════════════════════════════════════════

-- Cross-school listing (future feature)
INSERT INTO public.system_settings (key, value, description)
VALUES (
  'listing.cross_school',
  'false',
  'When enabled, listings from one school are visible to students at other schools in the same alliance.'
)
ON CONFLICT (key) DO NOTHING;
