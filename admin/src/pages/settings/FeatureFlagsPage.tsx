/**
 * Feature Flags management page.
 * Renders all system_settings (Feature Flags) and system_configs (Configurations) as manageable controls.
 * Only platform_super_admin can edit; others see read-only view.
 */
import { useState } from 'react';
import { Search, ToggleLeft, ToggleRight, Shield, Loader2, Database, Settings } from 'lucide-react';
import { useFeatureFlags, useToggleFlag } from '@/hooks/useFeatureFlags';
import { useSystemConfigs, useUpdateSystemConfig } from '@/hooks/useSystemConfigs';
import { useAdminRole } from '@/hooks/useAdminRole';
import { ADMIN_ROLES } from '@/lib/constants';
import { useAuth } from '@/hooks/useAuth';

interface UnifiedFlag {
  key: string;
  value: any;
  description: string;
  sourceTable: string;
  sourceColumn: string;
}

export function FeatureFlagsPage() {
  const [search, setSearch] = useState('');
  const { admin } = useAuth();
  const { data: settings, isLoading: loadingSettings, error: errorSettings } = useFeatureFlags();
  const { data: configs, isLoading: loadingConfigs, error: errorConfigs } = useSystemConfigs();
  const toggleFlag = useToggleFlag();
  const updateConfig = useUpdateSystemConfig();
  const { role } = useAdminRole();

  const canEdit = role === ADMIN_ROLES.PLATFORM_SUPER_ADMIN;

  // Parse flag value safely — handles string, boolean, and JSON
  const parseFlagValue = (value: unknown): boolean => {
    if (typeof value === 'boolean') return value;
    if (typeof value === 'string') {
      try {
        const parsed = JSON.parse(value);
        if (typeof parsed === 'boolean') return parsed;
        return value === 'true';
      } catch {
        return value === 'true';
      }
    }
    return false;
  };

  // Combine and normalize data
  const unifiedFlags: UnifiedFlag[] = [
    ...(settings ?? []).map(s => ({
      key: s.key,
      value: s.value,
      description: s.description ?? 'No description',
      sourceTable: 'system_settings',
      sourceColumn: 'value'
    })),
    ...(configs ?? []).map(c => ({
      key: c.config_key,
      value: c.config_value,
      description: c.description ?? 'No description',
      sourceTable: 'system_configs',
      sourceColumn: 'config_value'
    }))
  ];

  // Group flags by namespace (e.g. "presence", "moderation", "ai")
  const groupedFlags = unifiedFlags
    .filter((f) => 
      f.key.toLowerCase().includes(search.toLowerCase()) ||
      f.description.toLowerCase().includes(search.toLowerCase()) ||
      f.sourceTable.toLowerCase().includes(search.toLowerCase())
    )
    .reduce<Record<string, UnifiedFlag[]>>((acc, flag) => {
      const namespace = flag.key.split('.')[0] ?? 'other';
      if (!acc[namespace]) acc[namespace] = [];
      acc[namespace].push(flag);
      return acc;
    }, {});

  if (loadingSettings || loadingConfigs) {
    return (
      <div className="flags-loading">
        <Loader2 size={24} className="spin" />
        <span>Loading system configurations...</span>
      </div>
    );
  }

  if (errorSettings || errorConfigs) {
    return (
      <div className="flags-error">
        <p>Failed to load data: {(errorSettings as Error)?.message || (errorConfigs as Error)?.message}</p>
      </div>
    );
  }

  return (
    <div className="flags-page">
      <div className="flags-header">
        <div>
          <h1 className="flags-title">System Configurations & Feature Flags</h1>
          <p className="flags-subtitle">
            Control platform behavior and feature availability in real-time.
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
          placeholder="Search by key, description, or source table..."
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
              {items.map((flag) => {
                const isBoolean = typeof flag.value === 'boolean' || 
                                 (typeof flag.value === 'string' && (flag.value === 'true' || flag.value === 'false')) ||
                                 (flag.sourceTable === 'system_settings'); // settings are usually boolean
                
                const isOn = parseFlagValue(flag.value);
                const isPending = (toggleFlag.isPending && toggleFlag.variables?.key === flag.key) ||
                                 (updateConfig.isPending && updateConfig.variables?.key === flag.key);

                return (
                  <div
                    key={flag.key}
                    className={`flag-item ${isBoolean ? (isOn ? 'flag-on' : 'flag-off') : 'flag-config'}`}
                  >
                    <div className="flag-info">
                      <div className="flag-key-row">
                        <code className="flag-key">{flag.key}</code>
                        <div className="flag-source-badge">
                          <Database size={10} />
                          <span>{flag.sourceTable}.{flag.sourceColumn}</span>
                        </div>
                      </div>
                      <p className="flag-description">{flag.description}</p>
                      {!isBoolean && (
                        <div className="flag-raw-value">
                          <Settings size={10} />
                          <span>Value: {JSON.stringify(flag.value)}</span>
                        </div>
                      )}
                    </div>

                    <div className="flag-actions">
                      {isBoolean ? (
                        <button
                          className={`flag-toggle ${isOn ? 'toggle-on' : 'toggle-off'}`}
                          disabled={!canEdit || isPending}
                          onClick={() => {
                            if (flag.sourceTable === 'system_settings') {
                              toggleFlag.mutate({ key: flag.key, value: !isOn });
                            } else {
                              updateConfig.mutate({ 
                                key: flag.key, 
                                value: !isOn, 
                                oldValue: isOn, 
                                adminId: admin?.user_id || '' 
                              });
                            }
                          }}
                        >
                          {isPending ? (
                            <Loader2 size={20} className="spin" />
                          ) : isOn ? (
                            <ToggleRight size={28} />
                          ) : (
                            <ToggleLeft size={28} />
                          )}
                        </button>
                      ) : (
                        <div className="flag-non-bool-hint">
                          Edit in DB or via specific settings page
                        </div>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        ))}

        {Object.keys(groupedFlags).length === 0 && (
          <div className="flags-empty">
            No configurations match your search.
          </div>
        )}
      </div>

      <style>{`
        .flags-page {
          padding: var(--spacing-page);
          max-width: 900px;
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
          gap: 8px;
        }

        .flag-item {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 14px 16px;
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

        .flag-key-row {
          display: flex;
          align-items: center;
          gap: 10px;
          margin-bottom: 4px;
        }

        .flag-key {
          font-size: 13px;
          font-family: var(--font-mono);
          color: var(--color-text-primary);
          font-weight: 600;
        }

        .flag-source-badge {
          display: flex;
          align-items: center;
          gap: 4px;
          font-size: 10px;
          color: var(--color-text-tertiary);
          background: var(--color-bg-secondary);
          padding: 2px 6px;
          border-radius: 4px;
          font-family: var(--font-mono);
        }

        .flag-description {
          font-size: 12px;
          color: var(--color-text-secondary);
        }

        .flag-raw-value {
          display: flex;
          align-items: center;
          gap: 4px;
          font-size: 10px;
          color: var(--color-primary);
          margin-top: 6px;
          opacity: 0.8;
        }

        .flag-actions {
          flex-shrink: 0;
          margin-left: 20px;
        }

        .flag-toggle {
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

        .flag-non-bool-hint {
          font-size: 11px;
          color: var(--color-text-tertiary);
          font-style: italic;
          text-align: right;
          width: 120px;
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
