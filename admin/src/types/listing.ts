/**
 * Listing type — mirrors `listings` table with moderation extensions.
 * Defined in 04_ADMIN_WEB_SPEC.md §25.4.
 */

export type ListingType = 'sale' | 'rental';
export type ItemCondition = 'new' | 'like_new' | 'good' | 'fair' | 'poor';
export type ModerationStatus = 'auto_approved' | 'pending_review' | 'approved' | 'rejected' | 'taken_down';
export type ModerationPriority = 'urgent' | 'normal' | 'low';

export interface Listing {
  id: string;
  user_id: string;
  college_id: string;
  title: string;
  description: string | null;
  price: number;
  listing_type: ListingType;
  category: string;
  condition: ItemCondition;
  pickup_location: string | null;
  status: string;

  // Moderation fields
  moderation_status: ModerationStatus;
  moderation_priority: ModerationPriority;
  moderation_due_at: string | null;
  moderation_trigger: string | null;
  moderation_note: string | null;
  moderated_by: string | null;
  moderated_at: string | null;

  // Rental-specific
  daily_rate: number | null;
  weekly_rate: number | null;
  monthly_rate: number | null;
  deposit: number | null;

  // Stats
  view_count: number;
  save_count: number;

  created_at: string;
  updated_at: string;
}

export interface ListingImage {
  id: string;
  listing_id: string;
  image_url: string;
  sort_order: number;
  created_at: string;
}

/** Listing with images and seller info — used in moderation detail page */
export interface ListingWithDetails extends Listing {
  images: ListingImage[];
  seller: {
    id: string;
    display_name: string | null;
    email: string;
    avatar_url: string | null;
    created_at: string;
    listing_count: number;
    order_count: number;
    report_count: number;
    ban_count: number;
    risk_level: string;
  };
}
