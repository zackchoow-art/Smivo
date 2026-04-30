import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Filter, ChevronLeft, ChevronRight  } from 'lucide-react';
import { useFeedbacks } from '@/hooks/useFeedbacks';
import { DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { FeedbackStatus, FeedbackType } from '@/types/feedback';

export function FeedbackListPage() {
  const navigate = useNavigate();
  const [page, setPage] = useState(0);
  const [status, setStatus] = useState<FeedbackStatus | ''>('');
  const [type, setType] = useState<FeedbackType | ''>('');

  const { data, isLoading, error } = useFeedbacks(page, { 
    status: status || undefined, 
    type: type || undefined 
  });

  const totalPages = data ? Math.ceil(data.totalCount / DEFAULT_PAGE_SIZE) : 0;

  return (
    <div className="feedback-container">
      <header className="feedback-header">
        <h1 className="page-title">User Feedback</h1>
        <div className="filters-bar">
          <div className="filter-group">
            <Filter size={14} />
            <select value={type} onChange={(e) => { setType(e.target.value as FeedbackType | ''); setPage(0); }}>
              <option value="">All Types</option>
              <option value="bug">Bug Report</option>
              <option value="suggestion">Suggestion</option>
              <option value="complaint">Complaint</option>
              <option value="other">Other</option>
            </select>
          </div>
          <div className="filter-group">
            <select value={status} onChange={(e) => { setStatus(e.target.value as FeedbackStatus | ''); setPage(0); }}>
              <option value="">All Statuses</option>
              <option value="pending">Pending</option>
              <option value="processing">Processing</option>
              <option value="resolved">Resolved</option>
              <option value="dismissed">Dismissed</option>
            </select>
          </div>
        </div>
      </header>

      <div className="feedback-table-wrapper">
        <table className="feedback-table">
          <thead>
            <tr>
              <th>Title / Content</th>
              <th>Type</th>
              <th>Status</th>
              <th>Submitted At</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan={4} className="table-loading">Loading feedback...</td></tr>
            ) : error ? (
              <tr><td colSpan={4} className="table-error">Error loading feedback</td></tr>
            ) : data?.data.length === 0 ? (
              <tr><td colSpan={4} className="table-empty">No feedback found</td></tr>
            ) : (
              data?.data.map((item) => (
                <tr key={item.id} onClick={() => navigate(`/feedback/${item.id}`)} className="clickable-row">
                  <td className="content-cell">
                    <div className="feedback-title">{item.title || 'No Title'}</div>
                    <div className="feedback-preview">{item.content.slice(0, 80)}{item.content.length > 80 ? '...' : ''}</div>
                  </td>
                  <td><TypeBadge type={item.feedback_type} /></td>
                  <td><StatusBadge status={item.status} /></td>
                  <td><span className="time-cell">{new Date(item.created_at).toLocaleString()}</span></td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      <footer className="feedback-footer">
        <span className="pagination-info">
          Showing {page * DEFAULT_PAGE_SIZE + 1} - {Math.min((page + 1) * DEFAULT_PAGE_SIZE, data?.totalCount || 0)} of {data?.totalCount || 0}
        </span>
        <div className="pagination-actions">
          <button className="pagination-btn" disabled={page === 0} onClick={() => setPage(p => p - 1)}>
            <ChevronLeft size={18} />
          </button>
          <span className="current-page">Page {page + 1}</span>
          <button className="pagination-btn" disabled={page >= totalPages - 1} onClick={() => setPage(p => p + 1)}>
            <ChevronRight size={18} />
          </button>
        </div>
      </footer>

      <style>{`
        .feedback-container {
          padding: 24px;
          display: flex;
          flex-direction: column;
          gap: 24px;
        }

        .feedback-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .page-title {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .filters-bar {
          display: flex;
          gap: 12px;
        }

        .filter-group {
          display: flex;
          align-items: center;
          gap: 8px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-subtle);
          border-radius: var(--radius-md);
          padding: 4px 12px;
          color: var(--color-text-tertiary);
        }

        .filter-group select {
          border: none;
          background: transparent;
          font-size: 13px;
          color: var(--color-text-primary);
          outline: none;
          padding: 4px 0;
          cursor: pointer;
        }

        .feedback-table-wrapper {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-subtle);
          border-radius: var(--radius-md);
          overflow: hidden;
        }

        .feedback-table {
          width: 100%;
          border-collapse: collapse;
          text-align: left;
        }

        .feedback-table th {
          background: var(--color-bg-secondary);
          padding: 12px 16px;
          font-size: 12px;
          font-weight: 600;
          color: var(--color-text-secondary);
          text-transform: uppercase;
        }

        .feedback-table td {
          padding: 16px;
          border-bottom: 1px solid var(--color-border-subtle);
        }

        .content-cell {
          max-width: 400px;
        }

        .feedback-title {
          font-size: 14px;
          font-weight: 600;
          color: var(--color-text-primary);
          margin-bottom: 4px;
        }

        .feedback-preview {
          font-size: 13px;
          color: var(--color-text-secondary);
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .badge {
          display: inline-flex;
          align-items: center;
          padding: 2px 8px;
          border-radius: 12px;
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
        }

        .time-cell {
          font-size: 12px;
          color: var(--color-text-tertiary);
        }

        .clickable-row {
          cursor: pointer;
          transition: background-color 0.2s;
        }

        .clickable-row:hover {
          background-color: var(--color-bg-tertiary);
        }

        .table-loading, .table-error, .table-empty {
          text-align: center;
          padding: 48px;
          color: var(--color-text-tertiary);
        }

        .feedback-footer {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .pagination-info {
          font-size: 13px;
          color: var(--color-text-secondary);
        }

        .pagination-actions {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .pagination-btn {
          width: 32px;
          height: 32px;
          display: flex;
          align-items: center;
          justify-content: center;
          border: 1px solid var(--color-border-subtle);
          background: var(--color-bg-primary);
          border-radius: var(--radius-sm);
          color: var(--color-text-secondary);
          cursor: pointer;
        }

        .pagination-btn:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .current-page {
          font-size: 13px;
          font-weight: 500;
          color: var(--color-text-primary);
        }
      `}</style>
    </div>
  );
}

function TypeBadge({ type }: { type: FeedbackType }) {
  const styles: Record<FeedbackType, { bg: string, text: string }> = {
    bug: { bg: '#fee2e2', text: '#ef4444' },
    suggestion: { bg: '#dcfce7', text: '#22c55e' },
    complaint: { bg: '#fef3c7', text: '#f59e0b' },
    other: { bg: '#f3f4f6', text: '#6b7280' },
  };
  const style = styles[type] || styles.other;
  return <span className="badge" style={{ backgroundColor: style.bg, color: style.text }}>{type}</span>;
}

function StatusBadge({ status }: { status: FeedbackStatus }) {
  const styles: Record<FeedbackStatus, { bg: string, text: string }> = {
    pending: { bg: '#fef3c7', text: '#d97706' },
    processing: { bg: '#e0f2fe', text: '#0284c7' },
    resolved: { bg: '#dcfce7', text: '#16a34a' },
    dismissed: { bg: '#f3f4f6', text: '#6b7280' },
  };
  const style = styles[status] || styles.pending;
  return <span className="badge" style={{ backgroundColor: style.bg, color: style.text }}>{status}</span>;
}
