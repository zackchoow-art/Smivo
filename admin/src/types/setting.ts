/**
 * System settings / Feature Flag types.
 * Defined in 06_PRESENCE_AND_FLAGS_SPEC.md §3.
 */

export interface SystemSetting {
  key: string;
  value: boolean | string | number;
  description: string;
  updated_by: string | null;
  updated_at: string;
}

/** Known feature flag keys — kept in sync with system_settings initial data */
export const FLAG_KEYS = {
  PRESENCE_ENABLED: 'presence.enabled',
  PRESENCE_SHOW_ONLINE_DOT: 'presence.show_online_dot',
  MODERATION_STRICT_MODE: 'moderation.strict_mode',
  REGISTRATION_ENABLED: 'registration.enabled',
  WISHLIST_ENABLED: 'wishlist.enabled',
  WISHLIST_CROSS_SCHOOL: 'wishlist.cross_school',
  PLAZA_ENABLED: 'plaza.enabled',
  FEEDBACK_ENABLED: 'feedback.enabled',
  // Content filter (client-side)
  CONTENT_FILTER_ENABLED: 'content_filter.enabled',
  CONTENT_FILTER_WARN_ACTION: 'content_filter.warn_action',
  CONTENT_FILTER_BLOCK_ACTION: 'content_filter.block_action',
  // Backend review (server-side)
  BACKEND_REVIEW_ENABLED: 'backend_review.enabled',
  BACKEND_REVIEW_MODE: 'backend_review.mode',
} as const;
