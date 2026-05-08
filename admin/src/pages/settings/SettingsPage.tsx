/**
 * Settings hub page — card-based navigation to all configuration sub-pages.
 * Replaces the former sidebar Configuration group.
 * Access: via TopBar avatar dropdown → Settings.
 */
import { useNavigate } from 'react-router-dom';
import { useAdminRole } from '@/hooks/useAdminRole';
import {
  BookOpen,
  Cpu,
  UserCog,
  GraduationCap,
  Trash2,
  User,
  ToggleRight,
} from 'lucide-react';
import type { ReactNode } from 'react';

interface SettingsCard {
  path: string;
  label: string;
  description: string;
  icon: ReactNode;
  visible: boolean;
}

export function SettingsPage() {
  const navigate = useNavigate();
  const perms = useAdminRole();

  const cards: SettingsCard[] = [
    {
      path: '/settings/profile',
      label: 'Profile',
      description: 'View and update your admin profile information.',
      icon: <User size={24} />,
      visible: true,
    },
    {
      path: '/settings/dictionary',
      label: 'Data Dictionary',
      description: 'Manage platform-wide data dictionaries and lookup values.',
      icon: <BookOpen size={24} />,
      visible: perms.canViewDictionary,
    },
    {
      path: '/settings/configs',
      label: 'Platform Settings',
      description: 'Configure system-level settings and parameters.',
      icon: <Cpu size={24} />,
      visible: perms.canViewDictionary,
    },
    {
      path: '/settings/feature-flags',
      label: 'Feature Flags',
      description: 'Toggle platform features and view their database mappings.',
      icon: <ToggleRight size={24} />,
      visible: perms.canViewFeatureFlags,
    },
    {
      path: '/settings/admins',
      label: 'Admin Management',
      description: 'Manage admin users, roles, and permissions.',
      icon: <UserCog size={24} />,
      visible: perms.canViewAdminManagement,
    },
    {
      path: '/settings/colleges',
      label: 'Schools',
      description: 'Manage registered schools and campus configurations.',
      icon: <GraduationCap size={24} />,
      visible: perms.canViewCollegeManagement,
    },
    {
      path: '/settings/cleanup',
      label: 'Test Data Cleanup',
      description: 'Remove test data from the platform (sysadmin only).',
      icon: <Trash2 size={24} />,
      visible: perms.canViewCleanup,
    },
  ];

  const visibleCards = cards.filter((c) => c.visible);

  return (
    <div className="settings-page">
      <h1 className="settings-page__title">Settings</h1>
      <p className="settings-page__subtitle">
        Platform configuration and administration tools.
      </p>

      <div className="settings-page__grid">
        {visibleCards.map((card) => (
          <button
            key={card.path}
            className="settings-card"
            onClick={() => navigate(card.path)}
          >
            <div className="settings-card__icon">{card.icon}</div>
            <div className="settings-card__content">
              <div className="settings-card__label">{card.label}</div>
              <div className="settings-card__desc">{card.description}</div>
            </div>
          </button>
        ))}
      </div>

      <style>{`
        .settings-page {
          padding: 32px;
          max-width: 960px;
        }

        .settings-page__title {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
          margin: 0 0 4px;
        }

        .settings-page__subtitle {
          font-size: 14px;
          color: var(--color-text-tertiary);
          margin: 0 0 28px;
        }

        .settings-page__grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
          gap: 16px;
        }

        .settings-card {
          display: flex;
          align-items: flex-start;
          gap: 16px;
          padding: 20px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg);
          cursor: pointer;
          text-align: left;
          transition: border-color 0.15s, box-shadow 0.15s;
          width: 100%;
        }

        .settings-card:hover {
          border-color: var(--color-info);
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
        }

        .settings-card__icon {
          flex-shrink: 0;
          width: 40px;
          height: 40px;
          display: flex;
          align-items: center;
          justify-content: center;
          background: var(--color-bg-tertiary);
          border-radius: var(--radius-md);
          color: var(--color-text-secondary);
        }

        .settings-card__content {
          flex: 1;
          min-width: 0;
        }

        .settings-card__label {
          font-size: 14px;
          font-weight: 600;
          color: var(--color-text-primary);
          margin-bottom: 4px;
        }

        .settings-card__desc {
          font-size: 12px;
          color: var(--color-text-tertiary);
          line-height: 1.4;
        }
      `}</style>
    </div>
  );
}
