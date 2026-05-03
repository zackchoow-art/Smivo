/**
 * Adapter hook for school-scoped dictionary data.
 *
 * school_categories, school_conditions, and pickup_locations each live in
 * their own tables (with school_id FK) and are the source of truth used by
 * the Flutter app. This hook exposes them via a unified DictItem interface
 * so DictionaryItemsPage can use the same UI regardless of the backing table.
 *
 * Mapping from native schema → DictItem:
 *   school_categories : slug → dict_key, name → dict_value, icon → extra.icon
 *   school_conditions : slug → dict_key, name → dict_value, description → description
 *   pickup_locations  : id   → dict_key, name → dict_value  (no slug in this table)
 */
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useSchoolScopeStore } from '@/stores/school-scope-store';
import type { DictItem, PlatformCategoryDefault, PlatformConditionDefault } from '@/types';

// ── Source identifiers ────────────────────────────────────────────────────────

export type SchoolDictSource = 'school_categories' | 'school_conditions' | 'pickup_locations';

/** Map dict_type code to its backing DB table */
export const SCHOOL_DICT_SOURCE_MAP: Record<string, SchoolDictSource> = {
  category:        'school_categories',
  condition:       'school_conditions',
  pickup_location: 'pickup_locations',
};

// ── Normalizers: raw DB row → DictItem ────────────────────────────────────────

function fromSchoolCategory(row: any, schoolId: string): DictItem {
  return {
    id:                  row.id,
    dict_type:           'category',
    dict_key:            row.slug,
    dict_value:          row.name,
    description:         null,
    extra:               row.icon ? { icon: row.icon } : null,
    display_order:       row.display_order,
    is_active:           row.is_active ?? true,
    access_level:        'school',
    // NOTE: Tracks whether this row was seeded from platform template.
    is_imported_default: row.is_imported_default ?? false,
    created_at:          row.created_at,
    updated_at:          row.updated_at,
    _school_id:          schoolId,
  } as any;
}

function fromSchoolCondition(row: any, schoolId: string): DictItem {
  return {
    id:                  row.id,
    dict_type:           'condition',
    dict_key:            row.slug,
    dict_value:          row.name,
    description:         row.description ?? null,
    extra:               null,
    display_order:       row.display_order,
    is_active:           row.is_active ?? true,
    access_level:        'school',
    is_imported_default: row.is_imported_default ?? false,
    created_at:          row.created_at,
    updated_at:          row.updated_at,
    _school_id:          schoolId,
  } as any;
}

function fromPickupLocation(row: any, schoolId: string): DictItem {
  return {
    id:            row.id,
    dict_type:     'pickup_location',
    // pickup_locations has no slug; use the uuid as the stable key
    dict_key:      row.id,
    dict_value:    row.name,
    description:   null,
    extra:         null,
    display_order: row.display_order,
    is_active:     row.is_active ?? true,
    access_level:  'school',
    created_at:    row.created_at,
    updated_at:    row.updated_at,
    _school_id:    schoolId,
  } as any;
}

// ── Audit log helper (duplicated here to avoid circular import) ───────────────

async function writeAuditLog(params: {
  adminId: string;
  action: string;
  targetType: string;
  targetId: string;
  payload: Record<string, unknown>;
}) {
  const { error } = await supabase.from('admin_audit_logs').insert({
    admin_id:    params.adminId,
    action:      params.action,
    target_type: params.targetType,
    target_id:   params.targetId,
    payload:     params.payload,
  });
  if (error) console.error('[useSchoolDictData] audit log failed:', error.message);
}

// ── Query ─────────────────────────────────────────────────────────────────────

/**
 * Fetch all items for a school-scoped dict type.
 * Requires currentCollegeId to be set in school-scope-store.
 */
export function useSchoolDictItems(dictType: string) {
  const { currentCollegeId } = useSchoolScopeStore();
  const source = SCHOOL_DICT_SOURCE_MAP[dictType];

  return useQuery({
    queryKey: ['school-dict', dictType, currentCollegeId],
    enabled:  !!source && !!currentCollegeId,
    queryFn: async (): Promise<DictItem[]> => {
      if (!source || !currentCollegeId) return [];

      const { data, error } = await supabase
        .from(source)
        .select('*')
        .eq('school_id', currentCollegeId)
        .order('display_order');

      if (error) throw error;

      const rows = data ?? [];
      switch (source) {
        case 'school_categories':
          return rows.map((r) => fromSchoolCategory(r, currentCollegeId));
        case 'school_conditions':
          return rows.map((r) => fromSchoolCondition(r, currentCollegeId));
        case 'pickup_locations':
          return rows.map((r) => fromPickupLocation(r, currentCollegeId));
      }
    },
  });
}

// ── Mutations ─────────────────────────────────────────────────────────────────

/** Create a new school-scoped entry and write audit log. */
export function useCreateSchoolDictItem(dictType: string) {
  const queryClient = useQueryClient();
  const { currentCollegeId } = useSchoolScopeStore();
  const source = SCHOOL_DICT_SOURCE_MAP[dictType];

  return useMutation({
    mutationFn: async ({
      item,
      adminId,
    }: {
      item: Partial<DictItem>;
      adminId: string;
    }) => {
      if (!source || !currentCollegeId) throw new Error('No school selected');

      let insertPayload: Record<string, unknown> = {
        school_id:     currentCollegeId,
        display_order: item.display_order ?? 99,
        is_active:     item.is_active ?? true,
      };

      switch (source) {
        case 'school_categories':
          insertPayload = {
            ...insertPayload,
            slug: item.dict_key,
            name: item.dict_value,
            icon: (item.extra as any)?.icon ?? null,
          };
          break;
        case 'school_conditions':
          insertPayload = {
            ...insertPayload,
            slug:        item.dict_key,
            name:        item.dict_value,
            description: item.description ?? null,
          };
          break;
        case 'pickup_locations':
          insertPayload = { ...insertPayload, name: item.dict_value };
          break;
      }

      const { data, error } = await supabase
        .from(source)
        .insert(insertPayload)
        .select()
        .single();

      if (error) throw error;

      await writeAuditLog({
        adminId,
        action:      'school_dict_create',
        targetType:  source,
        targetId:    data.id,
        payload:     { dict_type: dictType, school_id: currentCollegeId, ...insertPayload },
      });

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['school-dict', dictType, currentCollegeId] });
    },
  });
}

/** Update a school-scoped entry and write audit log. */
export function useUpdateSchoolDictItem(dictType: string) {
  const queryClient = useQueryClient();
  const { currentCollegeId } = useSchoolScopeStore();
  const source = SCHOOL_DICT_SOURCE_MAP[dictType];

  return useMutation({
    mutationFn: async ({
      id,
      adminId,
      ...updates
    }: Partial<DictItem> & { id: string; adminId: string }) => {
      if (!source || !currentCollegeId) throw new Error('No school selected');

      let updatePayload: Record<string, unknown> = {};

      switch (source) {
        case 'school_categories':
          if (updates.dict_value !== undefined) updatePayload.name = updates.dict_value;
          if (updates.extra !== undefined)       updatePayload.icon = (updates.extra as any)?.icon ?? null;
          if (updates.is_active !== undefined)   updatePayload.is_active = updates.is_active;
          if (updates.display_order !== undefined) updatePayload.display_order = updates.display_order;
          break;
        case 'school_conditions':
          if (updates.dict_value !== undefined)  updatePayload.name = updates.dict_value;
          if (updates.description !== undefined)  updatePayload.description = updates.description;
          if (updates.is_active !== undefined)    updatePayload.is_active = updates.is_active;
          if (updates.display_order !== undefined) updatePayload.display_order = updates.display_order;
          break;
        case 'pickup_locations':
          if (updates.dict_value !== undefined)  updatePayload.name = updates.dict_value;
          if (updates.is_active !== undefined)   updatePayload.is_active = updates.is_active;
          if (updates.display_order !== undefined) updatePayload.display_order = updates.display_order;
          break;
      }

      const { error } = await supabase.from(source).update(updatePayload).eq('id', id);
      if (error) throw error;

      await writeAuditLog({
        adminId,
        action:     'school_dict_update',
        targetType: source,
        targetId:   id,
        payload:    { dict_type: dictType, school_id: currentCollegeId, changes: updatePayload },
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['school-dict', dictType, currentCollegeId] });
    },
  });
}

/** Delete a school-scoped entry and write audit log. */
export function useDeleteSchoolDictItem(dictType: string) {
  const queryClient = useQueryClient();
  const { currentCollegeId } = useSchoolScopeStore();
  const source = SCHOOL_DICT_SOURCE_MAP[dictType];

  return useMutation({
    mutationFn: async ({ id, adminId }: { id: string; adminId: string }) => {
      if (!source || !currentCollegeId) throw new Error('No school selected');

      const { error } = await supabase.from(source).delete().eq('id', id);
      if (error) throw error;

      await writeAuditLog({
        adminId,
        action:     'school_dict_delete',
        targetType: source,
        targetId:   id,
        payload:    { dict_type: dictType, school_id: currentCollegeId },
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['school-dict', dictType, currentCollegeId] });
    },
  });
}

/** Batch reorder school-scoped entries and write audit log. */
export function useReorderSchoolDictItems(dictType: string) {
  const queryClient = useQueryClient();
  const { currentCollegeId } = useSchoolScopeStore();
  const source = SCHOOL_DICT_SOURCE_MAP[dictType];

  return useMutation({
    mutationFn: async ({
      items,
      adminId,
    }: {
      items: { id: string; display_order: number }[];
      adminId: string;
    }) => {
      if (!source || !currentCollegeId) throw new Error('No school selected');

      for (const item of items) {
        const { error } = await supabase
          .from(source)
          .update({ display_order: item.display_order })
          .eq('id', item.id);
        if (error) throw error;
      }

      await writeAuditLog({
        adminId,
        action:     'school_dict_reorder',
        targetType: source,
        targetId:   dictType,
        payload:    { dict_type: dictType, school_id: currentCollegeId, new_order: items.map((i) => i.id) },
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['school-dict', dictType, currentCollegeId] });
    },
  });
}

// ── Platform defaults ──────────────────────────────────────────────────────────

/** Fetch all active platform category defaults (the master template). */
export function usePlatformCategoryDefaults() {
  return useQuery({
    queryKey: ['platform-category-defaults'],
    queryFn: async (): Promise<any[]> => {
      const { data, error } = await supabase
        .from('platform_category_defaults')
        .select('*')
        .eq('is_active', true)
        .order('display_order');
      if (error) throw error;
      return data ?? [];
    },
  });
}

/** Fetch all active platform condition defaults (the master template). */
export function usePlatformConditionDefaults() {
  return useQuery({
    queryKey: ['platform-condition-defaults'],
    queryFn: async (): Promise<any[]> => {
      const { data, error } = await supabase
        .from('platform_condition_defaults')
        .select('*')
        .eq('is_active', true)
        .order('display_order');
      if (error) throw error;
      return data ?? [];
    },
  });
}

/**
 * Calls the import_platform_defaults(school_id) RPC.
 * Copies all active platform defaults into the school,
 * skipping slugs that already exist (idempotent).
 */
export function useImportPlatformDefaults() {
  const queryClient = useQueryClient();
  const { currentCollegeId } = useSchoolScopeStore();

  return useMutation({
    mutationFn: async ({ adminId }: { adminId: string }) => {
      if (!currentCollegeId) throw new Error('No school selected');

      const { data, error } = await supabase
        .rpc('import_platform_defaults', { p_school_id: currentCollegeId });
      if (error) throw error;

      // Write audit log for the import action
      await supabase.from('admin_audit_logs').insert({
        admin_id:    adminId,
        action:      'import_platform_defaults',
        target_type: 'school',
        target_id:   currentCollegeId,
        payload:     { school_id: currentCollegeId, result: data },
      });

      return data as { categories_imported: number; conditions_imported: number };
    },
    onSuccess: () => {
      // Invalidate both dict types so the list refreshes after import
      queryClient.invalidateQueries({ queryKey: ['school-dict', 'category', currentCollegeId] });
      queryClient.invalidateQueries({ queryKey: ['school-dict', 'condition', currentCollegeId] });
    },
  });
}
