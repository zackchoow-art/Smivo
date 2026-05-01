import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useUserDetail } from '@/hooks/useUsers';
import { useCreateBan, useLiftBan } from '@/hooks/useBans';
import { useAuth } from '@/hooks/useAuth';
import type { BanType } from '@/types/ban';

export function UserDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data, isLoading, error } = useUserDetail(id);
  const { admin } = useAuth();
  const banMutation = useCreateBan();
  const liftBanMutation = useLiftBan();

  const [showBanForm, setShowBanForm] = useState(false);
  const [banType, setBanType] = useState<BanType>('temporary');
  const [banReason, setBanReason] = useState('');
  const [banDuration, setBanDuration] = useState<number>(7);

  if (isLoading) return <div className="ud-state-msg">Loading user details...</div>;
  if (error || !data) return <div className="ud-state-msg ud-state-error">Failed to load user.</div>;

  const { user, listings, orders, bans } = data;
  const activeBan = bans?.[0];

  const handleBanSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!admin) return;
    try {
      await banMutation.mutateAsync({
        userId: user.id,
        collegeId: (user as any).school_id || '', // fallback
        banType,
        reasonCode: 'manual',
        reasonDetail: banReason,
        durationDays: banType === 'temporary' ? banDuration : null,
        adminId: admin.user_id,
      });
      alert('User banned successfully');
      setShowBanForm(false);
      setBanReason('');
    } catch (err) {
      console.error(err);
      alert('Failed to ban user');
    }
  };

  const handleLiftBan = async () => {
    if (!admin || !activeBan) return;
    if (!confirm('Are you sure you want to lift this ban?')) return;
    const reason = prompt('Reason for lifting ban:');
    if (!reason) return;
    
    try {
      await liftBanMutation.mutateAsync({
        banId: activeBan.id,
        adminId: admin.user_id,
        liftReason: reason,
      });
      alert('Ban lifted successfully');
    } catch (err) {
      console.error(err);
      alert('Failed to lift ban');
    }
  };

  return (
    <div className="ud-container">
      <div className="ud-header">
        <button onClick={() => navigate(-1)} className="ud-btn-back">&larr; Back to Users</button>
        <h1 className="ud-page-title">User Details</h1>
        {activeBan ? (
          <button onClick={handleLiftBan} className="ud-btn-ban" style={{ backgroundColor: '#10b981' }}>
            Lift Ban
          </button>
        ) : (
          <button onClick={() => setShowBanForm(!showBanForm)} className="ud-btn-ban">
            {showBanForm ? 'Cancel Ban' : 'Ban User'}
          </button>
        )}
      </div>

      {showBanForm && !activeBan && (
        <div className="ud-ban-form-container">
          <h3 className="ud-table-title">Ban User</h3>
          <form onSubmit={handleBanSubmit} className="ud-ban-form">
            <div className="ud-form-group">
              <label>Ban Type</label>
              <select value={banType} onChange={(e) => setBanType(e.target.value as BanType)}>
                <option value="temporary">Temporary</option>
                <option value="permanent">Permanent</option>
              </select>
            </div>
            {banType === 'temporary' && (
              <div className="ud-form-group">
                <label>Duration (Days)</label>
                <input 
                  type="number" 
                  min="1"
                  value={banDuration} 
                  onChange={(e) => setBanDuration(parseInt(e.target.value))} 
                />
              </div>
            )}
            <div className="ud-form-group">
              <label>Reason</label>
              <textarea 
                required
                value={banReason} 
                onChange={(e) => setBanReason(e.target.value)} 
                placeholder="Explain the reason for the ban..."
                rows={3}
              />
            </div>
            <button 
              type="submit" 
              className="ud-btn-submit"
              disabled={banMutation.isPending}
            >
              {banMutation.isPending ? 'Banning...' : 'Confirm Ban'}
            </button>
          </form>
        </div>
      )}

      <div className="ud-layout">
        {/* Profile Card */}
        <div className="ud-profile-card">
          <div className="ud-avatar-section">
            {user.avatar_url ? (
              <img src={user.avatar_url} alt="Avatar" className="ud-avatar" />
            ) : (
              <div className="ud-avatar-placeholder">{user.email[0].toUpperCase()}</div>
            )}
            <h2 className="ud-display-name">{user.display_name || 'No Name'}</h2>
            <p className="ud-email">{user.email}</p>
          </div>
          <div className="ud-profile-meta">
            <div className="ud-meta-row">
              <span className="ud-meta-label">School</span>
              <span className="ud-meta-value">{(user as any).school || '—'}</span>
            </div>
            <div className="ud-meta-row">
              <span className="ud-meta-label">Status</span>
              {activeBan ? (
                <span className="ud-meta-value ud-status-banned" style={{ color: '#ef4444', fontWeight: 600 }}>Banned</span>
              ) : (
                <span className="ud-meta-value ud-status-active">Active</span>
              )}
            </div>
            <div className="ud-meta-row">
              <span className="ud-meta-label">Registered</span>
              <span className="ud-meta-value">{new Date(user.created_at).toLocaleDateString()}</span>
            </div>
          </div>
        </div>

        {/* Stats and Lists */}
        <div className="ud-main-col">
          <div className="ud-stats-grid">
            <div className="ud-stat-card">
              <div className="ud-stat-label">Listings</div>
              <div className="ud-stat-value">{listings.length}</div>
            </div>
            <div className="ud-stat-card">
              <div className="ud-stat-label">Orders</div>
              <div className="ud-stat-value">{orders.length}</div>
            </div>
            <div className="ud-stat-card ud-stat-card--danger">
              <div className="ud-stat-label">Reports Against</div>
              <div className="ud-stat-value ud-stat-value--danger">0</div>
            </div>
          </div>

          <div className="ud-table-card">
            <div className="ud-table-header">
              <h3 className="ud-table-title">Recent Listings</h3>
            </div>
            {listings.length === 0 ? (
              <div className="ud-empty-msg">No listings found.</div>
            ) : (
              <ul className="ud-list">
                {listings.map((l: any) => (
                  <li key={l.id} className="ud-list-item">
                    <div>
                      <p className="ud-item-title">{l.title}</p>
                      <p className="ud-item-date">{new Date(l.created_at).toLocaleDateString()}</p>
                    </div>
                    <div className="ud-item-meta">
                      <span className="ud-item-price">${l.price}</span>
                      <span className="ud-badge">{l.moderation_status}</span>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>

          <div className="ud-table-card">
            <div className="ud-table-header">
              <h3 className="ud-table-title">Recent Orders</h3>
            </div>
            {orders.length === 0 ? (
              <div className="ud-empty-msg">No orders found.</div>
            ) : (
              <ul className="ud-list">
                {orders.map((o: any) => (
                  <li key={o.id} className="ud-list-item">
                    <div>
                      <p className="ud-item-title">Order for: {o.listing?.title || 'Unknown Item'}</p>
                      <p className="ud-item-date">{new Date(o.created_at).toLocaleDateString()}</p>
                    </div>
                    <div className="ud-item-meta">
                      <span className="ud-item-price">${o.total_price}</span>
                      <span className="ud-badge ud-badge--info">{o.status}</span>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      </div>

      <style>{`
        .ud-container { padding: var(--spacing-page); max-width: 1024px; margin: 0 auto; }
        .ud-state-msg { padding: 48px; text-align: center; color: var(--color-text-secondary); font-size: 14px; }
        .ud-state-error { color: var(--color-danger); }
        .ud-header { display: flex; align-items: center; gap: 16px; margin-bottom: 24px; }
        .ud-btn-back { background: none; border: none; cursor: pointer; color: var(--color-text-secondary); font-size: 14px; padding: 0; }
        .ud-btn-back:hover { color: var(--color-text-primary); }
        .ud-page-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); flex: 1; margin: 0; }
        .ud-btn-ban { padding: 8px 16px; background: var(--color-danger); color: #fff; border: none; border-radius: var(--radius-sm); font-size: 14px; font-weight: 500; cursor: pointer; }
        .ud-btn-ban:hover { opacity: 0.88; }
        .ud-layout { display: grid; grid-template-columns: 1fr 2fr; gap: 24px; }
        @media (max-width: 768px) { .ud-layout { grid-template-columns: 1fr; } }
        .ud-profile-card { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); padding: 24px; display: flex; flex-direction: column; gap: 16px; }
        .ud-avatar-section { display: flex; flex-direction: column; align-items: center; gap: 8px; }
        .ud-avatar { width: 96px; height: 96px; border-radius: 50%; object-fit: cover; }
        .ud-avatar-placeholder { width: 96px; height: 96px; border-radius: 50%; background: var(--color-info-light); display: flex; align-items: center; justify-content: center; font-size: 32px; font-weight: 700; color: var(--color-info); }
        .ud-display-name { font-size: 20px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .ud-email { font-size: 13px; color: var(--color-text-secondary); margin: 0; }
        .ud-profile-meta { border-top: 1px solid var(--color-border-light); padding-top: 16px; display: flex; flex-direction: column; gap: 8px; }
        .ud-meta-row { display: flex; justify-content: space-between; font-size: 13px; }
        .ud-meta-label { color: var(--color-text-secondary); }
        .ud-meta-value { font-weight: 500; color: var(--color-text-primary); }
        .ud-status-active { color: var(--color-success); }
        .ud-main-col { display: flex; flex-direction: column; gap: 24px; }
        .ud-stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
        .ud-stat-card { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); padding: 16px; text-align: center; }
        .ud-stat-card--danger { border-top: 4px solid var(--color-danger); }
        .ud-stat-label { font-size: 13px; font-weight: 500; color: var(--color-text-secondary); margin-bottom: 4px; }
        .ud-stat-value { font-size: 24px; font-weight: 700; color: var(--color-text-primary); }
        .ud-stat-value--danger { color: var(--color-danger); }
        .ud-table-card { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); overflow: hidden; }
        .ud-table-header { padding: 16px 24px; border-bottom: 1px solid var(--color-border-light); }
        .ud-table-title { font-size: 16px; font-weight: 500; color: var(--color-text-primary); margin: 0; }
        .ud-empty-msg { padding: 24px; text-align: center; font-size: 13px; color: var(--color-text-secondary); }
        .ud-list { list-style: none; padding: 0; margin: 0; }
        .ud-list-item { display: flex; align-items: center; justify-content: space-between; padding: 16px 24px; border-bottom: 1px solid var(--color-border-light); }
        .ud-list-item:last-child { border-bottom: none; }
        .ud-list-item:hover { background: var(--color-bg-secondary); }
        .ud-item-title { font-size: 13px; font-weight: 500; color: var(--color-text-primary); margin: 0 0 2px; }
        .ud-item-date { font-size: 12px; color: var(--color-text-secondary); margin: 0; }
        .ud-item-meta { display: flex; align-items: center; gap: 12px; }
        .ud-item-price { font-size: 13px; font-weight: 500; color: var(--color-text-primary); }
        .ud-badge { padding: 2px 8px; font-size: 11px; border-radius: 999px; background: var(--color-bg-tertiary); color: var(--color-text-primary); }
        .ud-badge--info { background: var(--color-info-light); color: var(--color-info); }

        .ud-ban-form-container { background: var(--color-warning-light); border: 1px solid var(--color-warning); border-radius: var(--radius-md); padding: 24px; margin-bottom: 24px; }
        .ud-ban-form { display: flex; flex-direction: column; gap: 16px; margin-top: 16px; }
        .ud-form-group { display: flex; flex-direction: column; gap: 8px; }
        .ud-form-group label { font-size: 12px; font-weight: 600; color: var(--color-text-secondary); text-transform: uppercase; }
        .ud-form-group input, .ud-form-group select, .ud-form-group textarea { padding: 10px; border: 1px solid var(--color-border); border-radius: var(--radius-sm); font-family: inherit; font-size: 14px; }
        .ud-btn-submit { padding: 10px 16px; background: var(--color-danger); color: white; border: none; border-radius: var(--radius-sm); font-size: 14px; font-weight: 600; cursor: pointer; align-self: flex-start; }
        .ud-btn-submit:disabled { opacity: 0.6; cursor: not-allowed; }
      `}</style>
    </div>
  );
}
