/**
 * Data dictionary types.
 * Maps to `system_dictionaries` table (migration 00038).
 * Each row is a single dictionary entry; rows with the same
 * dict_type form a "dictionary group" (e.g. order_status, rental_status).
 */

export interface DictItem {
  id: string;
  dict_type: string;
  dict_key: string;
  dict_value: string;
  description: string | null;
  extra: Record<string, unknown> | null;
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
  items: DictItem[];
}
