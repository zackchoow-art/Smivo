/**
 * Feature Flags management page.
 * Renders all system_settings (Feature Flags) and system_configs (Configurations) as manageable controls.
 * Only platform_super_admin can edit; others see read-only view.
 */
import { useState } from 'react';
import { Search, ToggleLeft, ToggleRight, Shield, Loader2, Database, Settings, Plus, Trash2 } from 'lucide-react';
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
          {/* NOTE: Title changed from "System Configurations & Feature Flags" in T9 refactor */}
          <h1 className="flags-title">System Configuration</h1>
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
                      {/* NOTE: feedback.shortcuts is a JSON array — render dedicated editor instead of "Edit in DB" hint */}
                      {flag.key === 'feedback.shortcuts' ? (
                        <ShortcutsEditor
                          rawValue={flag.value}
                          canEdit={canEdit}
                          onSave={(newArray) => {
                            if (flag.sourceTable === 'system_configs') {
                              updateConfig.mutate({
                                key: flag.key,
                                value: JSON.stringify(newArray),
                                oldValue: flag.value,
                                adminId: admin?.user_id || '',
                              });
                            }
                          }}
                        />
                      ) : isBoolean ? (
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


// NOTE: Dedicated editor for feedback.shortcuts JSON array config.
// Renders an inline list with add / edit / delete controls and a Save button.

interface ShortcutsEditorProps {
  rawValue: unknown;
  canEdit: boolean;
  onSave: (newArray: string[]) => void;
}

function ShortcutsEditor({ rawValue, canEdit, onSave }: ShortcutsEditorProps) {
  // Parse the raw value safely — it may be a JSON string or already an array
  const parse = (v: unknown): string[] => {
    if (Array.isArray(v)) return v.map(String);
    if (typeof v === 'string') {
      try { const p = JSON.parse(v); return Array.isArray(p) ? p.map(String) : []; } catch { return []; }
    }
    return [];
  };

  const [items, setItems] = useState<string[]>(() => parse(rawValue));
  const [dirty, setDirty] = useState(false);

  const handleChange = (idx: number, value: string) => {
    const next = [...items];
    next[idx] = value;
    setItems(next);
    setDirty(true);
  };

  const handleAdd = () => {
    setItems(prev => [...prev, '']);
    setDirty(true);
  };

  const handleRemove = (idx: number) => {
    setItems(prev => prev.filter((_, i) => i !== idx));
    setDirty(true);
  };

  const handleSave = () => {
    // Filter empty strings before saving
    const filtered = items.filter(s => s.trim() !== '');
    onSave(filtered);
    setItems(filtered);
    setDirty(false);
  };

  return (
    <div className="se-root">
      <div className="se-list">
        {items.map((item, idx) => (
          <div key={idx} className="se-row">
            <input
              className="se-input"
              value={item}
              disabled={!canEdit}
              onChange={(e) => handleChange(idx, e.target.value)}
              placeholder="Quick reply text…"
            />
            {canEdit && (
              <button className="se-remove-btn" onClick={() => handleRemove(idx)} title="Remove">
                <Trash2 size={14} />
              </button>
            )}
          </div>
        ))}
        {items.length === 0 && (
          <p className="se-empty">No shortcuts defined.</p>
        )}
      </div>
      {canEdit && (
        <div className="se-footer">
          <button className="se-add-btn" onClick={handleAdd}>
            <Plus size={13} /> Add
          </button>
          {dirty && (
            <button className="se-save-btn" onClick={handleSave}>
              Save
            </button>
          )}
        </div>
      )}
      <style>{`
        .se-root { min-width: 260px; }
        .se-list { display: flex; flex-direction: column; gap: 6px; margin-bottom: 8px; }
        .se-row { display: flex; align-items: center; gap: 6px; }
        .se-input { flex: 1; padding: 5px 8px; font-size: 12px; border: 1px solid var(--color-border); border-radius: var(--radius-sm); background: var(--color-bg-secondary); color: var(--color-text-primary); outline: none; }
        .se-input:focus { border-color: var(--color-info); }
        .se-input:disabled { opacity: 0.6; cursor: not-allowed; }
        .se-remove-btn { padding: 4px; background: none; border: none; color: var(--color-danger); cursor: pointer; border-radius: var(--radius-sm); display: flex; align-items: center; }
        .se-remove-btn:hover { background: var(--color-danger-light); }
        .se-empty { font-size: 12px; color: var(--color-text-tertiary); font-style: italic; }
        .se-footer { display: flex; gap: 8px; align-items: center; }
        .se-add-btn { display: flex; align-items: center; gap: 4px; padding: 4px 10px; font-size: 12px; border: 1px solid var(--color-border); background: var(--color-bg-secondary); border-radius: var(--radius-sm); cursor: pointer; color: var(--color-text-secondary); }
        .se-add-btn:hover { background: var(--color-bg-tertiary); }
        .se-save-btn { padding: 4px 12px; font-size: 12px; background: var(--color-primary); color: #fff; border: none; border-radius: var(--radius-sm); cursor: pointer; font-weight: 600; }
        .se-save-btn:hover { opacity: 0.9; }
      `}</style>
    </div>
  );
}
