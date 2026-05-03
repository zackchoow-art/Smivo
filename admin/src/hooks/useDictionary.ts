/**
 * Hook for managing system dictionaries.
 * Groups entries by dict_type for list view; supports CRUD per entry.
 *
 * All mutations write an audit log entry to admin_audit_logs so every change
 * is traceable. The caller must pass the admin's ID to mutations.
 *
 * RBAC enforcement summary (mirrors DB access_level column):
 *   system   → only platform_super_admin can mutate
 *   platform → platform_moderator and above can mutate
 *   school   → school_admin can mutate; platform roles are read-only
 */
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, ADMIN_ROLES } from '@/lib/constants';
import type { DictItem, DictGroup, DictTypeMetadata, DictAccessLevel } from '@/types';

// ── Registry ─────────────────────────────────────────────────────────────────
// Defines display metadata and extra-field schema for every supported dict_type.
// This is the single source of truth for what appears in the Dictionary UI.

export const DICT_REGISTRY: Record<string, DictTypeMetadata> = {
  // ── System-level (state machine core) ─────────────────────────────────────
  order_status: {
    title: 'Order Statuses',
    description: 'Lifecycle states for sale and rental orders',
    icon: '📦',
    access_level: 'system',
    extraFields: [
      { key: 'icon', label: 'Material Icon', type: 'text', placeholder: 'e.g. check_circle' },
      { key: 'color', label: 'Color (hex)', type: 'color', placeholder: '#059669' },
    ],
  },
  rental_status: {
    title: 'Rental Statuses',
    description: 'Extended lifecycle states for active rental periods',
    icon: '🔄',
    access_level: 'system',
    extraFields: [
      { key: 'icon', label: 'Material Icon', type: 'text', placeholder: 'e.g. play_circle' },
      { key: 'color', label: 'Color (hex)', type: 'color', placeholder: '#059669' },
    ],
  },
  listing_status: {
    title: 'Listing Statuses',
    description: 'Visibility and availability states for listed items',
    icon: '🏷️',
    access_level: 'system',
    extraFields: [
      { key: 'icon', label: 'Material Icon', type: 'text', placeholder: 'e.g. visibility' },
      { key: 'color', label: 'Color (hex)', type: 'color', placeholder: '#059669' },
    ],
  },
  transaction_type: {
    title: 'Transaction Types',
    description: 'Core transaction models: Sale vs. Rental',
    icon: '💳',
    access_level: 'system',
    extraFields: [
      { key: 'icon', label: 'Material Icon', type: 'text', placeholder: 'e.g. shopping_cart' },
    ],
  },

  // ── Platform-level (operational config) ───────────────────────────────────
  notification_type: {
    title: 'Notification Types',
    description: 'Event types that trigger push and in-app notifications',
    icon: '🔔',
    access_level: 'platform',
  },
  review_tag: {
    title: 'Review Tags',
    description: 'Labels users attach to buyer/seller reviews',
    icon: '⭐',
    access_level: 'platform',
  },
  feedback_resolution: {
    title: 'Feedback Resolutions',
    description: 'Admin resolution categories for user feedback, with auto-reply and points',
    icon: '✅',
    access_level: 'platform',
    extraFields: [
      { key: 'points', label: 'Contribution Points', type: 'number', placeholder: '0' },
      { key: 'reply', label: 'Auto-Reply Template', type: 'text', placeholder: 'Thank you for...' },
    ],
  },
  system_url: {
    title: 'System URLs',
    description: 'Global app links: website, policies, store listings',
    icon: '🔗',
    access_level: 'platform',
    extraFields: [
      { key: 'url', label: 'URL Override', type: 'url', placeholder: 'https://...' },
    ],
  },

  // ── School-level (campus-specific config) ─────────────────────────────────
  category: {
    title: 'Product Categories',
    description: 'Listing classifications shown on the home feed filter chips',
    icon: '📂',
    access_level: 'school',
    extraFields: [
      { key: 'icon', label: 'Material Icon', type: 'text', placeholder: 'e.g. chair' },
    ],
  },
  condition: {
    title: 'Item Conditions',
    description: 'Condition grades sellers apply to listings',
    icon: '🔍',
    access_level: 'school',
  },
  pickup_location: {
    title: 'Pickup Locations',
    description: 'Pre-approved campus meeting points for item handoff',
    icon: '📍',
    access_level: 'school',
  },
};

// ── Access-level helpers ──────────────────────────────────────────────────────

const ACCESS_LEVEL_META: Record<DictAccessLevel, {
  label: string;
  color: string;
  bgColor: string;
  description: string;
}> = {
  system: {
    label: 'System',
    color: 'var(--color-danger)',
    bgColor: 'var(--color-danger-light)',
    description: 'Only Platform Super Admin can edit',
  },
  platform: {
    label: 'Platform',
    color: 'var(--color-info)',
    bgColor: 'var(--color-info-light)',
    description: 'Platform Admin and above can edit',
  },
  school: {
    label: 'School',
    color: 'var(--color-success)',
    bgColor: 'var(--color-success-light)',
    description: 'School Admin can edit; Platform roles are read-only',
  },
};

export { ACCESS_LEVEL_META };

/** Returns true if the admin role is allowed to mutate entries at this access level. */
export function canEditLevel(role: string | undefined, level: DictAccessLevel): boolean {
  if (!role) return false;
  // sysadmin can edit everything (PLATFORM_SUPER_ADMIN is alias for 'sysadmin')
  if (role === 'sysadmin' || role === ADMIN_ROLES.PLATFORM_SUPER_ADMIN) return true;

  switch (level) {
    case 'system':
      // Only sysadmin (handled above)
      return false;
    case 'platform':
      // Platform admin and above
      return role === 'platform_admin' || role === ADMIN_ROLES.PLATFORM_MODERATOR;
    case 'school':
      // School admin only (school_reviewer is read-only)
      return role === 'school_admin' || role === ADMIN_ROLES.SCHOOL_ADMIN;
    default:
      return false;
  }
}

// ── Query keys ────────────────────────────────────────────────────────────────

const QUERY_KEY = ['dictionaries'] as const;
const ITEMS_KEY = (dictType: string) => ['dict-items', dictType] as const;

// ── Audit log helper ──────────────────────────────────────────────────────────

async function writeAuditLog(params: {
  adminId: string;
  action: string;
  targetType: string;
  targetId: string;
  payload: Record<string, unknown>;
}) {
  const { error } = await supabase.from(TABLES.ADMIN_AUDIT_LOGS).insert({
    admin_id: params.adminId,
    action: params.action,
    target_type: params.targetType,
    target_id: params.targetId,
    payload: params.payload,
  });
  if (error) {
    // NOTE: Audit log failure is non-fatal — log and continue.
    console.error('[useDictionary] audit log write failed:', error.message);
  }
}

// ── Queries ───────────────────────────────────────────────────────────────────

/** Fetch all dictionary entries, grouped by dict_type, ordered by access_level then type. */
export function useDictionaries() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: async (): Promise<DictGroup[]> => {
      const { data, error } = await supabase
        .from(TABLES.SYSTEM_DICTIONARIES)
        .select('*')
        .order('access_level')
        .order('dict_type')
        .order('display_order');

      if (error) throw error;

      // Group by dict_type, preserving access_level from the first item in each group.
      const groups: Record<string, DictItem[]> = {};
      for (const item of (data ?? []) as DictItem[]) {
        if (!groups[item.dict_type]) groups[item.dict_type] = [];
        groups[item.dict_type]!.push(item);
      }

      return Object.entries(groups).map(([dict_type, items]) => ({
        dict_type,
        // All items in a group share the same access_level; use first item's value.
        access_level: (items[0]?.access_level ?? 'platform') as DictAccessLevel,
        items,
      }));
    },
  });
}

/** Fetch entries for a specific dict_type, sorted by display_order. */
export function useDictItems(dictType: string) {
  return useQuery({
    queryKey: ITEMS_KEY(dictType),
    queryFn: async (): Promise<DictItem[]> => {
      const { data, error } = await supabase
        .from(TABLES.SYSTEM_DICTIONARIES)
        .select('*')
        .eq('dict_type', dictType)
        .order('display_order');

      if (error) throw error;
      return (data ?? []) as DictItem[];
    },
    enabled: !!dictType,
  });
}

// ── Mutations ─────────────────────────────────────────────────────────────────

/** Create a new dict entry and write an audit log record. */
export function useCreateDictItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      item,
      adminId,
    }: {
      item: Partial<DictItem>;
      adminId: string;
    }) => {
      const { data, error } = await supabase
        .from(TABLES.SYSTEM_DICTIONARIES)
        .insert(item)
        .select()
        .single();
      if (error) throw error;

      await writeAuditLog({
        adminId,
        action: 'dict_create',
        targetType: 'system_dictionary',
        targetId: data.id,
        payload: { dict_type: item.dict_type, dict_key: item.dict_key, dict_value: item.dict_value },
      });

      return data as DictItem;
    },
    onSuccess: (_, { item }) => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
      queryClient.invalidateQueries({ queryKey: ITEMS_KEY(item.dict_type ?? '') });
    },
  });
}

/** Update a dict entry (any field) and write an audit log record. */
export function useUpdateDictItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      id,
      adminId,
      dictType,
      ...updates
    }: Partial<DictItem> & { id: string; adminId: string; dictType: string }) => {
      const { error } = await supabase
        .from(TABLES.SYSTEM_DICTIONARIES)
        .update(updates)
        .eq('id', id);
      if (error) throw error;

      await writeAuditLog({
        adminId,
        action: 'dict_update',
        targetType: 'system_dictionary',
        targetId: id,
        payload: { dict_type: dictType, changes: updates },
      });
    },
    onSuccess: (_, { dictType }) => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
      queryClient.invalidateQueries({ queryKey: ITEMS_KEY(dictType) });
    },
  });
}

/** Delete a dict entry and write an audit log record. */
export function useDeleteDictItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      id,
      adminId,
      dictType,
      dictKey,
    }: {
      id: string;
      adminId: string;
      dictType: string;
      dictKey: string;
    }) => {
      const { error } = await supabase
        .from(TABLES.SYSTEM_DICTIONARIES)
        .delete()
        .eq('id', id);
      if (error) throw error;

      await writeAuditLog({
        adminId,
        action: 'dict_delete',
        targetType: 'system_dictionary',
        targetId: id,
        payload: { dict_type: dictType, dict_key: dictKey },
      });
    },
    onSuccess: (_, { dictType }) => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
      queryClient.invalidateQueries({ queryKey: ITEMS_KEY(dictType) });
    },
  });
}

/** Batch update display_order for drag-and-drop reordering, with a single audit log entry. */
export function useReorderDictItems() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      items,
      adminId,
      dictType,
    }: {
      items: { id: string; display_order: number }[];
      adminId: string;
      dictType: string;
    }) => {
      // NOTE: Sequential updates are used here because PostgREST does not
      // support a single batch-update with different values per row.
      // For typical dict sizes (<50 rows) the latency is acceptable.
      for (const item of items) {
        const { error } = await supabase
          .from(TABLES.SYSTEM_DICTIONARIES)
          .update({ display_order: item.display_order })
          .eq('id', item.id);
        if (error) throw error;
      }

      await writeAuditLog({
        adminId,
        action: 'dict_reorder',
        targetType: 'system_dictionary',
        targetId: dictType,
        payload: { dict_type: dictType, new_order: items.map((i) => i.id) },
      });
    },
    onSuccess: (_, { dictType }) => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
      queryClient.invalidateQueries({ queryKey: ITEMS_KEY(dictType) });
    },
  });
}
