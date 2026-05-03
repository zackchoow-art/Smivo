import { useState } from 'react';
import { 
  Filter, 
  ChevronLeft, 
  ChevronRight, 
  UserMinus, 
  UserPlus, 
  Search,
  X
} from 'lucide-react';
import { useBans, useCreateBan, useLiftBan } from '@/hooks/useBans';
import { useAuth } from '@/hooks/useAuth';
import { UserSummaryPopup } from '@/components/users/UserSummaryPopup';
import { DEFAULT_PAGE_SIZE, BAN_TYPES, RESTRICTION_SCOPE_META, TABLES } from '@/lib/constants';
import { supabase } from '@/lib/supabase';
import type { BanType, BanStatus, RestrictionScope } from '@/types/ban';
import type { UserProfile } from '@/types/user-profile';
import { showToast } from '@/hooks/useToast';


export function BansPage() {
  const [page, setPage] = useState(0);
  const [status, setStatus] = useState<BanStatus | ''>('active');
  const [type, setType] = useState<BanType | ''>('');
  const [scopeFilter, setScopeFilter] = useState<RestrictionScope | ''>('');
  const [isModalOpen, setIsModalOpen] = useState(false);

  const { data, isLoading, error } = useBans(page, {
    status: status || undefined,
    type: type || undefined,
    scope: scopeFilter || undefined,
  });

  const liftBanMutation = useLiftBan();
  const { admin } = useAuth();

  const handleLiftBan = async (banId: string) => {
    if (!admin) return;
    const reason = prompt('Reason for lifting the ban:');
    if (!reason) return;

    try {
      await liftBanMutation.mutateAsync({
        banId,
        liftReason: reason,
        adminId: admin.user_id
      });
      showToast('Ban lifted successfully ✅', 'success');
    } catch (err) {
      console.error(err);
      showToast('Failed to lift ban. Please try again.', 'error', 5000);
    }
  };

  const totalPages = data ? Math.ceil(data.totalCount / DEFAULT_PAGE_SIZE) : 0;

  return (
    <div className="bans-container">
      <header className="bans-header">
        <div className="header-left">
          <h1 className="page-title">User Ban Management</h1>
          <p className="page-subtitle">Manage system-level restrictions and account suspensions</p>
        </div>
        <button className="create-btn" onClick={() => setIsModalOpen(true)}>
          <UserPlus size={18} />
          Create New Ban
        </button>
      </header>

      <div className="filters-bar">
        <div className="filter-group">
          <Filter size={14} />
          <select 
            value={type} 
            onChange={(e) => { setType(e.target.value as BanType | ''); setPage(0); }}
          >
            <option value="">All Types</option>
            {Object.entries(BAN_TYPES).map(([key, value]) => (
              <option key={key} value={value}>{value.toUpperCase()}</option>
            ))}
          </select>
        </div>
        <div className="filter-group">
          <select 
            value={scopeFilter} 
            onChange={(e) => { setScopeFilter(e.target.value as RestrictionScope | ''); setPage(0); }}
          >
            <option value="">All Scopes</option>
            {Object.entries(RESTRICTION_SCOPE_META).map(([key, meta]) => (
              <option key={key} value={key}>{meta.icon} {meta.label}</option>
            ))}
          </select>
        </div>
        <div className="filter-group">
          <select 
            value={status} 
            onChange={(e) => { setStatus(e.target.value as BanStatus | ''); setPage(0); }}
          >
            <option value="">All Statuses</option>
            <option value="active">Active</option>
            <option value="expired">Expired</option>
            <option value="lifted">Lifted</option>
          </select>
        </div>
      </div>

      <div className="bans-table-wrapper">
        <table className="bans-table">
          <thead>
            <tr>
              <th>User</th>
              <th>Scope</th>
              <th>Type</th>
              <th>Reason</th>
              <th>Status</th>
              <th>Expires At</th>
              <th>Banned By</th>
              <th className="actions-cell">Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan={8} className="table-loading">Loading bans...</td></tr>
            ) : error ? (
              <tr><td colSpan={8} className="table-error">Error loading bans</td></tr>
            ) : data?.data.length === 0 ? (
              <tr><td colSpan={8} className="table-empty">No ban records found</td></tr>
            ) : (
              data?.data.map((item) => {
                const scopeMeta = RESTRICTION_SCOPE_META[item.scope] || { icon: '❓', label: item.scope, color: '#666', bgColor: '#eee' };
                return (
                  <tr key={item.id}>
                    <td className="user-cell">
                      <div className="user-name">{item.user_display_name || 'User'}</div>
                      <div className="user-email">{item.user_email}</div>
                    </td>
                    <td>
                      <span className="scope-badge" style={{ backgroundColor: scopeMeta.bgColor, color: scopeMeta.color }}>
                        {scopeMeta.icon} {scopeMeta.label}
                      </span>
                    </td>
                    <td><BanTypeBadge type={item.ban_type} /></td>
                    <td className="reason-cell">
                      <div className="reason-code">{item.reason_code}</div>
                      <div className="reason-detail">{item.reason_detail}</div>
                    </td>
                    <td><BanStatusBadge status={item.status} /></td>
                    <td className="time-cell">
                      {item.expires_at ? new Date(item.expires_at).toLocaleDateString() : 'Permanent'}
                    </td>
                    <td><span className="admin-name">{item.banned_by_name || 'Admin'}</span></td>
                    <td className="actions-cell">
                      {item.status === 'active' && (
                        <button 
                          className="lift-btn" 
                          onClick={() => handleLiftBan(item.id)}
                          disabled={liftBanMutation.isPending}
                        >
                          <UserMinus size={14} /> Lift
                        </button>
                      )}
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>

      <footer className="bans-footer">
        <span className="pagination-info">
          Showing {page * DEFAULT_PAGE_SIZE + 1} - {Math.min((page + 1) * DEFAULT_PAGE_SIZE, data?.totalCount || 0)} of {data?.totalCount || 0}
        </span>
        <div className="pagination-actions">
          <button className="pagination-btn" disabled={page === 0} onClick={() => setPage(p => p - 1)}>
            <ChevronLeft size={18} />
          </button>
          <span className="current-page">Page {page + 1}</span>
          <button className="pagination-btn" disabled={page >= totalPages - 1} onClick={() => setPage(p => p + 1)}>
            <ChevronRight size={18} />
          </button>
        </div>
      </footer>

      {isModalOpen && <CreateBanModal onClose={() => setIsModalOpen(false)} />}

      <style>{`
        .bans-container {
          padding: var(--spacing-page);
          display: flex;
          flex-direction: column;
          gap: 24px;
        }

        .bans-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
        }

        .page-title {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
          margin-bottom: 4px;
        }

        .page-subtitle {
          font-size: 14px;
          color: var(--color-text-tertiary);
        }

        .create-btn {
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 10px 16px;
          background: var(--color-info);
          color: white;
          border: none;
          border-radius: var(--radius-md);
          font-size: 14px;
          font-weight: 600;
          cursor: pointer;
          transition: background-color 0.2s;
        }

        .create-btn:hover {
          background: #3b5bdb;
        }

        .filters-bar {
          display: flex;
          gap: 12px;
        }

        .filter-group {
          display: flex;
          align-items: center;
          gap: 8px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          padding: 6px 12px;
          color: var(--color-text-tertiary);
        }

        .filter-group select {
          border: none;
          background: transparent;
          font-size: 13px;
          color: var(--color-text-primary);
          outline: none;
          cursor: pointer;
        }

        .bans-table-wrapper {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          overflow: hidden;
          box-shadow: var(--shadow-card);
        }

        .bans-table {
          width: 100%;
          border-collapse: collapse;
          text-align: left;
        }

        .bans-table th {
          background: var(--color-bg-tertiary);
          padding: 12px 16px;
          font-size: 12px;
          font-weight: 600;
          color: var(--color-text-secondary);
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        .bans-table td {
          padding: 16px;
          border-bottom: 1px solid var(--color-border-light);
        }

        .user-cell {
          display: flex;
          flex-direction: column;
          gap: 2px;
        }

        .user-name {
          font-size: 14px;
          font-weight: 600;
          color: var(--color-text-primary);
        }

        .user-email {
          font-size: 12px;
          color: var(--color-text-tertiary);
        }

        .reason-cell {
          max-width: 300px;
        }

        .reason-code {
          font-size: 12px;
          font-weight: 700;
          color: var(--color-danger);
          text-transform: uppercase;
          margin-bottom: 4px;
        }

        .reason-detail {
          font-size: 13px;
          color: var(--color-text-secondary);
          display: -webkit-box;
          -webkit-line-clamp: 2;
          -webkit-box-orient: vertical;
          overflow: hidden;
        }

        .badge {
          display: inline-flex;
          align-items: center;
          padding: 2px 8px;
          border-radius: 12px;
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
        }

        .scope-badge {
          display: inline-flex;
          align-items: center;
          gap: 3px;
          padding: 3px 10px;
          border-radius: 12px;
          font-size: 11px;
          font-weight: 600;
          white-space: nowrap;
        }

        .time-cell {
          font-size: 12px;
          color: var(--color-text-secondary);
          font-family: var(--font-mono);
        }

        .admin-name {
          font-size: 13px;
          color: var(--color-text-secondary);
        }

        .actions-cell {
          text-align: right;
        }

        .lift-btn {
          display: inline-flex;
          align-items: center;
          gap: 4px;
          padding: 4px 10px;
          font-size: 12px;
          font-weight: 600;
          border-radius: var(--radius-sm);
          border: 1px solid var(--color-danger);
          background: transparent;
          color: var(--color-danger);
          cursor: pointer;
          transition: all 0.2s;
        }

        .lift-btn:hover {
          background: var(--color-danger-light);
        }

        .table-loading, .table-error, .table-empty {
          text-align: center;
          padding: 64px;
          color: var(--color-text-tertiary);
        }

        .bans-footer {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .pagination-info {
          font-size: 13px;
          color: var(--color-text-secondary);
        }

        .pagination-actions {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .pagination-btn {
          width: 36px;
          height: 36px;
          display: flex;
          align-items: center;
          justify-content: center;
          border: 1px solid var(--color-border);
          background: var(--color-bg-primary);
          border-radius: var(--radius-sm);
          color: var(--color-text-secondary);
          cursor: pointer;
        }

        .pagination-btn:disabled {
          opacity: 0.4;
          cursor: not-allowed;
        }

        .current-page {
          font-size: 13px;
          font-weight: 600;
          color: var(--color-text-primary);
        }
      `}</style>
    </div>
  );
}

function CreateBanModal({ onClose }: { onClose: () => void }) {
  const { admin } = useAuth();
  const createBanMutation = useCreateBan();

  const [searchQuery, setSearchQuery] = useState('');
  const [foundUsers, setFoundUsers] = useState<UserProfile[]>([]);
  const [selectedUser, setSelectedUser] = useState<UserProfile | null>(null);
  const [banType, setBanType] = useState<BanType>('temporary');
  const [banScope, setBanScope] = useState<RestrictionScope>('chat_mute');
  const [duration, setDuration] = useState('7');
  const [reasonCode, setReasonCode] = useState('violation_policy');
  const [reasonDetail, setReasonDetail] = useState('');
  const [isSearching, setIsSearching] = useState(false);
  const [popupUser, setPopupUser] = useState<string | null>(null);

  const searchUsers = async () => {
    if (!searchQuery.trim()) return;
    setIsSearching(true);
    try {
      const { data, error } = await supabase
        .from(TABLES.USER_PROFILES)
        .select('*')
        .or(`display_name.ilike.%${searchQuery}%,email.ilike.%${searchQuery}%`)
        .limit(5);
      
      if (error) throw error;
      setFoundUsers(data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setIsSearching(false);
    }
  };

  const handleCreate = async () => {
    if (!selectedUser || !admin) return;
    
    try {
      await createBanMutation.mutateAsync({
        userId: selectedUser.id,
        collegeId: selectedUser.college_id,
        banType,
        scope: banScope,
        reasonCode,
        reasonDetail,
        durationDays: banType === 'temporary' ? parseFloat(duration) : null,
        adminId: admin.user_id
      });
      showToast('User banned successfully ✅', 'success');
      onClose();
    } catch (err) {
      console.error(err);
      showToast('Failed to create ban. Please try again.', 'error', 5000);
    }
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <header className="modal-header">
          <h2>Create New Ban</h2>
          <button className="close-btn" onClick={onClose}><X size={20} /></button>
        </header>

        <div className="modal-body">
          {!selectedUser ? (
            <div className="user-search-section">
              <label>Search User</label>
              <div className="search-input-group">
                <input 
                  type="text" 
                  placeholder="Email or Name..." 
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && searchUsers()}
                />
                <button onClick={searchUsers} disabled={isSearching}>
                  <Search size={18} />
                </button>
              </div>
              
              <div className="search-results">
                {foundUsers.map(u => (
                  <div key={u.id} className="search-result-item" onClick={() => setSelectedUser(u)}>
                    <div className="result-name">{u.display_name}</div>
                    <div className="result-email">{u.email}</div>
                  </div>
                ))}
                {foundUsers.length === 0 && searchQuery && !isSearching && (
                  <div className="no-results">No users found</div>
                )}
              </div>
            </div>
          ) : (
            <div className="ban-details-section">
              <div className="selected-user-card" style={{ position: 'relative', cursor: 'pointer' }} onClick={() => setPopupUser(selectedUser.id)}>
                <div className="user-info">
                  <div className="user-name">{selectedUser.display_name}</div>
                  <div className="user-email">{selectedUser.email}</div>
                </div>
                <button 
                  className="change-btn" 
                  onClick={(e) => {
                    e.stopPropagation();
                    setSelectedUser(null);
                  }}
                >
                  Change
                </button>
                {popupUser === selectedUser.id && (
                  <UserSummaryPopup userId={selectedUser.id} onClose={() => setPopupUser(null)} />
                )}
              </div>

              <div className="form-group">
                <label>Restriction Scope</label>
                <select value={banScope} onChange={(e) => setBanScope(e.target.value as RestrictionScope)}>
                  {Object.entries(RESTRICTION_SCOPE_META).map(([key, meta]) => (
                    <option key={key} value={key}>{meta.icon} {meta.label} — {meta.description}</option>
                  ))}
                </select>
              </div>

              <div className="form-grid">
                <div className="form-group">
                  <label>Duration Type</label>
                  <select value={banType} onChange={(e) => setBanType(e.target.value as BanType)}>
                    <option value="temporary">Temporary</option>
                    <option value="permanent">Permanent</option>
                  </select>
                </div>

                {banType === 'temporary' && (
                  <div className="form-group">
                    <label>Duration (Days)</label>
                    <select value={duration} onChange={(e) => setDuration(e.target.value)}>
                      <option value="1">1 Day</option>
                      <option value="0.000694444">1 Minute (Test)</option>
                      <option value="0.003472222">5 Minutes (Test)</option>
                      <option value="3">3 Days</option>
                      <option value="7">7 Days</option>
                      <option value="14">14 Days</option>
                      <option value="30">30 Days</option>
                      <option value="90">90 Days</option>
                      <option value="180">180 Days</option>
                    </select>
                  </div>
                )}
              </div>

              <div className="form-group">
                <label>Reason Category</label>
                <select value={reasonCode} onChange={(e) => setReasonCode(e.target.value)}>
                  <option value="violation_policy">Policy Violation</option>
                  <option value="harassment">Harassment</option>
                  <option value="fraud">Fraud/Scam</option>
                  <option value="spam">Spamming</option>
                  <option value="abuse">Abuse of Feature</option>
                  <option value="other">Other</option>
                </select>
              </div>

              <div className="form-group">
                <label>Detailed Reason</label>
                <textarea 
                  placeholder="Explain why this user is being banned..."
                  value={reasonDetail}
                  onChange={(e) => setReasonDetail(e.target.value)}
                  rows={3}
                />
              </div>
            </div>
          )}
        </div>

        <footer className="modal-footer">
          <button className="cancel-btn" onClick={onClose}>Cancel</button>
          <button 
            className="confirm-btn" 
            disabled={!selectedUser || createBanMutation.isPending}
            onClick={handleCreate}
          >
            {createBanMutation.isPending ? 'Processing...' : 'Execute Ban'}
          </button>
        </footer>
      </div>

      <style>{`
        .modal-overlay {
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: rgba(0, 0, 0, 0.5);
          display: flex;
          align-items: center;
          justify-content: center;
          z-index: 1000;
          backdrop-filter: blur(4px);
        }

        .modal-content {
          background: var(--color-bg-primary);
          width: 500px;
          max-width: 90vw;
          border-radius: var(--radius-lg);
          box-shadow: var(--shadow-modal);
          overflow: hidden;
          display: flex;
          flex-direction: column;
        }

        .modal-header {
          padding: 20px;
          border-bottom: 1px solid var(--color-border-light);
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .modal-header h2 {
          font-size: 18px;
          font-weight: 700;
        }

        .close-btn {
          background: none;
          border: none;
          color: var(--color-text-tertiary);
          cursor: pointer;
        }

        .modal-body {
          padding: 24px;
        }

        .form-group {
          margin-bottom: 16px;
        }

        .form-group label {
          display: block;
          font-size: 13px;
          font-weight: 600;
          color: var(--color-text-secondary);
          margin-bottom: 6px;
        }

        .search-input-group {
          display: flex;
          gap: 8px;
        }

        .search-input-group input {
          flex: 1;
          padding: 10px 12px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          outline: none;
        }

        .search-input-group button {
          width: 42px;
          display: flex;
          align-items: center;
          justify-content: center;
          background: var(--color-info);
          color: white;
          border: none;
          border-radius: var(--radius-md);
          cursor: pointer;
        }

        .search-results {
          margin-top: 12px;
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-md);
          max-height: 200px;
          overflow-y: auto;
        }

        .search-result-item {
          padding: 10px 16px;
          border-bottom: 1px solid var(--color-border-light);
          cursor: pointer;
          transition: background-color 0.2s;
        }

        .search-result-item:hover {
          background: var(--color-bg-secondary);
        }

        .result-name {
          font-weight: 600;
          font-size: 14px;
        }

        .result-email {
          font-size: 12px;
          color: var(--color-text-tertiary);
        }

        .no-results {
          padding: 20px;
          text-align: center;
          color: var(--color-text-tertiary);
          font-size: 13px;
        }

        .selected-user-card {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 12px 16px;
          background: var(--color-bg-secondary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          margin-bottom: 20px;
        }

        .change-btn {
          font-size: 12px;
          color: var(--color-info);
          background: none;
          border: none;
          font-weight: 600;
          cursor: pointer;
        }

        .form-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 16px;
        }

        select, textarea {
          width: 100%;
          padding: 10px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          font-family: inherit;
          font-size: 14px;
          outline: none;
        }

        .modal-footer {
          padding: 20px;
          background: var(--color-bg-secondary);
          display: flex;
          justify-content: flex-end;
          gap: 12px;
        }

        .cancel-btn {
          padding: 10px 20px;
          background: white;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          font-size: 14px;
          font-weight: 600;
          cursor: pointer;
        }

        .confirm-btn {
          padding: 10px 24px;
          background: var(--color-danger);
          color: white;
          border: none;
          border-radius: var(--radius-md);
          font-size: 14px;
          font-weight: 700;
          cursor: pointer;
        }

        .confirm-btn:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
      `}</style>
    </div>
  );
}

function BanTypeBadge({ type }: { type: BanType }) {
  const isPerm = type === 'permanent';
  return (
    <span 
      className="badge" 
      style={{ 
        backgroundColor: isPerm ? 'var(--color-danger-light)' : 'var(--color-warning-light)', 
        color: isPerm ? 'var(--color-danger)' : 'var(--color-warning)' 
      }}
    >
      {type}
    </span>
  );
}

function BanStatusBadge({ status }: { status: BanStatus }) {
  const styles: Record<BanStatus, { bg: string, text: string }> = {
    active: { bg: 'var(--color-danger-light)', text: 'var(--color-danger)' },
    expired: { bg: 'var(--color-bg-tertiary)', text: 'var(--color-text-tertiary)' },
    lifted: { bg: 'var(--color-success-light)', text: 'var(--color-success)' },
  };
  const style = styles[status] || styles.active;
  return <span className="badge" style={{ backgroundColor: style.bg, color: style.text }}>{status}</span>;
}
