/**
 * useImageModeration hook
 *
 * Manages:
 *   - Saving / checking API keys in encrypted platform_secrets
 *   - Reading monthly usage counters
 *   - Calling Edge Functions to test image moderation
 */
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';

const USAGE_QUERY_KEY = ['image-moderation-usage'] as const;
const SECRET_STATUS_KEY = (key: string) => ['platform-secret-status', key] as const;

// ── Types ──────────────────────────────────────────────────────

export interface ProviderUsage {
  count: number;
  limit: number | null;
}

export interface ModerationUsage {
  month: string;
  openai: ProviderUsage;
  google_vision: ProviderUsage;
}

export interface SecretStatus {
  exists: boolean;
  secret_key: string;
  last_updated: string | null;
}

export interface OpenAIResult {
  provider: 'openai';
  model: string;
  image_url: string;
  flagged: boolean;
  categories: Record<string, boolean>;
  category_scores: Record<string, number>;
  is_test: boolean;
}

export interface GoogleResult {
  provider: 'google_vision';
  model: string;
  image_url: string;
  flagged: boolean;
  reasons: string[];
  safe_search: {
    adult: string;
    spoof: string;
    medical: string;
    violence: string;
    racy: string;
  };
  usage_count: number;
  quota_remaining: number;
  monthly_limit: number;
  is_test: boolean;
}

// ── Hooks ──────────────────────────────────────────────────────

/** Fetch current month's API usage for both providers */
export function useModerationUsage() {
  return useQuery({
    queryKey: USAGE_QUERY_KEY,
    queryFn: async (): Promise<ModerationUsage> => {
      const { data, error } = await supabase.rpc('get_image_moderation_usage');
      if (error) throw error;
      return data as ModerationUsage;
    },
    refetchInterval: 30_000, // Refresh every 30s to show live counter
  });
}

/** Check if a secret key is saved (does NOT return the value) */
export function useSecretStatus(secretKey: string) {
  return useQuery({
    queryKey: SECRET_STATUS_KEY(secretKey),
    queryFn: async (): Promise<SecretStatus> => {
      const { data, error } = await supabase.rpc('check_platform_secret_exists', {
        p_key: secretKey,
      });
      if (error) throw error;
      return data as SecretStatus;
    },
  });
}

/** Save (upsert) a platform secret — encrypts before storing */
export function useSavePlatformSecret() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      key,
      value,
      description,
    }: {
      key: string;
      value: string;
      description?: string;
    }) => {
      const { data, error } = await supabase.rpc('save_platform_secret', {
        p_key:         key,
        p_value:       value,
        p_description: description ?? null,
      });
      if (error) throw error;
      return data;
    },
    onSuccess: (_data, variables) => {
      // Invalidate the status cache for this secret key
      queryClient.invalidateQueries({ queryKey: SECRET_STATUS_KEY(variables.key) });
    },
  });
}

/** Test OpenAI omni-moderation-latest via Edge Function */
export function useTestOpenAIModeration() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      text,
      imageUrls,
      isTest = false,
    }: {
      text?: string;
      imageUrls?: string[];
      isTest?: boolean;
    }): Promise<OpenAIResult> => {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) throw new Error('Not authenticated');

      const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string;
      const response = await fetch(
        `${supabaseUrl}/functions/v1/moderate-image-openai`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${session.access_token}`,
            'apikey': import.meta.env.VITE_SUPABASE_ANON_KEY as string,
          },
          body: JSON.stringify(isTest ? { test: true } : { text, image_urls: imageUrls }),
        }
      );

      const result = await response.json();
      if (!response.ok) throw new Error(result.error ?? 'OpenAI moderation failed');
      return result as OpenAIResult;
    },
    onSuccess: () => {
      // Refresh usage counter after each call
      queryClient.invalidateQueries({ queryKey: USAGE_QUERY_KEY });
    },
  });
}

/** Test Google Vision SafeSearch via Edge Function */
export function useTestGoogleVisionModeration() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      text,
      imageUrls,
      isTest = false,
    }: {
      text?: string;
      imageUrls?: string[];
      isTest?: boolean;
    }): Promise<GoogleResult> => {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) throw new Error('Not authenticated');

      const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string;
      const response = await fetch(
        `${supabaseUrl}/functions/v1/moderate-image-google`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${session.access_token}`,
            'apikey': import.meta.env.VITE_SUPABASE_ANON_KEY as string,
          },
          body: JSON.stringify(isTest ? { test: true } : { text, image_urls: imageUrls }),
        }
      );

      const result = await response.json();
      if (!response.ok) throw new Error(result.error ?? 'Google Vision moderation failed');
      return result as GoogleResult;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: USAGE_QUERY_KEY });
    },
  });
}
