/**
 * User report types — for chat reports and listing reports.
 * Defined in 04_ADMIN_WEB_SPEC.md §8.
 */

export type ReportReason = 'spam' | 'harassment' | 'scam' | 'nsfw' | 'other';
export type ReportStatus = 'pending' | 'resolved' | 'dismissed';
export type ReportTargetType = 'message' | 'listing' | 'user';
export type ReportResolution = 'warn' | 'ban' | 'dismiss';

export interface UserReport {
  id: string;
  reporter_id: string;
  reported_user_id: string;
  target_type: ReportTargetType;
  target_id: string | null;
  reason: ReportReason;
  detail: string | null;
  screenshot_urls: string[];
  college_id: string;

  // Processing
  status: ReportStatus;
  resolution: ReportResolution | null;
  resolved_by: string | null;
  resolved_at: string | null;
  resolution_note: string | null;

  created_at: string;
}

/** Report with user info for display */
export interface ReportWithUsers extends UserReport {
  reporter_name: string | null;
  reporter_email: string;
  reported_name: string | null;
  reported_email: string;
  message_preview: string | null;
}
