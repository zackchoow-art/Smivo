/**
 * Hook for managing system dictionaries.
 * Groups entries by dict_type for list view; supports CRUD per entry.
 */
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';
import type { DictItem, DictGroup } from '@/types';

const QUERY_KEY = ['dictionaries'] as const;

/** Fetch all dictionary entries, grouped by dict_type */
export function useDictionaries() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: async (): Promise<DictGroup[]> => {
      const { data, error } = await supabase
        .from(TABLES.SYSTEM_DICTIONARIES)
        .select('*')
        .order('dict_type')
        .order('display_order');

      if (error) throw error;

      // Group by dict_type
      const groups: Record<string, DictItem[]> = {};
      for (const item of (data ?? []) as DictItem[]) {
        if (!groups[item.dict_type]) groups[item.dict_type] = [];
        groups[item.dict_type]!.push(item);
      }

      return Object.entries(groups).map(([dict_type, items]) => ({
        dict_type,
        items,
      }));
    },
  });
}

/** Fetch entries for a specific dict_type */
export function useDictItems(dictType: string) {
  return useQuery({
    queryKey: ['dict-items', dictType],
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

/** Create a new dict entry */
export function useCreateDictItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (item: Partial<DictItem>) => {
      const { error } = await supabase
        .from(TABLES.SYSTEM_DICTIONARIES)
        .insert(item);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
      queryClient.invalidateQueries({ queryKey: ['dict-items'] });
    },
  });
}

/** Update a dict entry */
export function useUpdateDictItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, ...updates }: Partial<DictItem> & { id: string }) => {
      const { error } = await supabase
        .from(TABLES.SYSTEM_DICTIONARIES)
        .update(updates)
        .eq('id', id);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
      queryClient.invalidateQueries({ queryKey: ['dict-items'] });
    },
  });
}

/** Delete a dict entry */
export function useDeleteDictItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from(TABLES.SYSTEM_DICTIONARIES)
        .delete()
        .eq('id', id);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
      queryClient.invalidateQueries({ queryKey: ['dict-items'] });
    },
  });
}

/** Batch update display_order for drag-and-drop reordering */
export function useReorderDictItems() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (items: { id: string; display_order: number }[]) => {
      // Update each item's order sequentially
      for (const item of items) {
        const { error } = await supabase
          .from(TABLES.SYSTEM_DICTIONARIES)
          .update({ display_order: item.display_order })
          .eq('id', item.id);
        if (error) throw error;
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
      queryClient.invalidateQueries({ queryKey: ['dict-items'] });
    },
  });
}
