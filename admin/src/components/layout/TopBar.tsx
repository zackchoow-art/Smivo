/**
 * Top bar with breadcrumb, school switcher, and admin avatar.
 * Defined in 04_ADMIN_WEB_SPEC.md §4.1.
 */
import { useAuthStore } from '@/stores/auth-store';
import { useSchoolScopeStore } from '@/stores/school-scope-store';
import { useAdminRole } from '@/hooks/useAdminRole';
import { useAuth } from '@/hooks/useAuth';
import { GlobalSearch } from '@/components/shared/GlobalSearch';
import { Bell, LogOut, User } from 'lucide-react';
import { useState } from 'react';

export function TopBar() {
  const { admin } = useAuthStore();
  const { currentCollegeId } = useSchoolScopeStore();
  const { showSchoolSwitcher } = useAdminRole();
  const { logout } = useAuth();
  const [showDropdown, setShowDropdown] = useState(false);

  return (
    <header className="topbar">
      <div className="topbar__left">
        {/* NOTE: Breadcrumb will be implemented per-page using a context provider */}
        <span className="topbar__breadcrumb">Smivo Admin</span>
      </div>

      {/* Global search — searches users, listings, orders */}
      <GlobalSearch />

      <div className="topbar__right">
        {/* School switcher placeholder — full implementation in Phase 2 */}
        {showSchoolSwitcher && (
          <div className="topbar__school">
            🏫 {currentCollegeId ? 'School View' : 'Platform View'}
          </div>
        )}

        {/* Alert bell */}
        <button className="topbar__icon-btn" aria-label="Notifications">
          <Bell size={18} />
        </button>

        {/* Admin avatar dropdown */}
        <div className="topbar__profile">
          <button
            className="topbar__avatar-btn"
            onClick={() => setShowDropdown(!showDropdown)}
          >
            <User size={18} />
            <span className="topbar__name">{admin?.display_name || admin?.email || 'Admin'}</span>
          </button>

          {showDropdown && (
            <div className="topbar__dropdown">
              <div className="topbar__dropdown-item topbar__dropdown-info">
                <div>{admin?.email}</div>
                <div className="topbar__role">{admin?.role?.replace(/_/g, ' ')}</div>
              </div>
              <button className="topbar__dropdown-item" onClick={logout}>
                <LogOut size={14} />
                Sign Out
              </button>
            </div>
          )}
        </div>
      </div>

      <style>{`
        .topbar {
          height: var(--topbar-height);
          background: var(--color-bg-primary);
          border-bottom: 1px solid var(--color-border-light);
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 0 20px;
          position: sticky;
          top: 0;
          z-index: 40;
        }

        .topbar__left {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .topbar__breadcrumb {
          font-size: 14px;
          font-weight: 600;
          color: var(--color-text-primary);
        }

        .topbar__right {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .topbar__school {
          font-size: 13px;
          padding: 6px 12px;
          background: var(--color-bg-tertiary);
          border-radius: var(--radius-md);
          cursor: pointer;
          color: var(--color-text-secondary);
        }

        .topbar__icon-btn {
          background: none;
          border: none;
          color: var(--color-text-secondary);
          cursor: pointer;
          padding: 6px;
          border-radius: var(--radius-sm);
          display: flex;
          align-items: center;
        }

        .topbar__icon-btn:hover {
          background: var(--color-bg-tertiary);
          color: var(--color-text-primary);
        }

        .topbar__profile {
          position: relative;
        }

        .topbar__avatar-btn {
          display: flex;
          align-items: center;
          gap: 8px;
          background: none;
          border: none;
          color: var(--color-text-secondary);
          cursor: pointer;
          padding: 6px 10px;
          border-radius: var(--radius-md);
          font-size: 13px;
        }

        .topbar__avatar-btn:hover {
          background: var(--color-bg-tertiary);
        }

        .topbar__name {
          max-width: 120px;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }

        .topbar__dropdown {
          position: absolute;
          right: 0;
          top: calc(100% + 4px);
          width: 220px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          box-shadow: var(--shadow-dropdown);
          overflow: hidden;
          z-index: 100;
        }

        .topbar__dropdown-item {
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 10px 14px;
          font-size: 13px;
          color: var(--color-text-secondary);
          cursor: pointer;
          background: none;
          border: none;
          width: 100%;
          text-align: left;
        }

        .topbar__dropdown-item:hover {
          background: var(--color-bg-tertiary);
        }

        .topbar__dropdown-info {
          border-bottom: 1px solid var(--color-border-light);
          cursor: default;
          flex-direction: column;
          align-items: flex-start;
        }

        .topbar__dropdown-info:hover {
          background: none;
        }

        .topbar__role {
          font-size: 11px;
          color: var(--color-text-tertiary);
          text-transform: capitalize;
          margin-top: 2px;
        }
      `}</style>
    </header>
  );
}
