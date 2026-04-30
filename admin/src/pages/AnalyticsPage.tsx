import { BarChart3, PieChart, TrendingUp } from 'lucide-react';
import { useAnalytics } from '@/hooks/useAnalytics';

export function AnalyticsPage() {
  const { data, isLoading, error } = useAnalytics();

  if (isLoading) return <div className="loading-state">Loading analytics...</div>;
  if (error) return <div className="error-state">Error loading analytics data</div>;

  const { dauTrend, categoryDist, orderDist } = data!;

  const maxDau = Math.max(...dauTrend.map(d => d.count), 1);
  const maxCategory = Math.max(...categoryDist.map(c => c.count), 1);
  // NOTE: Guard against division-by-zero when there are no orders yet
  const totalOrders = orderDist.reduce((acc, curr) => acc + curr.count, 0) || 1;

  return (
    <div className="analytics-container">
      <header className="analytics-header">
        <h1 className="page-title">Marketplace Analytics</h1>
        <p className="page-subtitle">Visualized trends and distribution metrics</p>
      </header>

      <div className="analytics-grid">
        {/* DAU Trend Chart */}
        <section className="analytics-card">
          <div className="card-header">
            <TrendingUp size={18} />
            <h2>DAU Trend (Last 7 Days)</h2>
          </div>
          {dauTrend.length === 0 ? (
            <p className="empty-chart">No activity data for the last 7 days.</p>
          ) : (
            <div className="chart-container dau-chart">
              {dauTrend.map((d) => (
                <div key={d.date} className="bar-group">
                  <div
                    className="bar dau-bar"
                    style={{ height: `${(d.count / maxDau) * 100}%` }}
                    title={`${d.date}: ${d.count}`}
                  >
                    <span className="bar-value">{d.count}</span>
                  </div>
                  <span className="bar-label">{d.date.slice(5)}</span>
                </div>
              ))}
            </div>
          )}
        </section>

        {/* Category Distribution */}
        <section className="analytics-card">
          <div className="card-header">
            <PieChart size={18} />
            <h2>Listing Categories</h2>
          </div>
          {categoryDist.length === 0 ? (
            <p className="empty-chart">No listings yet.</p>
          ) : (
            <div className="dist-list">
              {categoryDist.sort((a, b) => b.count - a.count).map((c) => (
                <div key={c.name} className="dist-item">
                  <div className="dist-info">
                    <span className="dist-name">{c.name}</span>
                    <span className="dist-count">{c.count} items</span>
                  </div>
                  <div className="dist-bar-bg">
                    <div
                      className="dist-bar"
                      style={{
                        width: `${(c.count / maxCategory) * 100}%`,
                        backgroundColor: 'var(--color-primary)',
                      }}
                    />
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>

        {/* Order Status Distribution */}
        <section className="analytics-card full-width">
          <div className="card-header">
            <BarChart3 size={18} />
            <h2>Order Status Breakdown</h2>
          </div>
          {orderDist.length === 0 ? (
            <p className="empty-chart">No orders yet.</p>
          ) : (
            <div className="order-stats-grid">
              {orderDist.map((o) => (
                <div key={o.name} className="order-stat-pill">
                  <span className="order-status-name">{o.name}</span>
                  <span className="order-status-value">{o.count}</span>
                  <span className="order-status-percent">
                    {((o.count / totalOrders) * 100).toFixed(1)}%
                  </span>
                </div>
              ))}
            </div>
          )}
        </section>
      </div>

      <style>{`
        .analytics-container {
          padding: 24px;
          max-width: 1200px;
          margin: 0 auto;
          display: flex;
          flex-direction: column;
          gap: 32px;
        }

        .empty-chart {
          text-align: center;
          padding: 40px 16px;
          color: var(--color-text-tertiary);
          font-size: 13px;
        }

        .analytics-header {
          margin-bottom: 8px;
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

        .analytics-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 24px;
        }

        .analytics-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-subtle);
          border-radius: var(--radius-md);
          padding: 24px;
          display: flex;
          flex-direction: column;
          gap: 20px;
        }

        .full-width {
          grid-column: 1 / -1;
        }

        .card-header {
          display: flex;
          align-items: center;
          gap: 10px;
          color: var(--color-text-secondary);
        }

        .card-header h2 {
          font-size: 16px;
          font-weight: 600;
          color: var(--color-text-primary);
        }

        /* DAU Chart Styles */
        .chart-container.dau-chart {
          height: 200px;
          display: flex;
          align-items: flex-end;
          justify-content: space-between;
          padding: 20px 10px 0;
          border-bottom: 1px solid var(--color-border-subtle);
        }

        .bar-group {
          flex: 1;
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 8px;
          height: 100%;
          justify-content: flex-end;
        }

        .bar {
          width: 60%;
          min-width: 20px;
          max-width: 40px;
          border-radius: var(--radius-sm) var(--radius-sm) 0 0;
          position: relative;
          transition: transform 0.2s;
        }

        .dau-bar {
          background: linear-gradient(to top, var(--color-primary), var(--color-info));
        }

        .bar:hover {
          transform: scaleY(1.05);
          filter: brightness(1.1);
        }

        .bar-value {
          position: absolute;
          top: -20px;
          left: 50%;
          transform: translateX(-50%);
          font-size: 11px;
          font-weight: 600;
          color: var(--color-text-secondary);
        }

        .bar-label {
          font-size: 11px;
          color: var(--color-text-tertiary);
          transform: rotate(-45deg);
          margin-top: 4px;
        }

        /* Category Distribution Styles */
        .dist-list {
          display: flex;
          flex-direction: column;
          gap: 14px;
        }

        .dist-item {
          display: flex;
          flex-direction: column;
          gap: 6px;
        }

        .dist-info {
          display: flex;
          justify-content: space-between;
          font-size: 13px;
        }

        .dist-name {
          font-weight: 500;
          color: var(--color-text-primary);
          text-transform: capitalize;
        }

        .dist-count {
          color: var(--color-text-tertiary);
        }

        .dist-bar-bg {
          height: 8px;
          background: var(--color-bg-tertiary);
          border-radius: 4px;
          overflow: hidden;
        }

        .dist-bar {
          height: 100%;
          border-radius: 4px;
        }

        /* Order Stats Styles */
        .order-stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
          gap: 16px;
        }

        .order-stat-pill {
          background: var(--color-bg-secondary);
          padding: 16px;
          border-radius: var(--radius-md);
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 4px;
          text-align: center;
        }

        .order-status-name {
          font-size: 12px;
          text-transform: uppercase;
          letter-spacing: 0.05em;
          color: var(--color-text-tertiary);
          font-weight: 600;
        }

        .order-status-value {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .order-status-percent {
          font-size: 11px;
          color: var(--color-success);
          font-weight: 600;
          background: var(--color-bg-primary);
          padding: 2px 8px;
          border-radius: 10px;
        }

        @media (max-width: 800px) {
          .analytics-grid {
            grid-template-columns: 1fr;
          }
        }
      `}</style>
    </div>
  );
}
