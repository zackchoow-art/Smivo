/**
 * Feedback and contribution types.
 * NOTE: Field names here must exactly match the `user_feedbacks` table schema.
 * DB columns: category, description, screenshots, device_info (jsonb),
 * admin_judgment, admin_notes, contribution_points
 */

// NOTE: DB enum values for category column (not 'bug' / 'suggestion')
export type FeedbackCategory = 'bug_report' | 'feature_request' | 'general';

// NOTE: DB enum values for status — 'reviewing' not 'processing', 'closed' not 'dismissed'
export type FeedbackStatus = 'pending' | 'reviewing' | 'resolved' | 'closed';

export type FeedbackJudgment =
  | 'confirmed_bug'
  | 'valid_suggestion'
  | 'duplicate'
  | 'invalid'
  | 'accepted_implemented';

export interface UserFeedback {
  id: string;
  user_id: string;

  // NOTE: DB column is 'category', not 'feedback_type'
  category: FeedbackCategory;
  title: string | null;

  // NOTE: DB column is 'description', not 'content'
  description: string;

  // NOTE: DB column is 'screenshots' (text[]), not 'screenshot_urls'
  screenshots: string[];

  // NOTE: Device/app context is stored as a single jsonb column, not separate columns
  device_info: Record<string, unknown> | null;

  priority: string | null;

  // Processing
  status: FeedbackStatus;

  // NOTE: DB column is 'admin_judgment', not 'judgment'
  admin_judgment: FeedbackJudgment | null;

  // NOTE: DB column is 'contribution_points', not 'contribution_awarded'
  contribution_points: number;

  // NOTE: DB column is 'admin_notes', not 'admin_reply'
  admin_notes: string | null;

  resolved_by: string | null;
  resolved_at: string | null;

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
