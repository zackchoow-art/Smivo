-- Migration 00071: Moderation Notification Helper Function
-- Provides a centralized SECURITY DEFINER function for sending in-app notifications
-- after admin moderation actions (report resolution, feedback resolution).
-- The email_queued flag triggers the existing push-notification Edge Function webhook.

-- ─── 1. Extend notification type CHECK constraint ──────────────────────────
-- We add new moderation-specific notification types while preserving existing ones.
-- Using a less-restrictive approach: drop old check and recreate with new values.

ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;

-- NOTE: No CHECK constraint on 'type' existed previously; adding one now
-- to document all valid values. If a check existed, we recreate it here.
-- Add new moderation notification types alongside the existing order/message types.
ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check CHECK (type IN (
    -- Existing order types
    'order_placed', 'order_accepted', 'order_cancelled', 'order_completed',
    'order_delivered', 'new_message', 'rental_extension', 'rental_reminder',
    -- System/admin types
    'system_broadcast',
    -- NEW: Moderation action result notifications
    'report_resolved',     -- Reporter: their report was actioned (valid)
    'report_dismissed',    -- Reporter: their report was dismissed (not actioned)
    'moderation_warned',   -- Reported user: received a formal warning
    'moderation_restricted', -- Reported user: account/feature restricted
    'feedback_responded'   -- Feedback submitter: admin replied to their feedback
  ));

-- ─── 2. Email template table ───────────────────────────────────────────────
-- Stores reusable HTML email templates referenced by notification type.
CREATE TABLE IF NOT EXISTS public.email_templates (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  template_key  text NOT NULL UNIQUE,   -- e.g. 'report_resolved', 'moderation_warned'
  subject       text NOT NULL,
  html_body     text NOT NULL,          -- Supports {{variable}} placeholders
  plain_body    text,                   -- Plain-text fallback
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.email_templates ENABLE ROW LEVEL SECURITY;

-- Admin-only write, anyone can read (Edge Function uses service role anyway)
CREATE POLICY "Admins can manage email templates"
  ON public.email_templates FOR ALL
  USING (public.is_platform_sysadmin())
  WITH CHECK (public.is_platform_sysadmin());

CREATE POLICY "Service role can read email templates"
  ON public.email_templates FOR SELECT
  USING (true);

-- ─── 3. Seed email templates ───────────────────────────────────────────────
INSERT INTO public.email_templates (template_key, subject, html_body, plain_body) VALUES

-- 3a. Reporter: report was actioned (valid)
('report_resolved',
 'Your Report Has Been Reviewed — Thank You!',
 '<!DOCTYPE html><html><body style="font-family:Inter,sans-serif;background:#f5f5f5;padding:32px">
<div style="max-width:520px;margin:auto;background:#fff;border-radius:12px;padding:32px;box-shadow:0 2px 12px rgba(0,0,0,0.06)">
  <div style="text-align:center;margin-bottom:24px">
    <img src="https://smivo.io/assets/logo.png" alt="Smivo" height="36" style="height:36px"/>
  </div>
  <h2 style="color:#1a1a1a;margin:0 0 8px">Your report has been reviewed ✅</h2>
  <p style="color:#555;line-height:1.6">Hi {{user_name}},</p>
  <p style="color:#555;line-height:1.6">
    Thank you for keeping Smivo safe. We have reviewed the report you submitted on
    <strong>{{reported_date}}</strong> and have taken action.
  </p>
  <div style="background:#f0faf4;border-left:4px solid #34c759;padding:16px;border-radius:8px;margin:20px 0">
    <p style="margin:0;color:#1a7a3c;font-weight:600">🎉 +{{points}} contribution points awarded</p>
    <p style="margin:4px 0 0;color:#555;font-size:14px">Your contribution score has been updated.</p>
  </div>
  <p style="color:#555;line-height:1.6;font-size:14px">
    We take all reports seriously and rely on community members like you to help maintain a safe
    marketplace. If you have further concerns, please don''t hesitate to report again.
  </p>
  <div style="border-top:1px solid #eee;margin-top:24px;padding-top:16px;text-align:center">
    <p style="color:#999;font-size:12px">You received this email because you submitted a report on Smivo.<br/>
    <a href="{{unsubscribe_url}}" style="color:#999">Unsubscribe from moderation emails</a></p>
  </div>
</div></body></html>',
 'Hi {{user_name}}, your report submitted on {{reported_date}} has been reviewed and action has been taken. You have been awarded {{points}} contribution points. Thank you for helping keep Smivo safe.'
),

-- 3b. Reporter: report was dismissed (not valid)
('report_dismissed',
 'Update on Your Report',
 '<!DOCTYPE html><html><body style="font-family:Inter,sans-serif;background:#f5f5f5;padding:32px">
<div style="max-width:520px;margin:auto;background:#fff;border-radius:12px;padding:32px;box-shadow:0 2px 12px rgba(0,0,0,0.06)">
  <div style="text-align:center;margin-bottom:24px">
    <img src="https://smivo.io/assets/logo.png" alt="Smivo" height="36" style="height:36px"/>
  </div>
  <h2 style="color:#1a1a1a;margin:0 0 8px">Update on your report</h2>
  <p style="color:#555;line-height:1.6">Hi {{user_name}},</p>
  <p style="color:#555;line-height:1.6">
    Thank you for taking the time to submit a report. After careful review, our moderation team
    has determined that no action is required at this time.
  </p>
  <p style="color:#555;line-height:1.6;font-size:14px">
    We review every report thoroughly. If you continue to experience issues, please submit a
    new report with additional details. Thank you for helping make Smivo better.
  </p>
  <div style="border-top:1px solid #eee;margin-top:24px;padding-top:16px;text-align:center">
    <p style="color:#999;font-size:12px">Smivo Campus Marketplace<br/>
    <a href="{{unsubscribe_url}}" style="color:#999">Unsubscribe</a></p>
  </div>
</div></body></html>',
 'Hi {{user_name}}, we have reviewed your report submitted on {{reported_date}}. After careful review, no further action is required at this time. Thank you for helping keep Smivo safe.'
),

-- 3c. Reported user: formal warning
('moderation_warned',
 'Important Notice from Smivo — Account Warning',
 '<!DOCTYPE html><html><body style="font-family:Inter,sans-serif;background:#f5f5f5;padding:32px">
<div style="max-width:520px;margin:auto;background:#fff;border-radius:12px;padding:32px;box-shadow:0 2px 12px rgba(0,0,0,0.06)">
  <div style="text-align:center;margin-bottom:24px">
    <img src="https://smivo.io/assets/logo.png" alt="Smivo" height="36" style="height:36px"/>
  </div>
  <div style="background:#fff8e1;border-left:4px solid #ff9500;padding:16px;border-radius:8px;margin-bottom:24px">
    <p style="margin:0;color:#b36200;font-weight:700;font-size:15px">⚠️ Official Warning</p>
  </div>
  <h2 style="color:#1a1a1a;margin:0 0 8px">Account Warning Notice</h2>
  <p style="color:#555;line-height:1.6">Hi {{user_name}},</p>
  <p style="color:#555;line-height:1.6">
    Our moderation team has reviewed recent activity on your account and issued a formal warning.
  </p>
  <div style="background:#f9f9f9;border:1px solid #eee;border-radius:8px;padding:16px;margin:16px 0">
    <p style="margin:0;color:#333;font-size:14px"><strong>Reason:</strong> {{reason}}</p>
  </div>
  <p style="color:#555;line-height:1.6;font-size:14px">
    Please review our <a href="https://smivo.io/safety" style="color:#007aff">Community Guidelines</a>.
    Repeated violations may result in account restrictions or permanent suspension.
  </p>
  <div style="border-top:1px solid #eee;margin-top:24px;padding-top:16px;text-align:center">
    <p style="color:#999;font-size:12px">Smivo Trust & Safety Team<br/>
    <a href="https://smivo.io/support" style="color:#999">Contact Support</a></p>
  </div>
</div></body></html>',
 'Hi {{user_name}}, our moderation team has issued a formal warning on your account. Reason: {{reason}}. Please review our community guidelines at smivo.io/safety. Repeated violations may result in account restrictions.'
),

-- 3d. Reported user: account/feature restricted
('moderation_restricted',
 'Important: Account Restriction Applied',
 '<!DOCTYPE html><html><body style="font-family:Inter,sans-serif;background:#f5f5f5;padding:32px">
<div style="max-width:520px;margin:auto;background:#fff;border-radius:12px;padding:32px;box-shadow:0 2px 12px rgba(0,0,0,0.06)">
  <div style="text-align:center;margin-bottom:24px">
    <img src="https://smivo.io/assets/logo.png" alt="Smivo" height="36" style="height:36px"/>
  </div>
  <div style="background:#fff0f0;border-left:4px solid #ff3b30;padding:16px;border-radius:8px;margin-bottom:24px">
    <p style="margin:0;color:#c0392b;font-weight:700;font-size:15px">🚫 Account Restriction</p>
  </div>
  <h2 style="color:#1a1a1a;margin:0 0 8px">Account Restriction Notice</h2>
  <p style="color:#555;line-height:1.6">Hi {{user_name}},</p>
  <p style="color:#555;line-height:1.6">
    Following a review of your account activity, the following restrictions have been applied:
  </p>
  <div style="background:#f9f9f9;border:1px solid #eee;border-radius:8px;padding:16px;margin:16px 0">
    <p style="margin:0 0 8px;color:#333;font-size:14px"><strong>Restrictions:</strong> {{restrictions}}</p>
    <p style="margin:0;color:#333;font-size:14px"><strong>Duration:</strong> {{duration}}</p>
    <p style="margin:8px 0 0;color:#333;font-size:14px"><strong>Reason:</strong> {{reason}}</p>
  </div>
  <p style="color:#555;line-height:1.6;font-size:14px">
    If you believe this is an error, please <a href="https://smivo.io/support" style="color:#007aff">contact our support team</a>.
    Please review our <a href="https://smivo.io/safety" style="color:#007aff">Community Guidelines</a> to prevent further action.
  </p>
  <div style="border-top:1px solid #eee;margin-top:24px;padding-top:16px;text-align:center">
    <p style="color:#999;font-size:12px">Smivo Trust & Safety Team</p>
  </div>
</div></body></html>',
 'Hi {{user_name}}, account restrictions have been applied: {{restrictions}} for {{duration}}. Reason: {{reason}}. Contact support at smivo.io/support if you believe this is an error.'
),

-- 3e. Feedback submitter: admin responded
('feedback_responded',
 'Response to Your Feedback on Smivo',
 '<!DOCTYPE html><html><body style="font-family:Inter,sans-serif;background:#f5f5f5;padding:32px">
<div style="max-width:520px;margin:auto;background:#fff;border-radius:12px;padding:32px;box-shadow:0 2px 12px rgba(0,0,0,0.06)">
  <div style="text-align:center;margin-bottom:24px">
    <img src="https://smivo.io/assets/logo.png" alt="Smivo" height="36" style="height:36px"/>
  </div>
  <h2 style="color:#1a1a1a;margin:0 0 8px">We responded to your feedback 💬</h2>
  <p style="color:#555;line-height:1.6">Hi {{user_name}},</p>
  <p style="color:#555;line-height:1.6">
    Thank you for sharing your feedback with us. Our team has reviewed it and left a response.
  </p>
  <div style="background:#f0f6ff;border-left:4px solid #007aff;padding:16px;border-radius:8px;margin:16px 0">
    <p style="margin:0 0 4px;color:#005bbf;font-weight:600;font-size:13px">Admin Response</p>
    <p style="margin:0;color:#333;line-height:1.6">{{admin_response}}</p>
  </div>
  {{#if points_awarded}}
  <div style="background:#f0faf4;border-left:4px solid #34c759;padding:12px 16px;border-radius:8px;margin:12px 0">
    <p style="margin:0;color:#1a7a3c;font-weight:600">🎉 +{{points_awarded}} contribution points awarded</p>
  </div>
  {{/if}}
  <p style="color:#555;line-height:1.6;font-size:14px">
    You can view the full response in the app under <strong>Settings → My Feedback</strong>.
    Thank you for helping us improve Smivo!
  </p>
  <div style="border-top:1px solid #eee;margin-top:24px;padding-top:16px;text-align:center">
    <p style="color:#999;font-size:12px">Smivo Campus Marketplace<br/>
    <a href="{{unsubscribe_url}}" style="color:#999">Unsubscribe from feedback emails</a></p>
  </div>
</div></body></html>',
 'Hi {{user_name}}, our team has reviewed your feedback and responded: {{admin_response}}. {{#if points_awarded}}You earned {{points_awarded}} contribution points!{{/if}} View it in the app under Settings → My Feedback.'
)

ON CONFLICT (template_key) DO UPDATE
  SET subject   = EXCLUDED.subject,
      html_body = EXCLUDED.html_body,
      plain_body = EXCLUDED.plain_body,
      updated_at = now();

-- ─── 4. Core helper: send_moderation_notification() ───────────────────────
-- Used by admin hooks to write an in-app notification with email_queued flag.
-- The existing push-notification Edge Function webhook fires on INSERT to notifications.
CREATE OR REPLACE FUNCTION public.send_moderation_notification(
  p_user_id        uuid,
  p_type           text,
  p_title          text,
  p_body           text,
  p_action_type    text DEFAULT 'route',
  p_action_url     text DEFAULT '/notifications'
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_email_enabled boolean;
  v_notif_id      uuid;
BEGIN
  -- Check user's global email notification preference
  SELECT coalesce(up.email_notifications_enabled, true)
  INTO v_email_enabled
  FROM public.user_profiles up
  WHERE up.id = p_user_id;

  INSERT INTO public.notifications (
    user_id, type, title, body,
    action_type, action_url,
    email_queued, is_read
  ) VALUES (
    p_user_id, p_type, p_title, p_body,
    p_action_type, p_action_url,
    coalesce(v_email_enabled, true), false
  )
  RETURNING id INTO v_notif_id;

  RETURN v_notif_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.send_moderation_notification TO authenticated;

COMMENT ON FUNCTION public.send_moderation_notification IS
  'Insert a moderation notification for a user, respecting their email preference.
   Called by admin hooks after resolving reports or responding to feedback.
   The push-notification Edge Function webhook fires automatically on INSERT.';
