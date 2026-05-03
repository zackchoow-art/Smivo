/**
 * Data dictionary types.
 * Maps to `system_dictionaries` table (migration 00038 + 00065).
 * Each row is a single dictionary entry; rows with the same
 * dict_type form a "dictionary group" (e.g. order_status, rental_status).
 */

/** Three-tier RBAC access level for each dictionary group. */
export type DictAccessLevel = 'system' | 'platform' | 'school';

export interface DictItem {
  id: string;
  dict_type: string;
  dict_key: string;
  dict_value: string;
  description: string | null;
  extra: Record<string, unknown> | null;
  display_order: number;
  is_active: boolean;
  /** Added in migration 00065. Controls who can edit this entry. */
  access_level: DictAccessLevel;
  /** Added in migration 00077. True when seeded from platform defaults. School admins cannot edit. */
  is_imported_default?: boolean;
  created_at: string;
  updated_at: string;
}

/** Platform-level template record for categories (migration 00077). */
export interface PlatformCategoryDefault {
  id: string;
  slug: string;
  name: string;
  icon: string | null;
  display_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

/** Platform-level template record for conditions (migration 00077). */
export interface PlatformConditionDefault {
  id: string;
  slug: string;
  name: string;
  description: string | null;
  display_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

/**
 * Virtual grouping — constructed client-side by grouping DictItems
 * by their dict_type. Not a separate DB table.
 */
export interface DictGroup {
  dict_type: string;
  access_level: DictAccessLevel;
  items: DictItem[];
}

/** Registry metadata for each dict_type — defines display info and field schema. */
export interface DictTypeMetadata {
  title: string;
  description: string;
  icon: string;
  access_level: DictAccessLevel;
  /** Extra fields beyond key/value/description (e.g. points, reply for feedback_resolution) */
  extraFields?: Array<{
    key: string;
    label: string;
    type: 'text' | 'number' | 'color' | 'url';
    placeholder?: string;
  }>;
}
