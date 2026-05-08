import { useState } from 'react';
import {
  Cpu, Loader2, ShieldAlert, ToggleLeft, ToggleRight, Shield, Search,
  KeyRound, Eye, EyeOff, CheckCircle2, XCircle, Upload, ImageIcon,
  RefreshCw, ScanSearch, AlertTriangle,
} from 'lucide-react';
import { useSystemConfigs, useUpdateSystemConfig, type SystemConfig } from '@/hooks/useSystemConfigs';
import { useFeatureFlags, useToggleFlag } from '@/hooks/useFeatureFlags';
import {
  useModerationUsage, useSecretStatus, useSavePlatformSecret,
  useTestOpenAIModeration, useTestGoogleVisionModeration,
  type OpenAIResult, type GoogleResult,
} from '@/hooks/useImageModeration';
import { useAuth } from '@/hooks/useAuth';
import { useAdminRole } from '@/hooks/useAdminRole';
import { supabase } from '@/lib/supabase';
import { ADMIN_ROLES } from '@/lib/constants';


type Tab = 'configs' | 'flags' | 'moderation';

export function SystemConfigsPage() {
  const [activeTab, setActiveTab] = useState<Tab>('configs');
  const { role } = useAdminRole();

  const canSeeModerationTest = role === ADMIN_ROLES.PLATFORM_SUPER_ADMIN || role === ADMIN_ROLES.PLATFORM_ADMIN;

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
          Content Moderation
        </button>
        <button
          className={`sc-tab ${activeTab === 'flags' ? 'sc-tab--active' : ''}`}
          onClick={() => setActiveTab('flags')}
        >
          <ToggleLeft size={14} />
          Feature Flags
        </button>
        {canSeeModerationTest && (
          <button
            className={`sc-tab ${activeTab === 'moderation' ? 'sc-tab--active' : ''}`}
            onClick={() => setActiveTab('moderation')}
          >
            <ScanSearch size={14} />
            Image Moderation
          </button>
        )}
      </div>

      {activeTab === 'configs' ? <ConfigsTab /> : activeTab === 'flags' ? <FlagsTab /> : <ImageModerationTab />}


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
        .sc-section-header { display: flex; align-items: flex-start; gap: 10px; margin-bottom: 16px; }
        .sc-section-header h2 { font-size: 18px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 3px; }
        .sc-section-desc { font-size: 13px; color: var(--color-text-secondary); margin: 0; }
        .sc-card--note { background: var(--color-bg-secondary) !important; }
        .sc-card--note p { font-size: 13px; color: var(--color-text-secondary); margin: 0; }

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

  const isBackendEnabled = backendReviewEnabled?.config_value === 'true' || backendReviewEnabled?.config_value === true;
  const showAiSettings = backendReviewMode?.config_value === 'ai' || backendReviewMode?.config_value === 'both';

  return (
    <>
      {/* ── App-Side Settings ──────────────────────────────────────── */}
      <div className="sc-section">
        <div className="sc-section-header">
          <ShieldAlert size={20} color="var(--color-warning)" />
          <div>
            <h2>App-Side Settings</h2>
            <p className="sc-section-desc">Client-side text filtering for chat messages and listing descriptions</p>
          </div>
        </div>
        <div className="sc-card-list">
          {contentFilterEnabled && (
            <div className="sc-card" style={{ borderBottom: '1px solid var(--color-border-light)' }}>
              <div className="sc-card-info">
                <h3>Enable Client-Side Word Filter</h3>
                <p>Flutter app checks each message locally against the sensitive word list before sending — no network request needed</p>
              </div>
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
              <div className="sc-card-info">
                <h3>When a Warn word is detected</h3>
                <p>Mildly inappropriate words — softer response</p>
              </div>
              <div className="sc-card-action" style={{ display: 'flex', flexDirection: 'column', gap: '8px', alignItems: 'flex-start' }}>
                {[
                  { v: 'show_warning', l: 'Show Warning — alert user but allow sending' },
                  { v: 'silent',       l: 'Silent — detect but take no visible action' },
                ].map(({ v, l }) => (
                  <label key={v} style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                    <input type="radio" name="warn_action" value={v} checked={contentFilterWarnAction.config_value === v} onChange={(e) => handleChangeRaw(contentFilterWarnAction, e.target.value)} disabled={updateConfig.isPending} />
                    <span style={{ fontSize: '14px', color: 'var(--color-text-primary)' }}>{l}</span>
                  </label>
                ))}
              </div>
            </div>
          )}
          {contentFilterBlockAction && (
            <div className="sc-card">
              <div className="sc-card-info">
                <h3>When a Block word is detected</h3>
                <p>Severely inappropriate words — stricter response</p>
              </div>
              <div className="sc-card-action" style={{ display: 'flex', flexDirection: 'column', gap: '8px', alignItems: 'flex-start' }}>
                {[
                  { v: 'reject',    l: 'Reject — prevent the message from being sent' },
                  { v: 'mask',      l: 'Mask — replace bad words with *** and allow send' },
                  { v: 'warn_only', l: 'Warn Only — show warning but allow send' },
                ].map(({ v, l }) => (
                  <label key={v} style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                    <input type="radio" name="block_action" value={v} checked={contentFilterBlockAction.config_value === v} onChange={(e) => handleChangeRaw(contentFilterBlockAction, e.target.value)} disabled={updateConfig.isPending} />
                    <span style={{ fontSize: '14px', color: 'var(--color-text-primary)' }}>{l}</span>
                  </label>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>


      {/* ── Server-Side Settings ────────────────────────────────────── */}
      <div className="sc-section">
        <div className="sc-section-header">
          <ShieldAlert size={20} color="var(--color-info)" />
          <div>
            <h2>Server-Side Settings</h2>
            <p className="sc-section-desc">Backend review pipelines for text and images</p>
          </div>
        </div>
        <div className="sc-card-list">
          {backendReviewEnabled && (
            <div className="sc-card" style={{ borderBottom: isBackendEnabled ? '1px solid var(--color-border-light)' : 'none' }}>
              <div className="sc-card-info">
                <h3>Enable Server-Side Review</h3>
                <p>After content is saved, run a secondary check on the server</p>
              </div>
              <div className="sc-card-action">
                <label className="sc-toggle">
                  <input type="checkbox" checked={isBackendEnabled} onChange={() => handleToggle(backendReviewEnabled)} disabled={updateConfig.isPending} />
                  <span className="sc-slider"></span>
                </label>
              </div>
            </div>
          )}

          {isBackendEnabled && backendReviewMode && (
            <div className="sc-card" style={{ borderBottom: showAiSettings ? '1px solid var(--color-border-light)' : 'none' }}>
              <div className="sc-card-info">
                <h3>Server Review Method</h3>
                <p>Choose how the backend analyzes content</p>
              </div>
              <div className="sc-card-action" style={{ display: 'flex', flexDirection: 'column', gap: '8px', alignItems: 'flex-start' }}>
                {[
                  { v: 'sensitive_words', l: 'Sensitive Words Only — fast, no AI cost' },
                  { v: 'ai',             l: 'AI Only — send to AI for analysis' },
                  { v: 'both',           l: 'Both — run word filter then AI review' },
                ].map(({ v, l }) => (
                  <label key={v} style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                    <input type="radio" name="backend_review_mode" value={v} checked={backendReviewMode.config_value === v} onChange={(e) => handleChangeRaw(backendReviewMode, e.target.value)} disabled={updateConfig.isPending} />
                    <span style={{ fontSize: '14px', color: 'var(--color-text-primary)' }}>{l}</span>
                  </label>
                ))}
              </div>
            </div>
          )}

          {isBackendEnabled && showAiSettings && (
            <>
              {aiProvider && (
                <div className="sc-card" style={{ borderBottom: '1px solid var(--color-border-light)' }}>
                  <div className="sc-card-info">
                    <h3>AI Engine Provider</h3>
                    <p>Which AI service to call for content analysis</p>
                  </div>
                  <div className="sc-card-action">
                    <select
                      value={(aiProvider.config_value || '').replace(/"/g, '')}
                      onChange={(e) => handleChangeSelect(aiProvider, e.target.value)}
                      disabled={updateConfig.isPending}
                      className="sc-select"
                    >
                      <option value="openai">OpenAI — omni-moderation-latest</option>
                      <option value="google">Google — Cloud Vision SafeSearch</option>
                    </select>
                  </div>
                </div>
              )}
              {aiModerationEnabled && (
                <div className="sc-card" style={{ borderBottom: '1px solid var(--color-border-light)' }}>
                  <div className="sc-card-info">
                    <h3>Enable AI Image Review</h3>
                    <p>Also run AI checks on listing photos when a seller uploads them</p>
                  </div>
                  <div className="sc-card-action">
                    <label className="sc-toggle">
                      <input type="checkbox" checked={aiModerationEnabled.config_value === 'true' || aiModerationEnabled.config_value === true} onChange={() => handleToggle(aiModerationEnabled)} disabled={updateConfig.isPending} />
                      <span className="sc-slider"></span>
                    </label>
                  </div>
                </div>
              )}
              {aiAction && (
                <div className="sc-card">
                  <div className="sc-card-info">
                    <h3>Action on Violation</h3>
                    <p>What happens when AI flags content as unsafe</p>
                  </div>
                  <div className="sc-card-action">
                    <select
                      value={(aiAction.config_value || '').replace(/"/g, '')}
                      onChange={(e) => handleChangeSelect(aiAction, e.target.value)}
                      disabled={updateConfig.isPending}
                      className="sc-select"
                    >
                      <option value="flag">Flag — queue for manual admin review</option>
                      <option value="reject">Auto-Reject — block or remove immediately</option>
                    </select>
                  </div>
                </div>
              )}
            </>
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

// ─── Helpers ─────────────────────────────────────────────────────────────────

/** Upload a file to Supabase storage and return a public URL for AI testing. */
async function uploadTestImage(file: File): Promise<string> {
  const ext  = file.name.split('.').pop() ?? 'jpg';
  const path = `${Date.now()}.${ext}`;

  // NOTE: Uses the dedicated moderation-test-images bucket (public read,
  // admin-only write). The listing-images bucket's RLS requires the first
  // folder to match the uploader's UUID, which blocks admin test uploads.
  const { error } = await supabase.storage.from('moderation-test-images').upload(path, file, {
    upsert: true,
    contentType: file.type,
  });
  if (error) throw new Error(`Upload failed: ${error.message}`);

  const { data } = supabase.storage.from('moderation-test-images').getPublicUrl(path);
  return data.publicUrl;
}

// ─── API Key Row ──────────────────────────────────────────────────────────────

function ApiKeyRow({ secretKey, label }: { secretKey: string, label: string }) {
  const { role } = useAdminRole();
  const isSysadmin = role === ADMIN_ROLES.PLATFORM_SUPER_ADMIN;
  const { data: status, isLoading } = useSecretStatus(secretKey);
  const save = useSavePlatformSecret();
  const [input, setInput] = useState('');
  const [showInput, setShowInput] = useState(false);
  const [visible, setVisible] = useState(false);
  const [saving, setSaving] = useState(false);

  const handleSave = async () => {
    if (!input.trim()) return;
    setSaving(true);
    try {
      await save.mutateAsync({ key: secretKey, value: input.trim(), description: label });
      setInput('');
      setShowInput(false);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="im-key-row">
      <div className="im-key-meta">
        <KeyRound size={14} color="var(--color-info)" />
        <span className="im-key-label">{label}</span>
        {isLoading ? (
          <Loader2 size={12} className="spin" />
        ) : status?.exists ? (
          <span className="im-badge im-badge--ok"><CheckCircle2 size={11} /> Saved</span>
        ) : (
          <span className="im-badge im-badge--missing"><AlertTriangle size={11} /> Not set</span>
        )}
      </div>
      {showInput ? (
        <div className="im-key-input-row">
          <div className="im-key-input-wrap">
            <input
              className="im-key-input"
              type={visible ? 'text' : 'password'}
              placeholder="Paste API key…"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSave()}
            />
            <button className="im-eye-btn" onClick={() => setVisible(v => !v)}>
              {visible ? <EyeOff size={14} /> : <Eye size={14} />}
            </button>
          </div>
          <button className="im-save-btn" onClick={handleSave} disabled={saving || !input.trim()}>
            {saving ? <Loader2 size={13} className="spin" /> : 'Save'}
          </button>
          <button className="im-cancel-btn" onClick={() => { setShowInput(false); setInput(''); }}>Cancel</button>
        </div>
      ) : (
        <button className="im-update-btn" onClick={() => setShowInput(true)} disabled={!isSysadmin} title={!isSysadmin ? 'Only SYSADMIN can update API keys' : ''}>
          {status?.exists ? 'Update Key' : 'Set Key'}
        </button>
      )}
    </div>
  );
}

// ─── Result display ───────────────────────────────────────────────────────────

function OpenAIResultView({ result }: { result: OpenAIResult }) {
  const flaggedEntries = Object.entries(result.categories).filter(([, v]) => v);
  return (
    <div className={`im-result ${result.flagged ? 'im-result--flagged' : 'im-result--ok'}`}>
      <div className="im-result-header">
        {result.flagged ? <XCircle size={16} /> : <CheckCircle2 size={16} />}
        <strong>OpenAI · {result.model}</strong>
        <span className="im-result-verdict">{result.flagged ? 'FLAGGED' : 'SAFE'}</span>
      </div>
      {flaggedEntries.length > 0 && (
        <p className="im-result-detail">Categories: {flaggedEntries.map(([k]) => k).join(', ')}</p>
      )}
      <p className="im-result-url" title={result.image_url}>{result.image_url}</p>
    </div>
  );
}

function GoogleResultView({ result }: { result: GoogleResult }) {
  return (
    <div className={`im-result ${result.flagged ? 'im-result--flagged' : 'im-result--ok'}`}>
      <div className="im-result-header">
        {result.flagged ? <XCircle size={16} /> : <CheckCircle2 size={16} />}
        <strong>Google Vision · {result.model}</strong>
        <span className="im-result-verdict">{result.flagged ? 'FLAGGED' : 'SAFE'}</span>
      </div>
      {result.reasons.length > 0 && (
        <p className="im-result-detail">Reasons: {result.reasons.join(', ')}</p>
      )}
      <div className="im-safesearch">
        {Object.entries(result.safe_search).map(([k, v]) => (
          <span key={k} className={`im-ss-chip im-ss-${v.toLowerCase()}`}>{k}: {v}</span>
        ))}
      </div>
      <p className="im-result-url" title={result.image_url}>{result.image_url}</p>
    </div>
  );
}

// ─── Image Moderation Tab ─────────────────────────────────────────────────────

function ImageModerationTab() {
  const { data: usage, isLoading: usageLoading, refetch: refetchUsage } = useModerationUsage();
  const testOpenAI = useTestOpenAIModeration();
  const testGoogle = useTestGoogleVisionModeration();


  const [uploadedUrls, setUploadedUrls] = useState<string[]>([]);
  const [uploading, setUploading]       = useState(false);
  const [uploadErr, setUploadErr]       = useState<string | null>(null);
  const [previewSrcs, setPreviewSrcs]   = useState<string[]>([]);
  const [testText, setTestText]         = useState('');
  const [openAIResult, setOpenAIResult] = useState<OpenAIResult | null>(null);
  const [googleResult, setGoogleResult] = useState<GoogleResult | null>(null);
  const [testErr, setTestErr]           = useState<string | null>(null);

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    if (!files.length) return;
    
    // Local preview
    setPreviewSrcs(files.map(f => URL.createObjectURL(f)));
    setUploadedUrls([]);
    setUploadErr(null);
    setOpenAIResult(null);
    setGoogleResult(null);
    setTestErr(null);

    setUploading(true);
    try {
      const urls = await Promise.all(files.map(f => uploadTestImage(f)));
      setUploadedUrls(urls);
    } catch (err: any) {
      setUploadErr(err.message);
    } finally {
      setUploading(false);
    }
  };

  const handleTest = async (provider: 'openai' | 'google') => {
    setTestErr(null);
    try {
      const isTest = uploadedUrls.length === 0 && !testText;
      const payload = isTest 
        ? { text: undefined, imageUrls: undefined, isTest: true }
        : { text: testText || undefined, imageUrls: uploadedUrls.length > 0 ? uploadedUrls : undefined };

      if (provider === 'openai') {
        const result = await testOpenAI.mutateAsync(payload);
        setOpenAIResult(result);
      } else {
        const result = await testGoogle.mutateAsync(payload);
        setGoogleResult(result);
      }
      refetchUsage();
    } catch (err: any) {
      setTestErr(err.message);
    }
  };

  const googlePct = usage
    ? Math.min(100, Math.round((usage.google_vision.count / (usage.google_vision.limit ?? 1000)) * 100))
    : 0;

  return (
    <>
      {/* API Keys */}
      <div className="sc-section">
        <div className="sc-section-header">
          <KeyRound size={20} color="var(--color-info)" />
          <h2>API Key Configuration</h2>
        </div>
        <p style={{ fontSize: 13, color: 'var(--color-text-tertiary)', marginBottom: 16 }}>
          Keys are encrypted with pgcrypto before storage. The plaintext is never returned after saving.
        </p>
        <div className="im-key-card">
          <ApiKeyRow secretKey="openai_api_key"        label="OpenAI API Key (omni-moderation-latest)" />
          <ApiKeyRow secretKey="google_vision_api_key" label="Google Vision API Key (SafeSearch)" />
        </div>
      </div>

      {/* Usage meters */}
      <div className="sc-section">
        <div className="sc-section-header">
          <RefreshCw size={18} color="var(--color-info)" />
          <h2>Monthly Usage</h2>
          <button className="im-refresh-btn" onClick={() => refetchUsage()} disabled={usageLoading}>
            <RefreshCw size={13} className={usageLoading ? 'spin' : ''} />
          </button>
        </div>
        {usageLoading ? (
          <div className="sc-state"><Loader2 size={20} className="spin" /></div>
        ) : usage ? (
          <div className="im-usage-grid">
            <div className="im-usage-card">
              <span className="im-usage-label">OpenAI</span>
              <span className="im-usage-count">{usage.openai.count.toLocaleString()}</span>
              <span className="im-usage-sublabel">calls this month · no hard limit</span>
            </div>
            <div className="im-usage-card">
              <span className="im-usage-label">Google Vision</span>
              <span className="im-usage-count">{usage.google_vision.count.toLocaleString()} / {(usage.google_vision.limit ?? 1000).toLocaleString()}</span>
              <div className="im-progress-bar">
                <div
                  className={`im-progress-fill ${googlePct >= 90 ? 'danger' : googlePct >= 70 ? 'warn' : ''}`}
                  style={{ width: `${googlePct}%` }}
                />
              </div>
              <span className="im-usage-sublabel">{googlePct}% of free tier used</span>
            </div>
          </div>
        ) : null}
      </div>

      {/* Test Section */}
      <div className="sc-section">
        <div className="sc-section-header">
          <ScanSearch size={20} color="var(--color-info)" />
          <h2>Test Moderation</h2>
        </div>
        <p style={{ fontSize: 13, color: 'var(--color-text-tertiary)', marginBottom: 16 }}>
          Upload an image to test whether the AI providers can read it from Supabase Storage.
          Verifies your API keys and end-to-end connectivity.
        </p>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', marginBottom: '16px' }}>
          <textarea
            className="sc-textarea"
            style={{ minHeight: '80px' }}
            placeholder="Enter text content to moderate (optional)..."
            value={testText}
            onChange={(e) => setTestText(e.target.value)}
          />
          
          {/* Upload zone */}
          <label
            className={`im-upload-zone ${previewSrcs.length > 0 ? 'has-preview' : ''}`}
          >
            <input
              type="file"
              accept="image/*"
              multiple
              style={{ display: 'none' }}
              onChange={handleFileChange}
            />
            {previewSrcs.length > 0 ? (
              <div className="im-preview-wrap" style={{ position: 'relative', display: 'flex', gap: '8px', flexWrap: 'wrap', justifyContent: 'center', width: '100%', padding: '20px' }}>
                {previewSrcs.map((src, i) => (
                  <img key={i} className="im-preview" style={{ width: '80px', height: '80px', objectFit: 'cover' }} src={src} alt="preview" />
                ))}
                <div className="im-preview-overlay">
                  <Upload size={20} />
                  <span>Click to replace</span>
                </div>
              </div>
            ) : (
              <>
                <ImageIcon size={32} color="var(--color-text-tertiary)" />
                <p className="im-upload-hint">Click to upload images<br />JPEG · PNG · WEBP — max 10 MB</p>
              </>
            )}
          </label>
        </div>

        {uploading && (
          <div className="im-upload-status">
            <Loader2 size={14} className="spin" /> Uploading to Supabase Storage…
          </div>
        )}
        {uploadErr && (
          <div className="im-upload-status im-upload-status--err">
            <XCircle size={14} /> {uploadErr}
          </div>
        )}
        {uploadedUrls.length > 0 && !uploading && (
          <div className="im-upload-status im-upload-status--ok">
            <CheckCircle2 size={14} /> {uploadedUrls.length} image(s) uploaded · Ready for testing
          </div>
        )}

        {/* Test buttons */}
        <div className="im-test-actions">
          <button
            className="im-test-btn"
            onClick={() => handleTest('openai')}
            disabled={testOpenAI.isPending}
          >
            {testOpenAI.isPending ? <Loader2 size={14} className="spin" /> : <ScanSearch size={14} />}
            {uploadedUrls.length > 0 || testText ? 'Test with OpenAI' : 'Quick Test OpenAI'}
          </button>
          <button
            className="im-test-btn im-test-btn--google"
            onClick={() => handleTest('google')}
            disabled={testGoogle.isPending}
          >
            {testGoogle.isPending ? <Loader2 size={14} className="spin" /> : <ScanSearch size={14} />}
            {uploadedUrls.length > 0 || testText ? 'Test with Google Vision' : 'Quick Test Google Vision'}
          </button>
        </div>
        {uploadedUrls.length === 0 && !testText && (
          <p style={{ fontSize: 12, color: 'var(--color-text-tertiary)', marginTop: 8 }}>
            "Quick Test" uses a default image URL embedded in the Edge Function.
            Enter text or upload images above to test with your own inputs.
          </p>
        )}

        {testErr && (
          <div className="im-result im-result--flagged" style={{ marginTop: 16 }}>
            <div className="im-result-header"><XCircle size={16} /> Error</div>
            <p className="im-result-detail">{testErr}</p>
          </div>
        )}

        {openAIResult && <OpenAIResultView result={openAIResult} />}
        {googleResult && <GoogleResultView result={googleResult} />}
      </div>

      <style>{`
        /* API Key rows */
        .im-key-card { background: var(--color-bg-primary); border: 1px solid var(--color-border-light); border-radius: var(--radius-md); overflow: hidden; }
        .im-key-row { display: flex; align-items: flex-start; flex-direction: column; gap: 10px; padding: 16px 20px; border-bottom: 1px solid var(--color-border-light); }
        .im-key-row:last-child { border-bottom: none; }
        .im-key-meta { display: flex; align-items: center; gap: 8px; }
        .im-key-label { font-size: 14px; font-weight: 500; color: var(--color-text-primary); }
        .im-badge { display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px; border-radius: var(--radius-sm); font-size: 11px; font-weight: 600; }
        .im-badge--ok { background: var(--color-success-light); color: var(--color-success); }
        .im-badge--missing { background: var(--color-warning-light, #fff3cd); color: var(--color-warning, #d97706); }
        .im-key-input-row { display: flex; align-items: center; gap: 8px; width: 100%; }
        .im-key-input-wrap { position: relative; flex: 1; }
        .im-key-input { width: 100%; padding: 8px 36px 8px 10px; font-size: 13px; border: 1px solid var(--color-info); border-radius: var(--radius-sm); background: var(--color-bg-secondary); color: var(--color-text-primary); outline: none; box-sizing: border-box; }
        .im-eye-btn { position: absolute; right: 8px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; color: var(--color-text-tertiary); padding: 0; }
        .im-save-btn { padding: 8px 16px; font-size: 13px; background: var(--color-info); color: white; border: none; border-radius: var(--radius-sm); cursor: pointer; display: flex; align-items: center; gap: 6px; white-space: nowrap; }
        .im-save-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .im-cancel-btn { padding: 8px 12px; font-size: 13px; background: none; border: 1px solid var(--color-border); border-radius: var(--radius-sm); cursor: pointer; color: var(--color-text-secondary); }
        .im-update-btn { padding: 6px 14px; font-size: 12px; background: var(--color-bg-secondary); border: 1px solid var(--color-border); border-radius: var(--radius-sm); cursor: pointer; color: var(--color-text-secondary); transition: all 0.1s; }
        .im-update-btn:hover { border-color: var(--color-info); color: var(--color-info); }
        .im-refresh-btn { margin-left: auto; padding: 4px 8px; background: none; border: 1px solid var(--color-border-light); border-radius: var(--radius-sm); cursor: pointer; color: var(--color-text-tertiary); display: flex; align-items: center; }
        .im-refresh-btn:hover { border-color: var(--color-info); color: var(--color-info); }

        /* Usage meters */
        .im-usage-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        @media (max-width: 600px) { .im-usage-grid { grid-template-columns: 1fr; } }
        .im-usage-card { background: var(--color-bg-primary); border: 1px solid var(--color-border-light); border-radius: var(--radius-md); padding: 20px; display: flex; flex-direction: column; gap: 4px; }
        .im-usage-label { font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; color: var(--color-text-tertiary); }
        .im-usage-count { font-size: 24px; font-weight: 700; color: var(--color-text-primary); font-variant-numeric: tabular-nums; }
        .im-usage-sublabel { font-size: 12px; color: var(--color-text-tertiary); }
        .im-progress-bar { height: 6px; background: var(--color-bg-tertiary); border-radius: 3px; overflow: hidden; margin: 4px 0; }
        .im-progress-fill { height: 100%; border-radius: 3px; background: var(--color-success); transition: width 0.3s ease; }
        .im-progress-fill.warn { background: var(--color-warning, #d97706); }
        .im-progress-fill.danger { background: var(--color-danger); }

        /* Upload zone */
        .im-upload-zone {
          border: 2px dashed var(--color-border);
          border-radius: var(--radius-lg);
          padding: 40px;
          display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 12px;
          cursor: pointer; transition: all 0.15s; min-height: 160px;
          background: var(--color-bg-secondary);
        }
        .im-upload-zone:hover { border-color: var(--color-info); background: var(--color-info-light, #e8f4fd); }
        .im-upload-zone.has-preview { padding: 0; overflow: hidden; }
        .im-upload-hint { font-size: 13px; color: var(--color-text-tertiary); text-align: center; line-height: 1.6; margin: 0; }
        .im-preview-wrap { position: relative; width: 100%; }
        .im-preview { width: 100%; max-height: 260px; object-fit: contain; display: block; background: var(--color-bg-tertiary); }
        .im-preview-overlay {
          position: absolute; inset: 0; background: rgba(0,0,0,0.4);
          display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 8px;
          color: white; font-size: 13px; opacity: 0; transition: opacity 0.2s;
        }
        .im-preview-wrap:hover .im-preview-overlay { opacity: 1; }
        .im-upload-status { display: flex; align-items: center; gap: 8px; margin-top: 10px; font-size: 13px; color: var(--color-text-secondary); }
        .im-upload-status--ok { color: var(--color-success); }
        .im-upload-status--err { color: var(--color-danger); }

        /* Test buttons */
        .im-test-actions { display: flex; gap: 10px; margin-top: 16px; flex-wrap: wrap; }
        .im-test-btn {
          display: flex; align-items: center; gap: 6px; padding: 10px 18px;
          font-size: 13px; font-weight: 500;
          background: var(--color-info); color: white;
          border: none; border-radius: var(--radius-md); cursor: pointer;
          transition: opacity 0.15s;
        }
        .im-test-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .im-test-btn:hover:not(:disabled) { opacity: 0.88; }
        .im-test-btn--google { background: #4285F4; }

        /* Results */
        .im-result { margin-top: 16px; padding: 16px; border-radius: var(--radius-md); border: 1px solid; }
        .im-result--ok { background: var(--color-success-light, #d3f9d8); border-color: var(--color-success); color: var(--color-success); }
        .im-result--flagged { background: var(--color-danger-light, #ffe4e6); border-color: var(--color-danger); color: var(--color-danger); }
        .im-result-header { display: flex; align-items: center; gap: 8px; font-size: 14px; margin-bottom: 6px; }
        .im-result-verdict { margin-left: auto; font-size: 12px; font-weight: 700; letter-spacing: 0.05em; }
        .im-result-detail { font-size: 12px; margin: 4px 0; opacity: 0.85; }
        .im-result-url { font-size: 11px; font-family: var(--font-mono); word-break: break-all; opacity: 0.6; margin: 4px 0 0; }
        .im-safesearch { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; }
        .im-ss-chip { font-size: 11px; padding: 2px 8px; border-radius: var(--radius-sm); background: rgba(255,255,255,0.5); border: 1px solid currentColor; opacity: 0.8; }
      `}</style>
    </>
  );
}

