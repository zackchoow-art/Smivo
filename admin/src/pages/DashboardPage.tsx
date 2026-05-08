import { useNavigate } from 'react-router-dom';
import {
  Users, Package, ShoppingCart, Activity,
  ShieldAlert, AlertTriangle, MessageSquareWarning,
  Clock, History, ChevronRight, FileWarning,
} from 'lucide-react';
import { useDashboard } from '@/hooks/useDashboard';
import { translateAction } from '@/lib/audit-translations';
import { formatDistanceToNow } from 'date-fns';

export function DashboardPage() {
  const navigate = useNavigate();
  const { data, isLoading, error } = useDashboard();

  if (isLoading) return <div className="dash-state">Loading dashboard...</div>;
  if (error) return <div className="dash-state dash-state--error">Error loading dashboard stats</div>;

  const { stats, recentLogs, urgentListings, urgentReports } = data!;

  const totalUrgent = stats.pendingReportCount + stats.pendingModerationCount + stats.pendingFeedbackCount;

  return (
    <div className="dash">
      <header className="dash-header">
        <div>
          <h1 className="dash-title">Dashboard</h1>
          <p className="dash-subtitle">Things that need your attention right now</p>
        </div>
        {totalUrgent > 0 && (
          <div className="dash-alert-badge">
            <AlertTriangle size={16} />
            <span>{totalUrgent} pending review{totalUrgent !== 1 ? 's' : ''}</span>
          </div>
        )}
      </header>

      {/* ── Action Required Section ── */}
      {totalUrgent > 0 && (
        <section className="dash-urgent-section">
          <h2 className="dash-section-title"><Clock size={16} /> Action Required</h2>
          <div className="dash-urgent-grid">
            {stats.pendingModerationCount > 0 && (
              <div className="urgent-card urgent-card--danger" onClick={() => navigate('/moderation/listings')}>
                <div className="urgent-card-icon"><ShieldAlert size={24} /></div>
                <div className="urgent-card-content">
                  <span className="urgent-card-count">{stats.pendingModerationCount}</span>
                  <span className="urgent-card-label">Listings Pending Review</span>
                </div>
                <ChevronRight size={18} className="urgent-card-arrow" />
              </div>
            )}
            {stats.pendingReportCount > 0 && (
              <div className="urgent-card urgent-card--warning" onClick={() => navigate('/moderation/chat-reports')}>
                <div className="urgent-card-icon"><MessageSquareWarning size={24} /></div>
                <div className="urgent-card-content">
                  <span className="urgent-card-count">{stats.pendingReportCount}</span>
                  <span className="urgent-card-label">Chat Reports Pending</span>
                </div>
                <ChevronRight size={18} className="urgent-card-arrow" />
              </div>
            )}
            {stats.pendingFeedbackCount > 0 && (
              <div className="urgent-card urgent-card--info" onClick={() => navigate('/feedback')}>
                <div className="urgent-card-icon"><FileWarning size={24} /></div>
                <div className="urgent-card-content">
                  <span className="urgent-card-count">{stats.pendingFeedbackCount}</span>
                  <span className="urgent-card-label">User Feedback to Review</span>
                </div>
                <ChevronRight size={18} className="urgent-card-arrow" />
              </div>
            )}
          </div>
        </section>
      )}

      {/* ── KPI Grid ── */}
      <div className="dash-stats-grid">
        <StatCard icon={<Users size={20} />} label="Total Users" value={stats.userCount} color="var(--color-info)" />
        <StatCard icon={<Package size={20} />} label="Total Listings" value={stats.listingCount} color="var(--color-success)" />
        <StatCard icon={<ShoppingCart size={20} />} label="Active Orders" value={stats.activeOrderCount} color="var(--color-warning)" />
        <StatCard icon={<Activity size={20} />} label="DAU (24h)" value={stats.activeUsers.dau} color="var(--color-danger)" />
        <StatCard icon={<Activity size={20} />} label="WAU (7d)" value={stats.activeUsers.wau} color="#8884d8" />
        <StatCard icon={<Activity size={20} />} label="MAU (30d)" value={stats.activeUsers.mau} color="#FF8042" />
      </div>

      {/* ── Two Column Detail ── */}
      <div className="dash-detail-grid">
        {/* Urgent Items */}
        <section className="dash-card">
          <div className="dash-card-header">
            <ShieldAlert size={16} />
            <h2>Oldest Pending Reviews</h2>
          </div>
          <div className="dash-card-body">
            {urgentListings.length === 0 && urgentReports.length === 0 ? (
              <div className="dash-empty">
                <span className="dash-empty-icon">✅</span>
                All caught up! No pending reviews.
              </div>
            ) : (
              <>
                {urgentListings.map((listing) => (
                  <div
                    key={listing.id}
                    className="dash-item"
                    onClick={() => navigate(`/moderation/listings/${listing.id}`)}
                  >
                    <div className="dash-item-info">
                      <span className="dash-item-badge dash-item-badge--listing">Listing</span>
                      <span className="dash-item-title">{listing.title}</span>
                    </div>
                    <div className="dash-item-meta">
                      <span className="dash-item-time">
                        {formatDistanceToNow(new Date(listing.created_at), { addSuffix: true })}
                      </span>
                      <span className="dash-item-price">${listing.price}</span>
                    </div>
                  </div>
                ))}
                {urgentReports.map((report: any) => (
                  <div
                    key={report.id}
                    className="dash-item"
                    onClick={() => navigate(`/moderation/chat-reports/${report.id}`)}
                  >
                    <div className="dash-item-info">
                      <span className="dash-item-badge dash-item-badge--report">Report</span>
                      <span className="dash-item-title">
                        {report.reporter?.display_name || 'User'} reported {report.reported?.display_name || 'User'}
                      </span>
                    </div>
                    <div className="dash-item-meta">
                      <span className="dash-item-time">
                        {formatDistanceToNow(new Date(report.created_at), { addSuffix: true })}
                      </span>
                    </div>
                  </div>
                ))}
              </>
            )}
          </div>
        </section>

        {/* Recent Activity Log */}
        <section className="dash-card">
          <div className="dash-card-header">
            <History size={16} />
            <h2>Recent Admin Activity</h2>
          </div>
          <div className="dash-card-body">
            {recentLogs.length === 0 ? (
              <div className="dash-empty">No recent activities</div>
            ) : (
              recentLogs.map((log) => (
                <div key={log.id} className="dash-log-item">
                  <div className="dash-log-text">{translateAction(log.action)}</div>
                  <span className="dash-log-time">
                    {formatDistanceToNow(new Date(log.created_at), { addSuffix: true })}
                  </span>
                </div>
              ))
            )}
          </div>
        </section>
      </div>

      <style>{`
        .dash {
          padding: 24px;
          max-width: 1200px;
          margin: 0 auto;
          display: flex;
          flex-direction: column;
          gap: 24px;
        }

        .dash-state {
          display: flex; align-items: center; justify-content: center;
          padding: 80px; color: var(--color-text-tertiary); font-size: 15px;
        }
        .dash-state--error { color: var(--color-danger); }

        .dash-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
        }

        .dash-title {
          font-size: 26px;
          font-weight: 700;
          color: var(--color-text-primary);
          margin-bottom: 4px;
        }

        .dash-subtitle {
          font-size: 14px;
          color: var(--color-text-tertiary);
        }

        .dash-alert-badge {
          display: flex;
          align-items: center;
          gap: 6px;
          padding: 8px 16px;
          background: var(--color-danger);
          color: white;
          border-radius: var(--radius-md);
          font-size: 13px;
          font-weight: 600;
          animation: pulse-badge 2s ease-in-out infinite;
        }

        @keyframes pulse-badge {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.8; }
        }

        /* ── Action Required ── */
        .dash-urgent-section {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-danger);
          border-radius: var(--radius-lg);
          padding: 20px;
        }

        .dash-section-title {
          display: flex;
          align-items: center;
          gap: 8px;
          font-size: 14px;
          font-weight: 600;
          color: var(--color-danger);
          margin-bottom: 16px;
          text-transform: uppercase;
          letter-spacing: 0.04em;
        }

        .dash-urgent-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
          gap: 12px;
        }

        .urgent-card {
          display: flex;
          align-items: center;
          gap: 14px;
          padding: 16px;
          border-radius: var(--radius-md);
          cursor: pointer;
          transition: transform 0.15s, box-shadow 0.15s;
          border: 1px solid transparent;
        }

        .urgent-card:hover {
          transform: translateY(-2px);
          box-shadow: var(--shadow-card);
        }

        .urgent-card--danger {
          background: #fef2f2;
          border-color: #fecaca;
          color: #991b1b;
        }

        .urgent-card--warning {
          background: #fffbeb;
          border-color: #fde68a;
          color: #92400e;
        }

        .urgent-card--info {
          background: #eff6ff;
          border-color: #bfdbfe;
          color: #1e40af;
        }

        .urgent-card-icon {
          flex-shrink: 0;
          opacity: 0.7;
        }

        .urgent-card-content {
          flex: 1;
          display: flex;
          flex-direction: column;
        }

        .urgent-card-count {
          font-size: 28px;
          font-weight: 700;
          line-height: 1;
        }

        .urgent-card-label {
          font-size: 12px;
          font-weight: 500;
          margin-top: 4px;
          opacity: 0.8;
        }

        .urgent-card-arrow {
          opacity: 0.4;
        }

        /* ── KPI Stats ── */
        .dash-stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
          gap: 16px;
        }

        .stat-card {
          background: var(--color-bg-primary);
          padding: 20px;
          border-radius: var(--radius-md);
          border: 1px solid var(--color-border-subtle);
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .stat-icon {
          width: 44px;
          height: 44px;
          border-radius: var(--radius-sm);
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
        }

        .stat-content {
          display: flex;
          flex-direction: column;
        }

        .stat-label {
          font-size: 13px;
          color: var(--color-text-tertiary);
          margin-bottom: 2px;
        }

        .stat-value {
          font-size: 22px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        /* ── Detail Grid ── */
        .dash-detail-grid {
          display: grid;
          grid-template-columns: 1.4fr 1fr;
          gap: 24px;
        }

        @media (max-width: 900px) {
          .dash-detail-grid { grid-template-columns: 1fr; }
        }

        .dash-card {
          background: var(--color-bg-primary);
          border-radius: var(--radius-md);
          border: 1px solid var(--color-border-subtle);
          overflow: hidden;
        }

        .dash-card-header {
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 16px 20px;
          border-bottom: 1px solid var(--color-border-subtle);
          color: var(--color-text-secondary);
        }

        .dash-card-header h2 {
          font-size: 14px;
          font-weight: 600;
          color: var(--color-text-primary);
        }

        .dash-card-body {
          max-height: 400px;
          overflow-y: auto;
        }

        .dash-empty {
          padding: 40px 20px;
          text-align: center;
          color: var(--color-text-tertiary);
          font-size: 13px;
        }

        .dash-empty-icon {
          display: block;
          font-size: 24px;
          margin-bottom: 8px;
        }

        /* ── Urgent Items ── */
        .dash-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 14px 20px;
          border-bottom: 1px solid var(--color-border-subtle);
          cursor: pointer;
          transition: background 0.1s;
        }

        .dash-item:hover {
          background: var(--color-bg-secondary);
        }

        .dash-item:last-child {
          border-bottom: none;
        }

        .dash-item-info {
          display: flex;
          align-items: center;
          gap: 10px;
        }

        .dash-item-badge {
          font-size: 10px;
          font-weight: 600;
          padding: 2px 8px;
          border-radius: 4px;
          text-transform: uppercase;
          letter-spacing: 0.03em;
        }

        .dash-item-badge--listing {
          background: #fef3c7;
          color: #d97706;
        }

        .dash-item-badge--report {
          background: #fce7f3;
          color: #be185d;
        }

        .dash-item-title {
          font-size: 13px;
          font-weight: 500;
          color: var(--color-text-primary);
        }

        .dash-item-meta {
          display: flex;
          align-items: center;
          gap: 12px;
          flex-shrink: 0;
        }

        .dash-item-time {
          font-size: 11px;
          color: var(--color-text-tertiary);
        }

        .dash-item-price {
          font-size: 13px;
          font-weight: 600;
          color: var(--color-success);
        }

        /* ── Log Items ── */
        .dash-log-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 12px 20px;
          border-bottom: 1px solid var(--color-border-subtle);
        }

        .dash-log-item:last-child {
          border-bottom: none;
        }

        .dash-log-text {
          font-size: 13px;
          color: var(--color-text-primary);
          font-weight: 500;
        }

        .dash-log-time {
          font-size: 11px;
          color: var(--color-text-tertiary);
          flex-shrink: 0;
          margin-left: 12px;
        }
      `}</style>
    </div>
  );
}

function StatCard({ icon, label, value, color }: { icon: React.ReactNode, label: string, value: number, color: string }) {
  return (
    <div className="stat-card">
      <div className="stat-icon" style={{ backgroundColor: color }}>
        {icon}
      </div>
      <div className="stat-content">
        <span className="stat-label">{label}</span>
        <span className="stat-value">{value.toLocaleString()}</span>
      </div>
    </div>
  );
}
