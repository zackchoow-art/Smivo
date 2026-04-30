/**
 * User profile type — mirrors `user_profiles` table with admin extensions.
 */

export type UserStatus = 'active' | 'banned' | 'suspended';
export type RiskLevel = 'normal' | 'attention' | 'risk' | 'banned';

export interface UserProfile {
  id: string;
  email: string;
  display_name: string | null;
  avatar_url: string | null;
  college_id: string;
  school_id: string | null;

  // Activity
  last_active_at: string | null;
  created_at: string;
  updated_at: string;

  // Contribution
  contribution_score: number;
  contribution_level: number;

  // Admin-managed fields
  admin_note: string | null;
  custom_tags: string[];
  warning_count: number;

  // Computed
  is_email_verified: boolean;
}

/** Extended user profile with computed risk info for admin views */
export interface UserProfileWithRisk extends UserProfile {
  risk_level: RiskLevel;
  risk_signals: string[];
  listing_count: number;
  order_count: number;
  report_received_count: number;
  report_submitted_count: number;
  ban_count: number;
  college_name: string;
}
