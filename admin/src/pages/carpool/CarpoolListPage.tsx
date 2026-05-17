/**
 * Carpool trip list page — admin management of all carpool trips.
 * Supports filtering by status, role, date range, and search.
 */
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, ChevronLeft, ChevronRight, Car, Users } from 'lucide-react';
import { useCarpoolList } from '@/hooks/useCarpool';
import { useSchoolScopeStore } from '@/stores/school-scope-store';
import { DEFAULT_PAGE_SIZE } from '@/lib/constants';
import { CARPOOL_STATUS_META } from '@/types';
import type { CarpoolTripStatus, CarpoolTrip } from '@/types';

export function CarpoolListPage() {
  const navigate = useNavigate();
  const currentCollegeId = useSchoolScopeStore((state) => state.currentCollegeId);
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState<CarpoolTripStatus | ''>('');
  const [role, setRole] = useState<'driver' | 'organizer' | ''>('');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');

  const { data, isLoading, error } = useCarpoolList(page, {
    status,
    role,
    search,
    schoolId: currentCollegeId || undefined,
    dateFrom: dateFrom || undefined,
    dateTo: dateTo || undefined,
  });

  const totalPages = data ? Math.ceil(data.totalCount / DEFAULT_PAGE_SIZE) : 0;

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(0);
  };

  const formatRoute = (trip: CarpoolTrip) => {
    const from = trip.departure_description || trip.departure_address.slice(0, 20);
    const to = trip.destination_description || trip.destination_address.slice(0, 20);
    return `${from} → ${to}`;
  };

  return (
    <div className="cp-list-container">
      <header className="cp-list-header">
        <div>
          <h1 className="page-title">Carpool Trips</h1>
          <p className="page-subtitle">Manage all carpool trip postings across schools</p>
        </div>
        <button
          className="analytics-btn"
          onClick={() => navigate('/carpool/analytics')}
        >
          📊 Analytics
        </button>
      </header>

      {/* Filters */}
      <div className="cp-filters">
        <div className="filter-group">
          <label>Status</label>
          <select value={status} onChange={(e) => { setStatus(e.target.value as CarpoolTripStatus | ''); setPage(0); }}>
            <option value="">All Statuses</option>
            <option value="active">Active</option>
            <option value="inactive">Full</option>
            <option value="confirmed">Confirmed</option>
            <option value="departed">Departed</option>
            <option value="arrived">Arrived</option>
            <option value="completed">Completed</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>
        <div className="filter-group">
          <label>Role</label>
          <select value={role} onChange={(e) => { setRole(e.target.value as 'driver' | 'organizer' | ''); setPage(0); }}>
            <option value="">All Roles</option>
            <option value="driver">Driver</option>
            <option value="organizer">Organizer</option>
          </select>
        </div>
        <div className="filter-group">
          <label>From</label>
          <input type="date" value={dateFrom} onChange={(e) => { setDateFrom(e.target.value); setPage(0); }} />
        </div>
        <div className="filter-group">
          <label>To</label>
          <input type="date" value={dateTo} onChange={(e) => { setDateTo(e.target.value); setPage(0); }} />
        </div>
        <form className="search-box" onSubmit={handleSearch}>
          <Search size={18} />
          <input
            type="text"
            placeholder="Search by location..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </form>
      </div>

      {/* Table */}
      <div className="cp-table-wrapper">
        <table className="cp-table">
          <thead>
            <tr>
              <th>Route</th>
              <th>Organizer</th>
              <th>Role</th>
              <th>Departure</th>
              <th>Seats</th>
              <th>Price</th>
              <th>Status</th>
              <th>Created</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan={8} className="table-loading">Loading trips...</td></tr>
            ) : error ? (
              <tr><td colSpan={8} className="table-error">Error loading trips</td></tr>
            ) : data?.data.length === 0 ? (
              <tr><td colSpan={8} className="table-empty">No trips found</td></tr>
            ) : (
              data?.data.map((trip) => {
                const meta = CARPOOL_STATUS_META[trip.status];
                return (
                  <tr key={trip.id} onClick={() => navigate(`/carpool/${trip.id}`)} className="clickable-row">
                    <td>
                      <div className="route-cell">
                        <span className="route-text">{formatRoute(trip)}</span>
                        {trip.school?.name && (
                          <span className="school-tag">{trip.school.name}</span>
                        )}
                      </div>
                    </td>
                    <td>
                      <div className="user-cell">
                        {trip.creator?.avatar_url ? (
                          <img src={trip.creator.avatar_url} alt="" className="user-avatar" />
                        ) : (
                          <div className="user-avatar-placeholder"><Users size={14} /></div>
                        )}
                        <span>{trip.creator?.display_name || 'Unknown'}</span>
                      </div>
                    </td>
                    <td>
                      <span className={`role-badge role-badge--${trip.role}`}>
                        {trip.role === 'driver' ? <><Car size={12} /> Driver</> : <><Users size={12} /> Organizer</>}
                      </span>
                    </td>
                    <td>
                      <span className="time-cell">
                        {new Date(trip.departure_time).toLocaleString('en-US', {
                          month: 'short', day: 'numeric',
                          hour: '2-digit', minute: '2-digit',
                        })}
                      </span>
                    </td>
                    <td>
                      <span className="seats-cell">
                        {trip.total_seats - trip.available_seats}/{trip.total_seats}
                      </span>
                    </td>
                    <td>
                      <span className="price-cell">
                        {trip.estimated_total_price != null ? `$${trip.estimated_total_price.toFixed(2)}` : '—'}
                      </span>
                    </td>
                    <td>
                      <span className="status-badge" style={{ backgroundColor: meta.bgColor, color: meta.color }}>
                        {meta.label}
                      </span>
                    </td>
                    <td>
                      <span className="time-cell">{new Date(trip.created_at).toLocaleDateString()}</span>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <footer className="cp-footer">
        <span className="pagination-info">
          Showing {data ? page * DEFAULT_PAGE_SIZE + 1 : 0} - {Math.min((page + 1) * DEFAULT_PAGE_SIZE, data?.totalCount || 0)} of {data?.totalCount || 0}
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
        .cp-list-container {
          padding: 24px;
          display: flex;
          flex-direction: column;
          gap: 20px;
        }

        .cp-list-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
        }

        .page-title {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .page-subtitle {
          font-size: 14px;
          color: var(--color-text-tertiary);
          margin-top: 2px;
        }

        .analytics-btn {
          display: flex;
          align-items: center;
          gap: 6px;
          padding: 8px 16px;
          background: var(--color-info);
          color: white;
          border: none;
          border-radius: var(--radius-md);
          font-size: 13px;
          font-weight: 600;
          cursor: pointer;
          transition: opacity 0.2s;
        }

        .analytics-btn:hover {
          opacity: 0.85;
        }

        .cp-filters {
          display: flex;
          flex-wrap: wrap;
          gap: 12px;
          align-items: flex-end;
        }

        .filter-group {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .filter-group label {
          font-size: 11px;
          font-weight: 600;
          color: var(--color-text-tertiary);
          text-transform: uppercase;
        }

        .filter-group select,
        .filter-group input[type="date"] {
          padding: 7px 10px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-sm);
          background: var(--color-bg-primary);
          color: var(--color-text-primary);
          font-size: 13px;
          outline: none;
          cursor: pointer;
        }

        .filter-group select:focus,
        .filter-group input:focus {
          border-color: var(--color-info);
        }

        .search-box {
          display: flex;
          align-items: center;
          gap: 8px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-sm);
          padding: 7px 12px;
          min-width: 220px;
          color: var(--color-text-tertiary);
        }

        .search-box:focus-within {
          border-color: var(--color-info);
        }

        .search-box input {
          border: none;
          background: transparent;
          font-size: 13px;
          color: var(--color-text-primary);
          width: 100%;
          outline: none;
        }

        .cp-table-wrapper {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          overflow: hidden;
        }

        .cp-table {
          width: 100%;
          border-collapse: collapse;
          text-align: left;
        }

        .cp-table th {
          background: var(--color-bg-secondary);
          padding: 10px 16px;
          font-size: 11px;
          font-weight: 600;
          color: var(--color-text-secondary);
          text-transform: uppercase;
          letter-spacing: 0.04em;
        }

        .cp-table td {
          padding: 14px 16px;
          border-bottom: 1px solid var(--color-border-light);
          font-size: 13px;
        }

        .clickable-row {
          cursor: pointer;
          transition: background-color 0.15s;
        }

        .clickable-row:hover {
          background-color: var(--color-bg-tertiary);
        }

        .route-cell {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .route-text {
          font-weight: 500;
          color: var(--color-text-primary);
        }

        .school-tag {
          font-size: 11px;
          color: var(--color-text-tertiary);
        }

        .user-cell {
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .user-avatar, .user-avatar-placeholder {
          width: 28px;
          height: 28px;
          border-radius: 50%;
          object-fit: cover;
          background: var(--color-bg-tertiary);
          display: flex;
          align-items: center;
          justify-content: center;
          color: var(--color-text-tertiary);
          flex-shrink: 0;
        }

        .role-badge {
          display: inline-flex;
          align-items: center;
          gap: 4px;
          padding: 2px 8px;
          border-radius: 10px;
          font-size: 11px;
          font-weight: 600;
        }

        .role-badge--driver {
          background: #dbeafe;
          color: #2563eb;
        }

        .role-badge--organizer {
          background: #fef3c7;
          color: #d97706;
        }

        .seats-cell {
          font-family: var(--font-mono);
          font-size: 13px;
        }

        .price-cell {
          font-family: var(--font-mono);
          font-size: 13px;
          color: var(--color-text-secondary);
        }

        .status-badge {
          display: inline-flex;
          padding: 2px 10px;
          border-radius: 10px;
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
        }

        .time-cell {
          font-size: 12px;
          color: var(--color-text-tertiary);
        }

        .table-loading, .table-error, .table-empty {
          text-align: center;
          padding: 48px;
          color: var(--color-text-tertiary);
        }

        .cp-footer {
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
          border: 1px solid var(--color-border);
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
        }
      `}</style>
    </div>
  );
}
