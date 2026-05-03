import { useState } from 'react';
import { useUserSummary } from '@/hooks/useUsers';
import { User, Shield, Star, Award, AlertTriangle, Package, ShoppingBag, X } from 'lucide-react';

interface UserSummaryPopupProps {
  userId: string;
  onClose: () => void;
}

export function UserSummaryPopup({ userId, onClose }: UserSummaryPopupProps) {
  const { data: summary, isLoading, error } = useUserSummary(userId);
  const [showActivity, setShowActivity] = useState(false);

  if (isLoading) {
    return (
      <div className="user-summary-popup loading" onClick={(e) => e.stopPropagation()}>
        <div className="spinner"></div>
        <p>Loading user details...</p>
      </div>
    );
  }

  if (error || !summary || !summary.profile) {
    return (
      <div className="user-summary-popup error" onClick={(e) => e.stopPropagation()}>
        <button className="close-btn" onClick={(e) => { e.stopPropagation(); onClose(); }}><X size={16} /></button>
        <p>Failed to load user details.</p>
      </div>
    );
  }

  const { profile } = summary;
  const rating = profile.seller_rating || 0;
  const contributionLevel = profile.contribution_level || 1;
  const contributionScore = profile.contribution_score || 0;

  return (
    <div className="user-summary-popup" onClick={(e) => e.stopPropagation()}>
      <button className="close-btn" onClick={(e) => { e.stopPropagation(); onClose(); }}><X size={16} /></button>
      
      <div className="summary-header">
        <div className="user-avatar-large">
          {profile.avatar_url ? (
            <img src={profile.avatar_url} alt="Avatar" />
          ) : (
            <User size={32} />
          )}
        </div>
        <div className="user-info-basic">
          <h4>{profile.display_name || 'Unknown User'}</h4>
          <span className="user-email">{profile.email}</span>
        </div>
      </div>

      <div className="summary-stats-grid">
        <div className="stat-item">
          <Star size={14} className="icon-rating" />
          <div className="stat-content">
            <span className="stat-value">{rating.toFixed(1)}</span>
            <span className="stat-label">Rating</span>
          </div>
        </div>
        <div className="stat-item">
          <Award size={14} className="icon-contribution" />
          <div className="stat-content">
            <span className="stat-value">Lv {contributionLevel}</span>
            <span className="stat-label">{contributionScore} pts</span>
          </div>
        </div>
        <div className="stat-item">
          <Package size={14} className="icon-neutral" />
          <div className="stat-content">
            <span className="stat-value">{summary.listingsCount}</span>
            <span className="stat-label">Listings</span>
          </div>
        </div>
        <div className="stat-item">
          <ShoppingBag size={14} className="icon-neutral" />
          <div className="stat-content">
            <span className="stat-value">{summary.purchasesCount}</span>
            <span className="stat-label">Purchases</span>
          </div>
        </div>
      </div>

      <div className="summary-punishments">
        <div className="punishment-row">
          <span className="label"><Shield size={14} /> Violations (Reported)</span>
          <span className="value">{summary.reportsCount}</span>
        </div>
        <div className="punishment-row">
          <span className="label"><AlertTriangle size={14} /> Punishments</span>
          <span className="value">{summary.punishmentsCount}</span>
        </div>
        
        {summary.activeBans.length > 0 && (
          <div className="active-bans-box">
            <strong>Current Restrictions:</strong>
            <ul>
              {summary.activeBans.map((ban: any, idx: number) => (
                <li key={idx}>
                  {ban.scope} {ban.expires_at ? `(until ${new Date(ban.expires_at).toLocaleDateString()})` : '(Permanent)'}
                </li>
              ))}
            </ul>
          </div>
        )}
      </div>

      <div className="summary-actions">
        <button 
          className="btn btn-outline btn-sm w-full"
          onClick={(e) => {
            e.stopPropagation();
            setShowActivity(!showActivity);
          }}
        >
          {showActivity ? 'Hide Recent Activity' : 'View Recent Activity'}
        </button>
      </div>

      {showActivity && (
        <div className="recent-activity-list" onClick={(e) => e.stopPropagation()}>
          {summary.recentActivity.length === 0 ? (
            <div className="empty-activity">No recent activity found.</div>
          ) : (
            summary.recentActivity.map((activity: any) => {
              const isBuyer = activity.buyer_id === userId;
              const roleLabel = isBuyer ? 'Bought' : 'Sold';
              return (
                <div key={activity.id} className="activity-item">
                  <div className="activity-header">
                    <span className={`role-badge ${isBuyer ? 'buyer' : 'seller'}`}>{roleLabel}</span>
                    <span className="activity-date">{new Date(activity.created_at).toLocaleDateString()}</span>
                  </div>
                  <div className="activity-title">{activity.listing?.title || 'Unknown Item'}</div>
                  <div className="activity-status" style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span>Status: {activity.status}</span>
                    <span style={{ fontWeight: 'bold' }}>${Number(activity.total_price).toFixed(2)}</span>
                  </div>
                </div>
              );
            })
          )}
        </div>
      )}

      <style>{`
        .user-summary-popup {
          position: absolute;
          top: 100%;
          left: 0;
          width: 320px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-lg);
          box-shadow: var(--shadow-lg);
          padding: 20px;
          z-index: 100;
          margin-top: 8px;
          display: flex;
          flex-direction: column;
          gap: 16px;
        }

        .user-summary-popup.loading, .user-summary-popup.error {
          align-items: center;
          justify-content: center;
          min-height: 150px;
        }

        .close-btn {
          position: absolute;
          top: 12px;
          right: 12px;
          background: none;
          border: none;
          color: var(--color-text-tertiary);
          cursor: pointer;
          padding: 4px;
        }
        .close-btn:hover { color: var(--color-text-primary); }

        .summary-header {
          display: flex;
          align-items: center;
          gap: 12px;
        }
        
        .user-avatar-large {
          width: 48px;
          height: 48px;
          border-radius: 24px;
          background: var(--color-bg-secondary);
          display: flex;
          align-items: center;
          justify-content: center;
          overflow: hidden;
        }
        .user-avatar-large img { width: 100%; height: 100%; object-fit: cover; }
        
        .user-info-basic h4 { margin: 0 0 4px 0; font-size: 15px; }
        .user-info-basic .user-email { font-size: 12px; color: var(--color-text-tertiary); }

        .summary-stats-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 12px;
          background: var(--color-bg-secondary);
          padding: 12px;
          border-radius: var(--radius-md);
        }

        .stat-item {
          display: flex;
          align-items: center;
          gap: 8px;
        }
        .stat-content {
          display: flex;
          flex-direction: column;
        }
        .stat-value { font-weight: 600; font-size: 14px; }
        .stat-label { font-size: 11px; color: var(--color-text-tertiary); }
        
        .icon-rating { color: #f59e0b; }
        .icon-contribution { color: #8b5cf6; }
        .icon-neutral { color: var(--color-text-tertiary); }

        .summary-punishments {
          display: flex;
          flex-direction: column;
          gap: 8px;
          font-size: 13px;
        }
        .punishment-row {
          display: flex;
          justify-content: space-between;
          align-items: center;
          color: var(--color-text-secondary);
        }
        .punishment-row .label { display: flex; align-items: center; gap: 6px; }
        .punishment-row .value { font-weight: 600; }

        .active-bans-box {
          margin-top: 4px;
          padding: 8px;
          background: var(--color-danger-light);
          border: 1px solid var(--color-danger);
          border-radius: var(--radius-sm);
          color: var(--color-danger);
          font-size: 12px;
        }
        .active-bans-box ul { margin: 4px 0 0 0; padding-left: 16px; }

        .summary-actions {
          margin-top: 4px;
        }

        .recent-activity-list {
          display: flex;
          flex-direction: column;
          gap: 8px;
          max-height: 200px;
          overflow-y: auto;
          border-top: 1px solid var(--color-border-light);
          padding-top: 12px;
        }
        
        .empty-activity {
          font-size: 12px;
          color: var(--color-text-tertiary);
          text-align: center;
          padding: 12px 0;
        }

        .activity-item {
          padding: 8px;
          background: var(--color-bg-secondary);
          border-radius: var(--radius-sm);
          font-size: 12px;
        }
        .activity-header {
          display: flex;
          justify-content: space-between;
          margin-bottom: 4px;
        }
        .role-badge {
          padding: 2px 6px;
          border-radius: 4px;
          font-size: 10px;
          font-weight: 600;
          text-transform: uppercase;
        }
        .role-badge.buyer { background: #dbeafe; color: #1e3a8a; }
        .role-badge.seller { background: #dcfce7; color: #166534; }
        
        .activity-date { color: var(--color-text-tertiary); }
        .activity-title { font-weight: 600; color: var(--color-text-primary); margin-bottom: 2px; }
        .activity-status { color: var(--color-text-secondary); text-transform: capitalize; }
      `}</style>
    </div>
  );
}
