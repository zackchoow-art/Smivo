/**
 * Hook for managing sensitive words with pagination, filtering, and batch ops.
 */
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { SensitiveWord } from '@/types';

export interface SensitiveWordFilters {
  category?: string;
  severity?: string;
  language?: string;
  source?: string;
  isActive?: boolean;
  search?: string;
}

const QUERY_KEY = ['sensitive-words'] as const;

/** Fetch paginated sensitive words */
export function useSensitiveWords(page: number, filters?: SensitiveWordFilters) {
  return useQuery({
    queryKey: [...QUERY_KEY, page, filters],
    queryFn: async (): Promise<{ data: SensitiveWord[]; count: number }> => {
      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;

      let query = supabase
        .from(TABLES.SENSITIVE_WORDS)
        .select('*', { count: 'exact' })
        .order('created_at', { ascending: false })
        .range(from, to);

      if (filters?.category) query = query.eq('category', filters.category);
      if (filters?.severity) query = query.eq('severity', filters.severity);
      if (filters?.language) query = query.eq('language', filters.language);
      if (filters?.source) query = query.eq('source', filters.source);
      if (filters?.isActive !== undefined) query = query.eq('is_active', filters.isActive);
      if (filters?.search) query = query.ilike('word', `%${filters.search}%`);

      const { data, error, count } = await query;
      if (error) throw error;
      return { data: (data ?? []) as SensitiveWord[], count: count ?? 0 };
    },
  });
}

/** Create a single word */
export function useCreateSensitiveWord() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (word: Partial<SensitiveWord>) => {
      const { error } = await supabase
        .from(TABLES.SENSITIVE_WORDS)
        .insert(word);
      if (error) throw error;
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  });
}

/** Update a word */
export function useUpdateSensitiveWord() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, ...updates }: Partial<SensitiveWord> & { id: string }) => {
      const { error } = await supabase
        .from(TABLES.SENSITIVE_WORDS)
        .update(updates)
        .eq('id', id);
      if (error) throw error;
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  });
}

/** Delete a word */
export function useDeleteSensitiveWord() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from(TABLES.SENSITIVE_WORDS)
        .delete()
        .eq('id', id);
      if (error) throw error;
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  });
}

/** Batch import words from CSV data */
export function useBatchImportWords() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (words: Partial<SensitiveWord>[]) => {
      const { error } = await supabase
        .from(TABLES.SENSITIVE_WORDS)
        .upsert(words, { onConflict: 'word,language' });
      if (error) throw error;
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  });
}

/** Batch toggle active status */
export function useBatchToggleWords() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ ids, is_active }: { ids: string[]; is_active: boolean }) => {
      const { error } = await supabase
        .from(TABLES.SENSITIVE_WORDS)
        .update({ is_active })
        .in('id', ids);
      if (error) throw error;
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  });
}
