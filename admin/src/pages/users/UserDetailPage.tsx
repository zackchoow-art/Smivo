import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useUserDetail } from '@/hooks/useUsers';
import { useCreateBan, useLiftBan, useUserActiveRestrictions } from '@/hooks/useBans';
import { useAuth } from '@/hooks/useAuth';
import { RESTRICTION_SCOPE_META } from '@/lib/constants';
import type { BanType, RestrictionScope } from '@/types/ban';

const ALL_SCOPES: RestrictionScope[] = ['chat_mute', 'listing_ban', 'feedback_ban', 'account_freeze'];

export function UserDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data, isLoading, error } = useUserDetail(id);
  const { admin } = useAuth();
  const { data: activeRestrictions, refetch: refetchRestrictions } = useUserActiveRestrictions(id);
  const banMutation = useCreateBan();
  const liftBanMutation = useLiftBan();

  // State for the "Add Restriction" form
  const [showAddForm, setShowAddForm] = useState(false);
  const [addScope, setAddScope] = useState<RestrictionScope>('chat_mute');
  const [addType, setAddType] = useState<BanType>('temporary');
  const [addDuration, setAddDuration] = useState(7);
  const [addReason, setAddReason] = useState('');
  const [addReasonCode, setAddReasonCode] = useState('violation_policy');

  if (isLoading) return <div className="ud-state-msg">Loading user details...</div>;
  if (error || !data) return <div className="ud-state-msg ud-state-error">Failed to load user.</div>;

  const { user, listings, orders } = data;

  // Build a map of scope -> active restriction record
  const activeMap: Record<string, any> = {};
  if (activeRestrictions) {
    for (const r of activeRestrictions) {
      activeMap[r.scope] = r;
    }
  }

  const hasAnyRestriction = Object.keys(activeMap).length > 0;

  const handleAddRestriction = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!admin) return;
    try {
      await banMutation.mutateAsync({
        userId: user.id,
        collegeId: (user as any).school_id || '',
        banType: addType,
        scope: addScope,
        reasonCode: addReasonCode,
        reasonDetail: addReason,
        durationDays: addType === 'temporary' ? addDuration : null,
        adminId: admin.user_id,
      });
      setShowAddForm(false);
      setAddReason('');
      refetchRestrictions();
    } catch (err) {
      console.error(err);
      alert('Failed to add restriction');
    }
  };

  const handleLiftRestriction = async (banId: string, scopeLabel: string) => {
    if (!admin) return;
    const reason = prompt(`Reason for lifting "${scopeLabel}":`);
    if (!reason) return;

    try {
      await liftBanMutation.mutateAsync({
        banId,
        adminId: admin.user_id,
        liftReason: reason,
      });
      refetchRestrictions();
    } catch (err) {
      console.error(err);
      alert('Failed to lift restriction');
    }
  };

  // Scopes that are not yet active (available for adding)
  const availableScopes = ALL_SCOPES.filter(s => !activeMap[s]);

  return (
    <div className="ud-container">
      <div className="ud-header">
        <button onClick={() => navigate(-1)} className="ud-btn-back">&larr; Back to Users</button>
        <h1 className="ud-page-title">User Details</h1>
        <button onClick={() => setShowAddForm(!showAddForm)} className="ud-btn-add-restriction">
          {showAddForm ? 'Cancel' : '+ Add Restriction'}
        </button>
      </div>

      {/* Add Restriction Form */}
      {showAddForm && (
        <div className="ud-add-form-card">
          <h3 className="ud-card-title">Add New Restriction</h3>
          <form onSubmit={handleAddRestriction} className="ud-add-form">
            <div className="ud-form-row">
              <div className="ud-form-group">
                <label>Restriction Type</label>
                <select value={addScope} onChange={e => setAddScope(e.target.value as RestrictionScope)}>
                  {availableScopes.length === 0 ? (
                    <option disabled>All restrictions active</option>
                  ) : (
                    availableScopes.map(s => (
                      <option key={s} value={s}>
                        {RESTRICTION_SCOPE_META[s]?.icon} {RESTRICTION_SCOPE_META[s]?.label}
                      </option>
                    ))
                  )}
                </select>
              </div>
              <div className="ud-form-group">
                <label>Duration</label>
                <select value={addType} onChange={e => setAddType(e.target.value as BanType)}>
                  <option value="temporary">Temporary</option>
                  <option value="permanent">Permanent</option>
                </select>
              </div>
              {addType === 'temporary' && (
                <div className="ud-form-group">
                  <label>Days</label>
                  <select value={addDuration} onChange={e => setAddDuration(parseInt(e.target.value))}>
                    <option value={1}>1 Day</option>
                    <option value={3}>3 Days</option>
                    <option value={7}>7 Days</option>
                    <option value={14}>14 Days</option>
                    <option value={30}>30 Days</option>
                    <option value={90}>90 Days</option>
                    <option value={180}>180 Days</option>
                  </select>
                </div>
              )}
            </div>
            <div className="ud-form-group">
              <label>Reason Category</label>
              <select value={addReasonCode} onChange={e => setAddReasonCode(e.target.value)}>
                <option value="violation_policy">Policy Violation</option>
                <option value="harassment">Harassment</option>
                <option value="fraud">Fraud/Scam</option>
                <option value="spam">Spamming</option>
                <option value="abuse">Abuse of Feature</option>
                <option value="other">Other</option>
              </select>
            </div>
            <div className="ud-form-group">
              <label>Detailed Reason</label>
              <textarea
                required
                value={addReason}
                onChange={e => setAddReason(e.target.value)}
                placeholder="Explain why this restriction is being applied..."
                rows={2}
              />
            </div>
            <button
              type="submit"
              className="ud-btn-submit"
              disabled={banMutation.isPending || availableScopes.length === 0}
            >
              {banMutation.isPending ? 'Applying...' : 'Apply Restriction'}
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
              {hasAnyRestriction ? (
                <span className="ud-meta-value" style={{ color: '#ef4444', fontWeight: 600 }}>Restricted</span>
              ) : (
                <span className="ud-meta-value ud-status-active">Active</span>
              )}
            </div>
            <div className="ud-meta-row">
              <span className="ud-meta-label">Registered</span>
              <span className="ud-meta-value">{new Date(user.created_at).toLocaleDateString()}</span>
            </div>
          </div>

          {/* Active Restrictions Section */}
          <div className="ud-restrictions-section">
            <h4 className="ud-section-label">Active Restrictions</h4>
            {ALL_SCOPES.map(scope => {
              const meta = RESTRICTION_SCOPE_META[scope];
              const active = activeMap[scope];
              return (
                <div
                  key={scope}
                  className={`ud-restriction-row ${active ? 'ud-restriction-active' : ''}`}
                  style={active ? { borderLeftColor: meta.color } : {}}
                >
                  <div className="ud-restriction-info">
                    <span className="ud-restriction-icon">{meta.icon}</span>
                    <div>
                      <div className="ud-restriction-label">{meta.label}</div>
                      {active ? (
                        <div className="ud-restriction-detail">
                          {active.expires_at
                            ? `Until ${new Date(active.expires_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}`
                            : 'Permanent'}
                          {active.reason_detail && ` — ${active.reason_detail}`}
                        </div>
                      ) : (
                        <div className="ud-restriction-detail ud-restriction-inactive">Not active</div>
                      )}
                    </div>
                  </div>
                  {active && (
                    <button
                      className="ud-btn-lift"
                      onClick={() => handleLiftRestriction(active.id, meta.label)}
                      disabled={liftBanMutation.isPending}
                    >
                      Lift
                    </button>
                  )}
                </div>
              );
            })}
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
            <div className="ud-stat-card ud-stat-card--warn">
              <div className="ud-stat-label">Active Restrictions</div>
              <div className="ud-stat-value" style={hasAnyRestriction ? { color: '#ef4444' } : {}}>{Object.keys(activeMap).length}</div>
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

        .ud-btn-add-restriction {
          padding: 8px 16px;
          background: var(--color-danger);
          color: #fff;
          border: none;
          border-radius: var(--radius-sm);
          font-size: 14px;
          font-weight: 500;
          cursor: pointer;
        }
        .ud-btn-add-restriction:hover { opacity: 0.88; }

        /* Add Restriction Form */
        .ud-add-form-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-danger);
          border-radius: var(--radius-md);
          padding: 24px;
          margin-bottom: 24px;
          box-shadow: var(--shadow-card);
        }
        .ud-card-title { font-size: 16px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 16px; }
        .ud-add-form { display: flex; flex-direction: column; gap: 16px; }
        .ud-form-row { display: flex; gap: 16px; flex-wrap: wrap; }
        .ud-form-row .ud-form-group { flex: 1; min-width: 140px; }
        .ud-form-group { display: flex; flex-direction: column; gap: 6px; }
        .ud-form-group label { font-size: 12px; font-weight: 600; color: var(--color-text-secondary); text-transform: uppercase; }
        .ud-form-group input, .ud-form-group select, .ud-form-group textarea {
          padding: 10px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-sm);
          font-family: inherit;
          font-size: 14px;
        }
        .ud-btn-submit {
          padding: 10px 16px;
          background: var(--color-danger);
          color: white;
          border: none;
          border-radius: var(--radius-sm);
          font-size: 14px;
          font-weight: 600;
          cursor: pointer;
          align-self: flex-start;
        }
        .ud-btn-submit:disabled { opacity: 0.6; cursor: not-allowed; }

        /* Layout */
        .ud-layout { display: grid; grid-template-columns: 1fr 2fr; gap: 24px; }
        @media (max-width: 768px) { .ud-layout { grid-template-columns: 1fr; } }

        /* Profile Card */
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

        /* Active Restrictions */
        .ud-restrictions-section { border-top: 1px solid var(--color-border-light); padding-top: 16px; }
        .ud-section-label { font-size: 12px; font-weight: 600; color: var(--color-text-secondary); text-transform: uppercase; letter-spacing: 0.5px; margin: 0 0 12px; }
        .ud-restriction-row {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 10px 12px;
          border-radius: var(--radius-sm);
          border-left: 3px solid transparent;
          margin-bottom: 6px;
          transition: background-color 0.2s;
        }
        .ud-restriction-active {
          background: var(--color-bg-secondary);
        }
        .ud-restriction-info { display: flex; align-items: center; gap: 10px; }
        .ud-restriction-icon { font-size: 18px; width: 24px; text-align: center; }
        .ud-restriction-label { font-size: 13px; font-weight: 600; color: var(--color-text-primary); }
        .ud-restriction-detail { font-size: 11px; color: var(--color-text-secondary); margin-top: 2px; }
        .ud-restriction-inactive { color: var(--color-text-tertiary); font-style: italic; }
        .ud-btn-lift {
          padding: 4px 10px;
          font-size: 11px;
          font-weight: 600;
          border-radius: var(--radius-sm);
          border: 1px solid var(--color-success);
          background: transparent;
          color: var(--color-success);
          cursor: pointer;
        }
        .ud-btn-lift:hover { background: var(--color-success-light); }
        .ud-btn-lift:disabled { opacity: 0.5; cursor: not-allowed; }

        /* Main column */
        .ud-main-col { display: flex; flex-direction: column; gap: 24px; }
        .ud-stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
        .ud-stat-card { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); padding: 16px; text-align: center; }
        .ud-stat-card--warn { border-top: 4px solid var(--color-danger); }
        .ud-stat-label { font-size: 13px; font-weight: 500; color: var(--color-text-secondary); margin-bottom: 4px; }
        .ud-stat-value { font-size: 24px; font-weight: 700; color: var(--color-text-primary); }

        /* Tables */
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
      `}</style>
    </div>
  );
}
