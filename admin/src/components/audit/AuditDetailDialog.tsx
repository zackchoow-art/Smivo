/**
 * Dialog component for viewing audit log entry details.
 * Shows the full JSON payload and status change information.
 */
import { X, Clock, User, Target, ArrowRight } from 'lucide-react';
import { format } from 'date-fns';
import type { AuditLog } from '@/types';

interface AuditDetailDialogProps {
  log: AuditLog | null;
  onClose: () => void;
}

export function AuditDetailDialog({ log, onClose }: AuditDetailDialogProps) {
  if (!log) return null;

  return (
    <div className="audit-overlay" onClick={onClose}>
      <div className="audit-dialog" onClick={(e) => e.stopPropagation()}>
        <div className="audit-dialog-header">
          <h2>Audit Log Detail</h2>
          <button className="audit-close-btn" onClick={onClose}>
            <X size={18} />
          </button>
        </div>

        <div className="audit-dialog-body">
          {/* Metadata */}
          <div className="audit-meta-grid">
            <div className="audit-meta-item">
              <Clock size={14} />
              <span className="audit-meta-label">Time</span>
              <span className="audit-meta-value tabular-nums">
                {format(new Date(log.created_at), 'yyyy-MM-dd HH:mm:ss')}
              </span>
            </div>

            <div className="audit-meta-item">
              <User size={14} />
              <span className="audit-meta-label">Admin</span>
              <span className="audit-meta-value">
                <code>{log.admin_id.slice(0, 8)}…</code>
              </span>
            </div>

            <div className="audit-meta-item">
              <Target size={14} />
              <span className="audit-meta-label">Target</span>
              <span className="audit-meta-value">
                {log.target_type}
                {log.target_id && <code> {log.target_id.slice(0, 8)}…</code>}
              </span>
            </div>
          </div>

          {/* Action */}
          <div className="audit-section">
            <h3 className="audit-section-title">Action</h3>
            <div className="audit-action-badge">{log.action}</div>
          </div>

          {/* Status Change */}
          {(log.status_before || log.status_after) && (
            <div className="audit-section">
              <h3 className="audit-section-title">Status Change</h3>
              <div className="audit-status-change">
                <span className="audit-status-chip before">
                  {log.status_before ?? '—'}
                </span>
                <ArrowRight size={14} color="var(--color-text-tertiary)" />
                <span className="audit-status-chip after">
                  {log.status_after ?? '—'}
                </span>
              </div>
            </div>
          )}

          {/* IP & User Agent */}
          {(log.ip_address || log.user_agent) && (
            <div className="audit-section">
              <h3 className="audit-section-title">Client Info</h3>
              {log.ip_address && (
                <p className="audit-client-info">
                  <strong>IP:</strong> {log.ip_address}
                </p>
              )}
              {log.user_agent && (
                <p className="audit-client-info">
                  <strong>UA:</strong> {log.user_agent}
                </p>
              )}
            </div>
          )}

          {/* Payload */}
          {log.payload && (
            <div className="audit-section">
              <h3 className="audit-section-title">Payload</h3>
              <pre className="audit-payload">
                {JSON.stringify(log.payload, null, 2)}
              </pre>
            </div>
          )}
        </div>
      </div>

      <style>{`
        .audit-overlay {
          position: fixed;
          inset: 0;
          background: rgba(0, 0, 0, 0.5);
          display: flex;
          align-items: center;
          justify-content: center;
          z-index: 1000;
          padding: 24px;
        }

        .audit-dialog {
          background: var(--color-bg-primary);
          border-radius: var(--radius-lg);
          box-shadow: var(--shadow-modal);
          width: 100%;
          max-width: 560px;
          max-height: 80vh;
          display: flex;
          flex-direction: column;
        }

        .audit-dialog-header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 16px 20px;
          border-bottom: 1px solid var(--color-border-light);
        }

        .audit-dialog-header h2 {
          font-size: 16px;
          font-weight: 600;
          color: var(--color-text-primary);
        }

        .audit-close-btn {
          background: none;
          border: none;
          cursor: pointer;
          padding: 4px;
          color: var(--color-text-tertiary);
          border-radius: var(--radius-sm);
        }

        .audit-close-btn:hover {
          background: var(--color-bg-tertiary);
          color: var(--color-text-primary);
        }

        .audit-dialog-body {
          padding: 20px;
          overflow-y: auto;
          display: flex;
          flex-direction: column;
          gap: 20px;
        }

        .audit-meta-grid {
          display: flex;
          flex-direction: column;
          gap: 8px;
        }

        .audit-meta-item {
          display: flex;
          align-items: center;
          gap: 8px;
          font-size: 13px;
          color: var(--color-text-secondary);
        }

        .audit-meta-label {
          min-width: 48px;
          color: var(--color-text-tertiary);
          font-size: 12px;
        }

        .audit-meta-value {
          color: var(--color-text-primary);
        }

        .audit-meta-value code {
          font-family: var(--font-mono);
          font-size: 12px;
          background: var(--color-bg-tertiary);
          padding: 2px 6px;
          border-radius: var(--radius-sm);
        }

        .audit-section {
          display: flex;
          flex-direction: column;
          gap: 8px;
        }

        .audit-section-title {
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.05em;
          color: var(--color-text-tertiary);
        }

        .audit-action-badge {
          display: inline-block;
          font-size: 13px;
          font-weight: 500;
          padding: 4px 10px;
          background: var(--color-info-light);
          color: var(--color-info);
          border-radius: var(--radius-sm);
          font-family: var(--font-mono);
          width: fit-content;
        }

        .audit-status-change {
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .audit-status-chip {
          font-size: 12px;
          padding: 3px 8px;
          border-radius: var(--radius-sm);
          font-family: var(--font-mono);
        }

        .audit-status-chip.before {
          background: var(--color-bg-tertiary);
          color: var(--color-text-secondary);
        }

        .audit-status-chip.after {
          background: var(--color-success-light);
          color: var(--color-success);
        }

        .audit-client-info {
          font-size: 12px;
          color: var(--color-text-secondary);
          word-break: break-all;
        }

        .audit-payload {
          font-size: 12px;
          font-family: var(--font-mono);
          background: var(--color-bg-tertiary);
          padding: 12px;
          border-radius: var(--radius-md);
          overflow-x: auto;
          color: var(--color-text-secondary);
          line-height: 1.6;
          max-height: 240px;
        }
      `}</style>
    </div>
  );
}
