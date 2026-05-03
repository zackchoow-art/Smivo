/**
 * Audit Log page — read-only table of all admin operations.
 * Supports filtering by date range, action type, and target type.
 */
import { useState } from 'react';
import { Search, ChevronLeft, ChevronRight, Filter, Loader2 } from 'lucide-react';
import { format } from 'date-fns';
import { useAuditLogs, type AuditLogFilters } from '@/hooks/useAuditLogs';
import { AuditDetailDialog } from '@/components/audit/AuditDetailDialog';
import { AuditTargetSummary } from '@/components/audit/AuditTargetSummary';
import { DEFAULT_PAGE_SIZE } from '@/lib/constants';
import { translateAction } from '@/lib/audit-translations';
import type { AuditLogWithAdmin } from '@/types';

export function AuditLogPage() {
  const [page, setPage] = useState(0);
  const [selectedLog, setSelectedLog] = useState<AuditLogWithAdmin | null>(null);
  const [showFilters, setShowFilters] = useState(false);
  const [filters, setFilters] = useState<AuditLogFilters>({});
  const [filterDraft, setFilterDraft] = useState<AuditLogFilters>({});

  const { data, isLoading, error } = useAuditLogs({
    page,
    filters,
  });

  const totalPages = Math.ceil((data?.count ?? 0) / DEFAULT_PAGE_SIZE);

  const applyFilters = () => {
    setFilters(filterDraft);
    setPage(0);
    setShowFilters(false);
  };

  const clearFilters = () => {
    setFilterDraft({});
    setFilters({});
    setPage(0);
  };

  return (
    <div className="audit-page">
      <div className="audit-header">
        <div>
          <h1 className="audit-title">Audit Log</h1>
          <p className="audit-subtitle">
            Complete history of all admin operations.{' '}
            {data?.count != null && (
              <span className="tabular-nums">{data.count} total entries</span>
            )}
          </p>
        </div>
        <button
          className={`audit-filter-btn ${showFilters ? 'active' : ''}`}
          onClick={() => setShowFilters(!showFilters)}
        >
          <Filter size={14} />
          Filters
          {Object.values(filters).filter(Boolean).length > 0 && (
            <span className="audit-filter-count">
              {Object.values(filters).filter(Boolean).length}
            </span>
          )}
        </button>
      </div>

      {/* Filter panel */}
      {showFilters && (
        <div className="audit-filters">
          <div className="audit-filter-grid">
            <div className="audit-filter-field">
              <label>Action Type</label>
              <input
                type="text"
                placeholder="e.g. listing_approve"
                value={filterDraft.actionType ?? ''}
                onChange={(e) => setFilterDraft({ ...filterDraft, actionType: e.target.value || undefined })}
              />
            </div>
            <div className="audit-filter-field">
              <label>Target Type</label>
              <input
                type="text"
                placeholder="e.g. listing, user"
                value={filterDraft.targetType ?? ''}
                onChange={(e) => setFilterDraft({ ...filterDraft, targetType: e.target.value || undefined })}
              />
            </div>
            <div className="audit-filter-field">
              <label>Date From</label>
              <input
                type="date"
                value={filterDraft.dateFrom ?? ''}
                onChange={(e) => setFilterDraft({ ...filterDraft, dateFrom: e.target.value || undefined })}
              />
            </div>
            <div className="audit-filter-field">
              <label>Date To</label>
              <input
                type="date"
                value={filterDraft.dateTo ?? ''}
                onChange={(e) => setFilterDraft({ ...filterDraft, dateTo: e.target.value || undefined })}
              />
            </div>
          </div>
          <div className="audit-filter-actions">
            <button className="audit-btn-secondary" onClick={clearFilters}>
              Clear
            </button>
            <button className="audit-btn-primary" onClick={applyFilters}>
              <Search size={14} />
              Apply
            </button>
          </div>
        </div>
      )}

      {/* Table */}
      {isLoading ? (
        <div className="audit-loading">
          <Loader2 size={24} className="spin" />
          <span>Loading audit logs...</span>
        </div>
      ) : error ? (
        <div className="audit-error">
          Failed to load: {(error as Error).message}
        </div>
      ) : (
        <>
          <div className="audit-table-wrap">
            <table className="audit-table">
              <thead>
                <tr>
                  <th>Time</th>
                  <th>Admin</th>
                  <th>Action</th>
                  <th>Target</th>
                  <th>Status Change</th>
                </tr>
              </thead>
              <tbody>
                {data?.data.map((log) => (
                  <tr
                    key={log.id}
                    className="audit-row"
                    onClick={() => setSelectedLog(log)}
                  >
                    <td className="tabular-nums">
                      {format(new Date(log.created_at), 'MM-dd HH:mm')}
                    </td>
                    <td>
                      <div className="audit-admin-cell">
                        {log.admin_avatar ? (
                          <img src={log.admin_avatar} alt="Admin" className="audit-admin-avatar" />
                        ) : (
                          <div className="audit-admin-avatar-placeholder">
                            {log.admin_name ? log.admin_name.charAt(0).toUpperCase() : 'A'}
                          </div>
                        )}
                        <div className="audit-admin-info">
                          <span className="audit-admin-name">{log.admin_name || 'System Admin'}</span>
                          <code className="audit-id">{log.admin_id.slice(0, 8)}</code>
                        </div>
                      </div>
                    </td>
                    <td>
                      <span className="audit-action-chip">{translateAction(log.action)}</span>
                    </td>
                    <td>
                      <AuditTargetSummary 
                        targetType={log.target_type} 
                        targetId={log.target_id} 
                        payload={log.payload} 
                      />
                    </td>
                    <td>
                      {log.status_before || log.status_after ? (
                        <span className="audit-status-text">
                          {log.status_before ?? '—'} → {log.status_after ?? '—'}
                        </span>
                      ) : (
                        <span className="audit-no-change">—</span>
                      )}
                    </td>
                  </tr>
                ))}
                {data?.data.length === 0 && (
                  <tr>
                    <td colSpan={5} className="audit-empty">
                      No audit log entries found.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="audit-pagination">
              <button
                className="audit-page-btn"
                disabled={page === 0}
                onClick={() => setPage(page - 1)}
              >
                <ChevronLeft size={16} />
              </button>
              <span className="audit-page-info tabular-nums">
                Page {page + 1} of {totalPages}
              </span>
              <button
                className="audit-page-btn"
                disabled={page >= totalPages - 1}
                onClick={() => setPage(page + 1)}
              >
                <ChevronRight size={16} />
              </button>
            </div>
          )}
        </>
      )}

      {/* Detail modal */}
      <AuditDetailDialog
        log={selectedLog}
        onClose={() => setSelectedLog(null)}
      />

      <style>{`
        .audit-page {
          padding: var(--spacing-page);
        }

        .audit-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          margin-bottom: 20px;
        }

        .audit-title {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .audit-subtitle {
          font-size: 13px;
          color: var(--color-text-tertiary);
          margin-top: 4px;
        }

        .audit-filter-btn {
          display: flex;
          align-items: center;
          gap: 6px;
          padding: 8px 14px;
          font-size: 13px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          color: var(--color-text-secondary);
          cursor: pointer;
          transition: all 0.15s ease;
        }

        .audit-filter-btn:hover,
        .audit-filter-btn.active {
          border-color: var(--color-info);
          color: var(--color-info);
        }

        .audit-filter-count {
          background: var(--color-info);
          color: white;
          font-size: 10px;
          padding: 1px 5px;
          border-radius: 8px;
          font-weight: 600;
        }

        .audit-filters {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg);
          padding: 16px;
          margin-bottom: 16px;
        }

        .audit-filter-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
          gap: 12px;
          margin-bottom: 12px;
        }

        .audit-filter-field {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .audit-filter-field label {
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.04em;
          color: var(--color-text-tertiary);
        }

        .audit-filter-field input {
          padding: 6px 10px;
          font-size: 13px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-sm);
          background: var(--color-bg-secondary);
          color: var(--color-text-primary);
          outline: none;
        }

        .audit-filter-field input:focus {
          border-color: var(--color-border-focus);
        }

        .audit-filter-actions {
          display: flex;
          justify-content: flex-end;
          gap: 8px;
        }

        .audit-btn-primary,
        .audit-btn-secondary {
          display: flex;
          align-items: center;
          gap: 4px;
          padding: 6px 14px;
          font-size: 13px;
          border-radius: var(--radius-md);
          cursor: pointer;
          border: 1px solid var(--color-border);
        }

        .audit-btn-primary {
          background: var(--color-info);
          color: white;
          border-color: var(--color-info);
        }

        .audit-btn-secondary {
          background: var(--color-bg-primary);
          color: var(--color-text-secondary);
        }

        .audit-table-wrap {
          overflow-x: auto;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg);
        }

        .audit-table {
          width: 100%;
          border-collapse: collapse;
          font-size: 13px;
        }

        .audit-table th {
          text-align: left;
          padding: 10px 14px;
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.04em;
          color: var(--color-text-tertiary);
          border-bottom: 1px solid var(--color-border-light);
          background: var(--color-bg-secondary);
        }

        .audit-table td {
          padding: 10px 14px;
          color: var(--color-text-secondary);
          border-bottom: 1px solid var(--color-border-light);
        }

        .audit-row {
          cursor: pointer;
          transition: background 0.1s ease;
        }

        .audit-row:hover {
          background: var(--color-bg-secondary);
        }

        .audit-id {
          font-family: var(--font-mono);
          font-size: 12px;
          background: var(--color-bg-tertiary);
          padding: 2px 6px;
          border-radius: var(--radius-sm);
        }

        .audit-action-chip {
          font-size: 12px;
          font-weight: 500;
          padding: 2px 8px;
          background: var(--color-info-light);
          color: var(--color-info);
          border-radius: var(--radius-sm);
          font-family: var(--font-mono);
        }

        .audit-target-type {
          font-size: 12px;
          color: var(--color-text-primary);
          font-weight: 500;
        }

        .audit-status-text {
          font-size: 12px;
          font-family: var(--font-mono);
          color: var(--color-text-tertiary);
        }

        .audit-no-change {
          color: var(--color-text-tertiary);
        }

        .audit-empty {
          text-align: center;
          padding: 40px 0 !important;
          color: var(--color-text-tertiary);
        }

        .audit-pagination {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 12px;
          padding: 16px 0;
        }

        .audit-page-btn {
          display: flex;
          align-items: center;
          padding: 6px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-sm);
          cursor: pointer;
          color: var(--color-text-secondary);
        }

        .audit-page-btn:disabled {
          opacity: 0.3;
          cursor: not-allowed;
        }

        .audit-page-info {
          font-size: 13px;
          color: var(--color-text-tertiary);
        }

        .audit-loading, .audit-error {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
          padding: 60px 0;
          color: var(--color-text-tertiary);
          font-size: 14px;
        }

        .audit-error {
          color: var(--color-danger);
        }

        .spin {
          animation: spin 1s linear infinite;
        }

        @keyframes spin {
          to { transform: rotate(360deg); }
        }

        /* Admin Cell Styles */
        .audit-admin-cell {
          display: flex;
          align-items: center;
          gap: 10px;
        }
        .audit-admin-avatar {
          width: 28px;
          height: 28px;
          border-radius: 50%;
          object-fit: cover;
          border: 1px solid var(--color-border);
        }
        .audit-admin-avatar-placeholder {
          width: 28px;
          height: 28px;
          border-radius: 50%;
          background: var(--color-info);
          color: white;
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: bold;
          font-size: 12px;
        }
        .audit-admin-info {
          display: flex;
          flex-direction: column;
          gap: 2px;
        }
        .audit-admin-name {
          font-weight: 600;
          color: var(--color-text-primary);
          font-size: 13px;
        }

        /* Target Card Styles */
        .audit-target-card {
          display: flex;
          align-items: center;
          gap: 10px;
          max-width: 250px;
        }
        .target-icon {
          width: 28px;
          height: 28px;
          border-radius: var(--radius-sm);
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
          flex-shrink: 0;
        }
        .target-avatar, .target-thumb {
          width: 28px;
          height: 28px;
          border-radius: var(--radius-sm);
          object-fit: cover;
          border: 1px solid var(--color-border);
          flex-shrink: 0;
        }
        .target-avatar {
          border-radius: 50%;
        }
        .target-info {
          display: flex;
          flex-direction: column;
          min-width: 0;
        }
        .target-type {
          font-size: 10px;
          font-weight: 700;
          color: var(--color-text-tertiary);
          text-transform: uppercase;
        }
        .target-title {
          font-weight: 500;
          color: var(--color-text-primary);
          font-size: 13px;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
        .target-subtitle {
          font-size: 11px;
          color: var(--color-text-tertiary);
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
        .bg-info { background: var(--color-info); }
        .bg-success { background: var(--color-success); }
        .bg-danger { background: var(--color-danger); }
        .bg-warning { background: var(--color-warning); color: #000; }
        .bg-gray { background: var(--color-text-tertiary); }
        .text-muted { color: var(--color-text-tertiary); }
        .truncate { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .animate-pulse { animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite; }
        @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: .5; }
        }
      `}</style>
    </div>
  );
}
