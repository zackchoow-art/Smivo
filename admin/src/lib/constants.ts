/**
 * Admin Web application-level constants.
 * Mirrors database table names and API paths defined in 04_ADMIN_WEB_SPEC.md §24.
 */

// ── Database Table Names ──
export const TABLES = {
  // Core multi-tenant
  // NOTE: In the DB this table is called 'schools', not 'colleges'
  COLLEGES: 'schools',
  ADMIN_USERS: 'admin_users',
  ADMIN_SCHOOL_SCOPES: 'admin_school_scopes',

  // Business tables
  USER_PROFILES: 'user_profiles',
  LISTINGS: 'listings',
  LISTING_IMAGES: 'listing_images',
  ORDERS: 'orders',
  CHAT_ROOMS: 'chat_rooms',
  MESSAGES: 'messages',

  // Admin infrastructure
  ADMIN_AUDIT_LOGS: 'admin_audit_logs',
  SYSTEM_SETTINGS: 'system_settings',
  // NOTE: Uses system_dictionaries from migration 00038
  SYSTEM_DICTIONARIES: 'system_dictionaries',
  SENSITIVE_WORDS: 'sensitive_words',
  SYSTEM_CONFIGS: 'system_configs',

  // Moderation
  MODERATION_DRAFTS: 'moderation_drafts',
  LISTING_MODERATION_NOTICES: 'listing_moderation_notices',

  // User governance
  USER_BANS: 'user_bans',
  // NOTE: Uses content_reports from migration 00044
  CONTENT_REPORTS: 'content_reports',

  // Feedback & contribution
  USER_FEEDBACKS: 'user_feedbacks',
  CONTRIBUTION_LEDGER: 'contribution_ledger',
  // NOTE: user_badges not yet created — future migration

  // Push
  PUSH_JOBS: 'push_jobs',
  PUSH_TEMPLATES: 'push_templates',

  // Presence
  USER_HEARTBEATS: 'user_heartbeats',
  HOURLY_ACTIVE_USERS: 'hourly_active_users',
} as const;

// ── Admin Roles (5-level hierarchy, migration 00067) ──
export const ADMIN_ROLES = {
  // Platform scope — cross-school
  SYSADMIN:           'sysadmin',           // Only one; full control
  PLATFORM_ADMIN:     'platform_admin',     // Read/write across all schools
  PLATFORM_REVIEWER:  'platform_reviewer',  // Read-only across all schools
  // School scope — per-school only
  SCHOOL_ADMIN:       'school_admin',       // Read/write within their school(s)
  SCHOOL_REVIEWER:    'school_reviewer',    // Read-only within their school(s)
  // Legacy aliases (keep for backward compat with older code)
  PLATFORM_SUPER_ADMIN: 'sysadmin',
  PLATFORM_MODERATOR:   'platform_admin',
} as const;

/** Human-readable label for each admin role */
export const ADMIN_ROLE_LABELS: Record<string, string> = {
  sysadmin:           'Super Admin',
  platform_admin:     'Platform Admin',
  platform_reviewer:  'Platform Reviewer',
  school_admin:       'School Admin',
  school_reviewer:    'School Reviewer',
};

// ── Moderation Statuses ──
export const MODERATION_STATUS = {
  PENDING_REVIEW: 'pending_review',
  APPROVED: 'approved',
  REJECTED: 'rejected',
  AUTO_APPROVED: 'auto_approved',
  TAKEN_DOWN: 'taken_down',
} as const;

// ── Moderation Priorities ──
export const MODERATION_PRIORITY = {
  URGENT: 'urgent',     // 4h SLA
  NORMAL: 'normal',     // 24h SLA
  LOW: 'low',           // 72h SLA
} as const;

// ── Draft Decisions ──
export const DRAFT_DECISIONS = {
  APPROVE: 'approve',
  REJECT: 'reject',
  TAKEDOWN: 'takedown',
  WARN: 'warn',
  BAN: 'ban',
} as const;

// ── Feedback Judgments ──
export const FEEDBACK_JUDGMENTS = {
  CONFIRMED_BUG: 'confirmed_bug',
  VALID_SUGGESTION: 'valid_suggestion',
  DUPLICATE: 'duplicate',
  INVALID: 'invalid',
  ACCEPTED_IMPLEMENTED: 'accepted_implemented',
} as const;

// ── Contribution Points per Judgment ──
export const CONTRIBUTION_POINTS: Record<string, number> = {
  confirmed_bug: 10,
  valid_suggestion: 5,
  duplicate: 1,
  invalid: 0,
  accepted_implemented: 30,
} as const;

// ── Ban Types ──
export const BAN_TYPES = {
  TEMPORARY: 'temporary',
  PERMANENT: 'permanent',
} as const;

// ── Restriction Scopes ──
// Each scope can be applied independently to a user.
export const RESTRICTION_SCOPES = {
  CHAT_MUTE: 'chat_mute',
  LISTING_BAN: 'listing_ban',
  FEEDBACK_BAN: 'feedback_ban',
  ACCOUNT_FREEZE: 'account_freeze',
} as const;

/** Display metadata for each restriction scope */
export const RESTRICTION_SCOPE_META: Record<string, {
  label: string;
  description: string;
  icon: string;
  color: string;
  bgColor: string;
}> = {
  chat_mute: {
    label: 'Chat Mute',
    description: 'Cannot send chat messages. Other users see a "muted" notice.',
    icon: '🔇',
    color: '#e67700',
    bgColor: '#fff3cd',
  },
  listing_ban: {
    label: 'Listing Ban',
    description: 'Cannot create or edit listings.',
    icon: '🚫',
    color: '#c92a2a',
    bgColor: '#ffe3e3',
  },
  feedback_ban: {
    label: 'Feedback Ban',
    description: 'Cannot submit feedback to prevent abuse.',
    icon: '📝',
    color: '#5c7cfa',
    bgColor: '#dbe4ff',
  },
  account_freeze: {
    label: 'Account Freeze',
    description: 'Full account suspension. User cannot log in.',
    icon: '❄️',
    color: '#495057',
    bgColor: '#e9ecef',
  },
} as const;

// ── Push Job Statuses ──
export const PUSH_STATUS = {
  DRAFT: 'draft',
  SCHEDULED: 'scheduled',
  SENDING: 'sending',
  SENT: 'sent',
  FAILED: 'failed',
  CANCELLED: 'cancelled',
} as const;

// ── Report Reasons ──
export const REPORT_REASONS = {
  SPAM: 'spam',
  HARASSMENT: 'harassment',
  SCAM: 'scam',
  NSFW: 'nsfw',
  OTHER: 'other',
} as const;

// ── Sensitive Word Severities ──
export const SENSITIVE_SEVERITY = {
  BLOCK: 'block',
  REVIEW: 'review',
  MASK: 'mask',
} as const;

// ── Pagination ──
export const DEFAULT_PAGE_SIZE = 20;
export const MAX_PAGE_SIZE = 100;

// ── SLA Durations (hours) ──
export const SLA_HOURS: Record<string, number> = {
  urgent: 4,
  normal: 24,
  low: 72,
} as const;

// ── LocalStorage Keys ──
export const LS_KEYS = {
  LAST_SCHOOL: 'smivo_admin_last_school',
  SIDEBAR_COLLAPSED: 'smivo_admin_sidebar_collapsed',
  DARK_MODE: 'smivo_admin_dark_mode',
} as const;
