import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useListingsModeration, useBatchModerateListings } from '@/hooks/useListingModeration';
import { DEFAULT_PAGE_SIZE, MODERATION_STATUS, MODERATION_PRIORITY } from '@/lib/constants';
import type { ModerationStatus } from '@/types';
import { useAuth } from '@/hooks/useAuth'; // Assumed to exist for getting admin ID

export function ListingModerationPage() {
  const [page, setPage] = useState(0);
  const [statusFilter, setStatusFilter] = useState<ModerationStatus | 'all'>('pending_review');
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());

  const { data, isLoading, error } = useListingsModeration(page, { status: statusFilter });
  const batchModerate = useBatchModerateListings();
  const { admin } = useAuth(); // Assume we get the logged in admin user

  const handleSelectAll = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.checked) {
      const allIds = new Set(data?.data.map((l: any) => l.id) || []);
      setSelectedIds(allIds);
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
        <h1 className="lm-page-title">Listing Moderation</h1>
        <div className="lm-header-actions">
          <select
            value={statusFilter}
            onChange={(e) => {
              setStatusFilter(e.target.value as any);
              setPage(0);
              setSelectedIds(new Set());
            }}
            className="lm-filter-select"
          >
            <option value="all">All Statuses</option>
            <option value={MODERATION_STATUS.PENDING_REVIEW}>Pending Review</option>
            <option value={MODERATION_STATUS.APPROVED}>Approved</option>
            <option value={MODERATION_STATUS.REJECTED}>Rejected</option>
            <option value={MODERATION_STATUS.TAKEN_DOWN}>Taken Down</option>
          </select>

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
                    onChange={handleSelectAll}
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
                  <td colSpan={8} className="lm-td-empty">No listings found.</td>
                </tr>
              ) : (
                data?.data.map((listing: any) => (
                  <tr key={listing.id} className="lm-tr">
                    <td className="lm-td">
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
                    <td className="lm-td lm-td--right">
                      <Link to={`/moderation/listings/${listing.id}`} className="lm-review-link">
                        Review
                      </Link>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* Pagination Controls */}
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

      <style>{`
        .lm-container { padding: var(--spacing-page); max-width: 1280px; margin: 0 auto; }
        .lm-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .lm-page-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .lm-header-actions { display: flex; align-items: center; gap: 12px; }
        .lm-filter-select { border: 1px solid var(--color-border); border-radius: var(--radius-sm); padding: 6px 10px; font-size: 13px; color: var(--color-text-primary); background: var(--color-bg-primary); outline: none; }
        .lm-filter-select:focus { border-color: var(--color-border-focus); }
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
        .lm-tr:hover { background: var(--color-bg-secondary); }
        .lm-td { padding: 14px 20px; font-size: 13px; border-bottom: 1px solid var(--color-border-light); white-space: nowrap; }
        .lm-td--right { text-align: right; }
        .lm-td-empty { padding: 24px; text-align: center; font-size: 13px; color: var(--color-text-secondary); }
        .lm-cell-title { font-weight: 500; color: var(--color-text-primary); max-width: 240px; overflow: hidden; text-overflow: ellipsis; }
        .lm-cell-text { color: var(--color-text-primary); }
        .lm-cell-muted { color: var(--color-text-secondary); }
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
