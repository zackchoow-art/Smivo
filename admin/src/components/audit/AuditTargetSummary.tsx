import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';
import { translateTarget } from '@/lib/audit-translations';
import { User, FileText, Settings, AlertTriangle, MessageSquare } from 'lucide-react';

interface AuditTargetSummaryProps {
  targetType: string;
  targetId: string | null;
  payload: Record<string, any> | null;
}

export function AuditTargetSummary({ targetType, targetId, payload }: AuditTargetSummaryProps) {
  // Query for Target Details
  const { data: details, isLoading } = useQuery({
    queryKey: ['audit-target', targetType, targetId],
    queryFn: async () => {
      if (!targetId) return null;

      switch (targetType) {
        case 'user':
        case 'user_profile':
        case 'user_ban':
        case 'user_restriction': {
          // Some targets might refer to the user id
          const idToFetch = payload?.userId || targetId;
          const { data } = await supabase
            .from(TABLES.USER_PROFILES)
            .select('display_name, email, avatar_url')
            .eq('id', idToFetch)
            .maybeSingle();
          return data;
        }
        case 'listing': {
          const { data } = await supabase
            .from(TABLES.LISTINGS)
            .select('title, price, images:listing_images(image_url)')
            .eq('id', targetId)
            .maybeSingle();
          return data;
        }
        case 'chat_report':
        case 'listing_report':
        case 'content_report': {
          const { data } = await supabase
            .from(TABLES.CONTENT_REPORTS)
            .select('reason, reason_category')
            .eq('id', targetId)
            .maybeSingle();
          return data;
        }
        case 'feedback': {
          const { data } = await supabase
            .from(TABLES.USER_FEEDBACKS)
            .select('title, type')
            .eq('id', targetId)
            .maybeSingle();
          return data;
        }
        default:
          return null;
      }
    },
    enabled: !!targetId && !['system_config', 'push_job'].includes(targetType),
    staleTime: 5 * 60 * 1000,
  });

  if (targetType === 'system_config') {
    return (
      <div className="audit-target-card">
        <div className="target-icon bg-info"><Settings size={14} /></div>
        <div className="target-info">
          <span className="target-type">{translateTarget(targetType)}</span>
          <span className="target-title">{payload?.key || 'System Config'}</span>
        </div>
      </div>
    );
  }

  if (targetType === 'push_job') {
    return (
      <div className="audit-target-card">
        <div className="target-icon bg-success"><MessageSquare size={14} /></div>
        <div className="target-info">
          <span className="target-type">{translateTarget(targetType)}</span>
          <span className="target-title">{payload?.title || targetId?.slice(0, 8)}</span>
        </div>
      </div>
    );
  }

  if (!targetId) {
    return <span className="audit-target-type">{translateTarget(targetType)}</span>;
  }

  if (isLoading) {
    return (
      <div className="audit-target-card">
        <div className="target-icon bg-gray animate-pulse" />
        <div className="target-info">
          <span className="target-type">{translateTarget(targetType)}</span>
          <span className="target-title text-muted">Loading...</span>
        </div>
      </div>
    );
  }

  // Render specific cards based on type
  if (['user', 'user_profile', 'user_ban', 'user_restriction'].includes(targetType) && details) {
    const userDetails = details as any;
    return (
      <div className="audit-target-card">
        {userDetails.avatar_url ? (
          <img src={userDetails.avatar_url} alt="Avatar" className="target-avatar" />
        ) : (
          <div className="target-icon bg-gray"><User size={14} /></div>
        )}
        <div className="target-info">
          <span className="target-type">{translateTarget(targetType)}</span>
          <span className="target-title">{userDetails.display_name || 'Unknown User'}</span>
          <span className="target-subtitle">{userDetails.email}</span>
        </div>
      </div>
    );
  }

  if (targetType === 'listing' && details) {
    const listingDetails = details as any;
    const thumb = listingDetails.images?.[0]?.image_url;
    return (
      <div className="audit-target-card">
        {thumb ? (
          <img src={thumb} alt="Listing" className="target-thumb" />
        ) : (
          <div className="target-icon bg-gray"><FileText size={14} /></div>
        )}
        <div className="target-info">
          <span className="target-type">{translateTarget(targetType)}</span>
          <span className="target-title truncate" title={listingDetails.title}>{listingDetails.title}</span>
          <span className="target-subtitle">${listingDetails.price}</span>
        </div>
      </div>
    );
  }

  if (['chat_report', 'listing_report', 'content_report'].includes(targetType) && details) {
    const reportDetails = details as any;
    return (
      <div className="audit-target-card">
        <div className="target-icon bg-danger"><AlertTriangle size={14} /></div>
        <div className="target-info">
          <span className="target-type">{translateTarget(targetType)}</span>
          <span className="target-title">Reason: {reportDetails.reason_category || reportDetails.reason || 'Unknown'}</span>
          <code className="audit-id">{targetId.slice(0, 8)}</code>
        </div>
      </div>
    );
  }

  if (targetType === 'feedback' && details) {
    const feedbackDetails = details as any;
    return (
      <div className="audit-target-card">
        <div className="target-icon bg-warning"><MessageSquare size={14} /></div>
        <div className="target-info">
          <span className="target-type">{translateTarget(targetType)}</span>
          <span className="target-title truncate">{feedbackDetails.title}</span>
        </div>
      </div>
    );
  }

  // Fallback
  return (
    <div className="audit-target-card">
      <div className="target-icon bg-gray"><FileText size={14} /></div>
      <div className="target-info">
        <span className="target-type">{translateTarget(targetType)}</span>
        <code className="audit-id">{targetId.slice(0, 8)}</code>
      </div>
    </div>
  );
}
