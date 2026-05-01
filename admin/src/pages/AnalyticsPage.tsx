import { BarChart3, PieChart as PieChartIcon, TrendingUp } from 'lucide-react';
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import { useAnalytics } from '@/hooks/useAnalytics';

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8', '#ffc658', '#d0ed57'];

export function AnalyticsPage() {
  const { data, isLoading, error } = useAnalytics();

  if (isLoading) return <div className="loading-state">Loading analytics...</div>;
  if (error) return <div className="error-state">Error loading analytics data</div>;

  const { dauTrend, categoryDist, orderDist } = data!;

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
            <div style={{ width: '100%', height: 250 }}>
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={dauTrend} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--color-border-subtle)" />
                  <XAxis 
                    dataKey="date" 
                    tickFormatter={(v) => v.slice(5)} 
                    tick={{ fontSize: 12, fill: 'var(--color-text-tertiary)' }} 
                    axisLine={false}
                    tickLine={false}
                  />
                  <YAxis tick={{ fontSize: 12, fill: 'var(--color-text-tertiary)' }} axisLine={false} tickLine={false} />
                  <Tooltip 
                    contentStyle={{ backgroundColor: 'var(--color-bg-primary)', border: '1px solid var(--color-border)', borderRadius: '8px' }}
                    itemStyle={{ color: 'var(--color-text-primary)', fontSize: '13px' }}
                  />
                  <Line type="monotone" dataKey="count" stroke="var(--color-info)" strokeWidth={3} dot={{ r: 4, fill: 'var(--color-bg-primary)', strokeWidth: 2 }} activeDot={{ r: 6 }} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          )}
        </section>

        {/* Category Distribution */}
        <section className="analytics-card">
          <div className="card-header">
            <PieChartIcon size={18} />
            <h2>Listing Categories</h2>
          </div>
          {categoryDist.length === 0 ? (
            <p className="empty-chart">No listings yet.</p>
          ) : (
            <div style={{ width: '100%', height: 250, display: 'flex', alignItems: 'center' }}>
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={categoryDist}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={90}
                    paddingAngle={2}
                    dataKey="count"
                    stroke="none"
                  >
                    {categoryDist.map((_, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip 
                    contentStyle={{ backgroundColor: 'var(--color-bg-primary)', border: '1px solid var(--color-border)', borderRadius: '8px' }}
                    itemStyle={{ color: 'var(--color-text-primary)', fontSize: '13px' }}
                  />
                </PieChart>
              </ResponsiveContainer>
              <div className="custom-legend">
                {categoryDist.sort((a,b) => b.count - a.count).slice(0, 5).map((entry, index) => (
                  <div key={entry.name} className="legend-item">
                    <span className="legend-color" style={{ backgroundColor: COLORS[index % COLORS.length] }} />
                    <span className="legend-name">{entry.name}</span>
                    <span className="legend-value">{entry.count}</span>
                  </div>
                ))}
              </div>
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
            <div style={{ width: '100%', height: 300 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={orderDist} margin={{ top: 20, right: 20, left: -20, bottom: 0 }} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="var(--color-border-subtle)" />
                  <XAxis type="number" tick={{ fontSize: 12, fill: 'var(--color-text-tertiary)' }} axisLine={false} tickLine={false} />
                  <YAxis type="category" dataKey="name" tick={{ fontSize: 12, fill: 'var(--color-text-primary)' }} axisLine={false} tickLine={false} width={100} />
                  <Tooltip 
                    cursor={{ fill: 'var(--color-bg-secondary)' }}
                    contentStyle={{ backgroundColor: 'var(--color-bg-primary)', border: '1px solid var(--color-border)', borderRadius: '8px' }}
                    itemStyle={{ color: 'var(--color-text-primary)', fontSize: '13px' }}
                  />
                  <Bar dataKey="count" fill="var(--color-success)" radius={[0, 4, 4, 0]} barSize={24} />
                </BarChart>
              </ResponsiveContainer>
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

        .custom-legend {
          display: flex;
          flex-direction: column;
          gap: 12px;
          min-width: 140px;
        }

        .legend-item {
          display: flex;
          align-items: center;
          gap: 8px;
          font-size: 13px;
        }

        .legend-color {
          width: 10px;
          height: 10px;
          border-radius: 50%;
        }

        .legend-name {
          color: var(--color-text-secondary);
          flex: 1;
          text-transform: capitalize;
        }

        .legend-value {
          font-weight: 600;
          color: var(--color-text-primary);
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
