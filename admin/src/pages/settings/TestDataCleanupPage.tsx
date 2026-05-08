/**
 * Pre-launch test data cleanup page.
 * Located at /settings/cleanup — visible only in settings sidebar.
 *
 * Two actions:
 *   1. Platform-wide purge  → sysadmin only
 *   2. School-scoped purge  → sysadmin or school_admin with matching scope
 *
 * Each action requires the admin to type a confirmation phrase before the
 * button becomes active, preventing accidental data loss.
 */
import { useState } from 'react';
import { School, Trash2, AlertTriangle, CheckCircle, Loader2, Lock } from 'lucide-react';
import { usePurgeSchoolData } from '@/hooks/useTestDataCleanup';
import { useAdminRole } from '@/hooks/useAdminRole';
import { useColleges } from '@/hooks/useColleges';
import { useSchoolScopeStore } from '@/stores/school-scope-store';

const SCHOOL_CONFIRM_PHRASE = 'DELETE SCHOOL DATA';

// ── PurgeCard ─────────────────────────────────────────────────────────────────

interface PurgeCardProps {
  title: string;
  subtitle: string;
  icon: React.ReactNode;
  accentColor: string;
  confirmPhrase: string;
  items: string[];
  onConfirm: () => void;
  isPending: boolean;
  isSuccess: boolean;
  isAllowed: boolean;
  denyReason?: string;
}

function PurgeCard({
  title, subtitle, icon, accentColor, confirmPhrase,
  items, onConfirm, isPending, isSuccess, isAllowed, denyReason,
}: PurgeCardProps) {
  const [input, setInput] = useState('');
  const ready = input === confirmPhrase;

  if (!isAllowed) {
    return (
      <div className="purge-card purge-card--denied">
        <div className="purge-card-icon-wrap" style={{ background: '#f1f3f5' }}>
          <Lock size={22} color="var(--color-text-tertiary)" />
        </div>
        <div>
          <h3 className="purge-card-title">{title}</h3>
          <p className="purge-denied-reason">{denyReason ?? 'You do not have permission for this action.'}</p>
        </div>
      </div>
    );
  }

  if (isSuccess) {
    return (
      <div className="purge-card purge-card--success">
        <CheckCircle size={28} color="var(--color-success)" />
        <div>
          <h3 className="purge-card-title">Purge Completed</h3>
          <p className="purge-success-msg">All test data has been deleted successfully.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="purge-card" style={{ borderColor: accentColor + '40' }}>
      {/* Header */}
      <div className="purge-card-header">
        <div className="purge-card-icon-wrap" style={{ background: accentColor + '18' }}>
          {icon}
        </div>
        <div>
          <h3 className="purge-card-title">{title}</h3>
          <p className="purge-card-subtitle">{subtitle}</p>
        </div>
      </div>

      {/* What gets deleted */}
      <div className="purge-scope-list">
        <p className="purge-scope-label">The following data will be permanently deleted:</p>
        <ul>
          {items.map((item) => (
            <li key={item}>
              <Trash2 size={11} color="var(--color-danger)" />
              {item}
            </li>
          ))}
        </ul>
      </div>

      {/* Confirmation input */}
      <div className="purge-confirm-block">
        <AlertTriangle size={14} color="#e67700" />
        <p className="purge-confirm-label">
          Type <strong>{confirmPhrase}</strong> to enable the button:
        </p>
        <input
          className={`purge-confirm-input ${ready ? 'ready' : ''}`}
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder={confirmPhrase}
          spellCheck={false}
          autoComplete="off"
        />
      </div>

      <button
        className="purge-btn"
        style={{ background: ready ? accentColor : undefined }}
        onClick={onConfirm}
        disabled={!ready || isPending}
      >
        {isPending
          ? <><Loader2 size={14} className="spin" /> Deleting…</>
          : <><Trash2 size={14} /> {title}</>}
      </button>
    </div>
  );
}

// ── Main page ─────────────────────────────────────────────────────────────────

export function TestDataCleanupPage() {
  const { isSysadmin } = useAdminRole();
  const { currentCollegeId } = useSchoolScopeStore();
  const { data: colleges }   = useColleges();

  const schoolPurge   = usePurgeSchoolData();

  const currentSchool = colleges?.find((c) => c.id === currentCollegeId);

  const SCHOOL_ITEMS = [
    `All listings from ${currentSchool?.name ?? 'the selected school'}`,
    'Orders, rentals, and user reviews tied to those listings',
    'Chat rooms and messages for those listings',
    'AI moderation logs and tasks for school content',
    'Reports, feedback, bans, and contribution points for school users',
    'Notifications and push jobs for school users',
    'User saved locations and activity sessions',
    'Storage files (listing images, chat images, evidence photos, avatars)',
  ];

  return (
    <div className="cleanup-page">
      {/* ── Warning banner ── */}
      <div className="cleanup-banner">
        <AlertTriangle size={18} color="#c92a2a" />
        <div>
          <strong>Pre-Launch Only — Irreversible</strong>
          <p>
            These tools permanently delete data from the production database.
            Use them only before going live. All actions are logged in the audit trail.
          </p>
        </div>
      </div>

      <h1 className="cleanup-title">Test Data Cleanup</h1>
      <p className="cleanup-subtitle">
        Remove all test data before launching to real users. Sysadmin access only.
      </p>

      <div className="cleanup-cards">


        {/* ── School-scoped purge ── */}
        <PurgeCard
          title={`Purge ${currentSchool?.name ?? 'School'} Data`}
          subtitle={
            currentSchool
              ? `Deletes all test data for ${currentSchool.name} only`
              : 'Select a school from the sidebar first'
          }
          icon={<School size={22} color="#e67700" />}
          accentColor="#e67700"
          confirmPhrase={SCHOOL_CONFIRM_PHRASE}
          items={SCHOOL_ITEMS}
          onConfirm={() => { if (currentCollegeId) schoolPurge.mutate(currentCollegeId); }}
          isPending={schoolPurge.isPending}
          isSuccess={schoolPurge.isSuccess}
          isAllowed={isSysadmin && !!currentCollegeId}
          denyReason={
            !currentCollegeId
              ? 'Select a school from the sidebar first.'
              : 'Only the Super Admin (sysadmin) can purge school data.'
          }
        />
      </div>

      <style>{`
        .cleanup-page { padding: var(--spacing-page); max-width: 800px; }

        .cleanup-banner {
          display: flex;
          align-items: flex-start;
          gap: 12px;
          padding: 14px 16px;
          background: #fff5f5;
          border: 1px solid #ffc9c9;
          border-radius: var(--radius-md);
          margin-bottom: 24px;
          color: #c92a2a;
          font-size: 13px;
        }
        .cleanup-banner strong { display: block; font-size: 14px; margin-bottom: 2px; }
        .cleanup-banner p { margin: 0; color: #c92a2a; opacity: 0.85; }

        .cleanup-title {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
          margin-bottom: 4px;
        }
        .cleanup-subtitle {
          font-size: 13px;
          color: var(--color-text-tertiary);
          margin-bottom: 28px;
        }

        .cleanup-cards {
          display: flex;
          flex-direction: column;
          gap: 20px;
        }

        /* ── Purge card ── */
        .purge-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg);
          padding: 20px;
          display: flex;
          flex-direction: column;
          gap: 16px;
        }

        .purge-card--denied {
          opacity: 0.65;
          display: flex;
          flex-direction: row;
          align-items: center;
          gap: 14px;
          padding: 16px 20px;
        }

        .purge-card--success {
          display: flex;
          flex-direction: row;
          align-items: center;
          gap: 14px;
          padding: 20px;
          background: var(--color-success-light);
          border-color: var(--color-success);
        }

        .purge-card-header {
          display: flex;
          align-items: center;
          gap: 14px;
        }

        .purge-card-icon-wrap {
          width: 44px;
          height: 44px;
          border-radius: var(--radius-md);
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;
        }

        .purge-card-title {
          font-size: 16px;
          font-weight: 700;
          color: var(--color-text-primary);
          margin: 0 0 2px 0;
        }

        .purge-card-subtitle, .purge-denied-reason, .purge-success-msg {
          font-size: 12px;
          color: var(--color-text-secondary);
          margin: 0;
        }

        /* Scope list */
        .purge-scope-list {
          background: var(--color-bg-secondary);
          border-radius: var(--radius-sm);
          padding: 12px 14px;
        }
        .purge-scope-label {
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.04em;
          color: var(--color-text-tertiary);
          margin: 0 0 8px 0;
        }
        .purge-scope-list ul {
          margin: 0;
          padding: 0;
          list-style: none;
          display: flex;
          flex-direction: column;
          gap: 5px;
        }
        .purge-scope-list li {
          display: flex;
          align-items: center;
          gap: 7px;
          font-size: 12px;
          color: var(--color-text-secondary);
        }

        /* Confirmation block */
        .purge-confirm-block {
          display: flex;
          flex-direction: column;
          gap: 6px;
        }
        .purge-confirm-label {
          font-size: 12px;
          color: var(--color-text-secondary);
          margin: 0;
          display: flex;
          align-items: center;
          gap: 6px;
          flex-wrap: wrap;
        }
        .purge-confirm-label strong {
          font-family: var(--font-mono);
          background: var(--color-bg-tertiary);
          padding: 1px 6px;
          border-radius: 3px;
          color: var(--color-danger);
        }
        .purge-confirm-input {
          padding: 8px 12px;
          font-size: 13px;
          font-family: var(--font-mono);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-sm);
          background: var(--color-bg-secondary);
          color: var(--color-text-primary);
          outline: none;
          transition: border-color 0.15s;
        }
        .purge-confirm-input.ready {
          border-color: var(--color-danger);
        }

        /* Purge button */
        .purge-btn {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 6px;
          width: 100%;
          padding: 11px 0;
          font-size: 13px;
          font-weight: 600;
          border-radius: var(--radius-md);
          border: none;
          cursor: pointer;
          color: white;
          background: var(--color-text-tertiary);
          transition: opacity 0.15s;
        }
        .purge-btn:disabled {
          cursor: not-allowed;
          opacity: 0.6;
        }
        .purge-btn:not(:disabled):hover { opacity: 0.88; }

        .spin { animation: spin 1s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
