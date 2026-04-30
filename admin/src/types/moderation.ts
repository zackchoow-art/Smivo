/**
 * Moderation types — covers drafts, notices, and the shopping cart workflow.
 * Core of the admin content review system defined in 04_ADMIN_WEB_SPEC.md §6.5.
 */

export type DraftTargetType = 'listing' | 'chat_report' | 'user_report' | 'feedback';
export type DraftDecision = 'approve' | 'reject' | 'takedown' | 'warn' | 'ban';

export interface ModerationDraft {
  id: string;
  admin_id: string;
  target_type: DraftTargetType;
  target_id: string;
  college_id: string;
  decision: DraftDecision;
  rule_violated: string | null;
  reason_detail: string | null;
  created_at: string;
  updated_at: string;
}

/** Draft with display info for the drawer UI */
export interface ModerationDraftWithInfo extends ModerationDraft {
  target_title: string;
  priority: string;
  due_at: string | null;
  admin_name: string;
}

export interface ListingModerationNotice {
  id: string;
  listing_id: string;
  user_id: string;
  action: 'approved' | 'rejected' | 'taken_down';
  reason: string | null;
  rule_violated: string | null;
  is_read: boolean;
  created_at: string;
}

/** Violation rules for the reject dialog */
export const VIOLATION_RULES = [
  { code: 'incomplete', label: '信息不完整 / Incomplete Information' },
  { code: 'fake_listing', label: '涉嫌虚假交易 / Suspected Fake Listing' },
  { code: 'community_violation', label: '违反校园社区规范 / Community Violation' },
  { code: 'prohibited_item', label: '禁售物品 / Prohibited Item' },
  { code: 'other', label: '其他 / Other' },
] as const;
