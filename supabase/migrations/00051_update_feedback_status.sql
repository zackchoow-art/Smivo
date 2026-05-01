-- Migration 00051: Update user_feedbacks status enum and add shortcuts

-- 1. Update the check constraint on user_feedbacks.status
ALTER TABLE public.user_feedbacks DROP CONSTRAINT user_feedbacks_status_check;

-- Convert existing values
UPDATE public.user_feedbacks SET status = 'submitted' WHERE status = 'pending';
UPDATE public.user_feedbacks SET status = 'read' WHERE status = 'in_review';
UPDATE public.user_feedbacks SET status = 'accepted' WHERE status = 'resolved';
UPDATE public.user_feedbacks SET status = 'submitted' WHERE status IN ('rejected', 'duplicate');

ALTER TABLE public.user_feedbacks 
  ADD CONSTRAINT user_feedbacks_status_check 
  CHECK (status IN ('submitted', 'read', 'accepted', 'high_contribution'));

ALTER TABLE public.user_feedbacks ALTER COLUMN status SET DEFAULT 'submitted';

-- 2. Add preset shortcut replies to system_configs
INSERT INTO public.system_configs (config_key, config_value, description)
VALUES 
  ('feedback.shortcuts', '["Thanks for your feedback! We will look into this shortly.", "We have confirmed this bug and are working on a fix.", "Great suggestion! We have added it to our roadmap.", "This issue has been resolved in the latest update."]', 'Preset shortcut replies for admin feedback processing')
ON CONFLICT (config_key) DO UPDATE SET 
  config_value = EXCLUDED.config_value,
  description = EXCLUDED.description;
