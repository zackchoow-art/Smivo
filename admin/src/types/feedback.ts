/**
 * Feedback and contribution types.
 * NOTE: Field names EXACTLY match the `user_feedbacks` table schema.
 * DB columns: type, title, description, screenshot_url (single text),
 * device_info (jsonb), status, admin_response, points_awarded
 */

// DB enum values for the `type` column
export type FeedbackType = 'bug_report' | 'feature_request' | 'general';

// Kept for backward-compat; FeedbackCategory is an alias of FeedbackType
export type FeedbackCategory = FeedbackType;

// DB enum values for status
export type FeedbackStatus = 'pending' | 'reviewing' | 'resolved' | 'closed';

// Internal judgment values stored in admin_response prefix
export type FeedbackJudgment =
  | 'confirmed_bug'
  | 'valid_suggestion'
  | 'duplicate'
  | 'invalid'
  | 'accepted_implemented';

export interface UserFeedback {
  id: string;
  user_id: string;

  // NOTE: DB column is 'type' (not 'category' / 'feedback_type')
  type: FeedbackType;

  title: string | null;
  description: string;

  // NOTE: DB column is 'screenshot_url' (single text, not screenshots text[])
  screenshot_url: string | null;

  // Device/app context stored as a single jsonb column
  device_info: Record<string, unknown> | null;

  status: FeedbackStatus;

  // NOTE: DB column is 'admin_response' (not admin_notes / admin_judgment)
  admin_response: string | null;

  // NOTE: DB column is 'points_awarded' (not contribution_points)
  points_awarded: number;

  created_at: string;
  updated_at: string;
}

/** Feedback joined with user info — for detail view display */
export interface FeedbackWithUser extends UserFeedback {
  user_display_name: string | null;
  user_email: string;
  user_avatar_url: string | null;
}

export interface ContributionScore {
  id: string;
  user_id: string;
  college_id: string;
  delta: number;
  reason: string;
  source_type: string | null;
  source_id: string | null;
  created_at: string;
}

export interface UserBadge {
  user_id: string;
  badge_code: string;
  earned_at: string;
}

/** Badge definitions for display */
export const BADGE_DEFINITIONS: Record<
  string,
  { emoji: string; label: string; threshold: number }
> = {
  smivo_explorer: { emoji: '🌱', label: 'Smivo 探索者', threshold: 10 },
  bug_hunter: { emoji: '🔧', label: 'Bug 猎人', threshold: 50 },
  smivo_guardian: { emoji: '💎', label: '校园守护者', threshold: 100 },
  smivo_builder: { emoji: '👑', label: 'Smivo 共建者', threshold: 500 },
};
