/**
 * Hook for managing system_settings (Feature Flags).
 * Provides CRUD operations against the system_settings table.
 */
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';
import type { SystemSetting } from '@/types';

const QUERY_KEY = ['feature-flags'] as const;

/** Fetch all system settings */
export function useFeatureFlags() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: async (): Promise<SystemSetting[]> => {
      const { data, error } = await supabase
        .from(TABLES.SYSTEM_SETTINGS)
        .select('*')
        .order('key');

      if (error) throw error;
      return data ?? [];
    },
  });
}

/** Toggle a single feature flag value */
export function useToggleFlag() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ key, value }: { key: string; value: boolean }) => {
      const { error } = await supabase
        .from(TABLES.SYSTEM_SETTINGS)
        .update({
          value: JSON.stringify(value),
          updated_at: new Date().toISOString(),
        })
        .eq('key', key);

      if (error) throw error;
    },
    // Optimistic update for instant UI feedback
    onMutate: async ({ key, value }) => {
      await queryClient.cancelQueries({ queryKey: QUERY_KEY });

      const previous = queryClient.getQueryData<SystemSetting[]>(QUERY_KEY);

      queryClient.setQueryData<SystemSetting[]>(QUERY_KEY, (old) =>
        old?.map((s) =>
          s.key === key ? { ...s, value: JSON.stringify(value) } : s
        ) ?? []
      );

      return { previous };
    },
    onError: (_err, _vars, context) => {
      // Roll back on error
      if (context?.previous) {
        queryClient.setQueryData(QUERY_KEY, context.previous);
      }
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });
}
