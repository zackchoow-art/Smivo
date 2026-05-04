/**
 * Hook for managing admin roles via the unified admin_roles table.
 * Replaces the old admin_users + admin_school_scopes pattern.
 */
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';
import type { AdminRoleRecord, AdminUserInfo, AdminRoleName } from '@/types';

const QUERY_KEY = ['admins'] as const;

/** Role hierarchy priority for sorting */
const ROLE_PRIORITY: Record<AdminRoleName, number> = {
  school_reviewer: 1,
  school_admin: 2,
  platform_reviewer: 3,
  platform_admin: 4,
  sysadmin: 5,
};

/** Fetch all admin role records, grouped by user */
export function useAdmins() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: async (): Promise<AdminUserInfo[]> => {
      // Fetch all admin role records with user profiles
      const { data: roleRecords, error: roleError } = await supabase
        .from(TABLES.ADMIN_ROLES)
        .select(`
          *,
          user_profiles!inner(email, display_name, avatar_url),
          schools(name)
        `)
        .order('created_at', { ascending: false });

      if (roleError) throw roleError;

      // Group by user_id
      const userMap = new Map<string, AdminUserInfo>();

      for (const row of (roleRecords ?? [])) {
        const userProfile = row.user_profiles as { email: string; display_name: string | null; avatar_url: string | null } | null;
        const school = row.schools as { name: string } | null;
        const roleRecord: AdminRoleRecord = {
          id: row.id,
          user_id: row.user_id,
          role: row.role,
          scope_type: row.scope_type,
          scope_id: row.scope_id,
          is_active: row.is_active,
          created_at: row.created_at,
          updated_at: row.updated_at,
        };

        if (!userMap.has(row.user_id)) {
          userMap.set(row.user_id, {
            user_id: row.user_id,
            display_name: userProfile?.display_name ?? null,
            email: userProfile?.email ?? '',
            avatar_url: userProfile?.avatar_url ?? null,
            roles: [],
            highest_role: null,
            school_names: [],
          });
        }

        const user = userMap.get(row.user_id)!;
        user.roles.push(roleRecord);

        // Track school names for display
        if (school?.name && !user.school_names.includes(school.name)) {
          user.school_names.push(school.name);
        }
      }

      // Compute highest_role for each user
      for (const user of userMap.values()) {
        const active = user.roles.filter((r) => r.is_active);
        if (active.length > 0) {
          user.highest_role = active.reduce<AdminRoleName>((best, r) => {
            return (ROLE_PRIORITY[r.role] ?? 0) > (ROLE_PRIORITY[best] ?? 0) ? r.role : best;
          }, active[0].role);
        }
      }

      return Array.from(userMap.values());
    },
  });
}

/** Search user_profiles to find potential admin candidates */
export function useSearchUsers(query: string) {
  return useQuery({
    queryKey: ['search-users', query],
    queryFn: async () => {
      const { data, error } = await supabase
        .from(TABLES.USER_PROFILES)
        .select('id, display_name, email, avatar_url')
        .or(`display_name.ilike.%${query}%,email.ilike.%${query}%`)
        .limit(10);

      if (error) throw error;
      return data ?? [];
    },
    enabled: query.length >= 2,
  });
}

/** Create a new admin role assignment */
export function useCreateAdminRole() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      userId,
      role,
      scopeType,
      scopeId,
    }: {
      userId: string;
      role: AdminRoleName;
      scopeType: 'platform' | 'school';
      scopeId?: string | null;
    }) => {
      const { error } = await supabase
        .from(TABLES.ADMIN_ROLES)
        .insert({
          user_id: userId,
          role,
          scope_type: scopeType,
          scope_id: scopeType === 'platform' ? null : scopeId,
          is_active: true,
        });

      if (error) throw error;
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  });
}

/** Update an existing admin role record */
export function useUpdateAdminRole() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ roleId, role, isActive }: { roleId: string; role?: AdminRoleName; isActive?: boolean }) => {
      const updates: Record<string, unknown> = {};
      if (role !== undefined) updates.role = role;
      if (isActive !== undefined) updates.is_active = isActive;
      updates.updated_at = new Date().toISOString();

      const { error } = await supabase
        .from(TABLES.ADMIN_ROLES)
        .update(updates)
        .eq('id', roleId);
      if (error) throw error;
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  });
}

/** Delete a specific admin role record */
export function useDeleteAdminRole() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ roleId }: { roleId: string }) => {
      const { error } = await supabase
        .from(TABLES.ADMIN_ROLES)
        .delete()
        .eq('id', roleId);
      if (error) throw error;
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  });
}

/** Remove ALL admin roles for a user */
export function useRemoveAdmin() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ userId }: { userId: string }) => {
      const { error } = await supabase
        .from(TABLES.ADMIN_ROLES)
        .delete()
        .eq('user_id', userId);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
    onError: (error: Error) => {
      console.error('Error revoking admin access:', error);
    },
  });
}
