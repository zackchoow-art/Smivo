/**
 * Hook for managing colleges (schools) data.
 * Provides CRUD operations and seed_school_defaults RPC call.
 */
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';
import type { College } from '@/types';

const QUERY_KEY = ['colleges'] as const;

/** Fetch all schools */
export function useColleges() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: async (): Promise<College[]> => {
      const { data, error } = await supabase
        .from(TABLES.COLLEGES)
        .select('*')
        .order('name');

      if (error) throw error;
      return data ?? [];
    },
  });
}

/** Create a new school */
export function useCreateCollege() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (college: Partial<College>) => {
      const { data, error } = await supabase
        .from(TABLES.COLLEGES)
        .insert(college)
        .select()
        .single();

      if (error) throw error;

      // Seed default categories, conditions, and pickup locations
      if (data) {
        const { error: seedError } = await supabase
          .rpc('seed_school_defaults', { p_school_id: data.id });

        if (seedError) {
          console.warn('Failed to seed defaults:', seedError);
        }
      }

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });
}

/** Update an existing school */
export function useUpdateCollege() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, ...updates }: Partial<College> & { id: string }) => {
      const { error } = await supabase
        .from(TABLES.COLLEGES)
        .update({ ...updates, updated_at: new Date().toISOString() })
        .eq('id', id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });
}

/** Toggle school active status */
export function useToggleCollegeActive() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, is_active }: { id: string; is_active: boolean }) => {
      const { error } = await supabase
        .from(TABLES.COLLEGES)
        .update({ is_active, updated_at: new Date().toISOString() })
        .eq('id', id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });
}
