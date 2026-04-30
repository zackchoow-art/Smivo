/**
 * Ban record types — for the ban management page.
 * Defined in 04_ADMIN_WEB_SPEC.md §12.
 */

export type BanType = 'temporary' | 'permanent';
export type BanStatus = 'active' | 'expired' | 'lifted';

export interface UserBan {
  id: string;
  user_id: string;
  college_id: string;
  ban_type: BanType;
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
