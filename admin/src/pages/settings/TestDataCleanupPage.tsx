/**
 * School-scoped test data cleanup page with backup & restore.
 * Located at /settings/cleanup — visible only in settings sidebar.
 *
 * Features:
 *   - School-scoped purge with automatic backup
 *   - One-click restore from existing backup
 *   - Previous backup is auto-deleted on next cleanup
 *   - Platform-wide purge is deliberately NOT provided
 */
import { useState } from 'react';
import {
  School, Trash2, AlertTriangle, CheckCircle, Loader2, Lock,
  RotateCcw, ShieldCheck, Database, HardDrive,
} from 'lucide-react';
import {
  usePurgeSchoolData,
  useRestoreSchoolBackup,
  useSchoolBackups,
} from '@/hooks/useTestDataCleanup';
import { useAdminRole } from '@/hooks/useAdminRole';
import { useColleges } from '@/hooks/useColleges';
import { useSchoolScopeStore } from '@/stores/school-scope-store';

// ── Helpers ───────────────────────────────────────────────────────────────────

function schoolConfirmPhrase(schoolName: string | undefined): string {
  return schoolName ? `DELETE ${schoolName.toUpperCase()}` : 'DELETE SCHOOL DATA';
}

function formatDate(iso: string): string {
  return new Date(iso).toLocaleString('en-US', {
    month: 'short', day: 'numeric', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  });
}

// ── BackupCard ────────────────────────────────────────────────────────────────

interface BackupCardProps {
  backupId: string;
  schoolId: string;
  createdAt: string;
  meta: { listing_count: number; user_count: number; order_count: number };
  storageFileCount: number;
  isRestoring: boolean;
  onRestore: () => void;
}

function BackupCard({
  createdAt, meta, storageFileCount, isRestoring, onRestore,
}: BackupCardProps) {
  const [confirmRestore, setConfirmRestore] = useState(false);

  return (
    <div className="backup-card">
      <div className="backup-card-header">
        <div className="backup-card-icon-wrap">
          <Database size={20} color="#1971c2" />
        </div>
        <div style={{ flex: 1 }}>
          <h4 className="backup-card-title">Backup Available</h4>
          <p className="backup-card-date">Created {formatDate(createdAt)}</p>
        </div>
        <ShieldCheck size={18} color="var(--color-success)" />
      </div>

      <div className="backup-stats">
        <div className="backup-stat">
          <span className="backup-stat-value">{meta.listing_count}</span>
          <span className="backup-stat-label">Listings</span>
        </div>
        <div className="backup-stat">
          <span className="backup-stat-value">{meta.user_count}</span>
          <span className="backup-stat-label">Users</span>
        </div>
        <div className="backup-stat">
          <span className="backup-stat-value">{meta.order_count}</span>
          <span className="backup-stat-label">Orders</span>
        </div>
        <div className="backup-stat">
          <span className="backup-stat-value">{storageFileCount}</span>
          <span className="backup-stat-label">Files</span>
        </div>
      </div>

      {!confirmRestore ? (
        <button
          className="restore-btn"
          onClick={() => setConfirmRestore(true)}
          disabled={isRestoring}
        >
          <RotateCcw size={14} /> Restore This Backup
        </button>
      ) : (
        <div className="restore-confirm">
          <p className="restore-confirm-text">
            <AlertTriangle size={13} color="#e67700" />
            This will re-insert all backed-up data. Continue?
          </p>
          <div className="restore-confirm-actions">
            <button
              className="restore-btn restore-btn--confirm"
              onClick={() => { onRestore(); setConfirmRestore(false); }}
              disabled={isRestoring}
            >
              {isRestoring
                ? <><Loader2 size={14} className="spin" /> Restoring…</>
                : <><RotateCcw size={14} /> Yes, Restore</>}
            </button>
            <button
              className="restore-btn restore-btn--cancel"
              onClick={() => setConfirmRestore(false)}
              disabled={isRestoring}
            >
              Cancel
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

// ── PurgeCard ─────────────────────────────────────────────────────────────────

interface PurgeCardProps {
  title: string;
  subtitle: string;
  confirmPhrase: string;
  items: string[];
  hasExistingBackup: boolean;
  onConfirm: () => void;
  isPending: boolean;
  isSuccess: boolean;
  isError: boolean;
  errorMessage: string;
  isAllowed: boolean;
  denyReason?: string;
}

function PurgeCard({
  title, subtitle, confirmPhrase, items,
  hasExistingBackup, onConfirm,
  isPending, isSuccess, isError, errorMessage,
  isAllowed, denyReason,
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
          <p className="purge-denied-reason">{denyReason ?? 'Permission denied.'}</p>
        </div>
      </div>
    );
  }

  if (isSuccess) {
    return (
      <div className="purge-card purge-card--success">
        <CheckCircle size={28} color="var(--color-success)" />
        <div style={{ flex: 1 }}>
          <h3 className="purge-card-title">Purge Completed — Backup Created</h3>
          <p className="purge-success-msg">
            Data has been deleted and a backup snapshot was saved.
            You can restore it from the Backup section above.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="purge-card" style={{ borderColor: '#e6770040' }}>
      {isError && (
        <div className="purge-error-banner">
          <strong>Purge failed:</strong> {errorMessage || 'Check browser console.'}
        </div>
      )}

      <div className="purge-card-header">
        <div className="purge-card-icon-wrap" style={{ background: '#e6770018' }}>
          <School size={22} color="#e67700" />
        </div>
        <div>
          <h3 className="purge-card-title">{title}</h3>
          <p className="purge-card-subtitle">{subtitle}</p>
        </div>
      </div>

      {/* Safety info */}
      <div className="purge-safety-banner">
        <ShieldCheck size={14} color="#1971c2" />
        <span>
          A full backup snapshot will be created before deletion.
          {hasExistingBackup && ' The previous backup will be permanently deleted.'}
        </span>
      </div>

      {/* Scope list */}
      <div className="purge-scope-list">
        <p className="purge-scope-label">The following data will be backed up then deleted:</p>
        <ul>
          {items.map((item) => (
            <li key={item}><Trash2 size={11} color="var(--color-danger)" />{item}</li>
          ))}
        </ul>
      </div>

      {/* Confirmation */}
      <div className="purge-confirm-block">
        <AlertTriangle size={14} color="#e67700" />
        <p className="purge-confirm-label">
          Type <strong>{confirmPhrase}</strong> to enable:
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
        style={{ background: ready ? '#e67700' : undefined }}
        onClick={onConfirm}
        disabled={!ready || isPending}
      >
        {isPending
          ? <><Loader2 size={14} className="spin" /> Backing up & Deleting…</>
          : <><Trash2 size={14} /> {title}</>}
      </button>
    </div>
  );
}

// ── Main page ─────────────────────────────────────────────────────────────────

export function TestDataCleanupPage() {
  const { isSysadmin } = useAdminRole();
  const { currentCollegeId } = useSchoolScopeStore();
  const { data: colleges } = useColleges();

  const schoolPurge = usePurgeSchoolData();
  const schoolRestore = useRestoreSchoolBackup();
  const { data: backups } = useSchoolBackups(currentCollegeId ?? undefined);

  const currentSchool = colleges?.find((c) => c.id === currentCollegeId);
  const confirmPhrase = schoolConfirmPhrase(currentSchool?.name);

  // Find the active (not restored, not purged) backup
  const activeBackup = backups?.find(
    (b) => b.restored_at === null && b.purged_at === null,
  );

  const SCHOOL_ITEMS = [
    `All listings from ${currentSchool?.name ?? 'the selected school'}`,
    'Orders, rentals, and evidence photos',
    'Chat rooms and messages',
    'Carpool trips, members, proposals, and reviews',
    'Group chat rooms and messages',
    'Notifications and content reports',
    `Storage files (listing images, order files) — scoped to ${currentSchool?.name ?? 'school'} users only`,
  ];

  return (
    <div className="cleanup-page">
      {/* Warning banner */}
      <div className="cleanup-banner">
        <AlertTriangle size={18} color="#c92a2a" />
        <div>
          <strong>Pre-Launch Only — School-Scoped</strong>
          <p>
            These tools permanently delete data for a single school.
            A backup is automatically created before deletion.
            Platform-wide operations are not available.
          </p>
        </div>
      </div>

      <h1 className="cleanup-title">Test Data Cleanup</h1>
      <p className="cleanup-subtitle">
        Remove test data for a specific school. All data is backed up before deletion.
      </p>

      <div className="cleanup-cards">

        {/* ── Backup section ── */}
        {activeBackup && (
          <div className="cleanup-section">
            <div className="section-header">
              <HardDrive size={16} color="#1971c2" />
              <h2 className="section-title">Recovery Backup</h2>
            </div>
            <BackupCard
              backupId={activeBackup.id}
              schoolId={activeBackup.school_id}
              createdAt={activeBackup.created_at}
              meta={activeBackup.meta}
              storageFileCount={activeBackup.storage_manifest?.length ?? 0}
              isRestoring={schoolRestore.isPending}
              onRestore={() => {
                if (!currentCollegeId) return;
                schoolRestore.mutate({
                  backupId: activeBackup.id,
                  schoolId: currentCollegeId,
                  storageManifest: activeBackup.storage_manifest ?? [],
                });
              }}
            />
            {schoolRestore.isSuccess && (
              <div className="restore-success-banner">
                <CheckCircle size={16} color="var(--color-success)" />
                <span>Data restored successfully. Storage files have been recovered.</span>
              </div>
            )}
            {schoolRestore.isError && (
              <div className="purge-error-banner">
                <strong>Restore failed:</strong>{' '}
                {schoolRestore.error instanceof Error
                  ? schoolRestore.error.message
                  : 'Check browser console.'}
              </div>
            )}
          </div>
        )}

        {/* ── School purge ── */}
        <PurgeCard
          title={`Purge ${currentSchool?.name ?? 'School'} Data`}
          subtitle={
            currentSchool
              ? `Backs up then deletes all test data for ${currentSchool.name}`
              : 'Select a school from the sidebar first'
          }
          confirmPhrase={confirmPhrase}
          items={SCHOOL_ITEMS}
          hasExistingBackup={!!activeBackup}
          onConfirm={() => {
            if (!currentCollegeId) return;
            schoolPurge.mutate(currentCollegeId);
          }}
          isPending={schoolPurge.isPending}
          isSuccess={schoolPurge.isSuccess}
          isError={schoolPurge.isError}
          errorMessage={
            schoolPurge.error instanceof Error
              ? schoolPurge.error.message
              : String(schoolPurge.error ?? '')
          }
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
          display: flex; align-items: flex-start; gap: 12px;
          padding: 14px 16px; background: #fff5f5; border: 1px solid #ffc9c9;
          border-radius: var(--radius-md); margin-bottom: 24px;
          color: #c92a2a; font-size: 13px;
        }
        .cleanup-banner strong { display: block; font-size: 14px; margin-bottom: 2px; }
        .cleanup-banner p { margin: 0; color: #c92a2a; opacity: 0.85; }

        .cleanup-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin-bottom: 4px; }
        .cleanup-subtitle { font-size: 13px; color: var(--color-text-tertiary); margin-bottom: 28px; }
        .cleanup-cards { display: flex; flex-direction: column; gap: 20px; }

        /* Section header */
        .cleanup-section { display: flex; flex-direction: column; gap: 12px; }
        .section-header { display: flex; align-items: center; gap: 8px; }
        .section-title { font-size: 15px; font-weight: 600; color: var(--color-text-primary); margin: 0; }

        /* Backup card */
        .backup-card {
          background: var(--color-bg-primary); border: 1px solid #a5d8ff;
          border-radius: var(--radius-lg); padding: 16px;
          display: flex; flex-direction: column; gap: 12px;
        }
        .backup-card-header { display: flex; align-items: center; gap: 12px; }
        .backup-card-icon-wrap {
          width: 40px; height: 40px; border-radius: var(--radius-md);
          background: #d0ebff; display: flex; align-items: center;
          justify-content: center; flex-shrink: 0;
        }
        .backup-card-title { font-size: 14px; font-weight: 600; color: var(--color-text-primary); margin: 0; }
        .backup-card-date { font-size: 12px; color: var(--color-text-tertiary); margin: 2px 0 0 0; }

        .backup-stats {
          display: flex; gap: 16px; padding: 10px 14px;
          background: var(--color-bg-secondary); border-radius: var(--radius-sm);
        }
        .backup-stat { display: flex; flex-direction: column; align-items: center; gap: 2px; }
        .backup-stat-value { font-size: 16px; font-weight: 700; color: var(--color-text-primary); }
        .backup-stat-label { font-size: 10px; text-transform: uppercase; letter-spacing: 0.04em; color: var(--color-text-tertiary); }

        .restore-btn {
          display: flex; align-items: center; justify-content: center; gap: 6px;
          width: 100%; padding: 9px 0; font-size: 13px; font-weight: 600;
          border-radius: var(--radius-md); border: 1px solid #a5d8ff;
          cursor: pointer; color: #1971c2; background: #e7f5ff;
          transition: opacity 0.15s;
        }
        .restore-btn:not(:disabled):hover { opacity: 0.85; }
        .restore-btn:disabled { cursor: not-allowed; opacity: 0.6; }
        .restore-btn--confirm { background: #1971c2; color: white; border-color: #1971c2; }
        .restore-btn--cancel { background: white; color: var(--color-text-secondary); border-color: var(--color-border); }
        .restore-confirm { display: flex; flex-direction: column; gap: 8px; }
        .restore-confirm-text {
          display: flex; align-items: center; gap: 6px;
          font-size: 12px; color: #e67700; margin: 0;
        }
        .restore-confirm-actions { display: flex; gap: 8px; }
        .restore-confirm-actions .restore-btn { flex: 1; }

        .restore-success-banner {
          display: flex; align-items: center; gap: 8px;
          padding: 10px 14px; background: var(--color-success-light);
          border: 1px solid var(--color-success); border-radius: var(--radius-sm);
          font-size: 12px; color: var(--color-text-primary);
        }

        /* Purge card */
        .purge-card {
          background: var(--color-bg-primary); border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg); padding: 20px;
          display: flex; flex-direction: column; gap: 16px;
        }
        .purge-card--denied {
          opacity: 0.65; display: flex; flex-direction: row;
          align-items: center; gap: 14px; padding: 16px 20px;
        }
        .purge-card--success {
          display: flex; flex-direction: row; align-items: center; gap: 14px;
          padding: 20px; background: var(--color-success-light); border-color: var(--color-success);
        }
        .purge-card-header { display: flex; align-items: center; gap: 14px; }
        .purge-card-icon-wrap {
          width: 44px; height: 44px; border-radius: var(--radius-md);
          display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        }
        .purge-card-title { font-size: 16px; font-weight: 700; color: var(--color-text-primary); margin: 0 0 2px 0; }
        .purge-card-subtitle, .purge-denied-reason, .purge-success-msg {
          font-size: 12px; color: var(--color-text-secondary); margin: 0;
        }

        /* Safety banner */
        .purge-safety-banner {
          display: flex; align-items: center; gap: 8px;
          padding: 10px 14px; background: #e7f5ff; border: 1px solid #a5d8ff;
          border-radius: var(--radius-sm); font-size: 12px; color: #1971c2;
        }

        /* Error banner */
        .purge-error-banner {
          background: #fff5f5; border: 1px solid #ffc9c9; border-radius: 6px;
          padding: 10px 12px; font-size: 12px; color: #c92a2a;
        }

        /* Scope list */
        .purge-scope-list { background: var(--color-bg-secondary); border-radius: var(--radius-sm); padding: 12px 14px; }
        .purge-scope-label {
          font-size: 11px; font-weight: 600; text-transform: uppercase;
          letter-spacing: 0.04em; color: var(--color-text-tertiary); margin: 0 0 8px 0;
        }
        .purge-scope-list ul { margin: 0; padding: 0; list-style: none; display: flex; flex-direction: column; gap: 5px; }
        .purge-scope-list li { display: flex; align-items: center; gap: 7px; font-size: 12px; color: var(--color-text-secondary); }

        /* Confirmation */
        .purge-confirm-block { display: flex; flex-direction: column; gap: 6px; }
        .purge-confirm-label {
          font-size: 12px; color: var(--color-text-secondary); margin: 0;
          display: flex; align-items: center; gap: 6px; flex-wrap: wrap;
        }
        .purge-confirm-label strong {
          font-family: var(--font-mono); background: var(--color-bg-tertiary);
          padding: 1px 6px; border-radius: 3px; color: var(--color-danger);
        }
        .purge-confirm-input {
          padding: 8px 12px; font-size: 13px; font-family: var(--font-mono);
          border: 1px solid var(--color-border); border-radius: var(--radius-sm);
          background: var(--color-bg-secondary); color: var(--color-text-primary);
          outline: none; transition: border-color 0.15s;
        }
        .purge-confirm-input.ready { border-color: var(--color-danger); }

        /* Purge button */
        .purge-btn {
          display: flex; align-items: center; justify-content: center; gap: 6px;
          width: 100%; padding: 11px 0; font-size: 13px; font-weight: 600;
          border-radius: var(--radius-md); border: none; cursor: pointer;
          color: white; background: var(--color-text-tertiary); transition: opacity 0.15s;
        }
        .purge-btn:disabled { cursor: not-allowed; opacity: 0.6; }
        .purge-btn:not(:disabled):hover { opacity: 0.88; }

        .spin { animation: spin 1s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
