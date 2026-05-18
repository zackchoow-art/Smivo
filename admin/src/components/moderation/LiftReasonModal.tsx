import { useState } from 'react';
import { X } from 'lucide-react';

interface LiftReasonModalProps {
  title: string;
  onConfirm: (reason: string) => void;
  onCancel: () => void;
  isPending?: boolean;
}

/**
 * Modal dialog for collecting a reason when lifting a ban/restriction.
 * Replaces the browser-native prompt() which gets auto-dismissed by React
 * re-renders triggered by React Query state updates.
 */
export function LiftReasonModal({ title, onConfirm, onCancel, isPending }: LiftReasonModalProps) {
  const [reason, setReason] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (reason.trim()) {
      onConfirm(reason.trim());
    }
  };

  return (
    <div className="lrm-overlay" onMouseDown={(e) => {
      // NOTE: Close on backdrop click, but not when clicking inside modal
      if (e.target === e.currentTarget) onCancel();
    }}>
      <div className="lrm-modal">
        <header className="lrm-header">
          <h3 className="lrm-title">{title}</h3>
          <button className="lrm-close" onClick={onCancel} type="button">
            <X size={18} />
          </button>
        </header>

        <form onSubmit={handleSubmit}>
          <div className="lrm-body">
            <label className="lrm-label" htmlFor="lift-reason-input">
              Reason for lifting
            </label>
            <textarea
              id="lift-reason-input"
              className="lrm-textarea"
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              placeholder="Explain why this restriction is being lifted..."
              rows={3}
              autoFocus
            />
          </div>

          <footer className="lrm-footer">
            <button type="button" className="lrm-btn-cancel" onClick={onCancel}>
              Cancel
            </button>
            <button
              type="submit"
              className="lrm-btn-confirm"
              disabled={!reason.trim() || isPending}
            >
              {isPending ? 'Processing...' : 'Confirm'}
            </button>
          </footer>
        </form>
      </div>

      <style>{`
        .lrm-overlay {
          position: fixed;
          inset: 0;
          background: rgba(0, 0, 0, 0.45);
          display: flex;
          align-items: center;
          justify-content: center;
          z-index: 1100;
          backdrop-filter: blur(3px);
        }

        .lrm-modal {
          background: var(--color-bg-primary);
          width: 440px;
          max-width: 90vw;
          border-radius: var(--radius-lg);
          box-shadow: var(--shadow-modal);
          overflow: hidden;
        }

        .lrm-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 18px 20px;
          border-bottom: 1px solid var(--color-border-light);
        }

        .lrm-title {
          font-size: 16px;
          font-weight: 700;
          color: var(--color-text-primary);
          margin: 0;
        }

        .lrm-close {
          background: none;
          border: none;
          color: var(--color-text-tertiary);
          cursor: pointer;
          padding: 4px;
          border-radius: var(--radius-sm);
          display: flex;
          align-items: center;
          justify-content: center;
          transition: background-color 0.15s;
        }

        .lrm-close:hover {
          background: var(--color-bg-secondary);
          color: var(--color-text-primary);
        }

        .lrm-body {
          padding: 20px;
        }

        .lrm-label {
          display: block;
          font-size: 13px;
          font-weight: 600;
          color: var(--color-text-secondary);
          margin-bottom: 8px;
        }

        .lrm-textarea {
          width: 100%;
          padding: 10px 12px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          font-family: inherit;
          font-size: 14px;
          color: var(--color-text-primary);
          background: var(--color-bg-primary);
          resize: vertical;
          outline: none;
          transition: border-color 0.15s;
          box-sizing: border-box;
        }

        .lrm-textarea:focus {
          border-color: var(--color-info);
          box-shadow: 0 0 0 2px rgba(74, 144, 226, 0.15);
        }

        .lrm-footer {
          padding: 16px 20px;
          background: var(--color-bg-secondary);
          display: flex;
          justify-content: flex-end;
          gap: 10px;
        }

        .lrm-btn-cancel {
          padding: 8px 18px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          font-size: 14px;
          font-weight: 500;
          color: var(--color-text-secondary);
          cursor: pointer;
          transition: all 0.15s;
        }

        .lrm-btn-cancel:hover {
          background: var(--color-bg-tertiary);
        }

        .lrm-btn-confirm {
          padding: 8px 20px;
          background: var(--color-success);
          border: none;
          border-radius: var(--radius-md);
          font-size: 14px;
          font-weight: 600;
          color: white;
          cursor: pointer;
          transition: opacity 0.15s;
        }

        .lrm-btn-confirm:hover:not(:disabled) {
          opacity: 0.9;
        }

        .lrm-btn-confirm:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
      `}</style>
    </div>
  );
}
