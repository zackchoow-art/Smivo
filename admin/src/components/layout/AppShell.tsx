/**
 * App Shell — wraps all authenticated pages with sidebar + topbar layout.
 * Per 04_ADMIN_WEB_SPEC.md §4.
 */
import { Outlet, Navigate } from 'react-router-dom';
import { useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { Sidebar } from './Sidebar';
import { TopBar } from './TopBar';
import { LS_KEYS } from '@/lib/constants';

export function AppShell() {
  const { isAuthenticated, initialized, loading } = useAuth();
  const [sidebarCollapsed, setSidebarCollapsed] = useState(
    () => localStorage.getItem(LS_KEYS.SIDEBAR_COLLAPSED) === 'true'
  );

  // Show loading state while checking auth
  if (!initialized || loading) {
    return (
      <div className="shell-loading">
        <div className="shell-loading__spinner" />
        <p>Loading...</p>
      </div>
    );
  }

  // Redirect to login if not authenticated
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  const handleToggleSidebar = () => {
    setSidebarCollapsed((prev) => {
      const next = !prev;
      localStorage.setItem(LS_KEYS.SIDEBAR_COLLAPSED, String(next));
      return next;
    });
  };

  return (
    <div className="shell">
      <Sidebar collapsed={sidebarCollapsed} onToggle={handleToggleSidebar} />

      <div
        className="shell__main"
        style={{
          marginLeft: sidebarCollapsed
            ? 'var(--sidebar-collapsed-width)'
            : 'var(--sidebar-width)',
        }}
      >
        <TopBar />
        <main className="shell__content">
          <Outlet />
        </main>
      </div>

      <style>{`
        .shell {
          min-height: 100vh;
          background: var(--color-bg-secondary);
        }

        .shell__main {
          transition: margin-left 0.2s ease;
          min-height: 100vh;
          display: flex;
          flex-direction: column;
        }

        .shell__content {
          flex: 1;
          padding: var(--spacing-page);
        }

        .shell-loading {
          min-height: 100vh;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          gap: 12px;
          color: var(--color-text-tertiary);
          font-size: 14px;
        }

        .shell-loading__spinner {
          width: 28px;
          height: 28px;
          border: 3px solid var(--color-border);
          border-top-color: var(--color-info);
          border-radius: 50%;
          animation: spin 0.7s linear infinite;
        }

        @keyframes spin {
          to { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
}
