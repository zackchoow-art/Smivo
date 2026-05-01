/**
 * Human-readable translations for audit log entries.
 * Converts raw action_type/target_type strings into natural language.
 */

/** Maps raw action_type values to human-readable descriptions */
const ACTION_TRANSLATIONS: Record<string, string> = {
  // Restriction / Ban actions
  create_restriction: 'Applied restriction to user',
  lift_restriction: 'Lifted restriction from user',
  create_ban: 'Banned user',
  lift_ban: 'Lifted user ban',

  // Listing moderation
  listing_approve: 'Approved listing',
  listing_reject: 'Rejected listing',
  listing_flag: 'Flagged listing for review',
  listing_remove: 'Removed listing',
  listing_restore: 'Restored listing',

  // Feedback actions
  resolve_feedback: 'Resolved user feedback',
  close_feedback: 'Closed user feedback',

  // Chat report actions
  resolve_report: 'Resolved chat report',
  dismiss_report: 'Dismissed chat report',

  // Push notifications
  send_push: 'Sent push notification',
  schedule_push: 'Scheduled push notification',
  cancel_push: 'Cancelled push notification',

  // System configuration
  update_config: 'Updated system configuration',
  toggle_feature: 'Toggled feature flag',
  update_dictionary: 'Updated dictionary entry',
  create_dictionary: 'Created dictionary entry',
  delete_dictionary: 'Deleted dictionary entry',

  // Sensitive words
  import_words: 'Imported sensitive words',
  create_word: 'Added sensitive word',
  delete_word: 'Deleted sensitive word',
  toggle_word: 'Toggled sensitive word',

  // User management
  update_user_role: 'Changed user role',
  block_user: 'Blocked user',
  unblock_user: 'Unblocked user',

  // Admin management
  create_admin: 'Created admin account',
  update_admin: 'Updated admin account',
  delete_admin: 'Removed admin account',

  // College/School management
  create_college: 'Added new school',
  update_college: 'Updated school info',
  toggle_college: 'Toggled school active status',
};

/** Maps raw target_type values to human-readable labels */
const TARGET_TRANSLATIONS: Record<string, string> = {
  user: 'User',
  user_ban: 'User Ban',
  user_feedback: 'Feedback',
  listing: 'Listing',
  chat_report: 'Chat Report',
  message: 'Message',
  push_job: 'Push Notification',
  system_config: 'System Config',
  feature_flag: 'Feature Flag',
  dictionary: 'Dictionary',
  sensitive_word: 'Sensitive Word',
  admin_user: 'Admin',
  college: 'School',
  order: 'Order',
};

/**
 * Translates an audit log action_type to a human-readable string.
 * Falls back to formatting the raw string if no translation exists.
 */
export function translateAction(actionType: string | null | undefined): string {
  if (!actionType) return 'Unknown Action';
  if (ACTION_TRANSLATIONS[actionType]) {
    return ACTION_TRANSLATIONS[actionType];
  }
  // Fallback: convert snake_case to Title Case
  return actionType
    .split('_')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

/**
 * Translates a target_type to a human-readable label.
 */
export function translateTarget(targetType: string | null | undefined): string {
  if (!targetType) return 'Unknown';
  if (TARGET_TRANSLATIONS[targetType]) {
    return TARGET_TRANSLATIONS[targetType];
  }
  return targetType
    .split('_')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

/**
 * Builds a full human-readable sentence for an audit log entry.
 */
export function translateAuditLog(log: {
  action: string;
  target_type: string;
  target_id: string | null;
  status_before: string | null;
  status_after: string | null;
  payload: Record<string, unknown> | null;
}): string {
  const action = translateAction(log.action);
  const target = translateTarget(log.target_type);

  let sentence = action;

  // Add target ID snippet for context
  if (log.target_id) {
    sentence += ` (${target} #${log.target_id.slice(0, 8)})`;
  }

  // Add status change if present
  if (log.status_before && log.status_after) {
    sentence += ` — ${log.status_before} → ${log.status_after}`;
  }

  // Add payload details for common actions
  if (log.payload) {
    if (log.action === 'create_restriction' && log.payload.scope) {
      sentence += ` [${log.payload.scope}]`;
    }
    if (log.action === 'send_push' && log.payload.title) {
      sentence += `: "${log.payload.title}"`;
    }
  }

  return sentence;
}
