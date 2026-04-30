/**
 * Push notification types.
 * Defined in 04_ADMIN_WEB_SPEC.md §14.
 */

export type PushAudienceType = 'all' | 'filter' | 'csv' | 'platform_wide';
export type PushStatus = 'draft' | 'scheduled' | 'sending' | 'sent' | 'failed' | 'cancelled';
export type PushChannel = 'push' | 'inbox';

export interface PushJob {
  id: string;
  title: string;
  body: string;
  deep_link: string | null;
  channels: PushChannel[];

  // Audience
  audience_type: PushAudienceType;
  audience_filter: Record<string, unknown> | null;
  audience_user_ids: string[] | null;
  college_id: string | null;

  // Timing
  scheduled_at: string | null;

  // Status
  status: PushStatus;

  // Stats
  recipients_count: number | null;
  delivered_count: number;
  opened_count: number;
  clicked_count: number;
  failure_breakdown: Record<string, number> | null;

  // Metadata
  onesignal_id: string | null;
  created_by: string | null;
  created_at: string;
  sent_at: string | null;
}

export interface PushTemplate {
  id: string;
  name: string;
  title_template: string;
  body_template: string;
  default_deep_link: string | null;
  created_by: string | null;
  created_at: string;
}

/** Audience filter for the audience builder UI */
export interface AudienceFilter {
  registered_within_days?: number;
  active_within_days?: number;
  has_listings?: boolean;
  contribution_min?: number;
  contribution_max?: number;
}
