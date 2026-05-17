/**
 * Barrel export for all admin types.
 */

export type { College } from './college';
export type { AdminRoleRecord, AdminRoleName, AdminUserInfo } from './admin-user';
export type { UserProfile, UserProfileWithRisk, UserStatus, RiskLevel } from './user-profile';
export type { Listing, ListingImage, ListingWithDetails, ListingType, ItemCondition, ModerationStatus, ModerationPriority } from './listing';
export type { ModerationDraft, ModerationDraftWithInfo, ListingModerationNotice, DraftTargetType, DraftDecision } from './moderation';
export type { UserFeedback, FeedbackWithUser, ContributionScore, UserBadge, FeedbackCategory, FeedbackStatus, FeedbackJudgment } from './feedback';
export type { PushJob, PushTemplate, AudienceFilter, PushAudienceType, PushStatus, PushChannel } from './push';
export type { UserReport, ReportWithUsers, ReportReason, ReportStatus, ReportTargetType, ReportResolution } from './report';
export type { UserBan, BanWithUser, BanType, BanStatus } from './ban';
export type { DictItem, DictGroup, DictTypeMetadata, DictAccessLevel, PlatformCategoryDefault, PlatformConditionDefault } from './dict';
export type { SystemSetting } from './setting';
export type { AuditLog, AuditLogWithAdmin } from './audit-log';
export type { SensitiveWord, SensitiveWordLang, SensitiveWordSeverity, SensitiveWordSource } from './sensitive-word';
export type { Order, OrderStatus, RentalStatus } from './order';
export type {
  CarpoolTrip, CarpoolMember, CarpoolTripWithMembers,
  CarpoolTripStatus, CarpoolRole, CarpoolMemberStatus, CarpoolMemberRole,
  LuggageLimit, ApprovalMode,
  LocationCount, TimeSlotCount, CarpoolAnalyticsSummary,
} from './carpool';

// Re-export constants
export { VIOLATION_RULES } from './moderation';
export { BADGE_DEFINITIONS } from './feedback';
export { FLAG_KEYS } from './setting';
export { CARPOOL_STATUS_META, CARPOOL_MEMBER_STATUS_META, LUGGAGE_LABELS } from './carpool';
