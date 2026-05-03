import { useState } from 'react';
import { Cpu, Loader2, ShieldAlert, ToggleLeft, ToggleRight, Shield, Search } from 'lucide-react';
import { useSystemConfigs, useUpdateSystemConfig, type SystemConfig } from '@/hooks/useSystemConfigs';
import { useFeatureFlags, useToggleFlag } from '@/hooks/useFeatureFlags';
import { useAuth } from '@/hooks/useAuth';
import { useAdminRole } from '@/hooks/useAdminRole';
import { ADMIN_ROLES } from '@/lib/constants';


type Tab = 'configs' | 'flags';

export function SystemConfigsPage() {
  const [activeTab, setActiveTab] = useState<Tab>('configs');

  return (
    <div className="sc-page">
      <div className="sc-header">
        <h1 className="sc-title">Platform Settings</h1>
        <p className="sc-subtitle">System configurations, moderation rules, and feature toggles</p>
      </div>

      {/* Tab Switch */}
      <div className="sc-tabs">
        <button
          className={`sc-tab ${activeTab === 'configs' ? 'sc-tab--active' : ''}`}
          onClick={() => setActiveTab('configs')}
        >
          <Cpu size={14} />
          System Configs
        </button>
        <button
          className={`sc-tab ${activeTab === 'flags' ? 'sc-tab--active' : ''}`}
          onClick={() => setActiveTab('flags')}
        >
          <ToggleLeft size={14} />
          Feature Flags
        </button>
      </div>

      {activeTab === 'configs' ? <ConfigsTab /> : <FlagsTab />}

      <style>{`
        .sc-page { padding: var(--spacing-page); max-width: 900px; }
        .sc-header { margin-bottom: 24px; }
        .sc-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .sc-subtitle { font-size: 14px; color: var(--color-text-secondary); margin-top: 4px; }

        /* Tabs */
        .sc-tabs {
          display: flex;
          gap: 2px;
          background: var(--color-bg-secondary);
          border: 1px solid var(--color-border-subtle);
          border-radius: var(--radius-md);
          padding: 3px;
          margin-bottom: 28px;
          width: fit-content;
        }
        .sc-tab {
          display: flex;
          align-items: center;
          gap: 6px;
          padding: 8px 20px;
          font-size: 13px;
          font-weight: 500;
          border: none;
          border-radius: calc(var(--radius-md) - 2px);
          background: transparent;
          color: var(--color-text-tertiary);
          cursor: pointer;
          transition: all 0.15s;
        }
        .sc-tab:hover { color: var(--color-text-primary); }
        .sc-tab--active {
          background: var(--color-bg-primary);
          color: var(--color-text-primary);
          font-weight: 600;
          box-shadow: 0 1px 3px rgba(0,0,0,0.06);
        }

        .sc-section { margin-bottom: 32px; }
        .sc-section-header { display: flex; align-items: center; gap: 8px; margin-bottom: 16px; }
        .sc-section-header h2 { font-size: 18px; font-weight: 600; color: var(--color-text-primary); margin: 0; }
        
        .sc-card-list { display: flex; flex-direction: column; gap: 1px; background: var(--color-border-light); border: 1px solid var(--color-border-light); border-radius: var(--radius-md); overflow: hidden; }
        .sc-card { display: flex; justify-content: space-between; align-items: center; padding: 20px; background: var(--color-bg-primary); }
        
        .sc-card-info h3 { font-size: 15px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 4px; }
        .sc-card-info p { font-size: 13px; color: var(--color-text-secondary); margin: 0; }
        
        .sc-select { padding: 8px 12px; font-size: 13px; border: 1px solid var(--color-border); border-radius: var(--radius-sm); background: var(--color-bg-secondary); color: var(--color-text-primary); cursor: pointer; outline: none; }
        .sc-select:focus { border-color: var(--color-info); }
        .sc-select:disabled { opacity: 0.5; cursor: not-allowed; }
        
        /* Toggle Switch */
        .sc-toggle { position: relative; display: inline-block; width: 44px; height: 24px; }
        .sc-toggle input { opacity: 0; width: 0; height: 0; }
        .sc-slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: var(--color-border); transition: .2s; border-radius: 24px; }
        .sc-slider:before { position: absolute; content: ""; height: 18px; width: 18px; left: 3px; bottom: 3px; background-color: white; transition: .2s; border-radius: 50%; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        input:checked + .sc-slider { background-color: var(--color-success); }
        input:disabled + .sc-slider { opacity: 0.5; cursor: not-allowed; }
        input:checked + .sc-slider:before { transform: translateX(20px); }

        .sc-state { display: flex; align-items: center; justify-content: center; padding: 48px; gap: 8px; color: var(--color-text-secondary); }
        .sc-error { color: var(--color-danger); }

        /* Feature Flags section */
        .ff-search-bar {
          display: flex; align-items: center; gap: 8px;
          padding: 8px 12px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          margin-bottom: 20px;
        }
        .ff-search-input { flex: 1; border: none; outline: none; font-size: 14px; color: var(--color-text-primary); background: transparent; }

        .ff-group { margin-bottom: 24px; }
        .ff-group-title { font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--color-text-tertiary); margin-bottom: 8px; padding-left: 4px; }
        .ff-group-items { display: flex; flex-direction: column; gap: 2px; }

        .ff-item {
          display: flex; align-items: center; justify-content: space-between;
          padding: 12px 16px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-md);
          transition: box-shadow 0.15s ease;
        }
        .ff-item:hover { box-shadow: var(--shadow-card-hover); }
        .ff-info { flex: 1; min-width: 0; }
        .ff-key { font-size: 13px; font-family: var(--font-mono); color: var(--color-text-primary); font-weight: 500; }
        .ff-desc { font-size: 12px; color: var(--color-text-tertiary); margin-top: 2px; }
        .ff-toggle { flex-shrink: 0; display: flex; align-items: center; background: none; border: none; cursor: pointer; padding: 4px; border-radius: var(--radius-sm); transition: opacity 0.15s; }
        .ff-toggle:disabled { cursor: not-allowed; opacity: 0.4; }
        .ff-toggle-on { color: var(--color-success); }
        .ff-toggle-off { color: var(--color-text-tertiary); }
        .ff-readonly-badge { display: flex; align-items: center; gap: 6px; font-size: 12px; color: var(--color-warning); background: var(--color-warning-light); padding: 6px 12px; border-radius: var(--radius-md); white-space: nowrap; margin-bottom: 16px; }

        .ff-empty { display: flex; align-items: center; justify-content: center; padding: 40px; color: var(--color-text-tertiary); font-size: 13px; }

        .spin { animation: spin 1s linear infinite; }
        @keyframes spin { 100% { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}

/* ─── Configs Tab ─── */
function ConfigsTab() {
  const { admin } = useAuth();
  const { data: configs, isLoading, error } = useSystemConfigs();
  const updateConfig = useUpdateSystemConfig();

  const handleToggle = async (config: SystemConfig) => {
    if (!admin) return;
    const isCurrentlyEnabled = config.config_value === 'true' || config.config_value === true;
    const newValue = !isCurrentlyEnabled;
    await updateConfig.mutateAsync({
      key: config.config_key,
      value: String(newValue),
      oldValue: config.config_value,
      adminId: admin.user_id,
    });
  };

  const handleChangeSelect = async (config: SystemConfig, newValue: string) => {
    if (!admin) return;
    await updateConfig.mutateAsync({
      key: config.config_key,
      value: `"${newValue}"`,
      oldValue: config.config_value,
      adminId: admin.user_id,
    });
  };

  const handleChangeRaw = async (config: SystemConfig, newValue: string) => {
    if (!admin) return;
    await updateConfig.mutateAsync({
      key: config.config_key,
      value: newValue,
      oldValue: config.config_value,
      adminId: admin.user_id,
    });
  };

  if (isLoading) return <div className="sc-state"><Loader2 size={24} className="spin" /><span>Loading configurations...</span></div>;
  if (error || !configs) return <div className="sc-state sc-error">Failed to load configs.</div>;

  const aiModerationEnabled = configs.find(c => c.config_key === 'ai_moderation_enabled');
  const aiProvider = configs.find(c => c.config_key === 'ai_provider');
  const aiAction = configs.find(c => c.config_key === 'ai_action_on_hit');
  const contentFilterEnabled = configs.find(c => c.config_key === 'content_filter.enabled');
  const contentFilterWarnAction = configs.find(c => c.config_key === 'content_filter.warn_action');
  const contentFilterBlockAction = configs.find(c => c.config_key === 'content_filter.block_action');
  const backendReviewEnabled = configs.find(c => c.config_key === 'backend_review.enabled');
  const backendReviewMode = configs.find(c => c.config_key === 'backend_review.mode');

  return (
    <>
      <div className="sc-section">
        <div className="sc-section-header">
          <ShieldAlert size={20} color="var(--color-warning)" />
          <h2>Content Filter Settings</h2>
        </div>
        <div className="sc-card-list">
          {contentFilterEnabled && (
            <div className="sc-card" style={{ borderBottom: '1px solid var(--color-border-light)' }}>
              <div className="sc-card-info"><h3>Client-Side Filtering</h3><p>Enable Content Filter</p></div>
              <div className="sc-card-action">
                <label className="sc-toggle">
                  <input type="checkbox" checked={contentFilterEnabled.config_value === 'true' || contentFilterEnabled.config_value === true} onChange={() => handleToggle(contentFilterEnabled)} disabled={updateConfig.isPending} />
                  <span className="sc-slider"></span>
                </label>
              </div>
            </div>
          )}
          {contentFilterWarnAction && (
            <div className="sc-card" style={{ borderBottom: '1px solid var(--color-border-light)' }}>
              <div className="sc-card-info"><h3>When Warn words are detected:</h3></div>
              <div className="sc-card-action" style={{ display: 'flex', flexDirection: 'column', gap: '8px', alignItems: 'flex-start' }}>
                {['show_warning', 'silent'].map(val => (
                  <label key={val} style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                    <input type="radio" name="warn_action" value={val} checked={contentFilterWarnAction.config_value === val} onChange={(e) => handleChangeRaw(contentFilterWarnAction, e.target.value)} disabled={updateConfig.isPending} />
                    <span style={{ fontSize: '14px', color: 'var(--color-text-primary)' }}>{val === 'show_warning' ? 'Show Warning (allow send)' : 'Silent (no action)'}</span>
                  </label>
                ))}
              </div>
            </div>
          )}
          {contentFilterBlockAction && (
            <div className="sc-card" style={{ borderBottom: '1px solid var(--color-border-light)' }}>
              <div className="sc-card-info"><h3>When Block words are detected:</h3></div>
              <div className="sc-card-action" style={{ display: 'flex', flexDirection: 'column', gap: '8px', alignItems: 'flex-start' }}>
                {[{v:'reject',l:'Reject (prevent send)'},{v:'mask',l:'Mask (replace with ***)'},{v:'warn_only',l:'Warn Only (show warning, allow send)'}].map(({v,l}) => (
                  <label key={v} style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                    <input type="radio" name="block_action" value={v} checked={contentFilterBlockAction.config_value === v} onChange={(e) => handleChangeRaw(contentFilterBlockAction, e.target.value)} disabled={updateConfig.isPending} />
                    <span style={{ fontSize: '14px', color: 'var(--color-text-primary)' }}>{l}</span>
                  </label>
                ))}
              </div>
            </div>
          )}
          {backendReviewEnabled && (
            <div className="sc-card" style={{ borderBottom: '1px solid var(--color-border-light)' }}>
              <div className="sc-card-info"><h3>Server-Side Review</h3><p>Enable Backend Review</p></div>
              <div className="sc-card-action">
                <label className="sc-toggle">
                  <input type="checkbox" checked={backendReviewEnabled.config_value === 'true' || backendReviewEnabled.config_value === true} onChange={() => handleToggle(backendReviewEnabled)} disabled={updateConfig.isPending} />
                  <span className="sc-slider"></span>
                </label>
              </div>
            </div>
          )}
          {backendReviewMode && (
            <div className="sc-card">
              <div className="sc-card-info"><h3>Review Method:</h3></div>
              <div className="sc-card-action" style={{ display: 'flex', flexDirection: 'column', gap: '8px', alignItems: 'flex-start' }}>
                {[{v:'sensitive_words',l:'Sensitive Words Only'},{v:'ai',l:'AI Moderation Only'},{v:'both',l:'Both (Words + AI)'}].map(({v,l}) => (
                  <label key={v} style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                    <input type="radio" name="backend_review_mode" value={v} checked={backendReviewMode.config_value === v} onChange={(e) => handleChangeRaw(backendReviewMode, e.target.value)} disabled={updateConfig.isPending} />
                    <span style={{ fontSize: '14px', color: 'var(--color-text-primary)' }}>{l}</span>
                  </label>
                ))}
              </div>
            </div>
          )}
          <div className="sc-card" style={{ background: 'var(--color-bg-secondary)' }}>
            <p style={{ fontSize: '13px', color: 'var(--color-text-secondary)', margin: 0 }}>
              ℹ️ Client filtering and server review are independent. Both can be enabled simultaneously.
            </p>
          </div>
        </div>
      </div>

      <div className="sc-section">
        <div className="sc-section-header">
          <ShieldAlert size={20} color="var(--color-warning)" />
          <h2>AI Content Moderation</h2>
        </div>
        <div className="sc-card-list">
          {aiModerationEnabled && (
            <div className="sc-card">
              <div className="sc-card-info"><h3>Secondary AI Review</h3><p>{aiModerationEnabled.description}</p></div>
              <div className="sc-card-action">
                <label className="sc-toggle">
                  <input type="checkbox" checked={aiModerationEnabled.config_value === 'true' || aiModerationEnabled.config_value === true} onChange={() => handleToggle(aiModerationEnabled)} disabled={updateConfig.isPending} />
                  <span className="sc-slider"></span>
                </label>
              </div>
            </div>
          )}
          {aiProvider && (
            <div className="sc-card">
              <div className="sc-card-info"><h3>AI Provider</h3><p>{aiProvider.description}</p></div>
              <div className="sc-card-action">
                <select value={(aiProvider.config_value || '').replace(/"/g, '')} onChange={(e) => handleChangeSelect(aiProvider, e.target.value)} disabled={updateConfig.isPending} className="sc-select">
                  <option value="openai">OpenAI (GPT-4o Vision)</option>
                  <option value="google">Google (Gemini Pro Vision)</option>
                </select>
              </div>
            </div>
          )}
          {aiAction && (
            <div className="sc-card">
              <div className="sc-card-info"><h3>Action on Violation</h3><p>{aiAction.description}</p></div>
              <div className="sc-card-action">
                <select value={(aiAction.config_value || '').replace(/"/g, '')} onChange={(e) => handleChangeSelect(aiAction, e.target.value)} disabled={updateConfig.isPending} className="sc-select">
                  <option value="flag">Flag for Manual Review</option>
                  <option value="reject">Auto-Reject (Remove immediately)</option>
                </select>
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
}

/* ─── Feature Flags Tab ─── */
function FlagsTab() {
  const [search, setSearch] = useState('');
  const { data: flags, isLoading, error } = useFeatureFlags();
  const toggleFlag = useToggleFlag();
  const { role } = useAdminRole();

  const canEdit = role === ADMIN_ROLES.PLATFORM_SUPER_ADMIN;

  const parseFlagValue = (value: unknown): boolean => {
    if (typeof value === 'boolean') return value;
    if (typeof value === 'string') {
      try { return JSON.parse(value) === true; } catch { return value === 'true'; }
    }
    return false;
  };

  const groupedFlags = (flags ?? [])
    .filter((f) => f.key.toLowerCase().includes(search.toLowerCase()) || (f.description ?? '').toLowerCase().includes(search.toLowerCase()))
    .reduce<Record<string, typeof flags>>((acc, flag) => {
      if (!flag) return acc;
      const namespace = flag.key.split('.')[0] ?? 'other';
      if (!acc[namespace]) acc[namespace] = [];
      acc[namespace]!.push(flag);
      return acc;
    }, {});

  if (isLoading) return <div className="sc-state"><Loader2 size={24} className="spin" /><span>Loading feature flags...</span></div>;
  if (error) return <div className="sc-state sc-error">Failed to load feature flags: {(error as Error).message}</div>;

  return (
    <>
      {!canEdit && (
        <div className="ff-readonly-badge">
          <Shield size={14} />
          <span>Read-only — Super Admin access required to toggle</span>
        </div>
      )}

      <div className="ff-search-bar">
        <Search size={16} color="var(--color-text-tertiary)" />
        <input
          type="text"
          placeholder="Search flags by key or description..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="ff-search-input"
        />
      </div>

      <div className="ff-groups">
        {Object.entries(groupedFlags).map(([namespace, items]) => (
          <div key={namespace} className="ff-group">
            <h3 className="ff-group-title">{namespace}</h3>
            <div className="ff-group-items">
              {items?.map((flag) => {
                const isOn = parseFlagValue(flag.value);
                const isPending = toggleFlag.isPending && toggleFlag.variables?.key === flag.key;

                return (
                  <div key={flag.key} className="ff-item">
                    <div className="ff-info">
                      <code className="ff-key">{flag.key}</code>
                      <p className="ff-desc">{flag.description ?? 'No description'}</p>
                    </div>
                    <button
                      className={`ff-toggle ${isOn ? 'ff-toggle-on' : 'ff-toggle-off'}`}
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
          <div className="ff-empty">No flags match your search.</div>
        )}
      </div>
    </>
  );
}
