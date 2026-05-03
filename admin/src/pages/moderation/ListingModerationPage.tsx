import { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useListingsModeration, useBatchModerateListings } from '@/hooks/useListingModeration';
import { useGroupedListingReports } from '@/hooks/useListingReports';
import { DEFAULT_PAGE_SIZE, MODERATION_STATUS, MODERATION_PRIORITY, REPORT_REASONS } from '@/lib/constants';
import { Filter, ChevronRight } from 'lucide-react';
import { useAuth } from '@/hooks/useAuth';

export function ListingModerationPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const [viewTab, setViewTab] = useState<'system' | 'user'>(
    location.state?.tab === 'user' ? 'user' : 'system'
  );
  
  // System Queue State
  const [page, setPage] = useState(0);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [systemStatus, setSystemStatus] = useState<string>(MODERATION_STATUS.PENDING_REVIEW);

  const { data, isLoading, error } = useListingsModeration(page, { status: systemStatus as any });
  
  // User Reports State
  const [reportStatus, setReportStatus] = useState<string>('pending');
  const [reportReason, setReportReason] = useState<string>('all');
  const { data: reportsData, isLoading: reportsLoading, error: reportsError } = useGroupedListingReports({ 
    status: reportStatus, 
    reason: reportReason 
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
    if (checked) {
      newSet.add(id);
    } else {
      newSet.delete(id);
    }
    setSelectedIds(newSet);
  };

  const handleBatchAction = async (action: 'approve' | 'reject') => {
    if (selectedIds.size === 0 || !admin) return;
    try {
      await batchModerate.mutateAsync({
        ids: Array.from(selectedIds),
        action,
        adminId: admin?.user_id ?? ""
      });
      setSelectedIds(new Set());
    } catch (err) {
      console.error('Batch action failed', err);
    }
  };

  const getPriorityClass = (priority: string) => {
    switch (priority) {
      case MODERATION_PRIORITY.URGENT: return 'lm-badge lm-badge--danger';
      case MODERATION_PRIORITY.NORMAL: return 'lm-badge lm-badge--info';
      case MODERATION_PRIORITY.LOW:    return 'lm-badge lm-badge--neutral';
      default:                          return 'lm-badge lm-badge--neutral';
    }
  };

  const getStatusClass = (status: string) => {
    switch (status) {
      case MODERATION_STATUS.PENDING_REVIEW: return 'lm-badge lm-badge--warning';
      case MODERATION_STATUS.APPROVED:       return 'lm-badge lm-badge--success';
      case MODERATION_STATUS.REJECTED:       return 'lm-badge lm-badge--danger';
      case MODERATION_STATUS.TAKEN_DOWN:     return 'lm-badge lm-badge--neutral';
      default:                               return 'lm-badge lm-badge--neutral';
    }
  };

  return (
    <div className="lm-container">
      <div className="lm-header">
        <h1 className="lm-page-title">Listing Review</h1>
      </div>

      <div className="lm-tabs-container">
        <div className="lm-tabs">
          <button 
            className={`lm-tab-btn ${viewTab === 'system' ? 'active' : ''}`}
            onClick={() => { setViewTab('system'); setSelectedIds(new Set()); }}
          >
            System Queue
            {data?.count !== undefined && <span className="lm-badge-num">{data.count}</span>}
          </button>
          <button 
            className={`lm-tab-btn ${viewTab === 'user' ? 'active' : ''}`}
            onClick={() => { setViewTab('user'); setSelectedIds(new Set()); }}
          >
            User Reports
            {reportsData !== undefined && <span className="lm-badge-num">{reportsData.length}</span>}
          </button>
        </div>
      </div>

      {viewTab === 'system' && (
        <>
          <div className="lm-actions-row" style={{ justifyContent: 'space-between' }}>
            <div className="lm-filters">
              <div className="lm-filter-group" style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--color-bg-primary)', border: '1px solid var(--color-border)', borderRadius: 'var(--radius-md)', padding: '6px 12px', color: 'var(--color-text-tertiary)' }}>
                <Filter size={14} />
                <select 
                  className="lm-filter-select-inline"
                  value={systemStatus} 
                  onChange={(e) => { setSystemStatus(e.target.value); setPage(0); }}
                >
                  <option value="all">All Statuses</option>
                  <option value={MODERATION_STATUS.PENDING_REVIEW}>Pending</option>
                  <option value={MODERATION_STATUS.APPROVED}>Approved</option>
                  <option value={MODERATION_STATUS.REJECTED}>Rejected</option>
                  <option value={MODERATION_STATUS.TAKEN_DOWN}>Taken Down</option>
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
            <div className="lm-state-msg">Loading listings...</div>
          ) : error ? (
            <div className="lm-state-error">Error loading listings.</div>
          ) : (
            <div className="lm-table-wrap">
              <table className="lm-table">
                <thead className="lm-thead">
                  <tr>
                    <th className="lm-th">
                      <input
                        type="checkbox"
                        onChange={(e) => handleSelectAll(e, data?.data.map((l: any) => l.id) || [])}
                        checked={(data?.data?.length ?? 0) > 0 && selectedIds.size === (data?.data?.length ?? 0)}
                      />
                    </th>
                    <th className="lm-th">Title</th>
                    <th className="lm-th">Seller</th>
                    <th className="lm-th">Price</th>
                    <th className="lm-th">Status</th>
                    <th className="lm-th">Priority</th>
                    <th className="lm-th">Submitted</th>
                    <th className="lm-th lm-th--right">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {data?.data.length === 0 ? (
                    <tr>
                      <td colSpan={8} className="lm-td-empty">No listings found in system queue.</td>
                    </tr>
                  ) : (
                    data?.data.map((listing: any) => (
                      <tr 
                        key={listing.id} 
                        className="lm-tr" 
                        onClick={() => navigate(`/moderation/listings/${listing.id}`)}
                        style={{ cursor: 'pointer' }}
                      >
                        <td className="lm-td" onClick={(e) => e.stopPropagation()}>
                          <input
                            type="checkbox"
                            checked={selectedIds.has(listing.id)}
                            onChange={(e) => handleSelectOne(listing.id, e.target.checked)}
                          />
                        </td>
                        <td className="lm-td">
                          <div className="lm-cell-title">{listing.title}</div>
                        </td>
                        <td className="lm-td">
                          <div className="lm-seller-cell">
                            {listing.seller?.avatar_url && (
                              <img className="lm-seller-avatar" src={listing.seller.avatar_url} alt="" />
                            )}
                            <span className="lm-cell-text">{listing.seller?.display_name || 'Unknown'}</span>
                          </div>
                        </td>
                        <td className="lm-td lm-cell-muted">${listing.price}</td>
                        <td className="lm-td">
                          <span className={getStatusClass(listing.moderation_status)}>
                            {listing.moderation_status.replace('_', ' ')}
                          </span>
                        </td>
                        <td className="lm-td">
                          <span className={getPriorityClass(listing.moderation_priority)}>
                            {listing.moderation_priority}
                          </span>
                        </td>
                        <td className="lm-td lm-cell-muted">{new Date(listing.created_at).toLocaleDateString()}</td>
                        <td className="lm-td lm-td--right" onClick={(e) => e.stopPropagation()}>
                          <Link to={`/moderation/listings/${listing.id}`} className="lm-review-link" style={{ display: 'inline-flex', alignItems: 'center' }}>
                            <ChevronRight size={18} />
                          </Link>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          )}

          {data && data.count > DEFAULT_PAGE_SIZE && (
            <div className="lm-pagination">
              <p className="lm-pagination-info">
                Showing <strong>{page * DEFAULT_PAGE_SIZE + 1}</strong> to{' '}
                <strong>{Math.min((page + 1) * DEFAULT_PAGE_SIZE, data.count)}</strong> of{' '}
                <strong>{data.count}</strong> results
              </p>
              <div className="lm-pagination-nav">
                <button
                  onClick={() => setPage(p => Math.max(0, p - 1))}
                  disabled={page === 0}
                  className="lm-page-btn lm-page-btn--left"
                >
                  &larr; Previous
                </button>
                <button
                  onClick={() => setPage(p => p + 1)}
                  disabled={(page + 1) * DEFAULT_PAGE_SIZE >= data.count}
                  className="lm-page-btn lm-page-btn--right"
                >
                  Next &rarr;
                </button>
              </div>
            </div>
          )}
        </>
      )}

      {viewTab === 'user' && (
        <>
          <div className="lm-actions-row" style={{ justifyContent: 'space-between' }}>
            <div className="lm-filters">
              <div className="lm-filter-group" style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--color-bg-primary)', border: '1px solid var(--color-border)', borderRadius: 'var(--radius-md)', padding: '6px 12px', color: 'var(--color-text-tertiary)' }}>
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
              <div className="lm-filter-group" style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--color-bg-primary)', border: '1px solid var(--color-border)', borderRadius: 'var(--radius-md)', padding: '6px 12px', color: 'var(--color-text-tertiary)' }}>
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

          {reportsLoading ? (
            <div className="lm-state-msg">Loading user reports...</div>
          ) : reportsError ? (
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
                      <td colSpan={7} className="lm-td-empty">No listing reports found.</td>
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
                            <span className="lm-cell-muted" style={{fontSize: 11, display: 'block'}}>{report.reported_email}</span>
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


        </>
      )}

      <style>{`
        .lm-container { padding: var(--spacing-page); max-width: 1280px; margin: 0 auto; }
        .lm-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0px; padding-bottom: 16px; }
        .lm-page-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        
        .lm-tabs-container { border-bottom: 1px solid var(--color-border-light); margin-bottom: 24px; padding-bottom: 8px; }
        .lm-tabs { display: flex; gap: 24px; }
        .lm-tab-btn { padding: 8px 0; border: none; background: transparent; color: var(--color-text-secondary); font-size: 15px; font-weight: 600; cursor: pointer; border-bottom: 2px solid transparent; transition: all 0.2s; position: relative; display: flex; align-items: center; gap: 8px; }
        .lm-tab-btn:hover { color: var(--color-text-primary); }
        .lm-tab-btn.active { color: var(--color-text-primary); border-bottom-color: var(--color-primary); }
        .lm-badge-num { background: var(--color-danger); color: white; font-size: 11px; padding: 2px 6px; border-radius: 99px; font-weight: 700; }
        
        .lm-actions-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .lm-filters { display: flex; gap: 12px; }
        .lm-filter-select { border: 1px solid var(--color-border); border-radius: var(--radius-sm); padding: 6px 10px; font-size: 13px; color: var(--color-text-primary); background: var(--color-bg-primary); outline: none; }
        .lm-filter-select:focus { border-color: var(--color-border-focus); }
        .lm-batch-actions { display: flex; gap: 12px; }
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
        .lm-th--right { text-align: right; }
        .clickable-row { cursor: pointer; }
        .lm-tr:hover { background: var(--color-bg-secondary); }
        .lm-td { padding: 14px 20px; font-size: 13px; border-bottom: 1px solid var(--color-border-light); white-space: nowrap; }
        .lm-td--right { text-align: right; }
        .lm-td-empty { padding: 24px; text-align: center; font-size: 13px; color: var(--color-text-secondary); }
        .lm-cell-title { font-weight: 500; color: var(--color-text-primary); max-width: 240px; overflow: hidden; text-overflow: ellipsis; }
        .lm-cell-text { color: var(--color-text-primary); }
        .lm-cell-muted { color: var(--color-text-secondary); }
        .lm-user-info { display: flex; flex-direction: column; gap: 2px; }
        .lm-listing-cell { display: flex; align-items: center; gap: 12px; }
        .lm-listing-thumb { width: 40px; height: 40px; border-radius: 4px; object-fit: cover; }
        .lm-violation-item { font-size: 11px; color: var(--color-danger); margin-bottom: 2px; }
        .lm-seller-cell { display: flex; align-items: center; gap: 8px; }
        .lm-seller-avatar { width: 24px; height: 24px; border-radius: 50%; object-fit: cover; }
        .lm-badge { display: inline-flex; align-items: center; padding: 2px 8px; font-size: 11px; font-weight: 600; border-radius: 999px; white-space: nowrap; }
        .lm-badge--warning { background: var(--color-warning-light); color: var(--color-warning); }
        .lm-badge--success { background: var(--color-success-light); color: var(--color-success); }
        .lm-badge--danger  { background: var(--color-danger-light);  color: var(--color-danger); }
        .lm-badge--info    { background: var(--color-info-light);    color: var(--color-info); }
        .lm-badge--neutral { background: var(--color-bg-tertiary);   color: var(--color-text-secondary); }
        .lm-review-link { color: var(--color-info); font-weight: 500; text-decoration: none; font-size: 13px; }
        .lm-review-link:hover { text-decoration: underline; }
        .lm-pagination { margin-top: 16px; display: flex; align-items: center; justify-content: space-between; background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); padding: 12px 20px; }
        .lm-pagination-info { font-size: 13px; color: var(--color-text-secondary); margin: 0; }
        .lm-pagination-nav { display: flex; gap: 4px; }
        .lm-page-btn { padding: 6px 12px; font-size: 13px; border: 1px solid var(--color-border); background: var(--color-bg-primary); color: var(--color-text-secondary); cursor: pointer; }
        .lm-page-btn--left  { border-radius: var(--radius-sm) 0 0 var(--radius-sm); }
        .lm-page-btn--right { border-radius: 0 var(--radius-sm) var(--radius-sm) 0; }
        .lm-page-btn:hover:not(:disabled) { background: var(--color-bg-secondary); }
        .lm-page-btn:disabled { opacity: 0.5; cursor: not-allowed; }
      `}</style>
    </div>
  );
}
