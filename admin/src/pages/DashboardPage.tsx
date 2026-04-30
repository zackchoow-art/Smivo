import { Users, Package, ShoppingCart, Activity, ShieldAlert, History } from 'lucide-react';
import { useDashboard } from '@/hooks/useDashboard';

export function DashboardPage() {
  const { data, isLoading, error } = useDashboard();

  if (isLoading) return <div className="loading-state">Loading dashboard...</div>;
  if (error) return <div className="error-state">Error loading dashboard stats</div>;

  const { stats, recentLogs, pendingListings } = data!;

  return (
    <div className="dashboard-container">
      <header className="dashboard-header">
        <h1 className="page-title">Dashboard Overview</h1>
        <p className="page-subtitle">Real-time health of the Smivo marketplace</p>
      </header>

      {/* KPI Grid */}
      <div className="stats-grid">
        <StatCard 
          icon={<Users size={20} />} 
          label="Total Users" 
          value={stats.userCount} 
          color="var(--color-info)" 
        />
        <StatCard 
          icon={<Package size={20} />} 
          label="Total Listings" 
          value={stats.listingCount} 
          color="var(--color-success)" 
        />
        <StatCard 
          icon={<ShoppingCart size={20} />} 
          label="Active Orders" 
          value={stats.activeOrderCount} 
          color="var(--color-warning)" 
        />
        <StatCard 
          icon={<Activity size={20} />} 
          label="Today DAU" 
          value={stats.todayDau} 
          color="var(--color-danger)" 
        />
      </div>

      <div className="dashboard-main">
        {/* Audit Logs */}
        <section className="dashboard-section">
          <div className="section-header">
            <History size={18} />
            <h2>Recent Audit Logs</h2>
          </div>
          <div className="logs-list">
            {recentLogs.length === 0 ? (
              <p className="empty-hint">No recent activities</p>
            ) : (
              recentLogs.map((log) => (
                <div key={log.id} className="log-item">
                  <div className="log-info">
                    <span className="log-action">{log.action_type}</span>
                    <span className="log-target">{log.target_type} {log.target_id?.slice(0, 8)}</span>
                  </div>
                  <span className="log-time">{new Date(log.created_at).toLocaleString()}</span>
                </div>
              ))
            )}
          </div>
        </section>

        {/* Pending Moderation */}
        <section className="dashboard-section">
          <div className="section-header">
            <ShieldAlert size={18} />
            <h2>Pending Listings</h2>
          </div>
          <div className="listings-list">
            {pendingListings.length === 0 ? (
              <p className="empty-hint">All caught up! No pending reviews.</p>
            ) : (
              pendingListings.map((listing) => (
                <div key={listing.id} className="listing-item">
                  <div className="listing-info">
                    <span className="listing-title">{listing.title}</span>
                    <span className="listing-price">${listing.price}</span>
                  </div>
                  <span className="listing-time">{new Date(listing.created_at).toLocaleDateString()}</span>
                </div>
              ))
            )}
          </div>
        </section>
      </div>

      <style>{`
        .dashboard-container {
          padding: 24px;
          max-width: 1200px;
          margin: 0 auto;
        }

        .dashboard-header {
          margin-bottom: 32px;
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

        .stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
          gap: 20px;
          margin-bottom: 32px;
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
          margin-bottom: 4px;
        }

        .stat-value {
          font-size: 20px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .dashboard-main {
          display: grid;
          grid-template-columns: 1.5fr 1fr;
          gap: 24px;
        }

        .dashboard-section {
          background: var(--color-bg-primary);
          border-radius: var(--radius-md);
          border: 1px solid var(--color-border-subtle);
          padding: 20px;
        }

        .section-header {
          display: flex;
          align-items: center;
          gap: 8px;
          margin-bottom: 16px;
          color: var(--color-text-secondary);
        }

        .section-header h2 {
          font-size: 16px;
          font-weight: 600;
          color: var(--color-text-primary);
        }

        .log-item, .listing-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 12px 0;
          border-bottom: 1px solid var(--color-border-subtle);
        }

        .log-item:last-child, .listing-item:last-child {
          border-bottom: none;
        }

        .log-info, .listing-info {
          display: flex;
          flex-direction: column;
          gap: 2px;
        }

        .log-action {
          font-size: 14px;
          font-weight: 500;
          color: var(--color-text-primary);
          text-transform: capitalize;
        }

        .log-target, .listing-time {
          font-size: 12px;
          color: var(--color-text-tertiary);
        }

        .log-time {
          font-size: 12px;
          color: var(--color-text-tertiary);
          font-family: var(--font-mono);
        }

        .listing-title {
          font-size: 14px;
          font-weight: 500;
          color: var(--color-text-primary);
        }

        .listing-price {
          font-size: 12px;
          color: var(--color-success);
          font-weight: 600;
        }

        .empty-hint {
          text-align: center;
          padding: 32px 0;
          color: var(--color-text-tertiary);
          font-size: 13px;
        }

        @media (max-width: 900px) {
          .dashboard-main {
            grid-template-columns: 1fr;
          }
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
