/**
 * Dictionary list page — shows all dict_types grouped by access_level.
 * Click a group card to navigate to its items page.
 *
 * Permission display:
 *   🔴 system   → only platform_super_admin can edit
 *   🟦 platform → platform moderator or above can edit
 *   🟩 school   → school_admin can edit; platform roles read-only
 */
import { useNavigate } from 'react-router-dom';
import { ChevronRight, Loader2, Lock, Shield, School } from 'lucide-react';
import { useDictionaries, DICT_REGISTRY, ACCESS_LEVEL_META, canEditLevel } from '@/hooks/useDictionary';
import { useAdminRole } from '@/hooks/useAdminRole';
import type { DictAccessLevel } from '@/types';

// ── Constants ─────────────────────────────────────────────────────────────────

const ACCESS_LEVEL_ORDER: DictAccessLevel[] = ['system', 'platform', 'school'];

const ACCESS_LEVEL_ICON: Record<DictAccessLevel, React.ReactNode> = {
  system: <Shield size={14} />,
  platform: <Lock size={14} />,
  school: <School size={14} />,
};

const ACCESS_LEVEL_SECTION_TITLE: Record<DictAccessLevel, string> = {
  system: '🔴 System — Business Process Fields',
  platform: '🟦 Platform — Operational Configuration',
  school: '🟩 School — Campus-Specific Fields',
};

const ACCESS_LEVEL_SECTION_DESC: Record<DictAccessLevel, string> = {
  system: 'Core state machine values. Only Platform Super Admin can modify these.',
  platform: 'Platform-wide operational config. Platform Admin and above can modify.',
  school: 'Campus-specific data. School Admin manages; platform roles are read-only.',
};

// ── Component ─────────────────────────────────────────────────────────────────

export function DictionaryListPage() {
  const { data: groups, isLoading, error } = useDictionaries();
  const { role } = useAdminRole();
  const navigate = useNavigate();

  if (isLoading) {
    return (
      <div className="dlist-loading">
        <Loader2 size={24} className="spin" />
        <span>Loading dictionaries...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="dlist-error">
        Failed to load: {(error as Error).message}
      </div>
    );
  }

  // Build a registry-driven list: include ALL registry entries,
  // filling in live item counts from the DB where available.
  const liveCountMap: Record<string, { total: number; active: number; access_level: DictAccessLevel }> = {};
  for (const group of groups ?? []) {
    liveCountMap[group.dict_type] = {
      total: group.items.length,
      active: group.items.filter((i) => i.is_active).length,
      access_level: group.access_level,
    };
  }

  // Group registry entries by access_level for section rendering.
  const byLevel: Record<DictAccessLevel, string[]> = {
    system: [],
    platform: [],
    school: [],
  };
  for (const [dictCode, meta] of Object.entries(DICT_REGISTRY)) {
    byLevel[meta.access_level].push(dictCode);
  }

  return (
    <div className="dlist-page">
      {/* ── Header ── */}
      <div className="dlist-header">
        <h1 className="dlist-title">Data Dictionary</h1>
        <p className="dlist-subtitle">
          {Object.keys(DICT_REGISTRY).length} dictionary groups ·
          Manage enumerations and system constants
        </p>
      </div>

      {/* ── Permission legend ── */}
      <div className="dlist-legend">
        {ACCESS_LEVEL_ORDER.map((level) => {
          const meta = ACCESS_LEVEL_META[level];
          const canEdit = canEditLevel(role ?? undefined, level);
          return (
            <div className="dlist-legend-item" key={level}>
              <span
                className="dlist-legend-badge"
                style={{ background: meta.bgColor, color: meta.color }}
              >
                {ACCESS_LEVEL_ICON[level]}
                {meta.label}
              </span>
              <span className="dlist-legend-text">
                {meta.description}
                {' — '}
                <strong style={{ color: canEdit ? meta.color : 'var(--color-text-tertiary)' }}>
                  {canEdit ? 'You can edit' : 'Read-only for you'}
                </strong>
              </span>
            </div>
          );
        })}
      </div>

      {/* ── Sections by access level ── */}
      {ACCESS_LEVEL_ORDER.map((level) => {
        const dictCodes = byLevel[level];
        if (dictCodes.length === 0) return null;
        const levelMeta = ACCESS_LEVEL_META[level];
        const canEdit = canEditLevel(role ?? undefined, level);

        return (
          <section key={level} className="dlist-section">
            {/* Section header */}
            <div
              className="dlist-section-header"
              style={{ borderLeftColor: levelMeta.color }}
            >
              <div className="dlist-section-title-row">
                <h2 className="dlist-section-title">{ACCESS_LEVEL_SECTION_TITLE[level]}</h2>
                <span
                  className="dlist-section-badge"
                  style={{ background: levelMeta.bgColor, color: levelMeta.color }}
                >
                  {ACCESS_LEVEL_ICON[level]}
                  {levelMeta.label}
                </span>
                {!canEdit && (
                  <span className="dlist-readonly-badge">
                    <Lock size={10} />
                    Read-only
                  </span>
                )}
              </div>
              <p className="dlist-section-desc">{ACCESS_LEVEL_SECTION_DESC[level]}</p>
            </div>

            {/* Dict-type cards */}
            <div className="dlist-grid">
              {dictCodes.map((dictCode) => {
                const regMeta = DICT_REGISTRY[dictCode]!;
                const live = liveCountMap[dictCode];
                return (
                  <button
                    key={dictCode}
                    className="dlist-card"
                    onClick={() => navigate(`/settings/dictionary/${dictCode}`)}
                  >
                    <div className="dlist-card-left">
                      <div
                        className="dlist-icon-bg"
                        style={{ background: levelMeta.bgColor }}
                      >
                        <span className="dlist-icon-emoji">{regMeta.icon}</span>
                      </div>
                      <div>
                        <h3 className="dlist-card-title">{regMeta.title}</h3>
                        <p className="dlist-card-desc">
                          {regMeta.description}
                        </p>
                        {live && (
                          <p className="dlist-card-count">
                            <span className="tabular-nums">{live.total} entries</span>
                            {' · '}
                            <span className="tabular-nums" style={{ color: 'var(--color-success)' }}>
                              {live.active} active
                            </span>
                          </p>
                        )}
                        {!live && (
                          <p className="dlist-card-count" style={{ color: 'var(--color-text-tertiary)' }}>
                            No entries yet
                          </p>
                        )}
                      </div>
                    </div>
                    <div className="dlist-card-right">
                      <code className="dlist-card-code">{dictCode}</code>
                      <ChevronRight size={16} color="var(--color-text-tertiary)" />
                    </div>
                  </button>
                );
              })}
            </div>
          </section>
        );
      })}

      <style>{`
        .dlist-page {
          padding: var(--spacing-page);
          max-width: 960px;
        }

        .dlist-header {
          margin-bottom: 20px;
        }

        .dlist-title {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .dlist-subtitle {
          font-size: 13px;
          color: var(--color-text-tertiary);
          margin-top: 4px;
        }

        /* ── Permission legend ── */
        .dlist-legend {
          display: flex;
          flex-direction: column;
          gap: 8px;
          padding: 14px 16px;
          background: var(--color-bg-secondary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-md);
          margin-bottom: 28px;
        }

        .dlist-legend-item {
          display: flex;
          align-items: center;
          gap: 10px;
          font-size: 12px;
        }

        .dlist-legend-badge {
          display: inline-flex;
          align-items: center;
          gap: 4px;
          padding: 3px 8px;
          border-radius: var(--radius-sm);
          font-size: 11px;
          font-weight: 600;
          white-space: nowrap;
          min-width: 80px;
          justify-content: center;
        }

        .dlist-legend-text {
          color: var(--color-text-secondary);
          line-height: 1.4;
        }

        /* ── Section ── */
        .dlist-section {
          margin-bottom: 32px;
        }

        .dlist-section-header {
          border-left: 4px solid var(--color-border);
          padding-left: 12px;
          margin-bottom: 14px;
        }

        .dlist-section-title-row {
          display: flex;
          align-items: center;
          gap: 10px;
          flex-wrap: wrap;
        }

        .dlist-section-title {
          font-size: 15px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .dlist-section-badge {
          display: inline-flex;
          align-items: center;
          gap: 4px;
          padding: 2px 8px;
          border-radius: var(--radius-sm);
          font-size: 11px;
          font-weight: 600;
        }

        .dlist-readonly-badge {
          display: inline-flex;
          align-items: center;
          gap: 3px;
          padding: 2px 7px;
          background: var(--color-bg-tertiary);
          color: var(--color-text-tertiary);
          border-radius: var(--radius-sm);
          font-size: 11px;
          font-weight: 500;
        }

        .dlist-section-desc {
          font-size: 12px;
          color: var(--color-text-tertiary);
          margin-top: 3px;
        }

        /* ── Cards grid ── */
        .dlist-grid {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .dlist-card {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 12px 14px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-md);
          cursor: pointer;
          transition: box-shadow 0.12s ease, border-color 0.12s ease;
          text-align: left;
          width: 100%;
          gap: 12px;
        }

        .dlist-card:hover {
          box-shadow: var(--shadow-card-hover);
          border-color: var(--color-info);
        }

        .dlist-card-left {
          display: flex;
          align-items: center;
          gap: 14px;
          flex: 1;
          min-width: 0;
        }

        .dlist-icon-bg {
          width: 40px;
          height: 40px;
          border-radius: var(--radius-sm);
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;
        }

        .dlist-icon-emoji {
          font-size: 18px;
          line-height: 1;
        }

        .dlist-card-title {
          font-size: 14px;
          font-weight: 600;
          color: var(--color-text-primary);
          margin: 0 0 2px 0;
        }

        .dlist-card-desc {
          font-size: 12px;
          color: var(--color-text-secondary);
          margin: 0 0 3px 0;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          max-width: 420px;
        }

        .dlist-card-count {
          font-size: 11px;
          color: var(--color-text-tertiary);
          margin: 0;
        }

        .dlist-card-right {
          display: flex;
          align-items: center;
          gap: 8px;
          flex-shrink: 0;
        }

        .dlist-card-code {
          font-size: 11px;
          font-family: var(--font-mono);
          color: var(--color-text-tertiary);
          background: var(--color-bg-tertiary);
          padding: 2px 6px;
          border-radius: var(--radius-sm);
        }

        /* ── States ── */
        .dlist-loading, .dlist-error {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
          padding: 80px 0;
          color: var(--color-text-tertiary);
          font-size: 14px;
        }

        .dlist-error { color: var(--color-danger); }
        .spin { animation: spin 1s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
