import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { 
  ReportWithUsers, 
  ReportStatus, 
  ReportReason,
  ReportResolution
} from '@/types/report';

const QUERY_KEY = ['chat-reports'] as const;

export interface ChatReportFilters {
  status?: ReportStatus;
  reason?: ReportReason;
}

/**
 * Hook for listing chat reports.
 * Filters by target_type = 'message'.
 */
export function useChatReports(page: number, filters: ChatReportFilters = {}) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'list', page, filters],
    queryFn: async () => {
      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;

      // NOTE: We use a RPC or a complex select to get reporter/reported names if needed,
      // but for now we'll do a basic join if RLS allows or handle it in the view.
      // Migration 00044 introduced content_reports.
      let query = supabase
        .from(TABLES.CONTENT_REPORTS)
        .select(`
          *,
          reporter:user_profiles!reporter_id(display_name, email),
          reported:user_profiles!reported_user_id(display_name, email)
        `, { count: 'exact' })
        .not('chat_room_id', 'is', null)   // NOTE: chat reports have a chat_room_id
        .range(from, to)
        .order('created_at', { ascending: false });

      if (filters.status) {
        query = query.eq('status', filters.status);
      }
      if (filters.reason) {
        query = query.eq('reason', filters.reason);
      }

      const { data, error, count } = await query;
      if (error) throw error;

      // Map join results to the ReportWithUsers interface
      const mappedData: ReportWithUsers[] = (data || []).map((item: any) => ({
        ...item,
        reason: item.reason_category || 'other',
        detail: item.reason,
        reporter_name: item.reporter?.display_name || null,
        reporter_email: item.reporter?.email || '',
        reported_name: item.reported?.display_name || null,
        reported_email: item.reported?.email || '',
        message_preview: item.reason // Assuming reason contains message content for chat reports
      }));

      return {
        data: mappedData,
        totalCount: count || 0,
      };
    },
  });
}

/**
 * Hook for a single chat report detail.
 */
export function useChatReport(id: string | undefined) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'detail', id],
    queryFn: async () => {
      if (!id) return null;
      const { data, error } = await supabase
        .from(TABLES.CONTENT_REPORTS)
        .select(`
          *,
          reporter:user_profiles!reporter_id(display_name, email, avatar_url),
          reported:user_profiles!reported_user_id(display_name, email, avatar_url, school_id)
        `)
        .eq('id', id)
        .single();

      if (error) throw error;

      const mapped: ReportWithUsers = {
        ...data,
        reason: data.reason_category || 'other', // Map DB reason_category to Frontend reason
        detail: data.reason, // Map DB reason to Frontend detail
        reporter_name: data.reporter?.display_name || null,
        reporter_email: data.reporter?.email || '',
        reporter_avatar: data.reporter?.avatar_url || null,
        reported_name: data.reported?.display_name || null,
        reported_email: data.reported?.email || '',
        reported_avatar: data.reported?.avatar_url || null,
        message_preview: data.reason, // message_preview usually shows detail
        college_id: data.reported?.school_id || '',
      };

      try {
        // Next Report (Older report - we process older ones as 'next' in the queue)
        const { data: nextData } = await supabase
          .from(TABLES.CONTENT_REPORTS)
          .select('id')
          .not('chat_room_id', 'is', null)
          .lt('created_at', data.created_at)
          .order('created_at', { ascending: false })
          .limit(1)
          .maybeSingle();

        // Previous Report (Newer report)
        const { data: prevData } = await supabase
          .from(TABLES.CONTENT_REPORTS)
          .select('id')
          .not('chat_room_id', 'is', null)
          .gt('created_at', data.created_at)
          .order('created_at', { ascending: true })
          .limit(1)
          .maybeSingle();

        mapped.next_id = nextData?.id;
        mapped.prev_id = prevData?.id;
      } catch (e) {
        console.error('Failed to fetch prev/next report ids', e);
      }

      return mapped;
    },
    enabled: !!id,
  });
}

/**
 * Mutation for resolving a chat report.
 * Full enforcement pipeline:
 *   1. Update content_reports status + resolution_note
 *   2. If warn/restrict: insert into user_bans
 *   3. Hide reported messages via admin_hide_messages RPC
 *   4. Award reporter contribution points (if requested)
 *   5. Write audit log
 */
export function useResolveReport() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ 
      reportId, 
      resolution, 
      note,
      adminId,
      // Optional enforcement fields
      reportedUserId,
      reporterUserId,
      selectedMessageIds,
      restrictionScopes,
      giveReward,
      rewardPoints,
      collegeId,
    }: { 
      reportId: string; 
      resolution: ReportResolution; 
      note: string;
      adminId: string;
      reportedUserId?: string;
      reporterUserId?: string;
      selectedMessageIds?: string[];
      // Map of scope -> duration_days (e.g. { chat_mute: '7', listing_ban: '30' })
      restrictionScopes?: Record<string, string>;
      giveReward?: boolean;
      rewardPoints?: number;
      collegeId?: string;
    }) => {
      // ── Step 1: Update the report record ────────────────────────
      const { data, error } = await supabase
        .from(TABLES.CONTENT_REPORTS)
        .update({
          // NOTE: content_reports status CHECK: pending, reviewed, resolved, dismissed
          status: resolution === 'dismiss' ? 'dismissed' : 'resolved',
          resolution_note: note,
          // NOTE: action_taken stores the exact penalty for app-side display.
          // The reported user's RLS policy only reveals 'warn'/'restrict' records.
          action_taken: resolution === 'dismiss' ? null : resolution === 'warn' ? 'warn' : 'restrict',
          reporter_reward_points: (giveReward && rewardPoints && resolution !== 'dismiss') ? rewardPoints : 0,
        })
        .eq('id', reportId)
        .select()
        .single();

      if (error) throw error;


      // ── Step 2: Auto-enforce user restrictions ───────────────────
      // NOTE: 'warn' also creates a user_ban with scope='account_freeze'
      // but duration_days=0 acts as a formal warning record (expires immediately).
      if ((resolution === 'warn' || resolution === 'restrict') && reportedUserId) {
        const scopesToApply: Array<{ scope: string; days: number }> = [];

        if (resolution === 'warn') {
          // Formal warning: a 1-day chat_mute serves as an official record
          scopesToApply.push({ scope: 'chat_mute', days: 1 });
        } else if (resolution === 'restrict' && restrictionScopes) {
          // Apply each configured scope with its duration
          for (const [scope, daysStr] of Object.entries(restrictionScopes)) {
            scopesToApply.push({ scope, days: parseFloat(daysStr) });
          }
        }

        for (const { scope, days } of scopesToApply) {
          const isPermanent = days >= 9999;
          const expiresAt = isPermanent
            ? null
            : new Date(Date.now() + days * 86400 * 1000 + 60000).toISOString();

          const { error: banError } = await supabase.from(TABLES.USER_BANS).insert({
            user_id: reportedUserId,
            college_id: collegeId,
            scope,
            ban_type: isPermanent ? 'permanent' : 'temporary',
            reason_code: 'chat_report',
            reason_detail: `Resolved from chat report ${reportId}. ${note}`.trim(),
            banned_by: adminId,
            banned_at: new Date().toISOString(),
            duration_days: isPermanent ? null : days,
            expires_at: expiresAt,
          });

          if (banError) {
            // NOTE: Non-critical \u2014 log but continue; report is already resolved.
            console.error(`[useResolveReport] Failed to insert ban (scope=${scope}):`, banError);
          }
        }
      }

      // ── Step 3: Hide reported messages ───────────────────────────
      // Use SECURITY DEFINER RPC so admin can override RLS on messages table.
      if (selectedMessageIds && selectedMessageIds.length > 0 && resolution !== 'dismiss') {
        const { error: hideError } = await supabase.rpc('admin_hide_messages', {
          message_ids: selectedMessageIds,
          reason_text: `Reported content \u2014 hidden by moderation (report: ${reportId})`,
        });

        if (hideError) {
          console.error('[useResolveReport] Failed to hide messages:', hideError);
        }
      }

      // ── Step 4: Award reporter contribution points ───────────────
      if (giveReward && rewardPoints && rewardPoints > 0 && reporterUserId && resolution !== 'dismiss') {
        const { error: rewardError } = await supabase.rpc('admin_reward_user_points', {
          p_user_id: reporterUserId,
          p_points: rewardPoints,
          p_source_type: 'report_resolved',
          p_source_id: reportId,
          p_description: `Reward for valid chat report (report ID: ${reportId})`,
        });

        if (rewardError) {
          console.error('[useResolveReport] Failed to award points:', rewardError);
        }
      }

      // ── Step 5: Audit log ────────────────────────────────────────
      await supabase.from(TABLES.ADMIN_AUDIT_LOGS).insert({
        admin_id: adminId,
        action: 'resolve_report',
        target_type: 'chat_report',
        target_id: reportId,
        payload: {
          resolution,
          notes: note,
          restrictions_applied: resolution === 'restrict' ? restrictionScopes : null,
          messages_hidden: selectedMessageIds?.length ?? 0,
          points_awarded: giveReward ? (rewardPoints ?? 0) : 0,
        },
      });

      // ── Step 6: In-app + email notifications ─────────────────────
      // NOTE: send_moderation_notification() is a SECURITY DEFINER RPC that
      // inserts into notifications with email_queued=true (respecting user prefs).
      // The push-notification Edge Function fires automatically via Supabase webhook.

      // 6a. Notify the reporter of the outcome
      if (reporterUserId) {
        const isActioned = resolution !== 'dismiss';
        const reporterType = isActioned ? 'report_resolved' : 'report_dismissed';
        const reporterTitle = isActioned
          ? '✅ Your report has been reviewed'
          : 'Update on your report';
        const reporterBody = isActioned
          ? `Thank you for keeping Smivo safe! Your report was reviewed and action was taken.${giveReward && rewardPoints ? ` +${rewardPoints} contribution points awarded.` : ''}`
          : 'We reviewed your report. No action was required at this time. Thank you for your help.';

        const { error: reporterNotifErr } = await supabase.rpc('send_moderation_notification', {
          p_user_id: reporterUserId,
          p_type: reporterType,
          p_title: reporterTitle,
          p_body: reporterBody,
          p_action_type: 'route',
          p_action_url: '/settings/trust-and-safety',
        });
        if (reporterNotifErr) {
          console.error('[useResolveReport] Reporter notification failed:', reporterNotifErr);
        }
      }

      // 6b. Notify the reported user if a penalty was applied
      if (reportedUserId && resolution !== 'dismiss') {
        let penaltyType: string;
        let penaltyTitle: string;
        let penaltyBody: string;

        if (resolution === 'warn') {
          penaltyType = 'moderation_warned';
          penaltyTitle = '⚠️ Account Warning Issued';
          penaltyBody = 'Our moderation team has reviewed a report and issued a formal warning on your account. Please review our community guidelines.';
        } else {
          // 'restrict'
          const scopeLabels = restrictionScopes
            ? Object.entries(restrictionScopes)
                .map(([s, d]) => `${s.replace(/_/g, ' ')} (${d === '9999' ? 'Permanent' : `${d} days`})`)
                .join(', ')
            : 'account restrictions';
          penaltyType = 'moderation_restricted';
          penaltyTitle = '🚫 Account Restriction Applied';
          penaltyBody = `Account restrictions have been applied: ${scopeLabels}. Please review our community guidelines. Contact support if you believe this is an error.`;
        }

        const { error: penaltyNotifErr } = await supabase.rpc('send_moderation_notification', {
          p_user_id: reportedUserId,
          p_type: penaltyType,
          p_title: penaltyTitle,
          p_body: penaltyBody,
          p_action_type: 'route',
          p_action_url: '/settings/trust-and-safety',
        });
        if (penaltyNotifErr) {
          console.error('[useResolveReport] Penalty notification failed:', penaltyNotifErr);
        }
      }

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });
}


