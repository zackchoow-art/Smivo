/**
 * Top bar with admin role label, school switcher, and admin avatar.
 * Defined in 04_ADMIN_WEB_SPEC.md §4.1.
 */
import { useAuthStore, getHighestRole, getSchoolScopeIds } from '@/stores/auth-store';
import { useSchoolScopeStore } from '@/stores/school-scope-store';
import { useAdminRole } from '@/hooks/useAdminRole';
import { useColleges } from '@/hooks/useColleges';
import { useAuth } from '@/hooks/useAuth';
import { GlobalSearch } from '@/components/shared/GlobalSearch';
import { ADMIN_ROLE_LABELS } from '@/lib/constants';
import { Bell, LogOut, User, Settings } from 'lucide-react';
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';

export function TopBar() {
  const { roles, adminProfile } = useAuthStore();
  const { currentCollegeId, setCollege, setPlatformView } = useSchoolScopeStore();
  const { isSuperAdmin } = useAdminRole();
  const { logout } = useAuth();
  const { data: colleges } = useColleges();
  const [showDropdown, setShowDropdown] = useState(false);
  const navigate = useNavigate();

  // Derive role label from current roles
  const highestRole = getHighestRole(roles);
  const roleLabel = highestRole ? (ADMIN_ROLE_LABELS[highestRole] ?? highestRole) : 'Admin';

  // Determine available schools based on admin scopes
  const schoolScopeIds = getSchoolScopeIds(roles);
  const availableSchools = isSuperAdmin
    ? colleges || []
    : colleges?.filter((c) => schoolScopeIds.includes(c.id)) || [];

  // If not super admin and no current college is selected, select first available
  if (!isSuperAdmin && !currentCollegeId && availableSchools.length > 0) {
    setCollege(availableSchools[0].id);
  }

  return (
    <header className="topbar">
      <div className="topbar__left">
        {/* NOTE: Show current admin's role level instead of static "Smivo Admin" */}
        <span className="topbar__breadcrumb">{roleLabel}</span>
      </div>

      {/* Global search — searches users, listings, orders */}
      <GlobalSearch />

      <div className="topbar__right">
        {/* School scope indicator — always visible for non-sysadmin, or sysadmin with scope */}
        {availableSchools.length === 1 && !isSuperAdmin && (
          // Single school: show static label only
          <div className="topbar__school-badge">
            🏫 {availableSchools[0].name}
          </div>
        )}
        {(availableSchools.length > 1 || isSuperAdmin) && availableSchools.length > 0 && (
          // Multiple schools or sysadmin: show dropdown
          <select
            className="topbar__school-select"
            value={currentCollegeId || ''}
            onChange={(e) => {
              if (e.target.value === '') {
                setPlatformView();
              } else {
                setCollege(e.target.value);
              }
            }}
          >
            {isSuperAdmin && <option value="">🌐 All Platform</option>}
            {availableSchools.map((s) => (
              <option key={s.id} value={s.id}>
                🏫 {s.name}
              </option>
            ))}
          </select>
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
            {adminProfile?.avatar_url ? (
              <img
                src={adminProfile.avatar_url}
                alt=""
                className="topbar__avatar-img"
              />
            ) : (
              <User size={18} />
            )}
            <span className="topbar__name">
              {adminProfile?.display_name || adminProfile?.email || 'Admin'}
            </span>
          </button>

          {showDropdown && (
            <div className="topbar__dropdown">
              <div className="topbar__dropdown-item topbar__dropdown-info">
                <div>{adminProfile?.email}</div>
                <div className="topbar__role">{roleLabel}</div>
              </div>
              <button 
                className="topbar__dropdown-item" 
                onClick={() => {
                  setShowDropdown(false);
                  navigate('/settings/profile');
                }}
              >
                <Settings size={14} />
                Settings
              </button>
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

        .topbar__school-select {
          font-size: 13px;
          padding: 6px 30px 6px 12px;
          background: var(--color-bg-tertiary) url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>') no-repeat right 10px center;
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-md);
          cursor: pointer;
          color: var(--color-text-secondary);
          appearance: none;
          outline: none;
        }

        .topbar__school-select:hover {
          background-color: var(--color-bg-secondary);
        }

        .topbar__school-badge {
          font-size: 13px;
          padding: 5px 12px;
          background: var(--color-bg-tertiary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-md);
          color: var(--color-text-secondary);
          white-space: nowrap;
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

        .topbar__avatar-img {
          width: 24px;
          height: 24px;
          border-radius: 50%;
          object-fit: cover;
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
