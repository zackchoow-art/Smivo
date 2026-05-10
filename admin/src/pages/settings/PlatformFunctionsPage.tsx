/**
 * Platform Functions — unified hub for all platform-level configuration.
 * Replaces Feature Flags and parts of System Configuration pages.
 * Each section renders as a collapsible panel with inline content.
 */
import { useState } from 'react';
import {
  ChevronDown, ChevronRight, ShoppingCart, Bell, MessageCircle,
  Flag, Ban, Settings, Sparkles, Loader2, ExternalLink,
} from 'lucide-react';
import type { ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { useDictItems, DICT_REGISTRY } from '@/hooks/useDictionary';
import { useFeatureFlags, useToggleFlag } from '@/hooks/useFeatureFlags';
import { useSystemConfigs, useUpdateSystemConfig } from '@/hooks/useSystemConfigs';
import { useAuth } from '@/hooks/useAuth';
import { useAdminRole } from '@/hooks/useAdminRole';
import { ADMIN_ROLES } from '@/lib/constants';

// ── Reusable: Mini Dictionary Table ─────────────────────────────────────────
function DictMiniTable({ dictType }: { dictType: string }) {
  const { data: items, isLoading } = useDictItems(dictType);
  const navigate = useNavigate();
  const meta = DICT_REGISTRY[dictType];

  if (isLoading) return <div className="pf-mini-loading"><Loader2 size={14} className="spin" /> Loading...</div>;
  if (!items?.length) return <div className="pf-mini-empty">No entries</div>;

  return (
    <div className="pf-dict-block">
      <div className="pf-dict-block__header">
        <span className="pf-dict-block__title">{meta?.icon} {meta?.title ?? dictType}</span>
        <button className="pf-link-btn" onClick={() => navigate(`/settings/school-settings/${dictType}?from=platform-functions`)}>
          <ExternalLink size={12} /> Manage
        </button>
      </div>
      <table className="pf-table">
        <thead>
          <tr><th>Code</th><th>Label</th><th>Description</th><th>Status</th></tr>
        </thead>
        <tbody>
          {items.map((item) => (
            <tr key={item.id}>
              <td><code>{item.dict_key}</code></td>
              <td>{item.dict_value}</td>
              <td className="pf-td-desc">{item.description ?? '—'}</td>
              <td><span className={`pf-badge ${item.is_active ? 'pf-badge--active' : 'pf-badge--inactive'}`}>
                {item.is_active ? 'Active' : 'Inactive'}
              </span></td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="pf-source-hint">Source: system_dictionaries → {dictType}</div>
    </div>
  );
}

// ── Reusable: Feature Flag Toggle ───────────────────────────────────────────
function FlagToggle({ flagKey, label, description, flags, canEdit, onToggle }: {
  flagKey: string;
  label: string;
  description: string;
  flags: Array<{ key: string; value: boolean | string | number }>;
  canEdit: boolean;
  onToggle: (key: string, value: boolean) => void;
}) {
  const flag = flags.find((f) => f.key === flagKey);
  const isOn = flag ? parseBool(flag.value) : false;

  return (
    <div className="pf-toggle-row">
      <div className="pf-toggle-info">
        <span className="pf-toggle-label">{label}</span>
        <span className="pf-toggle-desc">{description}</span>
        <span className="pf-source-hint">Source: system_settings → {flagKey}</span>
      </div>
      <button
        className={`pf-toggle-switch ${isOn ? 'pf-toggle-switch--on' : ''}`}
        onClick={() => canEdit && onToggle(flagKey, !isOn)}
        disabled={!canEdit || !flag}
        title={!flag ? 'Flag not found in database' : canEdit ? 'Toggle' : 'Read-only'}
      >
        <span className="pf-toggle-knob" />
      </button>
    </div>
  );
}

// ── Reusable: Config Text Editor ────────────────────────────────────────────
function ConfigEditor({ configKey, label, description, configs, canEdit, onSave }: {
  configKey: string;
  label: string;
  description: string;
  configs: Array<{ config_key: string; config_value: string; description: string }>;
  canEdit: boolean;
  onSave: (key: string, value: string, oldValue: string) => void;
}) {
  const config = configs.find((c) => c.config_key === configKey);
  const [value, setValue] = useState(config?.config_value ?? '');
  const [dirty, setDirty] = useState(false);

  const handleChange = (v: string) => { setValue(v); setDirty(v !== (config?.config_value ?? '')); };
  const handleSave = () => { onSave(configKey, value, config?.config_value ?? ''); setDirty(false); };

  return (
    <div className="pf-config-row">
      <div className="pf-toggle-info">
        <span className="pf-toggle-label">{label}</span>
        <span className="pf-toggle-desc">{description}</span>
        <span className="pf-source-hint">Source: system_configs → {configKey}</span>
      </div>
      <div className="pf-config-input">
        <textarea
          className="pf-textarea"
          value={value}
          onChange={(e) => handleChange(e.target.value)}
          disabled={!canEdit}
          rows={2}
        />
        {dirty && canEdit && (
          <button className="pf-save-btn" onClick={handleSave}>Save</button>
        )}
      </div>
    </div>
  );
}

// ── Helper ──────────────────────────────────────────────────────────────────
function parseBool(v: unknown): boolean {
  if (typeof v === 'boolean') return v;
  if (typeof v === 'string') {
    try { const p = JSON.parse(v); if (typeof p === 'boolean') return p; } catch { /* noop */ }
    return v === 'true';
  }
  return false;
}

// ── Section Definitions ─────────────────────────────────────────────────────
interface SectionDef {
  id: string;
  title: string;
  description: string;
  icon: ReactNode;
}

const SECTION_DEFS: SectionDef[] = [
  { id: 'orders', title: 'Orders', description: 'Order statuses, moderation, and auto-accept messaging', icon: <ShoppingCart size={18} /> },
  { id: 'notification', title: 'Notification', description: 'Notification types and customizable message templates', icon: <Bell size={18} /> },
  { id: 'feedback', title: 'Feedback & Review', description: 'Feedback toggles, types, shortcuts, resolutions, and review tags', icon: <MessageCircle size={18} /> },
  { id: 'reports', title: 'User Reports', description: 'Report toggles, types, and resolution rewards', icon: <Flag size={18} /> },
  { id: 'punishment', title: 'User Punishment', description: 'Punishment types and reply templates', icon: <Ban size={18} /> },
  { id: 'system', title: 'System', description: 'System URLs, registration controls, presence settings', icon: <Settings size={18} /> },
  { id: 'coming-soon', title: 'Coming Soon', description: 'Features planned for future releases', icon: <Sparkles size={18} /> },
];

// ── Main Component ──────────────────────────────────────────────────────────
export function PlatformFunctionsPage() {
  const [openSections, setOpenSections] = useState<Set<string>>(new Set(['orders']));
  const { data: flags, isLoading: loadingFlags } = useFeatureFlags();
  const { data: configs, isLoading: loadingConfigs } = useSystemConfigs();
  const toggleFlag = useToggleFlag();
  const updateConfig = useUpdateSystemConfig();
  const { admin } = useAuth();
  const { role } = useAdminRole();
  const canEdit = role === ADMIN_ROLES.PLATFORM_SUPER_ADMIN;

  const toggleSection = (id: string) => {
    setOpenSections((prev) => { const n = new Set(prev); n.has(id) ? n.delete(id) : n.add(id); return n; });
  };

  const handleToggle = (key: string, value: boolean) => {
    toggleFlag.mutate({ key, value });
  };

  const handleConfigSave = (key: string, value: string, oldValue: string) => {
    if (!admin) return;
    updateConfig.mutate({ key, value, oldValue, adminId: admin.user_id });
  };

  if (loadingFlags || loadingConfigs) {
    return <div className="pf-loading"><Loader2 size={24} className="spin" /> Loading platform functions...</div>;
  }

  const safeFlags = flags ?? [];
  const safeConfigs = (configs ?? []) as Array<{ config_key: string; config_value: string; description: string }>;

  const renderSection = (id: string): ReactNode => {
    switch (id) {
      case 'orders':
        return <>
          <DictMiniTable dictType="order_status" />
          <DictMiniTable dictType="rental_status" />
          <DictMiniTable dictType="listing_status" />
          <DictMiniTable dictType="transaction_type" />
          <DictMiniTable dictType="moderation_status" />
          <div className="pf-divider" />
          <FlagToggle flagKey="auto_accept_message_enabled" label="Auto Accept Message" description="Send automatic message when seller accepts an order" flags={safeFlags} canEdit={canEdit} onToggle={handleToggle} />
          <ConfigEditor configKey="auto_accept_message.template" label="Auto Accept Message Template" description="Message template sent to buyer when their order is accepted" configs={safeConfigs} canEdit={canEdit} onSave={handleConfigSave} />
        </>;
      case 'notification':
        return <DictMiniTable dictType="notification_type" />;
      case 'feedback':
        return <>
          <FlagToggle flagKey="feedback.enabled" label="User Feedback" description="Allow users to submit feedback and bug reports" flags={safeFlags} canEdit={canEdit} onToggle={handleToggle} />
          <div className="pf-divider" />
          <DictMiniTable dictType="feedback_type" />
          <DictMiniTable dictType="feedback_resolution" />
          <DictMiniTable dictType="review_tag" />
        </>;
      case 'reports':
        return <>
          <ConfigToggle configKey="user_report.enabled" label="User Reports" description="Allow users to report content and other users" configs={safeConfigs} canEdit={canEdit} onSave={handleConfigSave} />
          <div className="pf-divider" />
          <DictMiniTable dictType="report_type" />
          <DictMiniTable dictType="report_resolution" />
        </>;
      case 'punishment':
        return <DictMiniTable dictType="punishment_type" />;
      case 'system':
        return <>
          <DictMiniTable dictType="system_url" />
          <div className="pf-divider" />
          <FlagToggle flagKey="registration.enabled" label="New User Registration" description="Allow new users to register accounts" flags={safeFlags} canEdit={canEdit} onToggle={handleToggle} />
          <ConfigToggle configKey="test_user.registration_enabled" label="Test User Registration" description="Allow test accounts to be created" configs={safeConfigs} canEdit={canEdit} onSave={handleConfigSave} />
          <ConfigToggle configKey="test_user.login_enabled" label="Test User Login" description="Allow test accounts to log in" configs={safeConfigs} canEdit={canEdit} onSave={handleConfigSave} />
          <div className="pf-divider" />
          <FlagToggle flagKey="presence.enabled" label="Online Presence" description="Track and display user online status" flags={safeFlags} canEdit={canEdit} onToggle={handleToggle} />
          <FlagToggle flagKey="presence.show_online_dot" label="Show Online Dot" description="Display green dot indicator for online users" flags={safeFlags} canEdit={canEdit} onToggle={handleToggle} />
        </>;
      case 'coming-soon':
        return <ComingSoonSection flags={safeFlags} />;
      default:
        return null;
    }
  };

  return (
    <div className="pf-page">
      <div className="pf-header">
        <h1 className="pf-title">Platform Functions</h1>
        <p className="pf-subtitle">Centralized configuration hub for all platform features, toggles, and operational settings.</p>
      </div>
      <div className="pf-sections">
        {SECTION_DEFS.map((section) => {
          const isOpen = openSections.has(section.id);
          return (
            <div key={section.id} className={`pf-section ${isOpen ? 'pf-section--open' : ''}`}>
              <button className="pf-section__header" onClick={() => toggleSection(section.id)} aria-expanded={isOpen}>
                <div className="pf-section__icon">{section.icon}</div>
                <div className="pf-section__info">
                  <span className="pf-section__title">{section.title}</span>
                  <span className="pf-section__desc">{section.description}</span>
                </div>
                <span className="pf-section__chevron">{isOpen ? <ChevronDown size={16} /> : <ChevronRight size={16} />}</span>
              </button>
              {isOpen && <div className="pf-section__body">{renderSection(section.id)}</div>}
            </div>
          );
        })}
      </div>
      <style>{STYLES}</style>
    </div>
  );
}

// ── Config-based Toggle (system_configs string 'true'/'false') ───────────────
function ConfigToggle({ configKey, label, description, configs, canEdit, onSave }: {
  configKey: string;
  label: string;
  description: string;
  configs: Array<{ config_key: string; config_value: string; description: string }>;
  canEdit: boolean;
  onSave: (key: string, value: string, oldValue: string) => void;
}) {
  const config = configs.find((c) => c.config_key === configKey);
  const isOn = config ? parseBool(config.config_value) : false;

  return (
    <div className="pf-toggle-row">
      <div className="pf-toggle-info">
        <span className="pf-toggle-label">{label}</span>
        <span className="pf-toggle-desc">{description}</span>
        <span className="pf-source-hint">Source: system_configs → {configKey}</span>
      </div>
      <button
        className={`pf-toggle-switch ${isOn ? 'pf-toggle-switch--on' : ''}`}
        onClick={() => canEdit && config && onSave(configKey, String(!isOn), config.config_value)}
        disabled={!canEdit || !config}
      >
        <span className="pf-toggle-knob" />
      </button>
    </div>
  );
}

// ── Coming Soon Section ─────────────────────────────────────────────────────
function ComingSoonSection({ flags }: { flags: Array<{ key: string; value: boolean | string | number; description: string }> }) {
  const items = [
    { key: 'moderation.strict_mode', label: 'Strict Moderation Mode', desc: 'Require manual review for all new listings' },
    { key: 'plaza.enable', label: 'Community Plaza', desc: 'Social feed for campus discussions' },
    { key: 'wishlist.enable', label: 'Wishlists', desc: 'Allow users to create item wishlists' },
    { key: 'wishlist.cross_school', label: 'Cross-School Wishlists', desc: 'Enable wishlist sharing across campuses' },
    { key: 'listing.cross_school', label: 'Cross-School Listings', desc: 'Allow listings to be visible across campuses' },
  ];

  return (
    <div className="pf-coming-grid">
      {items.map(({ key, label, desc }) => {
        const flag = flags.find((f) => f.key === key);
        const value = flag ? parseBool(flag.value) : false;
        return (
          <div key={key} className="pf-coming-card">
            <div className="pf-coming-card__top">
              <span className="pf-coming-card__label">{label}</span>
              <span className="pf-badge pf-badge--coming">Coming Soon</span>
            </div>
            <p className="pf-coming-card__desc">{desc}</p>
            <div className="pf-coming-card__status">
              Current: <span className={value ? 'pf-badge pf-badge--active' : 'pf-badge pf-badge--inactive'}>{value ? 'Enabled' : 'Disabled'}</span>
              <span className="pf-source-hint" style={{ marginLeft: 8 }}>{key}</span>
            </div>
          </div>
        );
      })}
    </div>
  );
}

// ── Styles ───────────────────────────────────────────────────────────────────
const STYLES = `
.pf-page { padding: 32px; max-width: 1100px; }
.pf-loading { display: flex; align-items: center; gap: 8px; padding: 80px; justify-content: center; color: var(--color-text-tertiary); }
.pf-header { margin-bottom: 28px; }
.pf-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0 0 4px; }
.pf-subtitle { font-size: 14px; color: var(--color-text-tertiary); margin: 0; }
.pf-sections { display: flex; flex-direction: column; gap: 8px; }

.pf-section { background: var(--color-bg-primary); border: 1px solid var(--color-border-light); border-radius: var(--radius-lg); overflow: hidden; transition: border-color 0.15s; }
.pf-section--open { border-color: var(--color-info); }
.pf-section__header { display: flex; align-items: center; gap: 12px; width: 100%; padding: 16px 20px; background: none; border: none; cursor: pointer; text-align: left; transition: background 0.1s; }
.pf-section__header:hover { background: var(--color-bg-tertiary); }
.pf-section__icon { flex-shrink: 0; width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; background: var(--color-bg-tertiary); border-radius: var(--radius-md); color: var(--color-text-secondary); }
.pf-section--open .pf-section__icon { background: var(--color-info); color: white; }
.pf-section__info { flex: 1; min-width: 0; }
.pf-section__title { display: block; font-size: 14px; font-weight: 600; color: var(--color-text-primary); }
.pf-section__desc { display: block; font-size: 12px; color: var(--color-text-tertiary); margin-top: 2px; }
.pf-section__chevron { flex-shrink: 0; color: var(--color-text-tertiary); }
.pf-section__body { padding: 4px 20px 20px; border-top: 1px solid var(--color-border-light); }

/* Dict block */
.pf-dict-block { margin-top: 16px; }
.pf-dict-block__header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.pf-dict-block__title { font-size: 13px; font-weight: 600; color: var(--color-text-primary); }
.pf-link-btn { display: inline-flex; align-items: center; gap: 4px; font-size: 12px; color: var(--color-info); background: none; border: none; cursor: pointer; padding: 2px 6px; border-radius: var(--radius-sm); }
.pf-link-btn:hover { background: var(--color-bg-tertiary); }

/* Table */
.pf-table { width: 100%; border-collapse: collapse; font-size: 12px; }
.pf-table th { text-align: left; padding: 6px 10px; background: var(--color-bg-tertiary); color: var(--color-text-secondary); font-weight: 600; border-bottom: 1px solid var(--color-border-light); }
.pf-table td { padding: 6px 10px; border-bottom: 1px solid var(--color-border-light); color: var(--color-text-primary); }
.pf-table code { font-size: 11px; background: var(--color-bg-tertiary); padding: 1px 5px; border-radius: 3px; }
.pf-td-desc { color: var(--color-text-tertiary); max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

/* Badges */
.pf-badge { display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: 500; }
.pf-badge--active { background: #dcfce7; color: #166534; }
.pf-badge--inactive { background: var(--color-bg-tertiary); color: var(--color-text-tertiary); }
.pf-badge--coming { background: #dbeafe; color: #1e40af; }

/* Toggle */
.pf-toggle-row { display: flex; align-items: center; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid var(--color-border-light); }
.pf-toggle-row:last-child { border-bottom: none; }
.pf-toggle-info { flex: 1; min-width: 0; }
.pf-toggle-label { display: block; font-size: 13px; font-weight: 600; color: var(--color-text-primary); }
.pf-toggle-desc { display: block; font-size: 12px; color: var(--color-text-tertiary); margin-top: 2px; }

.pf-toggle-switch { position: relative; width: 44px; height: 24px; border-radius: 12px; border: none; background: #d1d5db; cursor: pointer; transition: background 0.2s; flex-shrink: 0; }
.pf-toggle-switch--on { background: var(--color-info); }
.pf-toggle-switch:disabled { opacity: 0.5; cursor: not-allowed; }
.pf-toggle-knob { position: absolute; top: 2px; left: 2px; width: 20px; height: 20px; border-radius: 50%; background: white; transition: transform 0.2s; box-shadow: 0 1px 3px rgba(0,0,0,0.2); }
.pf-toggle-switch--on .pf-toggle-knob { transform: translateX(20px); }

/* Config editor */
.pf-config-row { padding: 12px 0; border-bottom: 1px solid var(--color-border-light); }
.pf-config-input { margin-top: 8px; display: flex; gap: 8px; align-items: flex-start; }
.pf-textarea { flex: 1; padding: 8px 10px; border: 1px solid var(--color-border-light); border-radius: var(--radius-md); font-size: 12px; font-family: inherit; resize: vertical; min-height: 40px; }
.pf-textarea:disabled { background: var(--color-bg-tertiary); }
.pf-save-btn { padding: 6px 14px; background: var(--color-info); color: white; border: none; border-radius: var(--radius-md); font-size: 12px; font-weight: 600; cursor: pointer; white-space: nowrap; }
.pf-save-btn:hover { opacity: 0.9; }

/* Source hint */
.pf-source-hint { font-size: 10px; color: var(--color-text-tertiary); opacity: 0.7; margin-top: 2px; display: block; }

/* Divider */
.pf-divider { height: 1px; background: var(--color-border-light); margin: 16px 0; }

/* Mini states */
.pf-mini-loading { font-size: 12px; color: var(--color-text-tertiary); padding: 12px; display: flex; align-items: center; gap: 6px; }
.pf-mini-empty { font-size: 12px; color: var(--color-text-tertiary); padding: 12px; text-align: center; }

/* Coming soon */
.pf-coming-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 12px; margin-top: 16px; }
.pf-coming-card { padding: 16px; background: var(--color-bg-tertiary); border-radius: var(--radius-md); border: 1px dashed var(--color-border-light); }
.pf-coming-card__top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
.pf-coming-card__label { font-size: 13px; font-weight: 600; color: var(--color-text-primary); }
.pf-coming-card__desc { font-size: 12px; color: var(--color-text-tertiary); margin: 4px 0 8px; }
.pf-coming-card__status { font-size: 11px; color: var(--color-text-tertiary); display: flex; align-items: center; gap: 4px; }

@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
.spin { animation: spin 1s linear infinite; }
`;
