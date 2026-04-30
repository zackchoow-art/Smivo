/**
 * Feature Flags management page.
 * Renders all system_settings as toggleable flags.
 * Only platform_super_admin can edit; others see read-only view.
 */
import { useState } from 'react';
import { Search, ToggleLeft, ToggleRight, Shield, Loader2 } from 'lucide-react';
import { useFeatureFlags, useToggleFlag } from '@/hooks/useFeatureFlags';
import { useAdminRole } from '@/hooks/useAdminRole';
import { ADMIN_ROLES } from '@/lib/constants';

export function FeatureFlagsPage() {
  const [search, setSearch] = useState('');
  const { data: flags, isLoading, error } = useFeatureFlags();
  const toggleFlag = useToggleFlag();
  const { role } = useAdminRole();

  const canEdit = role === ADMIN_ROLES.PLATFORM_SUPER_ADMIN;

  // Parse flag value safely — handles string, boolean, and JSON
  const parseFlagValue = (value: unknown): boolean => {
    if (typeof value === 'boolean') return value;
    if (typeof value === 'string') {
      try {
        return JSON.parse(value) === true;
      } catch {
        return value === 'true';
      }
    }
    return false;
  };

  // Group flags by namespace (e.g. "presence", "moderation")
  const groupedFlags = (flags ?? [])
    .filter((f) => f.key.toLowerCase().includes(search.toLowerCase()) ||
      (f.description ?? '').toLowerCase().includes(search.toLowerCase()))
    .reduce<Record<string, typeof flags>>((acc, flag) => {
      if (!flag) return acc;
      const namespace = flag.key.split('.')[0] ?? 'other';
      if (!acc[namespace]) acc[namespace] = [];
      acc[namespace]!.push(flag);
      return acc;
    }, {});

  if (isLoading) {
    return (
      <div className="flags-loading">
        <Loader2 size={24} className="spin" />
        <span>Loading feature flags...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flags-error">
        <p>Failed to load feature flags: {(error as Error).message}</p>
      </div>
    );
  }

  return (
    <div className="flags-page">
      <div className="flags-header">
        <div>
          <h1 className="flags-title">Feature Flags</h1>
          <p className="flags-subtitle">
            Control platform features in real-time. Changes take effect immediately.
          </p>
        </div>
        {!canEdit && (
          <div className="flags-readonly-badge">
            <Shield size={14} />
            <span>Read-only — Super Admin access required</span>
          </div>
        )}
      </div>

      <div className="flags-search-bar">
        <Search size={16} color="var(--color-text-tertiary)" />
        <input
          type="text"
          placeholder="Search flags by key or description..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="flags-search-input"
        />
      </div>

      <div className="flags-groups">
        {Object.entries(groupedFlags).map(([namespace, items]) => (
          <div key={namespace} className="flags-group">
            <h3 className="flags-group-title">{namespace}</h3>
            <div className="flags-group-items">
              {items?.map((flag) => {
                const isOn = parseFlagValue(flag.value);
                const isPending = toggleFlag.isPending &&
                  toggleFlag.variables?.key === flag.key;

                return (
                  <div
                    key={flag.key}
                    className={`flag-item ${isOn ? 'flag-on' : 'flag-off'}`}
                  >
                    <div className="flag-info">
                      <code className="flag-key">{flag.key}</code>
                      <p className="flag-description">
                        {flag.description ?? 'No description'}
                      </p>
                    </div>

                    <button
                      className={`flag-toggle ${isOn ? 'toggle-on' : 'toggle-off'}`}
                      disabled={!canEdit || isPending}
                      onClick={() => toggleFlag.mutate({ key: flag.key, value: !isOn })}
                      title={canEdit ? `Toggle ${flag.key}` : 'Super Admin access required'}
                    >
                      {isPending ? (
                        <Loader2 size={20} className="spin" />
                      ) : isOn ? (
                        <ToggleRight size={28} />
                      ) : (
                        <ToggleLeft size={28} />
                      )}
                    </button>
                  </div>
                );
              })}
            </div>
          </div>
        ))}

        {Object.keys(groupedFlags).length === 0 && (
          <div className="flags-empty">
            No flags match your search.
          </div>
        )}
      </div>

      <style>{`
        .flags-page {
          padding: var(--spacing-page);
          max-width: 800px;
        }

        .flags-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          margin-bottom: 24px;
        }

        .flags-title {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .flags-subtitle {
          font-size: 13px;
          color: var(--color-text-tertiary);
          margin-top: 4px;
        }

        .flags-readonly-badge {
          display: flex;
          align-items: center;
          gap: 6px;
          font-size: 12px;
          color: var(--color-warning);
          background: var(--color-warning-light);
          padding: 6px 12px;
          border-radius: var(--radius-md);
          white-space: nowrap;
        }

        .flags-search-bar {
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 8px 12px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          margin-bottom: 20px;
        }

        .flags-search-input {
          flex: 1;
          border: none;
          outline: none;
          font-size: 14px;
          color: var(--color-text-primary);
          background: transparent;
        }

        .flags-group {
          margin-bottom: 24px;
        }

        .flags-group-title {
          font-size: 12px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.05em;
          color: var(--color-text-tertiary);
          margin-bottom: 8px;
          padding-left: 4px;
        }

        .flags-group-items {
          display: flex;
          flex-direction: column;
          gap: 2px;
        }

        .flag-item {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 12px 16px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-md);
          transition: box-shadow 0.15s ease;
        }

        .flag-item:hover {
          box-shadow: var(--shadow-card-hover);
        }

        .flag-info {
          flex: 1;
          min-width: 0;
        }

        .flag-key {
          font-size: 13px;
          font-family: var(--font-mono);
          color: var(--color-text-primary);
          font-weight: 500;
        }

        .flag-description {
          font-size: 12px;
          color: var(--color-text-tertiary);
          margin-top: 2px;
        }

        .flag-toggle {
          flex-shrink: 0;
          display: flex;
          align-items: center;
          background: none;
          border: none;
          cursor: pointer;
          padding: 4px;
          border-radius: var(--radius-sm);
          transition: opacity 0.15s ease;
        }

        .flag-toggle:disabled {
          cursor: not-allowed;
          opacity: 0.4;
        }

        .toggle-on {
          color: var(--color-success);
        }

        .toggle-off {
          color: var(--color-text-tertiary);
        }

        .flags-loading, .flags-error, .flags-empty {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
          padding: 60px 0;
          color: var(--color-text-tertiary);
          font-size: 14px;
        }

        .flags-error {
          color: var(--color-danger);
        }

        .spin {
          animation: spin 1s linear infinite;
        }

        @keyframes spin {
          to { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
}
