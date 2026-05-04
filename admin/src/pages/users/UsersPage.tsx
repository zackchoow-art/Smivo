import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, ChevronLeft, ChevronRight, User } from 'lucide-react';
import { useUsers } from '@/hooks/useUsers';
import { useSchoolScopeStore } from '@/stores/school-scope-store';

import { DEFAULT_PAGE_SIZE, RESTRICTION_SCOPE_META } from '@/lib/constants';

export function UsersPage() {
  const navigate = useNavigate();
  const currentCollegeId = useSchoolScopeStore((state) => state.currentCollegeId);
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState('');
  
  // Filters
  const [status, setStatus] = useState('all');
  const [punished, setPunished] = useState('all');
  
  const { data, isLoading, error } = useUsers(page, { 
    search, 
    schoolId: currentCollegeId || 'all', 
    status, 
    punished 
  });

  const totalPages = data ? Math.ceil(data.totalCount / DEFAULT_PAGE_SIZE) : 0;

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(0);
  };

  const handleFilterChange = (setter: React.Dispatch<React.SetStateAction<string>>, value: string) => {
    setter(value);
    setPage(0);
  };

  return (
    <div className="users-container">
      <header className="users-header">
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <h1 className="page-title">Users</h1>
        </div>
        <div className="users-filters" style={{ marginTop: '16px' }}>
          <div className="filter-group">
            <label>Status</label>
            <select value={status} onChange={(e) => handleFilterChange(setStatus, e.target.value)}>
              <option value="all">All Statuses</option>
              <option value="restricted">Restricted Currently</option>
            </select>
          </div>

          <div className="filter-group">
            <label>History</label>
            <select value={punished} onChange={(e) => handleFilterChange(setPunished, e.target.value)}>
              <option value="all">All Users</option>
              <option value="yes">Has Past Punishments</option>
            </select>
          </div>

          <form className="search-box" onSubmit={handleSearch}>
            <Search size={18} />
            <input 
              type="text" 
              placeholder="Search by name or email..." 
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </form>
        </div>
      </header>

      <div className="users-table-wrapper">
        <table className="users-table">
          <thead>
            <tr>
              <th>User</th>
              <th>Email</th>
              <th>School</th>
              <th>Restrictions</th>
              <th>Last Active</th>
              <th>Joined</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan={6} className="table-loading">Loading users...</td></tr>
            ) : error ? (
              <tr><td colSpan={6} className="table-error">Error loading users</td></tr>
            ) : data?.data.length === 0 ? (
              <tr><td colSpan={6} className="table-empty">No users found</td></tr>
            ) : (
              data?.data.map((user) => {
                const restrictions: string[] = (user as any).active_restrictions || [];
                return (
                  <tr key={user.id} onClick={() => navigate(`/users/${user.id}`)} className="clickable-row">
                    <td>
                      <div className="user-cell">
                        {user.avatar_url ? (
                          <img src={user.avatar_url} alt="" className="user-avatar" />
                        ) : (
                          <div className="user-avatar-placeholder"><User size={14} /></div>
                        )}
                        <span className="user-name">{user.display_name || 'Anonymous'}</span>
                      </div>
                    </td>
                    <td><span className="user-email">{user.email}</span></td>
                    <td>
                      <span className="user-college">{(user as any).school || '—'}</span>
                    </td>
                    <td>
                      {restrictions.length > 0 ? (
                        <div className="restriction-pills">
                          {restrictions.map((scope) => {
                            const meta = RESTRICTION_SCOPE_META[scope];
                            if (!meta) return null;
                            return (
                              <span
                                key={scope}
                                className="restriction-pill"
                                style={{ backgroundColor: meta.bgColor, color: meta.color }}
                                title={meta.description}
                              >
                                {meta.icon} {meta.label}
                              </span>
                            );
                          })}
                        </div>
                      ) : (
                        <span className="no-restrictions">—</span>
                      )}
                    </td>
                    <td>
                      <span className="user-active">
                        {user.last_active_at
                          ? new Date(user.last_active_at).toLocaleString('en-US', {
                              year: 'numeric', month: 'short', day: 'numeric',
                              hour: '2-digit', minute: '2-digit',
                            })
                          : 'Never'}
                      </span>
                    </td>
                    <td><span className="user-joined">{new Date(user.created_at).toLocaleDateString()}</span></td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <footer className="users-footer">
        <span className="pagination-info">
          Showing {page * DEFAULT_PAGE_SIZE + 1} - {Math.min((page + 1) * DEFAULT_PAGE_SIZE, data?.totalCount || 0)} of {data?.totalCount || 0}
        </span>
        <div className="pagination-actions">
          <button 
            className="pagination-btn" 
            disabled={page === 0} 
            onClick={() => setPage(p => p - 1)}
          >
            <ChevronLeft size={18} />
          </button>
          <span className="current-page">Page {page + 1}</span>
          <button 
            className="pagination-btn" 
            disabled={page >= totalPages - 1} 
            onClick={() => setPage(p => p + 1)}
          >
            <ChevronRight size={18} />
          </button>
        </div>
      </footer>

      <style>{`
        .users-container {
          padding: 24px;
          display: flex;
          flex-direction: column;
          gap: 24px;
        }

        .users-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          gap: 24px;
        }

        .page-title {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .users-filters {
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .filter-group {
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .filter-group label {
          font-size: 13px;
          font-weight: 500;
          color: var(--color-text-secondary);
        }

        .filter-group select {
          padding: 8px 12px;
          border: 1px solid var(--color-border-subtle);
          border-radius: var(--radius-md);
          background: var(--color-bg-primary);
          color: var(--color-text-primary);
          font-size: 13px;
          outline: none;
          cursor: pointer;
          transition: border-color 0.2s;
        }

        .filter-group select:focus {
          border-color: var(--color-primary);
        }

        .search-box {
          display: flex;
          align-items: center;
          gap: 10px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-subtle);
          border-radius: var(--radius-md);
          padding: 8px 14px;
          min-width: 250px;
          color: var(--color-text-tertiary);
          transition: border-color 0.2s;
        }

        .search-box:focus-within {
          border-color: var(--color-primary);
        }

        .search-box input {
          border: none;
          background: transparent;
          font-size: 14px;
          color: var(--color-text-primary);
          width: 100%;
          outline: none;
        }

        .users-table-wrapper {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-subtle);
          border-radius: var(--radius-md);
          overflow: hidden;
        }

        .users-table {
          width: 100%;
          border-collapse: collapse;
          text-align: left;
        }

        .users-table th {
          background: var(--color-bg-secondary);
          padding: 12px 16px;
          font-size: 12px;
          font-weight: 600;
          color: var(--color-text-secondary);
          text-transform: uppercase;
          letter-spacing: 0.05em;
        }

        .users-table td {
          padding: 16px;
          border-bottom: 1px solid var(--color-border-subtle);
          font-size: 14px;
          color: var(--color-text-primary);
        }

        .clickable-row {
          cursor: pointer;
          transition: background-color 0.2s;
        }

        .clickable-row:hover {
          background-color: var(--color-bg-tertiary);
        }

        .user-cell {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .user-avatar, .user-avatar-placeholder {
          width: 32px;
          height: 32px;
          border-radius: 50%;
          object-fit: cover;
          background: var(--color-bg-tertiary);
          display: flex;
          align-items: center;
          justify-content: center;
          color: var(--color-text-tertiary);
        }

        .user-name {
          font-weight: 500;
        }

        .user-email {
          color: var(--color-text-secondary);
        }

        .user-college {
          color: var(--color-text-secondary);
          font-size: 13px;
        }

        .restriction-pills {
          display: flex;
          flex-wrap: wrap;
          gap: 4px;
        }

        .restriction-pill {
          display: inline-flex;
          align-items: center;
          gap: 3px;
          padding: 2px 8px;
          border-radius: 12px;
          font-size: 11px;
          font-weight: 600;
          white-space: nowrap;
        }

        .no-restrictions {
          color: var(--color-text-tertiary);
          font-size: 13px;
        }

        .user-active, .user-joined {
          color: var(--color-text-tertiary);
          font-size: 13px;
        }

        .table-loading, .table-error, .table-empty {
          text-align: center;
          padding: 48px;
          color: var(--color-text-tertiary);
        }

        .users-footer {
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
          width: 32px;
          height: 32px;
          display: flex;
          align-items: center;
          justify-content: center;
          border: 1px solid var(--color-border-subtle);
          background: var(--color-bg-primary);
          border-radius: var(--radius-sm);
          color: var(--color-text-secondary);
          cursor: pointer;
        }

        .pagination-btn:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .current-page {
          font-size: 13px;
          font-weight: 500;
          color: var(--color-text-primary);
        }
      `}</style>
      
    </div>
  );
}
