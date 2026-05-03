/**
 * Hook for managing admin users and their school scopes.
 */
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';
import type { AdminUser, AdminSchoolScope, AdminUserWithScopes } from '@/types';

const QUERY_KEY = ['admins'] as const;

/** Fetch all admin users with their school scopes */
export function useAdmins() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: async (): Promise<AdminUserWithScopes[]> => {
      // Fetch admin users
      const { data: admins, error: adminError } = await supabase
        .from(TABLES.ADMIN_USERS)
        .select('*')
        .order('created_at', { ascending: false });

      if (adminError) throw adminError;

      // Fetch all scopes
      const { data: scopes, error: scopeError } = await supabase
        .from(TABLES.ADMIN_SCHOOL_SCOPES)
        .select('*');

      if (scopeError) throw scopeError;

      // Fetch school names for display
      const { data: schools, error: schoolError } = await supabase
        .from(TABLES.COLLEGES)
        .select('id, name');

      if (schoolError) throw schoolError;

      const schoolMap = new Map((schools ?? []).map((s) => [s.id, s.name]));

      // Merge scopes into admin records
      return ((admins ?? []) as AdminUser[]).map((admin) => {
        const adminScopes = ((scopes ?? []) as AdminSchoolScope[])
          .filter((s) => s.admin_user_id === admin.user_id);
        return {
          ...admin,
          scopes: adminScopes,
          college_names: adminScopes.map((s) => schoolMap.get(s.college_id) ?? s.college_id),
        };
      });
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

/** Create a new admin user */
export function useCreateAdmin() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      userId,
      role,
      displayName,
      email,
      collegeIds,
    }: {
      userId: string;
      role: string;
      displayName: string;
      email: string;
      collegeIds: string[];
    }) => {
      // Insert admin_users
      const { error: adminError } = await supabase
        .from(TABLES.ADMIN_USERS)
        .insert({
          user_id: userId,
          role,
          display_name: displayName,
          email,
          is_active: true,
        });

      if (adminError) throw adminError;

      // Insert school scopes
      if (collegeIds.length > 0) {
        const scopeRows = collegeIds.map((cid) => ({
          admin_user_id: userId,
          college_id: cid,
        }));
        const { error: scopeError } = await supabase
          .from(TABLES.ADMIN_SCHOOL_SCOPES)
          .insert(scopeRows);

        if (scopeError) throw scopeError;
      }
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  });
}

/** Update admin role */
export function useUpdateAdminRole() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ userId, role }: { userId: string; role: string }) => {
      const { error } = await supabase
        .from(TABLES.ADMIN_USERS)
        .update({ role, updated_at: new Date().toISOString() })
        .eq('user_id', userId);
      if (error) throw error;
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  });
}

/** Toggle admin active status */
export function useToggleAdminActive() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ userId, isActive }: { userId: string; isActive: boolean }) => {
      const { error } = await supabase
        .from(TABLES.ADMIN_USERS)
        .update({ is_active: isActive, updated_at: new Date().toISOString() })
        .eq('user_id', userId);
      if (error) throw error;
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  });
}

/** Remove admin privileges completely */
export function useRemoveAdmin() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ userId }: { userId: string }) => {
      const { error } = await supabase
        .from(TABLES.ADMIN_USERS)
        .delete()
        .eq('user_id', userId);
      if (error) throw error;
    },
    onSuccess: () => {
      // toast.success('Admin privileges revoked'); // toast not defined here
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
    onError: (error: any) => {
      console.error('Error revoking admin access:', error);
      // toast.error(error.message || 'Failed to revoke admin access');
    },
  });
}

/** Update school scopes for an admin */
export function useUpdateAdminScopes() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ userId, collegeIds }: { userId: string; collegeIds: string[] }) => {
      // Delete existing scopes
      const { error: delError } = await supabase
        .from(TABLES.ADMIN_SCHOOL_SCOPES)
        .delete()
        .eq('admin_user_id', userId);
      if (delError) throw delError;

      // Insert new scopes
      if (collegeIds.length > 0) {
        const rows = collegeIds.map((cid) => ({
          admin_user_id: userId,
          college_id: cid,
        }));
        const { error: insError } = await supabase
          .from(TABLES.ADMIN_SCHOOL_SCOPES)
          .insert(rows);
        if (insError) throw insError;
      }
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  });
}
