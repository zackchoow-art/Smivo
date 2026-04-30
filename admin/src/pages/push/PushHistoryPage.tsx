import { useState } from 'react';
import { Link } from 'react-router-dom';
import { usePushJobs } from '@/hooks/usePush';
import { DEFAULT_PAGE_SIZE, PUSH_STATUS } from '@/lib/constants';
import type { PushStatus } from '@/types';

export function PushHistoryPage() {
  const [page, setPage] = useState(0);
  const [statusFilter, setStatusFilter] = useState<PushStatus | 'all'>('all');

  const { data, isLoading, error } = usePushJobs(page, { status: statusFilter });

  const getStatusClass = (status: string) => {
    switch (status) {
      case PUSH_STATUS.DRAFT:      return 'ph-badge ph-badge--neutral';
      case PUSH_STATUS.SCHEDULED:  return 'ph-badge ph-badge--info';
      case PUSH_STATUS.SENDING:    return 'ph-badge ph-badge--warning';
      case PUSH_STATUS.SENT:       return 'ph-badge ph-badge--success';
      case PUSH_STATUS.FAILED:     return 'ph-badge ph-badge--danger';
      case PUSH_STATUS.CANCELLED:  return 'ph-badge ph-badge--neutral';
      default:                     return 'ph-badge ph-badge--neutral';
    }
  };

  return (
    <div className="ph-container">
      <div className="ph-header">
        <div className="ph-header-left">
          <Link to="/push" className="ph-btn-back">&larr; Back to Overview</Link>
          <h1 className="ph-page-title">Push History</h1>
        </div>

        <div className="ph-header-right">
          <select
            value={statusFilter}
            onChange={(e) => {
              setStatusFilter(e.target.value as any);
              setPage(0);
            }}
            className="ph-filter-select"
          >
            <option value="all">All Statuses</option>
            <option value={PUSH_STATUS.DRAFT}>Draft</option>
            <option value={PUSH_STATUS.SCHEDULED}>Scheduled</option>
            <option value={PUSH_STATUS.SENDING}>Sending</option>
            <option value={PUSH_STATUS.SENT}>Sent</option>
            <option value={PUSH_STATUS.FAILED}>Failed</option>
            <option value={PUSH_STATUS.CANCELLED}>Cancelled</option>
          </select>

          <Link to="/push/new" className="ph-btn-create">Create Push</Link>
        </div>
      </div>

      <div className="ph-table-card">
        {isLoading ? (
          <div className="ph-state-msg">Loading history...</div>
        ) : error ? (
          <div className="ph-state-msg ph-state-error">Failed to load push jobs.</div>
        ) : (
          <table className="ph-table">
            <thead className="ph-thead">
              <tr>
                <th className="ph-th">Title / Content</th>
                <th className="ph-th">Audience</th>
                <th className="ph-th">Status</th>
                <th className="ph-th">Created / Scheduled</th>
                <th className="ph-th ph-th--right">Stats</th>
              </tr>
            </thead>
            <tbody>
              {data?.data.length === 0 ? (
                <tr>
                  <td colSpan={5} className="ph-td-empty">No push jobs found matching criteria.</td>
                </tr>
              ) : (
                data?.data.map((job) => (
                  <tr key={job.id} className="ph-tr">
                    <td className="ph-td">
                      <div className="ph-job-title">{job.title}</div>
                      <div className="ph-job-body">{job.body}</div>
                    </td>
                    <td className="ph-td ph-td--nowrap">
                      <span className="ph-cell-text">{job.audience_type}</span>
                    </td>
                    <td className="ph-td ph-td--nowrap">
                      <span className={getStatusClass(job.status)}>{job.status}</span>
                    </td>
                    <td className="ph-td ph-td--nowrap ph-cell-muted">
                      <div>Created: {new Date(job.created_at).toLocaleDateString()}</div>
                      {job.scheduled_at && (
                        <div className="ph-scheduled-date">
                          Scheduled: {new Date(job.scheduled_at).toLocaleString()}
                        </div>
                      )}
                    </td>
                    <td className="ph-td ph-td--right">
                      {job.status === 'sent' || job.status === 'sending' ? (
                        <div className="ph-stats">
                          <div className="ph-stat-delivered">Delivered: {job.delivered_count}</div>
                          <div className="ph-stat-opened">Opened: {job.opened_count}</div>
                        </div>
                      ) : (
                        <span className="ph-cell-muted">--</span>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        )}

        {/* Pagination */}
        {data && data.count > DEFAULT_PAGE_SIZE && (
          <div className="ph-pagination">
            <p className="ph-pagination-info">
              Showing <strong>{page * DEFAULT_PAGE_SIZE + 1}</strong> to{' '}
              <strong>{Math.min((page + 1) * DEFAULT_PAGE_SIZE, data.count)}</strong> of{' '}
              <strong>{data.count}</strong>
            </p>
            <div className="ph-pagination-nav">
              <button
                onClick={() => setPage(p => Math.max(0, p - 1))}
                disabled={page === 0}
                className="ph-page-btn ph-page-btn--left"
              >
                Previous
              </button>
              <button
                onClick={() => setPage(p => p + 1)}
                disabled={(page + 1) * DEFAULT_PAGE_SIZE >= data.count}
                className="ph-page-btn ph-page-btn--right"
              >
                Next
              </button>
            </div>
          </div>
        )}
      </div>

      <style>{`
        .ph-container { padding: var(--spacing-page); max-width: 1280px; margin: 0 auto; display: flex; flex-direction: column; gap: 24px; }
        .ph-header { display: flex; justify-content: space-between; align-items: center; }
        .ph-header-left { display: flex; align-items: center; gap: 16px; }
        .ph-header-right { display: flex; align-items: center; gap: 12px; }
        .ph-btn-back { color: var(--color-text-secondary); text-decoration: none; font-size: 14px; }
        .ph-btn-back:hover { color: var(--color-text-primary); }
        .ph-page-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .ph-filter-select { border: 1px solid var(--color-border); border-radius: var(--radius-sm); padding: 6px 10px; font-size: 13px; color: var(--color-text-primary); background: var(--color-bg-primary); outline: none; }
        .ph-filter-select:focus { border-color: var(--color-border-focus); }
        .ph-btn-create { padding: 8px 16px; background: var(--color-info); color: #fff; border-radius: var(--radius-sm); font-size: 13px; font-weight: 500; text-decoration: none; }
        .ph-btn-create:hover { opacity: 0.88; }
        .ph-table-card { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); overflow: hidden; }
        .ph-state-msg { padding: 48px; text-align: center; color: var(--color-text-secondary); font-size: 14px; }
        .ph-state-error { color: var(--color-danger); }
        .ph-table { width: 100%; border-collapse: collapse; }
        .ph-thead { background: var(--color-bg-secondary); }
        .ph-th { padding: 12px 20px; text-align: left; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--color-text-secondary); border-bottom: 1px solid var(--color-border-light); }
        .ph-th--right { text-align: right; }
        .ph-tr:hover { background: var(--color-bg-secondary); }
        .ph-td { padding: 14px 20px; font-size: 13px; border-bottom: 1px solid var(--color-border-light); }
        .ph-td--nowrap { white-space: nowrap; }
        .ph-td--right { text-align: right; }
        .ph-td-empty { padding: 48px; text-align: center; font-size: 13px; color: var(--color-text-secondary); }
        .ph-job-title { font-weight: 500; color: var(--color-text-primary); }
        .ph-job-body { font-size: 12px; color: var(--color-text-secondary); max-width: 360px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin-top: 4px; }
        .ph-cell-text { font-size: 13px; color: var(--color-text-primary); text-transform: capitalize; }
        .ph-cell-muted { color: var(--color-text-secondary); font-size: 13px; }
        .ph-scheduled-date { color: var(--color-info); }
        .ph-stats { display: flex; flex-direction: column; gap: 4px; }
        .ph-stat-delivered { color: var(--color-text-primary); font-size: 12px; }
        .ph-stat-opened    { color: var(--color-success); font-size: 12px; }
        .ph-badge { display: inline-flex; padding: 2px 8px; font-size: 11px; font-weight: 600; border-radius: 999px; }
        .ph-badge--neutral { background: var(--color-bg-tertiary);    color: var(--color-text-secondary); }
        .ph-badge--info    { background: var(--color-info-light);     color: var(--color-info); }
        .ph-badge--warning { background: var(--color-warning-light);  color: var(--color-warning); }
        .ph-badge--success { background: var(--color-success-light);  color: var(--color-success); }
        .ph-badge--danger  { background: var(--color-danger-light);   color: var(--color-danger); }
        .ph-pagination { display: flex; align-items: center; justify-content: space-between; border-top: 1px solid var(--color-border-light); padding: 12px 20px; }
        .ph-pagination-info { font-size: 13px; color: var(--color-text-secondary); margin: 0; }
        .ph-pagination-nav { display: flex; gap: 4px; }
        .ph-page-btn { padding: 6px 12px; font-size: 13px; border: 1px solid var(--color-border); background: var(--color-bg-primary); color: var(--color-text-secondary); cursor: pointer; }
        .ph-page-btn--left  { border-radius: var(--radius-sm) 0 0 var(--radius-sm); }
        .ph-page-btn--right { border-radius: 0 var(--radius-sm) var(--radius-sm) 0; }
        .ph-page-btn:hover:not(:disabled) { background: var(--color-bg-secondary); }
        .ph-page-btn:disabled { opacity: 0.5; cursor: not-allowed; }
      `}</style>
    </div>
  );
}
