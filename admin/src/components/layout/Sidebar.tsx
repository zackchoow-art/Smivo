/**
 * Sidebar navigation — role-driven menu rendering.
 * Menu items are hidden based on admin permissions per 04_ADMIN_WEB_SPEC.md §4.2.
 * NOTE: Configuration group restored in T9 refactor. Sensitive Words moved into
 * Platform Settings (SystemConfigsPage) as a tab — no longer a standalone sidebar entry.
 */
import { NavLink, useLocation, useSearchParams } from 'react-router-dom';
import { useAdminRole } from '@/hooks/useAdminRole';
import {
  LayoutDashboard,
  ClipboardList,
  MessageSquareWarning,
  ShieldAlert,
  Users,
  Ban,
  MessageCircle,
  Megaphone,
  ScrollText,
  ChevronLeft,
  ChevronRight,
  Bot,
  BookOpen,
  UserCog,
  GraduationCap,
  Cpu,
  Trash2,
  Blocks,
  Car,
  Smartphone,
} from 'lucide-react';
import type { ReactNode } from 'react';

interface SidebarProps {
  collapsed: boolean;
  onToggle: () => void;
}

interface MenuItem {
  path: string;
  label: string;
  icon: ReactNode;
  visible: boolean;
}

interface MenuGroup {
  title: string;
  items: MenuItem[];
}

export function Sidebar({ collapsed, onToggle }: SidebarProps) {
  const perms = useAdminRole();
  const location = useLocation();
  const [searchParams] = useSearchParams();
  const fromParam = searchParams.get('from');

  const menuGroups: MenuGroup[] = [
    {
      title: '',
      items: [
        { path: '/dashboard', label: 'Dashboard', icon: <LayoutDashboard size={18} />, visible: true },
      ],
    },
    {
      title: 'Review',
      items: [
        { path: '/moderation/listings', label: 'Listing Queue', icon: <ShieldAlert size={18} />, visible: perms.canViewModeration },
        { path: '/moderation/listing-reports', label: 'Listing Reports', icon: <MessageSquareWarning size={18} />, visible: perms.canViewModeration },
        { path: '/moderation/chat-reports', label: 'Chat Reports', icon: <MessageSquareWarning size={18} />, visible: perms.canViewModeration },
        { path: '/feedback', label: 'User Feedback', icon: <MessageCircle size={18} />, visible: perms.canViewFeedback },
      ],
    },
    {
      title: 'Content Moderation',
      items: [
        { path: '/moderation/all-listings', label: 'All Listings', icon: <ClipboardList size={18} />, visible: perms.canViewModeration },
        { path: '/moderation/ai-reviewed', label: 'AI Reviewed', icon: <Bot size={18} />, visible: perms.canViewModeration },
      ],
    },
    {
      title: 'Carpool',
      items: [
        { path: '/carpool', label: 'All Trips', icon: <Car size={18} />, visible: perms.canViewCarpool },
      ],
    },
    {
      title: 'Users',
      items: [
        { path: '/users', label: 'User List', icon: <Users size={18} />, visible: perms.canViewUsers },
        { path: '/bans', label: 'Ban Records', icon: <Ban size={18} />, visible: perms.canViewUsers },
      ],
    },
    {
      title: 'Engagement',
      items: [
        { path: '/push', label: 'Push Notifications', icon: <Megaphone size={18} />, visible: perms.canViewPush },
      ],
    },
    {
      title: 'Configuration',
      items: [
        { path: '/settings/platform-functions', label: 'Platform Functions', icon: <Blocks size={18} />, visible: perms.canViewFeatureFlags },
        { path: '/settings/content-moderation', label: 'Content Moderation', icon: <Cpu size={18} />, visible: perms.canViewSystemConfigs },
        { path: '/settings/school-settings', label: 'School Settings', icon: <BookOpen size={18} />, visible: perms.canViewDictionary },
        { path: '/settings/admins', label: 'Admin Management', icon: <UserCog size={18} />, visible: perms.canViewAdminManagement },
        { path: '/settings/colleges', label: 'Schools', icon: <GraduationCap size={18} />, visible: perms.canViewCollegeManagement },
        { path: '/settings/cleanup', label: 'Test Data Cleanup', icon: <Trash2 size={18} />, visible: perms.canViewCleanup },
        { path: '/settings/apk-upload', label: 'APK Upload', icon: <Smartphone size={18} />, visible: perms.canViewSystemConfigs },
      ],
    },
    {
      title: '',
      items: [
        { path: '/audit-log', label: 'Audit Log', icon: <ScrollText size={18} />, visible: perms.canViewAuditLog },
      ],
    },
  ];

  return (
    <aside className={`sidebar ${collapsed ? 'sidebar--collapsed' : ''}`}>
      {/* Logo */}
      <div className="sidebar__logo">
        {!collapsed && <span className="sidebar__logo-text">Smivo Admin</span>}
        <button className="sidebar__toggle" onClick={onToggle} aria-label="Toggle sidebar">
          {collapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
        </button>
      </div>

      {/* Navigation */}
      <nav className="sidebar__nav">
        {menuGroups.map((group, gi) => {
          const visibleItems = group.items.filter((item) => item.visible);
          if (visibleItems.length === 0) return null;

          return (
            <div key={gi} className="sidebar__group">
              {group.title && !collapsed && (
                <div className="sidebar__group-title">{group.title}</div>
              )}
              {visibleItems.map((item) => {
                // NOTE: When navigating from Platform Functions → dict edit page,
                // the URL is /settings/school-settings/:dictCode?from=platform-functions.
                // Without this override, School Settings would be incorrectly highlighted.
                const isFromPlatform = fromParam === 'platform-functions';
                const isDictSubpage = location.pathname.startsWith('/settings/school-settings/');

                return (
                <NavLink
                  key={item.path}
                  to={item.path}
                  className={({ isActive }) => {
                    let active = isActive;
                    if (isFromPlatform && isDictSubpage) {
                      // Suppress School Settings highlight, activate Platform Functions instead
                      if (item.path === '/settings/school-settings') active = false;
                      if (item.path === '/settings/platform-functions') active = true;
                    }
                    return `sidebar__item ${active ? 'sidebar__item--active' : ''}`;
                  }}
                  title={collapsed ? item.label : undefined}
                >
                  <span className="sidebar__icon">{item.icon}</span>
                  {!collapsed && <span className="sidebar__label">{item.label}</span>}
                </NavLink>
                );
              })}
            </div>
          );
        })}
      </nav>

      <style>{`
        .sidebar {
          width: var(--sidebar-width);
          min-height: 100vh;
          background: var(--color-bg-sidebar);
          color: var(--color-text-inverse);
          display: flex;
          flex-direction: column;
          transition: width 0.2s ease;
          overflow-x: hidden;
          position: fixed;
          left: 0;
          top: 0;
          z-index: 50;
        }

        .sidebar--collapsed {
          width: var(--sidebar-collapsed-width);
        }

        .sidebar__logo {
          height: var(--topbar-height);
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 0 16px;
          border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }

        .sidebar__logo-text {
          font-size: 16px;
          font-weight: 700;
          white-space: nowrap;
        }

        .sidebar__toggle {
          background: none;
          border: none;
          color: var(--color-text-inverse);
          cursor: pointer;
          padding: 4px;
          border-radius: var(--radius-sm);
          opacity: 0.6;
          transition: opacity 0.15s;
        }

        .sidebar__toggle:hover {
          opacity: 1;
        }

        .sidebar__nav {
          flex: 1;
          padding: 8px 0;
          overflow-y: auto;
        }

        .sidebar__group {
          margin-bottom: 4px;
        }

        .sidebar__group-title {
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.5px;
          color: rgba(255, 255, 255, 0.35);
          padding: 12px 16px 4px;
          white-space: nowrap;
        }

        .sidebar__item {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 8px 16px;
          color: rgba(255, 255, 255, 0.7);
          text-decoration: none;
          font-size: 13px;
          font-weight: 450;
          border-radius: 0;
          transition: background 0.1s, color 0.1s;
          white-space: nowrap;
        }

        .sidebar__item:hover {
          background: var(--color-bg-sidebar-hover);
          color: var(--color-text-inverse);
        }

        .sidebar__item--active {
          background: var(--color-bg-sidebar-active);
          color: var(--color-text-inverse);
          font-weight: 550;
          border-right: 3px solid var(--color-info);
        }

        .sidebar__icon {
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;
          width: 20px;
        }

        .sidebar__label {
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .sidebar--collapsed .sidebar__logo {
          justify-content: center;
          padding: 0;
        }

        .sidebar--collapsed .sidebar__item {
          justify-content: center;
          padding: 10px 0;
        }
      `}</style>
    </aside>
  );
}
