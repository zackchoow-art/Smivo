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

// ── LDNOOBW Cloud Sync ──────────────────────────────────────────────

const LDNOOBW_BASE =
  'https://raw.githubusercontent.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/master';

export type ImportMode = 'strict' | 'recommended' | 'relaxed';

/**
 * Common casual words that are too mild to block in a college marketplace.
 * In 'recommended' mode these become severity=warn; in 'relaxed' mode they are skipped entirely.
 */
const MILD_WORDS = new Set([
  'ass', 'arse', 'bloody', 'boob', 'boobs', 'breasts', 'bugger', 'boner',
  'crap', 'damn', 'dammit', 'dick', 'douche', 'fart', 'hell', 'hump',
  'lust', 'pee', 'piss', 'poop', 'porn', 'sex', 'sexy', 'suck', 'tit',
  'tits', 'wank', 'whore', 'erotic', 'kinky', 'orgasm', 'vagina', 'penis',
  'testicle', 'testicles', 'butthole', 'butt', 'nude', 'nudes',
]);

/**
 * Fetch raw word list from LDNOOBW GitHub for a given language.
 * Returns plain array of lowercase trimmed words.
 */
async function fetchLdnoobwWords(lang: 'en' | 'zh'): Promise<string[]> {
  const res = await fetch(`${LDNOOBW_BASE}/${lang}`);
  if (!res.ok) throw new Error(`Failed to fetch LDNOOBW/${lang}: ${res.status}`);
  const text = await res.text();
  return text
    .split('\n')
    .map((w) => w.trim().toLowerCase())
    .filter((w) => w.length > 0);
}

/**
 * Fetch all existing words in the DB for a given language to compute the diff.
 * Uses a lightweight select to minimise payload.
 */
async function fetchExistingWords(lang?: 'en' | 'zh'): Promise<Set<string>> {
  let query = supabase
    .from(TABLES.SENSITIVE_WORDS)
    .select('word, language');
  if (lang) query = query.eq('language', lang);
  const { data } = await query;
  return new Set((data ?? []).map((r: any) => `${r.language}:${r.word}`));
}

export interface CloudSyncPreview {
  /** All words fetched from cloud, ready to import */
  words: Partial<SensitiveWord>[];
  /** Stats for the preview panel */
  stats: {
    totalFetched: number;
    alreadyInDb: number;
    newWords: number;
    byLanguage: { en: number; zh: number };
  };
}

/**
 * Build a CloudSyncPreview by fetching from LDNOOBW and diffing against the DB.
 * Does NOT write anything — the caller decides whether to import.
 */
export async function buildCloudSyncPreview(
  languages: ('en' | 'zh')[],
  mode: ImportMode,
): Promise<CloudSyncPreview> {
  // 1. Fetch from cloud (parallel)
  const fetched: { word: string; lang: 'en' | 'zh' }[] = [];
  await Promise.all(
    languages.map(async (lang) => {
      const words = await fetchLdnoobwWords(lang);
      words.forEach((w) => fetched.push({ word: w, lang }));
    }),
  );

  // 2. Fetch existing from DB
  const existing = await fetchExistingWords();

  // 3. Apply mode filter and build SensitiveWord objects
  const result: Partial<SensitiveWord>[] = [];
  let alreadyInDb = 0;

  for (const { word, lang } of fetched) {
    const key = `${lang}:${word}`;
    if (existing.has(key)) {
      alreadyInDb++;
      continue;
    }

    const isMild = MILD_WORDS.has(word);

    // Relaxed mode: skip mild words entirely
    if (mode === 'relaxed' && isMild) continue;

    result.push({
      word,
      category: 'general',
      severity: mode === 'strict' ? 'block' : isMild ? 'warn' : 'block',
      language: lang,
      source: 'api',
      is_active: true,
    });
  }

  const enCount = result.filter((w) => w.language === 'en').length;
  const zhCount = result.filter((w) => w.language === 'zh').length;

  return {
    words: result,
    stats: {
      totalFetched: fetched.length,
      alreadyInDb,
      newWords: result.length,
      byLanguage: { en: enCount, zh: zhCount },
    },
  };
}
