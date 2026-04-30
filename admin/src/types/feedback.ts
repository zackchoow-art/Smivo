/**
 * Feedback and contribution types.
 * Defined in 04_ADMIN_WEB_SPEC.md §13.
 */

export type FeedbackType = 'bug' | 'suggestion' | 'complaint' | 'other';
export type FeedbackStatus = 'pending' | 'processing' | 'resolved' | 'dismissed';
export type FeedbackJudgment = 'confirmed_bug' | 'valid_suggestion' | 'duplicate' | 'invalid' | 'accepted_implemented';

export interface UserFeedback {
  id: string;
  user_id: string;
  college_id: string;
  feedback_type: FeedbackType;
  title: string | null;
  content: string;
  screenshot_urls: string[];

  // Auto-captured context
  app_version: string | null;
  os_version: string | null;
  device_model: string | null;
  current_route: string | null;
  meta: Record<string, unknown> | null;

  // Processing
  status: FeedbackStatus;
  judgment: FeedbackJudgment | null;
  contribution_awarded: number;
  tags: string[];
  admin_reply: string | null;
  admin_note: string | null;
  resolved_by: string | null;
  resolved_at: string | null;

  created_at: string;
}

/** Feedback with user info for list display */
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
export const BADGE_DEFINITIONS: Record<string, { emoji: string; label: string; threshold: number }> = {
  smivo_explorer: { emoji: '🌱', label: 'Smivo 探索者', threshold: 10 },
  bug_hunter: { emoji: '🔧', label: 'Bug 猎人', threshold: 50 },
  smivo_guardian: { emoji: '💎', label: '校园守护者', threshold: 100 },
  smivo_builder: { emoji: '👑', label: 'Smivo 共建者', threshold: 500 },
};
