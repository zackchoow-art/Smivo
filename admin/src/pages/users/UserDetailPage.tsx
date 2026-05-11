import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useUserDetail, useUserSummary, useAdminDeleteUser, useUpdateUserSchool } from '@/hooks/useUsers';
import { useCreateBan, useLiftBan, useUserActiveRestrictions } from '@/hooks/useBans';
import { useAuth } from '@/hooks/useAuth';
import { isSysadmin } from '@/stores/auth-store';
import { useColleges } from '@/hooks/useColleges';
import { RESTRICTION_SCOPE_META } from '@/lib/constants';
import type { BanType, RestrictionScope } from '@/types/ban';
import { Unlock, Shield, AlertTriangle, Trash2, Edit2, Check, X } from 'lucide-react';
import { showToast } from '@/hooks/useToast';


const ALL_SCOPES: RestrictionScope[] = ['chat_mute', 'listing_ban', 'feedback_ban', 'account_freeze'];

const REASON_SHORTCUTS = [
  '',
  'Multiple reports of spam/scam',
  'Selling prohibited items',
  'Using abusive language in chat',
  'Circumventing platform fees',
  'Evading previous ban',
  'Violating community guidelines',
];

export function UserDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data, isLoading, error } = useUserDetail(id);
  const { data: summary } = useUserSummary(id ?? null);
  const { roles } = useAuth();
  const userId = roles[0]?.user_id;
  const { data: activeRestrictions, refetch: refetchRestrictions } = useUserActiveRestrictions(id);
  const banMutation     = useCreateBan();
  const liftBanMutation = useLiftBan();
  const deleteMutation  = useAdminDeleteUser();

  // State for the "Add Restriction" form
  const [showAddForm, setShowAddForm] = useState(false);
  const [addScope, setAddScope] = useState<RestrictionScope>('chat_mute');
  const [addType, setAddType] = useState<BanType>('temporary');
  const [addDuration, setAddDuration] = useState(7);
  const [addReason, setAddReason] = useState('');
  const [shortcutReason, setShortcutReason] = useState('');
  const [addReasonCode, setAddReasonCode] = useState('violation_policy');

  // State for editing school
  const [isEditingSchool, setIsEditingSchool] = useState(false);
  const [editSchoolId, setEditSchoolId] = useState('');
  
  const { data: colleges } = useColleges();
  const updateSchoolMutation = useUpdateUserSchool();

  // Build a map of scope -> active restriction record
  const activeMap: Record<string, any> = {};
  if (activeRestrictions) {
    for (const r of activeRestrictions) {
      activeMap[r.scope] = r;
    }
  }

  const hasAnyRestriction = Object.keys(activeMap).length > 0;

  // Scopes that are not yet active (available for adding)
  const availableScopes = ALL_SCOPES.filter(s => !activeMap[s]);

  // Keep addScope synced with available options
  useEffect(() => {
    if (availableScopes.length > 0 && !availableScopes.includes(addScope)) {
      setAddScope(availableScopes[0]);
    }
  }, [availableScopes, addScope]);

  if (isLoading) return <div className="ud-state-msg">Loading user details...</div>;
  if (error || !data) return <div className="ud-state-msg ud-state-error">Failed to load user.</div>;

  const { user, listings, orders } = data;

  const handleAddRestriction = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!userId) return;
    try {
      await banMutation.mutateAsync({
        userId: user.id,
        collegeId: (user as any).school_id || '',
        banType: addType,
        scope: addScope,
        reasonCode: addReasonCode,
        reasonDetail: addReason.trim() || shortcutReason,
        durationDays: addType === 'temporary' ? addDuration : null,
        adminId: userId,
      });
      setShowAddForm(false);
      setAddReason('');
      setShortcutReason('');
      refetchRestrictions();
    } catch (err) {
      console.error(err);
      showToast('Failed to add restriction. Please try again.', 'error', 5000);
    }
  };

  const handleLiftRestriction = async (banId: string, scopeLabel: string) => {
    if (!userId) return;
    const reason = prompt(`Reason for lifting "${scopeLabel}":`);
    if (!reason) return;

    try {
      await liftBanMutation.mutateAsync({
        banId,
        adminId: userId,
        liftReason: reason,
      });
      refetchRestrictions();
    } catch (err) {
      console.error(err);
      showToast('Failed to lift restriction. Please try again.', 'error', 5000);
    }
  };

  const handleDeleteUser = async () => {
    if (!user) return;
    // NOTE: Double-confirm for destructive action. Soft-delete preserves
    // completed orders and chat history for counterparties.
    const first = confirm(
      `⚠️ Delete user "${user.display_name || user.email}"?\n\nThis will:\n• Delist all their active listings\n• Cancel all pending/active orders\n• Send farewell message to all chat rooms\n• Anonymize their profile\n• Ban their account and force logout\n\nCompleted orders and chat history are preserved.`
    );
    if (!first) return;
    const second = confirm(
      `Final confirmation: delete user ${user.email}?\n\nThe user will be able to re-register with the same email later.`
    );
    if (!second) return;

    try {
      await deleteMutation.mutateAsync(user.id);
      showToast(`User ${user.email} has been deleted and anonymized.`, 'success');
      navigate('/users');
    } catch (err: any) {
      console.error(err);
      showToast(err?.message || 'Failed to delete user.', 'error', 6000);
    }
  };

  const handleUpdateSchool = async () => {
    if (!editSchoolId) return;
    try {
      await updateSchoolMutation.mutateAsync({ userId: user.id, schoolId: editSchoolId });
      showToast('User school updated successfully', 'success');
      setIsEditingSchool(false);
    } catch (err: any) {
      console.error(err);
      showToast(err?.message || 'Failed to update school', 'error');
    }
  };

  // availableScopes moved above

  return (
    <div className="ud-container">
      <div className="ud-header">
        <button onClick={() => navigate(-1)} className="ud-btn-back">&larr; Back to Users</button>
        <h1 className="ud-page-title">User Details</h1>
        <div className="ud-header-actions">
          <button onClick={() => setShowAddForm(!showAddForm)} className="ud-btn-add-restriction">
            {showAddForm ? 'Cancel' : '+ Add Restriction'}
          </button>
          {isSysadmin(roles) && (
            <button
              onClick={handleDeleteUser}
              className="ud-btn-delete-user"
              disabled={deleteMutation.isPending}
              title="Permanently delete this user and all their data"
            >
              <Trash2 size={14} />
              {deleteMutation.isPending ? 'Deleting…' : 'Delete User'}
            </button>
          )}
        </div>
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
                  <select value={addDuration} onChange={e => setAddDuration(parseFloat(e.target.value))}>
                    <option value={1}>1 Day</option>
                    <option value={0.000694444}>1 Minute (Test)</option>
                    <option value={0.003472222}>5 Minutes (Test)</option>
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
              <select 
                value={shortcutReason} 
                onChange={e => setShortcutReason(e.target.value)}
                style={{ marginBottom: '8px' }}
              >
                <option value="">-- Or choose a quick reason --</option>
                {REASON_SHORTCUTS.filter(Boolean).map(r => (
                  <option key={r} value={r}>{r}</option>
                ))}
              </select>
              <textarea
                value={addReason}
                onChange={e => setAddReason(e.target.value)}
                placeholder="Or type a custom explanation..."
                rows={2}
              />
            </div>
            <button
              type="submit"
              className="ud-btn-submit"
              disabled={banMutation.isPending || availableScopes.length === 0 || (!addReason.trim() && !shortcutReason)}
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
              <div className="ud-avatar-placeholder">{user.email?.[0]?.toUpperCase() || '?'}</div>
            )}
            <h2 className="ud-display-name">{user.display_name || 'No Name'}</h2>
            <p className="ud-email">{user.email || 'No email'}</p>
          </div>
          <div className="ud-profile-meta">
            <div className="ud-meta-row">
              <span className="ud-meta-label">School</span>
              {isEditingSchool ? (
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <select 
                    value={editSchoolId} 
                    onChange={e => setEditSchoolId(e.target.value)}
                    style={{ padding: '4px', borderRadius: '4px', border: '1px solid var(--color-border)' }}
                  >
                    <option value="" disabled>Select a school...</option>
                    {colleges?.map(c => (
                      <option key={c.id} value={c.id}>{c.name}</option>
                    ))}
                  </select>
                  <button onClick={handleUpdateSchool} disabled={updateSchoolMutation.isPending} title="Save" style={{ color: 'var(--color-primary)' }}>
                    <Check size={16} />
                  </button>
                  <button onClick={() => setIsEditingSchool(false)} title="Cancel" style={{ color: 'var(--color-text-tertiary)' }}>
                    <X size={16} />
                  </button>
                </div>
              ) : (
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span className="ud-meta-value">{(user as any).school || '—'}</span>
                  {/* NOTE: Only sysadmin can reassign a user's school to prevent cross-school tampering */}
                  {isSysadmin(roles) && (
                    <button 
                      onClick={() => {
                        setEditSchoolId((user as any).school_id || '');
                        setIsEditingSchool(true);
                      }} 
                      style={{ color: 'var(--color-text-tertiary)', background: 'transparent', border: 'none', cursor: 'pointer', padding: 0 }}
                      title="Edit School"
                    >
                      <Edit2 size={14} />
                    </button>
                  )}
                </div>
              )}
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
            
            {summary && (
              <div className="ud-punishment-stats">
                <div className="ud-punishment-row">
                  <span className="ud-punishment-label"><Shield size={14} /> Violations (Reported)</span>
                  <span className="ud-punishment-value">{summary.reportsCount}</span>
                </div>
                <div className="ud-punishment-row">
                  <span className="ud-punishment-label"><AlertTriangle size={14} /> Total Punishments</span>
                  <span className="ud-punishment-value">{summary.punishmentsCount}</span>
                </div>
              </div>
            )}

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
                      className="ud-btn-lift-icon"
                      title="Cancel Restriction"
                      onClick={() => handleLiftRestriction(active.id, meta.label)}
                      disabled={liftBanMutation.isPending}
                    >
                      <Unlock size={16} />
                    </button>
                  )}
                </div>
              );
            })}
          </div>

          {/* Device Telemetry Section */}
          <div className="ud-telemetry-section" style={{ borderTop: '1px solid var(--color-border-light)', paddingTop: '16px', marginTop: '16px' }}>
            <h4 className="ud-section-label">Device Telemetry</h4>
            {data.heartbeat ? (
              <div style={{ fontSize: '13px', color: 'var(--color-text-secondary)', display: 'flex', flexDirection: 'column', gap: '6px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}><span>Last Seen:</span> <span style={{ color: 'var(--color-text-primary)' }}>{new Date(data.heartbeat.last_seen_at).toLocaleString()}</span></div>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}><span>App Version:</span> <span style={{ color: 'var(--color-text-primary)' }}>{data.heartbeat.app_version || '—'} ({data.heartbeat.build_number || '—'})</span></div>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}><span>OS Version:</span> <span style={{ color: 'var(--color-text-primary)' }}>{data.heartbeat.os_version || '—'}</span></div>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}><span>Device Model:</span> <span style={{ color: 'var(--color-text-primary)' }}>{data.heartbeat.device_model || '—'}</span></div>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}><span>Platform:</span> <span style={{ color: 'var(--color-text-primary)' }}>{data.heartbeat.platform || '—'}</span></div>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}><span>IP Address:</span> <span style={{ color: 'var(--color-text-primary)' }}>{data.heartbeat.ip_address || '—'}</span></div>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}><span>Locale:</span> <span style={{ color: 'var(--color-text-primary)' }}>{data.heartbeat.locale || '—'}</span></div>
              </div>
            ) : (
              <div style={{ fontSize: '13px', color: 'var(--color-text-tertiary)', fontStyle: 'italic' }}>No telemetry data available.</div>
            )}
          </div>
        </div>

        {/* Stats and Lists */}
        <div className="ud-main-col">
          <div className="ud-stats-grid">
            <div className="ud-stat-card">
              <div className="ud-stat-label">Rating</div>
              <div className="ud-stat-value">{Number((user as any).seller_rating || 0).toFixed(1)}</div>
            </div>
            <div className="ud-stat-card">
              <div className="ud-stat-label">Contribution</div>
              <div className="ud-stat-value">{(user as any).contribution_score || 0}</div>
            </div>
            <div className="ud-stat-card">
              <div className="ud-stat-label">Listings</div>
              <div className="ud-stat-value">{listings.length}</div>
            </div>
            <div className="ud-stat-card">
              <div className="ud-stat-label">Orders</div>
              <div className="ud-stat-value">{orders.length}</div>
            </div>
            <div className="ud-stat-card ud-stat-card--warn">
              <div className="ud-stat-label">Restrictions</div>
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
        
        .ud-punishment-stats { display: flex; flex-direction: column; gap: 8px; font-size: 13px; margin-bottom: 16px; background: var(--color-bg-secondary); padding: 12px; border-radius: var(--radius-sm); }
        .ud-punishment-row { display: flex; justify-content: space-between; align-items: center; color: var(--color-text-secondary); }
        .ud-punishment-label { display: flex; align-items: center; gap: 6px; }
        .ud-punishment-value { font-weight: 600; color: var(--color-text-primary); }
        
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
        .ud-btn-lift-icon {
          padding: 6px;
          border-radius: var(--radius-sm);
          border: 1px solid transparent;
          background: transparent;
          color: var(--color-text-tertiary);
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
          transition: all 0.2s;
        }
        .ud-btn-lift-icon:hover { background: var(--color-success-light); color: var(--color-success); border-color: var(--color-success); }
        .ud-btn-lift-icon:disabled { opacity: 0.5; cursor: not-allowed; }

        /* Main column */
        .ud-main-col { display: flex; flex-direction: column; gap: 24px; }
        .ud-stats-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; }
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

        /* Header actions group */
        .ud-header-actions { display: flex; align-items: center; gap: 10px; margin-left: auto; }

        /* Delete User button — destructive, shown in red */
        .ud-btn-delete-user {
          display: flex; align-items: center; gap: 6px;
          padding: 8px 14px; font-size: 13px; font-weight: 500;
          border: 1.5px solid var(--color-danger);
          background: transparent; color: var(--color-danger);
          border-radius: var(--radius-md); cursor: pointer;
          transition: all 0.15s; white-space: nowrap;
        }
        .ud-btn-delete-user:hover:not(:disabled) {
          background: var(--color-danger); color: #fff;
        }
        .ud-btn-delete-user:disabled { opacity: 0.5; cursor: not-allowed; }
      `}</style>
    </div>
  );
}
