import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';

const QUERY_KEY = ['system-configs'] as const;

export interface SystemConfig {
  config_key: string;
  config_value: any;
  description: string;
}

export function useSystemConfigs() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: async () => {
      const { data, error } = await supabase
        .from(TABLES.SYSTEM_CONFIGS || 'system_configs')
        .select('*')
        .order('config_key');

      if (error) throw error;
      return (data ?? []) as SystemConfig[];
    },
  });
}

export function useUpdateSystemConfig() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      key,
      value,
      oldValue,
      adminId,
    }: {
      key: string;
      value: any;
      oldValue?: any;
      adminId: string;
    }) => {
      const { data, error } = await supabase
        .from(TABLES.SYSTEM_CONFIGS || 'system_configs')
        .update({ config_value: value })
        .eq('config_key', key)
        .select()
        .single();

      if (error) throw error;

      // Log to audit log
      await supabase.from(TABLES.ADMIN_AUDIT_LOGS).insert({
        admin_id: adminId,
        action_type: 'update_system_config',
        target_type: 'system_config',
        target_id: null,
        payload: { key, old_value: oldValue, new_value: value },
      });

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });
}
