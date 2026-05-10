import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Users, Package, ShoppingCart, Activity,
  ShieldAlert, MessageSquareWarning, FileWarning,
  ChevronRight, TrendingUp, UserPlus, BarChart3,
  LineChart as LineChartIcon, AreaChart as AreaChartIcon,
} from 'lucide-react';
import {
  AreaChart, Area, BarChart, Bar, LineChart, Line,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
} from 'recharts';
import { useDashboard } from '@/hooks/useDashboard';
import { useAnalytics, type TimeRange } from '@/hooks/useAnalytics';

// ── Data source definitions for the chart ──
type ChartDataSource =
  | 'totalUsers'
  | 'totalListings'
  | 'activeOrders'
  | 'activeUsers'
  | 'newUsers'
  | 'pendingListings'
  | 'userReports'
  | 'chatReports';

const DATA_SOURCE_LABELS: Record<ChartDataSource, string> = {
  totalUsers: 'User Registrations',
  totalListings: 'New Listings',
  activeOrders: 'New Orders',
  activeUsers: 'Daily Active Users',
  newUsers: 'New Users',
  pendingListings: 'Pending Listings',
  userReports: 'Listing Reports',
  chatReports: 'Reports',
};

const DATA_SOURCE_COLORS: Record<ChartDataSource, string> = {
  totalUsers: '#3b82f6',
  totalListings: '#10b981',
  activeOrders: '#f59e0b',
  activeUsers: '#ef4444',
  newUsers: '#8b5cf6',
  pendingListings: '#ef4444',
  userReports: '#f59e0b',
  chatReports: '#ec4899',
};

type ChartType = 'area' | 'line' | 'bar';

const RANGE_OPTIONS: { value: TimeRange; label: string }[] = [
  { value: '7d', label: '7D' },
  { value: '30d', label: '30D' },
  { value: '90d', label: '90D' },
  { value: '365d', label: '1Y' },
];

export function DashboardPage() {
  const navigate = useNavigate();
  const { data, isLoading, error } = useDashboard();

  // Chart state
  const [chartSource, setChartSource] = useState<ChartDataSource>('totalUsers');
  const [chartType, setChartType] = useState<ChartType>('area');
  const [range, setRange] = useState<TimeRange>('30d');

  const { data: analytics, isLoading: analyticsLoading } = useAnalytics(range);

  if (isLoading) return <div className="dash-state">Loading dashboard...</div>;
  if (error) return <div className="dash-state dash-state--error">Error loading dashboard stats</div>;

  const { stats } = data!;

  // Map chart data source to the appropriate trend array from analytics
  const getChartData = (): { date: string; count: number }[] => {
    if (!analytics) return [];
    switch (chartSource) {
      case 'totalUsers':
      case 'newUsers':
        return analytics.userTrend;
      case 'totalListings':
      case 'pendingListings':
        return analytics.listingsTrend;
      case 'activeOrders':
        return analytics.ordersTrend;
      case 'activeUsers':
        return analytics.dauTrend;
      case 'userReports':
      case 'chatReports':
        return analytics.reportsTrend;
      default:
        return analytics.userTrend;
    }
  };

  const chartData = getChartData();
  const chartColor = DATA_SOURCE_COLORS[chartSource];
  const chartLabel = DATA_SOURCE_LABELS[chartSource];

  return (
    <div className="dash">
      <header className="dash-header">
        <div>
          <h1 className="dash-title">Dashboard</h1>
          <p className="dash-subtitle">Overview of your marketplace platform</p>
        </div>
      </header>

      {/* ── Row 1: Urgent Action Cards ── */}
      <section className="dash-section">
        <h2 className="dash-section-label">Action Required</h2>
        <div className="dash-urgent-grid">
          <div
            className={`urgent-card urgent-card--danger ${chartSource === 'pendingListings' ? 'urgent-card--selected' : ''}`}
            onClick={() => { setChartSource('pendingListings'); }}
          >
            <div className="urgent-card-icon"><ShieldAlert size={24} /></div>
            <div className="urgent-card-content">
              <span className="urgent-card-count">{stats.pendingModerationCount}</span>
              <span className="urgent-card-label">Pending Listings</span>
              <span className="urgent-card-ai-stats">
                AI approved: {stats.autoApprovedCount} · rejected: {stats.aiRejectedCount}
              </span>
            </div>
            <ChevronRight
              size={18}
              className="urgent-card-arrow"
              onClick={(e) => { e.stopPropagation(); navigate('/moderation/listings'); }}
            />
          </div>

          <div
            className={`urgent-card urgent-card--warning ${chartSource === 'userReports' ? 'urgent-card--selected' : ''}`}
            onClick={() => { setChartSource('userReports'); }}
          >
            <div className="urgent-card-icon"><MessageSquareWarning size={24} /></div>
            <div className="urgent-card-content">
              <span className="urgent-card-count">{stats.pendingReportCount}</span>
              <span className="urgent-card-label">User Reports</span>
            </div>
            <ChevronRight
              size={18}
              className="urgent-card-arrow"
              onClick={(e) => { e.stopPropagation(); navigate('/moderation/listing-reports'); }}
            />
          </div>

          <div
            className={`urgent-card urgent-card--info ${chartSource === 'chatReports' ? 'urgent-card--selected' : ''}`}
            onClick={() => { setChartSource('chatReports'); }}
          >
            <div className="urgent-card-icon"><FileWarning size={24} /></div>
            <div className="urgent-card-content">
              <span className="urgent-card-count">{stats.pendingFeedbackCount}</span>
              <span className="urgent-card-label">Chat Reports</span>
            </div>
            <ChevronRight
              size={18}
              className="urgent-card-arrow"
              onClick={(e) => { e.stopPropagation(); navigate('/moderation/chat-reports'); }}
            />
          </div>
        </div>
      </section>

      {/* ── Row 2: Business KPI Cards ── */}
      <section className="dash-section">
        <h2 className="dash-section-label">Business Overview</h2>
        <div className="dash-stats-grid dash-stats-grid--3">
          <KpiCard
            icon={<Users size={20} />}
            label="Total Users"
            value={stats.userCount}
            color="var(--color-info)"
            active={chartSource === 'totalUsers'}
            onClick={() => setChartSource('totalUsers')}
          />
          <KpiCard
            icon={<Package size={20} />}
            label="Total Listings"
            value={stats.listingCount}
            color="var(--color-success)"
            active={chartSource === 'totalListings'}
            onClick={() => setChartSource('totalListings')}
          />
          <KpiCard
            icon={<ShoppingCart size={20} />}
            label="Active Orders"
            value={stats.activeOrderCount}
            color="var(--color-warning)"
            active={chartSource === 'activeOrders'}
            onClick={() => setChartSource('activeOrders')}
          />
        </div>
      </section>

      {/* ── Row 3: User Metrics ── */}
      <section className="dash-section">
        <h2 className="dash-section-label">User Metrics</h2>
        <div className="dash-stats-grid dash-stats-grid--3">
          <KpiCard
            icon={<Users size={20} />}
            label="Total Users"
            value={stats.userCount}
            color="#3b82f6"
            active={chartSource === 'totalUsers'}
            onClick={() => setChartSource('totalUsers')}
          />
          <KpiCard
            icon={<UserPlus size={20} />}
            label="New Users (7d)"
            value={stats.newUserCount}
            color="#8b5cf6"
            active={chartSource === 'newUsers'}
            onClick={() => setChartSource('newUsers')}
          />
          <KpiCard
            icon={<Activity size={20} />}
            label="Active Users (DAU)"
            value={stats.activeUsers.dau}
            color="#ef4444"
            active={chartSource === 'activeUsers'}
            onClick={() => setChartSource('activeUsers')}
            subValues={[
              { label: 'WAU', value: stats.activeUsers.wau },
              { label: 'MAU', value: stats.activeUsers.mau },
            ]}
          />
        </div>
      </section>

      {/* ── Row 4: Chart Area ── */}
      <section className="dash-chart-section">
        <div className="dash-chart-header">
          <div className="dash-chart-title">
            <TrendingUp size={16} />
            <span>{chartLabel}</span>
          </div>
          <div className="dash-chart-controls">
            {/* Chart type switcher */}
            <div className="chart-type-toggle">
              <button
                className={`chart-type-btn ${chartType === 'area' ? 'chart-type-btn--active' : ''}`}
                onClick={() => setChartType('area')}
                title="Area Chart"
              >
                <AreaChartIcon size={14} />
              </button>
              <button
                className={`chart-type-btn ${chartType === 'line' ? 'chart-type-btn--active' : ''}`}
                onClick={() => setChartType('line')}
                title="Line Chart"
              >
                <LineChartIcon size={14} />
              </button>
              <button
                className={`chart-type-btn ${chartType === 'bar' ? 'chart-type-btn--active' : ''}`}
                onClick={() => setChartType('bar')}
                title="Bar Chart"
              >
                <BarChart3 size={14} />
              </button>
            </div>

            {/* Time range selector */}
            <div className="range-toggle">
              {RANGE_OPTIONS.map((opt) => (
                <button
                  key={opt.value}
                  className={`range-btn ${range === opt.value ? 'range-btn--active' : ''}`}
                  onClick={() => setRange(opt.value)}
                >
                  {opt.label}
                </button>
              ))}
            </div>
          </div>
        </div>

        <div className="dash-chart-body">
          {analyticsLoading ? (
            <div className="chart-loading">Loading chart data...</div>
          ) : chartData.length === 0 ? (
            <div className="chart-loading">No data available for this period</div>
          ) : (
            <ResponsiveContainer width="100%" height={320}>
              {chartType === 'area' ? (
                <AreaChart data={chartData}>
                  <defs>
                    <linearGradient id="chartGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor={chartColor} stopOpacity={0.3} />
                      <stop offset="95%" stopColor={chartColor} stopOpacity={0.02} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border-light)" />
                  <XAxis
                    dataKey="date"
                    tick={{ fontSize: 11, fill: 'var(--color-text-tertiary)' }}
                    tickFormatter={(v) => v.slice(5)}
                  />
                  <YAxis tick={{ fontSize: 11, fill: 'var(--color-text-tertiary)' }} width={40} />
                  <Tooltip
                    contentStyle={{
                      background: 'var(--color-bg-primary)',
                      border: '1px solid var(--color-border)',
                      borderRadius: 8,
                      fontSize: 12,
                    }}
                  />
                  <Area
                    type="monotone"
                    dataKey="count"
                    stroke={chartColor}
                    fill="url(#chartGradient)"
                    strokeWidth={2}
                    name={chartLabel}
                  />
                </AreaChart>
              ) : chartType === 'line' ? (
                <LineChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border-light)" />
                  <XAxis
                    dataKey="date"
                    tick={{ fontSize: 11, fill: 'var(--color-text-tertiary)' }}
                    tickFormatter={(v) => v.slice(5)}
                  />
                  <YAxis tick={{ fontSize: 11, fill: 'var(--color-text-tertiary)' }} width={40} />
                  <Tooltip
                    contentStyle={{
                      background: 'var(--color-bg-primary)',
                      border: '1px solid var(--color-border)',
                      borderRadius: 8,
                      fontSize: 12,
                    }}
                  />
                  <Line
                    type="monotone"
                    dataKey="count"
                    stroke={chartColor}
                    strokeWidth={2}
                    dot={{ fill: chartColor, r: 3 }}
                    name={chartLabel}
                  />
                </LineChart>
              ) : (
                <BarChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border-light)" />
                  <XAxis
                    dataKey="date"
                    tick={{ fontSize: 11, fill: 'var(--color-text-tertiary)' }}
                    tickFormatter={(v) => v.slice(5)}
                  />
                  <YAxis tick={{ fontSize: 11, fill: 'var(--color-text-tertiary)' }} width={40} />
                  <Tooltip
                    contentStyle={{
                      background: 'var(--color-bg-primary)',
                      border: '1px solid var(--color-border)',
                      borderRadius: 8,
                      fontSize: 12,
                    }}
                  />
                  <Bar dataKey="count" fill={chartColor} radius={[4, 4, 0, 0]} name={chartLabel} />
                </BarChart>
              )}
            </ResponsiveContainer>
          )}
        </div>
      </section>

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

        /* ── Section ── */
        .dash-section { display: flex; flex-direction: column; gap: 12px; }
        .dash-section-label {
          font-size: 12px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.06em;
          color: var(--color-text-tertiary);
        }

        /* ── Row 1: Urgent Cards ── */
        .dash-urgent-grid {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 12px;
        }
        @media (max-width: 768px) {
          .dash-urgent-grid { grid-template-columns: 1fr; }
        }
        .urgent-card {
          display: flex;
          align-items: center;
          gap: 14px;
          padding: 16px 18px;
          border-radius: var(--radius-md);
          cursor: pointer;
          transition: transform 0.15s, box-shadow 0.15s, border-color 0.15s;
          border: 2px solid transparent;
        }
        .urgent-card:hover {
          transform: translateY(-2px);
          box-shadow: var(--shadow-card);
        }
        .urgent-card--selected {
          border-color: currentColor !important;
          box-shadow: 0 0 0 1px currentColor;
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
        .urgent-card-icon { flex-shrink: 0; opacity: 0.7; }
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
        .urgent-card-ai-stats {
          font-size: 11px;
          opacity: 0.6;
          margin-top: 4px;
        }
        .urgent-card-arrow {
          opacity: 0.4;
          cursor: pointer;
          transition: opacity 0.15s;
        }
        .urgent-card-arrow:hover { opacity: 1; }

        /* ── KPI Stats Grid ── */
        .dash-stats-grid {
          display: grid;
          gap: 16px;
        }
        .dash-stats-grid--3 {
          grid-template-columns: repeat(3, 1fr);
        }
        @media (max-width: 768px) {
          .dash-stats-grid--3 { grid-template-columns: 1fr; }
        }

        .kpi-card {
          background: var(--color-bg-primary);
          padding: 18px 20px;
          border-radius: var(--radius-md);
          border: 2px solid var(--color-border-subtle);
          display: flex;
          align-items: center;
          gap: 16px;
          cursor: pointer;
          transition: all 0.15s;
        }
        .kpi-card:hover {
          border-color: var(--color-border);
          box-shadow: var(--shadow-card);
          transform: translateY(-1px);
        }
        .kpi-card--active {
          border-color: var(--kpi-color) !important;
          box-shadow: 0 0 0 1px var(--kpi-color);
        }
        .kpi-icon {
          width: 44px;
          height: 44px;
          border-radius: var(--radius-sm);
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
          flex-shrink: 0;
        }
        .kpi-content {
          flex: 1;
          display: flex;
          flex-direction: column;
        }
        .kpi-label {
          font-size: 12px;
          color: var(--color-text-tertiary);
          margin-bottom: 2px;
        }
        .kpi-value {
          font-size: 22px;
          font-weight: 700;
          color: var(--color-text-primary);
          line-height: 1.2;
        }
        .kpi-sub-values {
          display: flex;
          gap: 12px;
          margin-top: 4px;
        }
        .kpi-sub-item {
          font-size: 11px;
          color: var(--color-text-tertiary);
        }
        .kpi-sub-item strong {
          color: var(--color-text-secondary);
          font-weight: 600;
        }

        /* ── Chart Section ── */
        .dash-chart-section {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-subtle);
          border-radius: var(--radius-lg);
          overflow: hidden;
        }
        .dash-chart-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 16px 20px;
          border-bottom: 1px solid var(--color-border-subtle);
        }
        .dash-chart-title {
          display: flex;
          align-items: center;
          gap: 8px;
          font-size: 14px;
          font-weight: 600;
          color: var(--color-text-primary);
        }
        .dash-chart-controls {
          display: flex;
          align-items: center;
          gap: 12px;
        }
        .chart-type-toggle,
        .range-toggle {
          display: flex;
          background: var(--color-bg-tertiary);
          border-radius: var(--radius-sm);
          padding: 2px;
          gap: 2px;
        }
        .chart-type-btn,
        .range-btn {
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 5px 10px;
          border: none;
          background: transparent;
          border-radius: calc(var(--radius-sm) - 2px);
          font-size: 12px;
          font-weight: 500;
          color: var(--color-text-tertiary);
          cursor: pointer;
          transition: all 0.15s;
        }
        .chart-type-btn:hover,
        .range-btn:hover {
          color: var(--color-text-primary);
        }
        .chart-type-btn--active,
        .range-btn--active {
          background: var(--color-bg-primary);
          color: var(--color-text-primary);
          font-weight: 600;
          box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        }
        .dash-chart-body {
          padding: 20px;
        }
        .chart-loading {
          display: flex;
          align-items: center;
          justify-content: center;
          height: 320px;
          color: var(--color-text-tertiary);
          font-size: 14px;
        }
      `}</style>
    </div>
  );
}

// ── KPI Card Component ──
function KpiCard({
  icon, label, value, color, active, onClick, subValues,
}: {
  icon: React.ReactNode;
  label: string;
  value: number;
  color: string;
  active: boolean;
  onClick: () => void;
  subValues?: { label: string; value: number }[];
}) {
  return (
    <div
      className={`kpi-card ${active ? 'kpi-card--active' : ''}`}
      style={{ '--kpi-color': color } as React.CSSProperties}
      onClick={onClick}
    >
      <div className="kpi-icon" style={{ backgroundColor: color }}>
        {icon}
      </div>
      <div className="kpi-content">
        <span className="kpi-label">{label}</span>
        <span className="kpi-value">{value.toLocaleString()}</span>
        {subValues && (
          <div className="kpi-sub-values">
            {subValues.map((sv) => (
              <span key={sv.label} className="kpi-sub-item">
                {sv.label}: <strong>{sv.value}</strong>
              </span>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
