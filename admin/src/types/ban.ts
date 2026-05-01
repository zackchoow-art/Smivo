/**
 * Ban / Restriction record types — for the ban management page.
 * Supports granular restriction scopes: chat_mute, listing_ban,
 * feedback_ban, account_freeze.
 */

export type BanType = 'temporary' | 'permanent';
export type BanStatus = 'active' | 'expired' | 'lifted';

/** Restriction scopes — each can be applied independently */
export type RestrictionScope = 'chat_mute' | 'listing_ban' | 'feedback_ban' | 'account_freeze';

export interface UserBan {
  id: string;
  user_id: string;
  college_id: string;
  ban_type: BanType;
  scope: RestrictionScope;
  reason_code: string;
  reason_detail: string;
  duration_days: number | null;
  expires_at: string | null;

  // Lifecycle
  banned_by: string;
  banned_at: string;
  lifted_by: string | null;
  lifted_at: string | null;
  lift_reason: string | null;

  created_at: string;
}

/** Ban with user display info for the bans list */
export interface BanWithUser extends UserBan {
  user_display_name: string | null;
  user_email: string;
  banned_by_name: string | null;
  status: BanStatus;
}

/** Summary of active restrictions for a user (used in user list view) */
export interface UserRestrictionSummary {
  user_id: string;
  active_scopes: RestrictionScope[];
}

/** Metadata for each restriction scope */
export interface RestrictionScopeMeta {
  key: RestrictionScope;
  label: string;
  description: string;
  icon: string;
  color: string;
}
