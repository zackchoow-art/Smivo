import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useGroupedListingReports } from '@/hooks/useListingReports';
import { useBatchModerateListings } from '@/hooks/useListingModeration';
import { REPORT_REASONS } from '@/lib/constants';
import { Filter } from 'lucide-react';
import { useAuth } from '@/hooks/useAuth';

export function UserReportsPage() {
  const navigate = useNavigate();
  const [reportStatus, setReportStatus] = useState<string>('pending');
  const [reportReason, setReportReason] = useState<string>('all');
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());

  const { data: reportsData, isLoading, error } = useGroupedListingReports({
    status: reportStatus,
    reason: reportReason,
  });
  const batchModerate = useBatchModerateListings();
  const { admin } = useAuth();

  const handleSelectAll = (e: React.ChangeEvent<HTMLInputElement>, ids: string[]) => {
    if (e.target.checked) {
      setSelectedIds(new Set(ids));
    } else {
      setSelectedIds(new Set());
    }
  };

  const handleSelectOne = (id: string, checked: boolean) => {
    const newSet = new Set(selectedIds);
    if (checked) newSet.add(id);
    else newSet.delete(id);
    setSelectedIds(newSet);
  };

  const handleBatchAction = async (action: 'approve' | 'reject') => {
    if (selectedIds.size === 0 || !admin) return;
    try {
      await batchModerate.mutateAsync({
        ids: Array.from(selectedIds),
        action,
        adminId: admin?.user_id ?? '',
      });
      setSelectedIds(new Set());
    } catch (err) {
      console.error('Batch action failed', err);
    }
  };

  return (
    <div className="lm-container">
      <div className="lm-header">
        <h1 className="lm-page-title">User Reports</h1>
      </div>

      <div className="lm-actions-row" style={{ justifyContent: 'space-between' }}>
        <div className="lm-filters">
          <div className="lm-filter-group">
            <Filter size={14} />
            <select
              className="lm-filter-select-inline"
              value={reportReason}
              onChange={(e) => setReportReason(e.target.value)}
            >
              <option value="all">All Reasons</option>
              {Object.entries(REPORT_REASONS).map(([key, value]) => (
                <option key={key} value={value}>{value.toUpperCase()}</option>
              ))}
            </select>
          </div>
          <div className="lm-filter-group">
            <select
              className="lm-filter-select-inline"
              value={reportStatus}
              onChange={(e) => setReportStatus(e.target.value)}
            >
              <option value="all">All Statuses</option>
              <option value="pending">Pending</option>
              <option value="resolved">Resolved</option>
              <option value="dismissed">Dismissed</option>
            </select>
          </div>
        </div>
        <div className="lm-batch-actions">
          <button
            onClick={() => handleBatchAction('approve')}
            disabled={selectedIds.size === 0 || batchModerate.isPending}
            className="lm-btn lm-btn--success"
          >
            Batch Approve
          </button>
          <button
            onClick={() => handleBatchAction('reject')}
            disabled={selectedIds.size === 0 || batchModerate.isPending}
            className="lm-btn lm-btn--danger"
          >
            Batch Reject
          </button>
        </div>
      </div>

      {isLoading ? (
        <div className="lm-state-msg">Loading user reports...</div>
      ) : error ? (
        <div className="lm-state-error">Error loading reports.</div>
      ) : (
        <div className="lm-table-wrap">
          <table className="lm-table">
            <thead className="lm-thead">
              <tr>
                <th className="lm-th">
                  <input
                    type="checkbox"
                    onChange={(e) => handleSelectAll(e, reportsData?.map((r) => r.listing_id) || [])}
                    checked={(reportsData?.length ?? 0) > 0 && selectedIds.size === (reportsData?.length ?? 0)}
                  />
                </th>
                <th className="lm-th">Listing</th>
                <th className="lm-th">Reported Seller</th>
                <th className="lm-th">Reports</th>
                <th className="lm-th">Violations</th>
                <th className="lm-th">First Reported At</th>
              </tr>
            </thead>
            <tbody>
              {reportsData?.length === 0 ? (
                <tr>
                  <td colSpan={6} className="lm-td-empty">No listing reports found.</td>
                </tr>
              ) : (
                reportsData?.map((report) => (
                  <tr
                    key={report.listing_id}
                    className="lm-tr clickable-row"
                    onClick={() => navigate(`/moderation/listing-reports/${report.listing_id}`)}
                  >
                    <td className="lm-td" onClick={(e) => e.stopPropagation()}>
                      <input
                        type="checkbox"
                        checked={selectedIds.has(report.listing_id)}
                        onChange={(e) => handleSelectOne(report.listing_id, e.target.checked)}
                      />
                    </td>
                    <td className="lm-td">
                      <div className="lm-listing-cell">
                        {report.listing_images?.[0] && (
                          <img className="lm-listing-thumb" src={report.listing_images[0]} alt="Cover" />
                        )}
                        <div className="lm-cell-title">{report.listing_title}</div>
                      </div>
                    </td>
                    <td className="lm-td">
                      <div className="lm-user-info">
                        <span className="lm-cell-text">{report.reported_name || 'Unknown'}</span>
                        <span className="lm-cell-muted" style={{ fontSize: 11, display: 'block' }}>
                          {report.reported_email}
                        </span>
                      </div>
                    </td>
                    <td className="lm-td">
                      <span className="lm-badge lm-badge--danger" style={{ fontSize: 13, padding: '4px 10px' }}>
                        {report.report_count} Report{report.report_count > 1 ? 's' : ''}
                      </span>
                    </td>
                    <td className="lm-td">
                      <div className="lm-violations">
                        {report.reasons.map((reason, idx) => (
                          <div key={idx} className="lm-violation-item">{reason.toUpperCase()}</div>
                        ))}
                      </div>
                    </td>
                    <td className="lm-td lm-cell-muted">
                      {new Date(report.first_reported_at).toLocaleString()}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      <style>{`
        .lm-container { padding: var(--spacing-page); max-width: 1280px; margin: 0 auto; }
        .lm-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .lm-page-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .lm-actions-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .lm-filters { display: flex; gap: 12px; }
        .lm-batch-actions { display: flex; gap: 12px; }
        .lm-filter-group { display: flex; align-items: center; gap: 8px; background: var(--color-bg-primary); border: 1px solid var(--color-border); border-radius: var(--radius-md); padding: 6px 12px; color: var(--color-text-tertiary); }
        .lm-filter-select-inline { border: none; background: transparent; font-size: 13px; color: var(--color-text-primary); outline: none; cursor: pointer; }
        .lm-btn { padding: 8px 16px; border: none; border-radius: var(--radius-sm); font-size: 13px; font-weight: 500; cursor: pointer; }
        .lm-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .lm-btn--success { background: var(--color-success); color: #fff; }
        .lm-btn--danger  { background: var(--color-danger);  color: #fff; }
        .lm-state-msg { padding: 48px; text-align: center; color: var(--color-text-secondary); font-size: 14px; }
        .lm-state-error { padding: 16px; background: var(--color-danger-light); color: var(--color-danger); border-radius: var(--radius-sm); font-size: 14px; }
        .lm-table-wrap { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); overflow: hidden; }
        .lm-table { width: 100%; border-collapse: collapse; }
        .lm-thead { background: var(--color-bg-secondary); }
        .lm-th { padding: 12px 20px; text-align: left; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--color-text-secondary); border-bottom: 1px solid var(--color-border-light); }
        .clickable-row { cursor: pointer; }
        .lm-tr:hover { background: var(--color-bg-secondary); }
        .lm-td { padding: 14px 20px; font-size: 13px; border-bottom: 1px solid var(--color-border-light); white-space: nowrap; }
        .lm-td-empty { padding: 24px; text-align: center; font-size: 13px; color: var(--color-text-secondary); }
        .lm-cell-title { font-weight: 500; color: var(--color-text-primary); max-width: 240px; overflow: hidden; text-overflow: ellipsis; }
        .lm-cell-text { color: var(--color-text-primary); }
        .lm-cell-muted { color: var(--color-text-secondary); }
        .lm-user-info { display: flex; flex-direction: column; gap: 2px; }
        .lm-listing-cell { display: flex; align-items: center; gap: 12px; }
        .lm-listing-thumb { width: 40px; height: 40px; border-radius: 4px; object-fit: cover; }
        .lm-violation-item { font-size: 11px; color: var(--color-danger); margin-bottom: 2px; }
        .lm-violations { display: flex; flex-direction: column; }
        .lm-badge { display: inline-flex; align-items: center; padding: 2px 8px; font-size: 11px; font-weight: 600; border-radius: 999px; white-space: nowrap; }
        .lm-badge--danger  { background: var(--color-danger-light);  color: var(--color-danger); }
      `}</style>
    </div>
  );
}
