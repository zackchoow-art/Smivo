import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Filter, ChevronLeft, ChevronRight } from 'lucide-react';
import { useChatReports } from '@/hooks/useChatReports';
import { DEFAULT_PAGE_SIZE, REPORT_REASONS } from '@/lib/constants';
import type { ReportStatus, ReportReason } from '@/types/report';

export function ChatReportsPage() {
  const navigate = useNavigate();
  const [page, setPage] = useState(0);
  const [status, setStatus] = useState<ReportStatus | ''>('pending');
  const [reason, setReason] = useState<ReportReason | ''>('');

  const { data, isLoading, error } = useChatReports(page, {
    status: status || undefined,
    reason: reason || undefined
  });

  const totalPages = data ? Math.ceil(data.totalCount / DEFAULT_PAGE_SIZE) : 0;

  return (
    <div className="reports-container">
      <header className="reports-header">
        <div className="header-left">
          <h1 className="page-title">Chat Reports</h1>
          <p className="page-subtitle">Moderation queue for user-to-user messaging violations</p>
        </div>
      </header>

      <div className="filters-bar">
        <div className="filter-group">
          <Filter size={14} />
          <select 
            value={reason} 
            onChange={(e) => { setReason(e.target.value as ReportReason | ''); setPage(0); }}
          >
            <option value="">All Reasons</option>
            {Object.entries(REPORT_REASONS).map(([key, value]) => (
              <option key={key} value={value}>{value.toUpperCase()}</option>
            ))}
          </select>
        </div>
        <div className="filter-group">
          <select 
            value={status} 
            onChange={(e) => { setStatus(e.target.value as ReportStatus | ''); setPage(0); }}
          >
            <option value="">All Statuses</option>
            <option value="pending">Pending</option>
            <option value="resolved">Resolved</option>
            <option value="dismissed">Dismissed</option>
          </select>
        </div>
      </div>

      <div className="reports-table-wrapper">
        <table className="reports-table">
          <thead>
            <tr>
              <th>Reported User</th>
              <th>Reason</th>
              <th>Reporter</th>
              <th>Status</th>
              <th>Reported At</th>
              <th className="actions-cell"></th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan={6} className="table-loading">Loading reports...</td></tr>
            ) : error ? (
              <tr><td colSpan={6} className="table-error">Error loading reports</td></tr>
            ) : data?.data.length === 0 ? (
              <tr><td colSpan={6} className="table-empty">No reports found</td></tr>
            ) : (
              data?.data.map((item) => (
                <tr 
                  key={item.id} 
                  onClick={() => navigate(`/moderation/chat-reports/${item.id}`)} 
                  className="clickable-row"
                >
                  <td className="user-cell">
                    <div className="user-name">{item.reported_name || 'Unknown User'}</div>
                    <div className="user-email">{item.reported_email}</div>
                  </td>
                  <td><ReasonBadge reason={item.reason} /></td>
                  <td className="user-cell">
                    <div className="user-name">{item.reporter_name || 'Anonymous'}</div>
                    <div className="user-email">{item.reporter_email}</div>
                  </td>
                  <td><StatusBadge status={item.status} /></td>
                  <td><span className="time-cell">{new Date(item.created_at).toLocaleString()}</span></td>
                  <td className="actions-cell">
                    <button className="view-btn">View</button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      <footer className="reports-footer">
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
        .reports-container {
          padding: var(--spacing-page);
          display: flex;
          flex-direction: column;
          gap: 24px;
        }

        .reports-header {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .page-title {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
          margin-bottom: 4px;
        }

        .page-subtitle {
          font-size: 14px;
          color: var(--color-text-tertiary);
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
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          padding: 6px 12px;
          color: var(--color-text-tertiary);
        }

        .filter-group select {
          border: none;
          background: transparent;
          font-size: 13px;
          color: var(--color-text-primary);
          outline: none;
          cursor: pointer;
        }

        .reports-table-wrapper {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          overflow: hidden;
          box-shadow: var(--shadow-card);
        }

        .reports-table {
          width: 100%;
          border-collapse: collapse;
          text-align: left;
        }

        .reports-table th {
          background: var(--color-bg-tertiary);
          padding: 12px 16px;
          font-size: 12px;
          font-weight: 600;
          color: var(--color-text-secondary);
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        .reports-table td {
          padding: 16px;
          border-bottom: 1px solid var(--color-border-light);
        }

        .user-cell {
          display: flex;
          flex-direction: column;
          gap: 2px;
        }

        .user-name {
          font-size: 14px;
          font-weight: 600;
          color: var(--color-text-primary);
        }

        .user-email {
          font-size: 12px;
          color: var(--color-text-tertiary);
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
          color: var(--color-text-secondary);
          font-family: var(--font-mono);
        }

        .clickable-row {
          cursor: pointer;
          transition: background-color 0.2s;
        }

        .clickable-row:hover {
          background-color: var(--color-bg-tertiary);
        }

        .actions-cell {
          text-align: right;
        }

        .view-btn {
          padding: 4px 12px;
          font-size: 12px;
          font-weight: 500;
          border-radius: var(--radius-sm);
          border: 1px solid var(--color-border);
          background: var(--color-bg-secondary);
          color: var(--color-text-secondary);
          cursor: pointer;
          transition: all 0.2s;
        }

        .clickable-row:hover .view-btn {
          background: var(--color-info);
          color: white;
          border-color: var(--color-info);
        }

        .table-loading, .table-error, .table-empty {
          text-align: center;
          padding: 64px;
          color: var(--color-text-tertiary);
        }

        .reports-footer {
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
          width: 36px;
          height: 36px;
          display: flex;
          align-items: center;
          justify-content: center;
          border: 1px solid var(--color-border);
          background: var(--color-bg-primary);
          border-radius: var(--radius-sm);
          color: var(--color-text-secondary);
          cursor: pointer;
        }

        .pagination-btn:disabled {
          opacity: 0.4;
          cursor: not-allowed;
        }

        .current-page {
          font-size: 13px;
          font-weight: 600;
          color: var(--color-text-primary);
        }
      `}</style>
    </div>
  );
}

function ReasonBadge({ reason }: { reason: ReportReason }) {
  const colors: Record<ReportReason, string> = {
    spam: 'var(--color-text-tertiary)',
    harassment: 'var(--color-danger)',
    scam: 'var(--color-warning)',
    nsfw: 'var(--color-priority-urgent)',
    other: 'var(--color-text-secondary)'
  };
  
  return (
    <span className="badge" style={{ border: `1px solid ${colors[reason] || '#ccc'}`, color: colors[reason] }}>
      {reason}
    </span>
  );
}

function StatusBadge({ status }: { status: ReportStatus }) {
  const styles: Record<ReportStatus, { bg: string, text: string }> = {
    pending: { bg: 'var(--color-warning-light)', text: 'var(--color-warning)' },
    resolved: { bg: 'var(--color-success-light)', text: 'var(--color-success)' },
    dismissed: { bg: 'var(--color-bg-tertiary)', text: 'var(--color-text-tertiary)' },
  };
  const style = styles[status] || styles.pending;
  return <span className="badge" style={{ backgroundColor: style.bg, color: style.text }}>{status}</span>;
}
