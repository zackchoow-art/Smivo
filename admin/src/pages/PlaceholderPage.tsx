/**
 * Placeholder page component for pages not yet implemented.
 * Shows current route path and a "coming soon" message.
 */
import { useLocation } from 'react-router-dom';
import { Construction } from 'lucide-react';

export function PlaceholderPage() {
  const location = useLocation();

  return (
    <div className="placeholder-page">
      <Construction size={48} strokeWidth={1.5} color="var(--color-text-tertiary)" />
      <h2 className="placeholder-title">Under Construction</h2>
      <p className="placeholder-path">
        <code>{location.pathname}</code>
      </p>
      <p className="placeholder-hint">This page will be implemented in an upcoming sprint.</p>

      <style>{`
        .placeholder-page {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          min-height: 60vh;
          gap: 12px;
          text-align: center;
        }

        .placeholder-title {
          font-size: 20px;
          font-weight: 600;
          color: var(--color-text-primary);
          margin-top: 8px;
        }

        .placeholder-path code {
          font-size: 13px;
          background: var(--color-bg-tertiary);
          padding: 4px 10px;
          border-radius: var(--radius-sm);
          color: var(--color-text-secondary);
          font-family: var(--font-mono);
        }

        .placeholder-hint {
          font-size: 13px;
          color: var(--color-text-tertiary);
          margin-top: 4px;
        }
      `}</style>
    </div>
  );
}
