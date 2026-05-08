import { useState } from 'react';
import { BarChart3, PieChart as PieChartIcon, TrendingUp, Package, ShoppingCart, Users } from 'lucide-react';
import {
  BarChart,
  Bar,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from 'recharts';
import { useAnalytics, type TimeRange } from '@/hooks/useAnalytics';

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8', '#ffc658', '#d0ed57'];

const RANGE_LABELS: Record<TimeRange, string> = {
  '7d': 'Week',
  '30d': 'Month',
  '90d': 'Quarter',
  '365d': 'Year',
};

export function AnalyticsPage() {
  const [range, setRange] = useState<TimeRange>('30d');
  const { data, isLoading, error } = useAnalytics(range);

  if (isLoading) return <div className="an-state">Loading analytics...</div>;
  if (error) return <div className="an-state an-error">Error loading analytics data</div>;

  const { dauTrend, listingsTrend, categoryDist, orderDist, kpis } = data!;

  return (
    <div className="an-page">
      <header className="an-header">
        <div>
          <h1 className="an-title">Data Dashboard</h1>
          <p className="an-subtitle">Marketplace analytics and performance metrics</p>
        </div>
        {/* Time Range Toggle */}
        <div className="an-range-toggle">
          {(Object.keys(RANGE_LABELS) as TimeRange[]).map((r) => (
            <button
              key={r}
              className={`an-range-btn ${range === r ? 'an-range-btn--active' : ''}`}
              onClick={() => setRange(r)}
            >
              {RANGE_LABELS[r]}
            </button>
          ))}
        </div>
      </header>

      {/* Period KPIs */}
      <div className="an-kpi-grid">
        <KpiCard icon={<Users size={18} />} label="DAU (24h)" value={kpis.rollingDau} color="#0088FE" />
        <KpiCard icon={<Users size={18} />} label="WAU (7d)" value={kpis.rollingWau} color="#8884d8" />
        <KpiCard icon={<Users size={18} />} label="MAU (30d)" value={kpis.rollingMau} color="#FF8042" />
        <KpiCard icon={<Package size={18} />} label={`New Listings (${RANGE_LABELS[range]})`} value={kpis.newListingsCount} color="#00C49F" />
        <KpiCard icon={<ShoppingCart size={18} />} label={`New Orders (${RANGE_LABELS[range]})`} value={kpis.newOrdersCount} color="#FFBB28" />
      </div>

      <div className="an-grid">
        {/* DAU Trend */}
        <section className="an-card">
          <div className="an-card-header">
            <TrendingUp size={18} />
            <h2>Daily Active Users</h2>
          </div>
          {dauTrend.length === 0 ? (
            <p className="an-empty">No activity data for this period.</p>
          ) : (
            <div style={{ width: '100%', height: 250 }}>
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={dauTrend} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <defs>
                    <linearGradient id="dauGrad" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#0088FE" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#0088FE" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--color-border-subtle)" />
                  <XAxis dataKey="date" tickFormatter={(v) => v.slice(5)} tick={{ fontSize: 11, fill: 'var(--color-text-tertiary)' }} axisLine={false} tickLine={false} />
                  <YAxis tick={{ fontSize: 11, fill: 'var(--color-text-tertiary)' }} axisLine={false} tickLine={false} />
                  <Tooltip contentStyle={{ backgroundColor: 'var(--color-bg-primary)', border: '1px solid var(--color-border)', borderRadius: '8px', fontSize: '13px' }} />
                  <Area type="monotone" dataKey="count" stroke="#0088FE" strokeWidth={2} fill="url(#dauGrad)" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          )}
        </section>

        {/* Listings Trend */}
        <section className="an-card">
          <div className="an-card-header">
            <Package size={18} />
            <h2>New Listings</h2>
          </div>
          {listingsTrend.length === 0 ? (
            <p className="an-empty">No listings in this period.</p>
          ) : (
            <div style={{ width: '100%', height: 250 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={listingsTrend} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--color-border-subtle)" />
                  <XAxis dataKey="date" tickFormatter={(v) => v.slice(5)} tick={{ fontSize: 11, fill: 'var(--color-text-tertiary)' }} axisLine={false} tickLine={false} />
                  <YAxis tick={{ fontSize: 11, fill: 'var(--color-text-tertiary)' }} axisLine={false} tickLine={false} />
                  <Tooltip contentStyle={{ backgroundColor: 'var(--color-bg-primary)', border: '1px solid var(--color-border)', borderRadius: '8px', fontSize: '13px' }} />
                  <Bar dataKey="count" fill="#00C49F" radius={[4, 4, 0, 0]} barSize={range === '7d' ? 32 : range === '30d' ? 12 : 6} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}
        </section>

        {/* Category Distribution */}
        <section className="an-card">
          <div className="an-card-header">
            <PieChartIcon size={18} />
            <h2>Listing Categories</h2>
          </div>
          {categoryDist.length === 0 ? (
            <p className="an-empty">No listings yet.</p>
          ) : (
            <div style={{ width: '100%', height: 250, display: 'flex', alignItems: 'center' }}>
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={categoryDist}
                    cx="50%"
                    cy="50%"
                    innerRadius={55}
                    outerRadius={85}
                    paddingAngle={2}
                    dataKey="count"
                    stroke="none"
                  >
                    {categoryDist.map((_, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip contentStyle={{ backgroundColor: 'var(--color-bg-primary)', border: '1px solid var(--color-border)', borderRadius: '8px' }} />
                </PieChart>
              </ResponsiveContainer>
              <div className="an-legend">
                {categoryDist.sort((a, b) => b.count - a.count).slice(0, 6).map((entry, index) => (
                  <div key={entry.name} className="an-legend-item">
                    <span className="an-legend-dot" style={{ backgroundColor: COLORS[index % COLORS.length] }} />
                    <span className="an-legend-name">{entry.name}</span>
                    <span className="an-legend-val">{entry.count}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </section>

        {/* Order Status Breakdown */}
        <section className="an-card">
          <div className="an-card-header">
            <BarChart3 size={18} />
            <h2>Order Status Breakdown</h2>
          </div>
          {orderDist.length === 0 ? (
            <p className="an-empty">No orders yet.</p>
          ) : (
            <div style={{ width: '100%', height: 250 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={orderDist} margin={{ top: 20, right: 20, left: -20, bottom: 0 }} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="var(--color-border-subtle)" />
                  <XAxis type="number" tick={{ fontSize: 11, fill: 'var(--color-text-tertiary)' }} axisLine={false} tickLine={false} />
                  <YAxis type="category" dataKey="name" tick={{ fontSize: 11, fill: 'var(--color-text-primary)' }} axisLine={false} tickLine={false} width={90} />
                  <Tooltip cursor={{ fill: 'var(--color-bg-secondary)' }} contentStyle={{ backgroundColor: 'var(--color-bg-primary)', border: '1px solid var(--color-border)', borderRadius: '8px' }} />
                  <Bar dataKey="count" fill="#8884d8" radius={[0, 4, 4, 0]} barSize={20} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}
        </section>
      </div>

      <style>{`
        .an-page {
          padding: 24px;
          max-width: 1200px;
          margin: 0 auto;
          display: flex;
          flex-direction: column;
          gap: 24px;
        }

        .an-state {
          display: flex; align-items: center; justify-content: center;
          padding: 80px; color: var(--color-text-tertiary); font-size: 15px;
        }
        .an-error { color: var(--color-danger); }

        .an-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
        }

        .an-title {
          font-size: 26px;
          font-weight: 700;
          color: var(--color-text-primary);
          margin-bottom: 4px;
        }

        .an-subtitle {
          font-size: 14px;
          color: var(--color-text-tertiary);
        }

        /* Time Range Toggle */
        .an-range-toggle {
          display: flex;
          background: var(--color-bg-secondary);
          border: 1px solid var(--color-border-subtle);
          border-radius: var(--radius-md);
          overflow: hidden;
        }

        .an-range-btn {
          padding: 8px 16px;
          font-size: 13px;
          font-weight: 500;
          border: none;
          background: transparent;
          color: var(--color-text-tertiary);
          cursor: pointer;
          transition: all 0.15s;
        }

        .an-range-btn:hover {
          color: var(--color-text-primary);
        }

        .an-range-btn--active {
          background: var(--color-info);
          color: white;
          font-weight: 600;
        }

        /* KPI Grid */
        .an-kpi-grid {
          display: grid;
          grid-template-columns: repeat(5, 1fr);
          gap: 16px;
        }

        @media (max-width: 1100px) {
          .an-kpi-grid { grid-template-columns: repeat(3, 1fr); }
        }

        @media (max-width: 700px) {
          .an-kpi-grid { grid-template-columns: repeat(2, 1fr); }
        }

        @media (max-width: 800px) {
          .an-kpi-grid { grid-template-columns: repeat(2, 1fr); }
        }

        .an-kpi {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-subtle);
          border-radius: var(--radius-md);
          padding: 16px 20px;
          display: flex;
          align-items: center;
          gap: 14px;
        }

        .an-kpi-icon {
          width: 40px;
          height: 40px;
          border-radius: var(--radius-sm);
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
          flex-shrink: 0;
        }

        .an-kpi-label {
          font-size: 12px;
          color: var(--color-text-tertiary);
        }

        .an-kpi-value {
          font-size: 22px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        /* Chart Grid */
        .an-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 24px;
        }

        @media (max-width: 800px) {
          .an-grid { grid-template-columns: 1fr; }
        }

        .an-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-subtle);
          border-radius: var(--radius-md);
          padding: 20px 24px;
          display: flex;
          flex-direction: column;
          gap: 16px;
        }

        .an-card-header {
          display: flex;
          align-items: center;
          gap: 10px;
          color: var(--color-text-secondary);
        }

        .an-card-header h2 {
          font-size: 15px;
          font-weight: 600;
          color: var(--color-text-primary);
        }

        .an-empty {
          text-align: center;
          padding: 40px 16px;
          color: var(--color-text-tertiary);
          font-size: 13px;
        }

        .an-legend {
          display: flex;
          flex-direction: column;
          gap: 10px;
          min-width: 120px;
        }

        .an-legend-item {
          display: flex;
          align-items: center;
          gap: 8px;
          font-size: 12px;
        }

        .an-legend-dot {
          width: 8px;
          height: 8px;
          border-radius: 50%;
          flex-shrink: 0;
        }

        .an-legend-name {
          color: var(--color-text-secondary);
          flex: 1;
          text-transform: capitalize;
        }

        .an-legend-val {
          font-weight: 600;
          color: var(--color-text-primary);
        }
      `}</style>
    </div>
  );
}

function KpiCard({ icon, label, value, color }: { icon: React.ReactNode, label: string, value: number, color: string }) {
  return (
    <div className="an-kpi">
      <div className="an-kpi-icon" style={{ backgroundColor: color }}>{icon}</div>
      <div>
        <div className="an-kpi-label">{label}</div>
        <div className="an-kpi-value">{value.toLocaleString()}</div>
      </div>
    </div>
  );
}
