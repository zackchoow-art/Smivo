/**
 * Carpool types — mirrors `carpool_trips` and `carpool_members` tables.
 * Used by admin dashboard for trip management and analytics.
 */

export type CarpoolTripStatus =
  | 'active'
  | 'inactive'
  | 'confirmed'
  | 'departed'
  | 'arrived'
  | 'completed'
  | 'cancelled';

export type CarpoolRole = 'driver' | 'organizer';

export type CarpoolMemberStatus = 'pending' | 'approved' | 'rejected' | 'left' | 'kicked';

export type CarpoolMemberRole = 'creator' | 'member';

export type LuggageLimit = 'none' | 'small' | 'medium' | 'large' | null;

export type ApprovalMode = 'auto' | 'manual';

/** A single carpool trip row (joined with creator profile) */
export interface CarpoolTrip {
  id: string;
  creator_id: string;
  school_id: string;
  role: CarpoolRole;
  departure_address: string;
  departure_lat: number | null;
  departure_lng: number | null;
  departure_place_id: string | null;
  departure_description: string | null;
  destination_address: string;
  destination_lat: number | null;
  destination_lng: number | null;
  destination_place_id: string | null;
  destination_description: string | null;
  departure_time: string;
  estimated_arrival_time: string | null;
  total_seats: number;
  available_seats: number;
  luggage_limit: LuggageLimit;
  approval_mode: ApprovalMode;
  status: CarpoolTripStatus;
  closing_time: string | null;
  note: string | null;
  estimated_total_price: number | null;
  actual_total_cost: number | null;
  settled_at: string | null;
  created_at: string;
  updated_at: string;
  // Nested join fields
  creator?: {
    id: string;
    display_name: string | null;
    email: string;
    avatar_url: string | null;
  } | null;
  school?: {
    id: string;
    name: string;
  } | null;
}

/** A carpool member row (joined with user profile) */
export interface CarpoolMember {
  id: string;
  trip_id: string;
  user_id: string;
  role: CarpoolMemberRole;
  status: CarpoolMemberStatus;
  joined_at: string | null;
  created_at: string;
  cancelled_at: string | null;
  cancel_lead_time_minutes: number | null;
  user?: {
    id: string;
    display_name: string | null;
    email: string;
    avatar_url: string | null;
  } | null;
}

/** Trip with nested members for detail view */
export interface CarpoolTripWithMembers extends CarpoolTrip {
  members: CarpoolMember[];
}

/** Analytics aggregation row for top locations */
export interface LocationCount {
  location: string;
  count: number;
}

/** Analytics aggregation row for time distribution */
export interface TimeSlotCount {
  slot: number; // 0-23 for hours, 0-6 for weekdays
  label: string;
  count: number;
}

/** Overall carpool analytics summary */
export interface CarpoolAnalyticsSummary {
  totalTrips: number;
  activeTrips: number;
  completedTrips: number;
  cancelledTrips: number;
  avgSeatUtilization: number;
  avgPrice: number;
  driverCount: number;
  organizerCount: number;
}

/** Carpool status display metadata */
export const CARPOOL_STATUS_META: Record<CarpoolTripStatus, {
  label: string;
  color: string;
  bgColor: string;
}> = {
  active:    { label: 'Active',    color: '#059669', bgColor: '#ecfdf5' },
  inactive:  { label: 'Full',      color: '#d97706', bgColor: '#fffbeb' },
  confirmed: { label: 'Confirmed', color: '#2563eb', bgColor: '#eff6ff' },
  departed:  { label: 'Departed',  color: '#0891b2', bgColor: '#ecfeff' },
  arrived:   { label: 'Arrived',   color: '#10b981', bgColor: '#ecfdf5' },
  completed: { label: 'Completed', color: '#7c3aed', bgColor: '#f5f3ff' },
  cancelled: { label: 'Cancelled', color: '#dc2626', bgColor: '#fef2f2' },
};

/** Carpool member status display metadata */
export const CARPOOL_MEMBER_STATUS_META: Record<CarpoolMemberStatus, {
  label: string;
  color: string;
  bgColor: string;
}> = {
  pending:  { label: 'Pending',  color: '#d97706', bgColor: '#fffbeb' },
  approved: { label: 'Approved', color: '#059669', bgColor: '#ecfdf5' },
  rejected: { label: 'Rejected', color: '#dc2626', bgColor: '#fef2f2' },
  left:     { label: 'Left',     color: '#6b7280', bgColor: '#f3f4f6' },
  kicked:   { label: 'Kicked',   color: '#9333ea', bgColor: '#faf5ff' },
};

/** Luggage limit display labels */
export const LUGGAGE_LABELS: Record<string, string> = {
  none:   'No Luggage',
  small:  'Small Only',
  medium: 'Medium',
  large:  'Large OK',
};
