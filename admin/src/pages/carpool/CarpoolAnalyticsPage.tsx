/**
 * Carpool analytics page — aggregated statistics for carpool trips.
 * Shows popular origins/destinations, time distribution, and role/status breakdown.
 */
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, TrendingUp, MapPin, Clock, PieChart } from 'lucide-react';
import { useCarpoolAnalytics } from '@/hooks/useCarpool';
import { useSchoolScopeStore } from '@/stores/school-scope-store';
import { CARPOOL_STATUS_META } from '@/types';
import type { CarpoolTripStatus } from '@/types';

export function CarpoolAnalyticsPage() {
  const navigate = useNavigate();
  const currentCollegeId = useSchoolScopeStore((state) => state.currentCollegeId);
  const { data, isLoading, error } = useCarpoolAnalytics(currentCollegeId || undefined);

  if (isLoading) {
    return <div className="analytics-loading">Loading analytics...</div>;
  }

  if (error || !data) {
    return (
      <div className="analytics-error">
        <p>Failed to load analytics</p>
        <button onClick={() => navigate('/carpool')}>← Back to list</button>
      </div>
    );
  }

  const { summary, topDepartures, topDestinations, hourlyDistribution, weekdayDistribution, statusDistribution } = data;
  const maxHourCount = Math.max(...hourlyDistribution.map(h => h.count), 1);
  const maxWeekCount = Math.max(...weekdayDistribution.map(w => w.count), 1);

  return (
    <div className="analytics-container">
      <header>
        <button className="back-btn" onClick={() => navigate('/carpool')}>
          <ArrowLeft size={18} /> Back to Trips
        </button>
        <h1 className="page-title">Carpool Analytics</h1>
        <p className="page-subtitle">Aggregated statistics for all carpool trips</p>
      </header>

      {/* Summary Cards */}
      <div className="summary-grid">
        <SummaryCard label="Total Trips" value={summary.totalTrips} icon="🚗" />
        <SummaryCard label="Active Trips" value={summary.activeTrips} icon="✅" color="#059669" />
        <SummaryCard label="Completed" value={summary.completedTrips} icon="🏁" color="#7c3aed" />
        <SummaryCard label="Cancelled" value={summary.cancelledTrips} icon="❌" color="#dc2626" />
        <SummaryCard label="Seat Utilization" value={`${summary.avgSeatUtilization}%`} icon="💺" />
        <SummaryCard label="Avg Price" value={`$${summary.avgPrice.toFixed(2)}`} icon="💰" />
        <SummaryCard label="Drivers" value={summary.driverCount} icon="🚘" color="#2563eb" />
        <SummaryCard label="Organizers" value={summary.organizerCount} icon="👥" color="#d97706" />
      </div>

      {/* Two-column charts */}
      <div className="charts-grid">
        {/* Top Departures */}
        <div className="chart-card">
          <div className="chart-header">
            <MapPin size={16} />
            <h3>Top Departure Locations</h3>
          </div>
          <div className="chart-body">
            {topDepartures.length === 0 ? (
              <p className="empty-text">No data yet</p>
            ) : (
              topDepartures.map((item, i) => (
                <div key={i} className="bar-row">
                  <span className="bar-label">{item.location}</span>
                  <div className="bar-track">
                    <div
                      className="bar-fill bar-fill--green"
                      style={{ width: `${(item.count / topDepartures[0].count) * 100}%` }}
                    />
                  </div>
                  <span className="bar-count">{item.count}</span>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Top Destinations */}
        <div className="chart-card">
          <div className="chart-header">
            <MapPin size={16} />
            <h3>Top Destination Locations</h3>
          </div>
          <div className="chart-body">
            {topDestinations.length === 0 ? (
              <p className="empty-text">No data yet</p>
            ) : (
              topDestinations.map((item, i) => (
                <div key={i} className="bar-row">
                  <span className="bar-label">{item.location}</span>
                  <div className="bar-track">
                    <div
                      className="bar-fill bar-fill--blue"
                      style={{ width: `${(item.count / topDestinations[0].count) * 100}%` }}
                    />
                  </div>
                  <span className="bar-count">{item.count}</span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* Time Distribution */}
      <div className="charts-grid">
        {/* Hourly */}
        <div className="chart-card">
          <div className="chart-header">
            <Clock size={16} />
            <h3>Departure Time Distribution (24h)</h3>
          </div>
          <div className="chart-body">
            <div className="histogram">
              {hourlyDistribution.map((h) => (
                <div key={h.slot} className="histogram-col" title={`${h.label}: ${h.count} trips`}>
                  <div
                    className="histogram-bar"
                    style={{ height: `${(h.count / maxHourCount) * 100}%` }}
                  />
                  <span className="histogram-label">{h.slot % 3 === 0 ? h.label.slice(0, 2) : ''}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Weekly */}
        <div className="chart-card">
          <div className="chart-header">
            <TrendingUp size={16} />
            <h3>Weekday Distribution</h3>
          </div>
          <div className="chart-body">
            <div className="weekday-chart">
              {weekdayDistribution.map((w) => (
                <div key={w.slot} className="weekday-col">
                  <div className="weekday-bar-wrap">
                    <div
                      className="weekday-bar"
                      style={{ height: `${(w.count / maxWeekCount) * 100}%` }}
                    />
                  </div>
                  <span className="weekday-label">{w.label}</span>
                  <span className="weekday-count">{w.count}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Status Distribution */}
      <div className="chart-card chart-card--wide">
        <div className="chart-header">
          <PieChart size={16} />
          <h3>Status Distribution</h3>
        </div>
        <div className="chart-body">
          <div className="status-bars">
            {statusDistribution
              .sort((a, b) => b.count - a.count)
              .map((item) => {
                const meta = CARPOOL_STATUS_META[item.status as CarpoolTripStatus];
                const pct = summary.totalTrips > 0 ? ((item.count / summary.totalTrips) * 100).toFixed(1) : '0';
                return (
                  <div key={item.status} className="status-bar-row">
                    <span className="status-bar-label" style={{ color: meta?.color }}>
                      {meta?.label || item.status}
                    </span>
                    <div className="status-bar-track">
                      <div
                        className="status-bar-fill"
                        style={{
                          width: `${pct}%`,
                          backgroundColor: meta?.color || '#aaa',
                        }}
                      />
                    </div>
                    <span className="status-bar-count">{item.count} ({pct}%)</span>
                  </div>
                );
              })}
          </div>
        </div>
      </div>

      <style>{`
        .analytics-container {
          padding: 24px;
          display: flex;
          flex-direction: column;
          gap: 24px;
        }

        .analytics-loading, .analytics-error {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          min-height: 300px;
          gap: 12px;
          color: var(--color-text-tertiary);
        }

        .analytics-error button {
          padding: 8px 16px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          cursor: pointer;
        }

        .back-btn {
          display: inline-flex;
          align-items: center;
          gap: 6px;
          background: none;
          border: none;
          color: var(--color-text-secondary);
          font-size: 13px;
          cursor: pointer;
          padding: 4px 0;
          margin-bottom: 4px;
        }

        .back-btn:hover { color: var(--color-info); }

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

        /* Summary */
        .summary-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
          gap: 16px;
        }

        .summary-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg);
          padding: 20px;
          display: flex;
          flex-direction: column;
          gap: 8px;
        }

        .summary-card-label {
          font-size: 12px;
          font-weight: 600;
          color: var(--color-text-tertiary);
          text-transform: uppercase;
        }

        .summary-card-value {
          font-size: 28px;
          font-weight: 700;
          font-family: var(--font-mono);
        }

        .summary-card-icon {
          font-size: 22px;
        }

        /* Charts */
        .charts-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 20px;
        }

        @media (max-width: 900px) {
          .charts-grid { grid-template-columns: 1fr; }
        }

        .chart-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg);
          overflow: hidden;
        }

        .chart-card--wide {
          grid-column: 1 / -1;
        }

        .chart-header {
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 14px 20px;
          border-bottom: 1px solid var(--color-border-light);
          background: var(--color-bg-secondary);
        }

        .chart-header h3 {
          font-size: 13px;
          font-weight: 600;
          color: var(--color-text-secondary);
          text-transform: uppercase;
          letter-spacing: 0.03em;
        }

        .chart-header svg {
          color: var(--color-text-tertiary);
        }

        .chart-body {
          padding: 20px;
        }

        .empty-text {
          text-align: center;
          color: var(--color-text-tertiary);
          font-size: 13px;
          padding: 20px 0;
        }

        /* Bar chart rows */
        .bar-row {
          display: flex;
          align-items: center;
          gap: 10px;
          margin-bottom: 8px;
        }

        .bar-label {
          font-size: 12px;
          color: var(--color-text-secondary);
          min-width: 120px;
          max-width: 160px;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .bar-track {
          flex: 1;
          height: 20px;
          background: var(--color-bg-tertiary);
          border-radius: 4px;
          overflow: hidden;
        }

        .bar-fill {
          height: 100%;
          border-radius: 4px;
          min-width: 4px;
          transition: width 0.4s ease;
        }

        .bar-fill--green { background: #10b981; }
        .bar-fill--blue { background: #3b82f6; }

        .bar-count {
          font-size: 12px;
          font-weight: 600;
          color: var(--color-text-primary);
          min-width: 32px;
          text-align: right;
          font-family: var(--font-mono);
        }

        /* Histogram (hourly) */
        .histogram {
          display: flex;
          align-items: flex-end;
          gap: 2px;
          height: 160px;
          padding-top: 8px;
        }

        .histogram-col {
          flex: 1;
          display: flex;
          flex-direction: column;
          align-items: center;
          height: 100%;
          justify-content: flex-end;
        }

        .histogram-bar {
          width: 100%;
          background: linear-gradient(180deg, #4c6ef5 0%, #748ffc 100%);
          border-radius: 3px 3px 0 0;
          min-height: 2px;
          transition: height 0.4s ease;
        }

        .histogram-label {
          font-size: 9px;
          color: var(--color-text-tertiary);
          margin-top: 4px;
          height: 14px;
        }

        /* Weekday chart */
        .weekday-chart {
          display: flex;
          justify-content: space-between;
          align-items: flex-end;
          height: 160px;
          gap: 12px;
        }

        .weekday-col {
          flex: 1;
          display: flex;
          flex-direction: column;
          align-items: center;
          height: 100%;
        }

        .weekday-bar-wrap {
          flex: 1;
          width: 100%;
          display: flex;
          align-items: flex-end;
          justify-content: center;
        }

        .weekday-bar {
          width: 70%;
          background: linear-gradient(180deg, #f59e0b 0%, #fbbf24 100%);
          border-radius: 4px 4px 0 0;
          min-height: 2px;
          transition: height 0.4s ease;
        }

        .weekday-label {
          font-size: 11px;
          font-weight: 600;
          color: var(--color-text-secondary);
          margin-top: 6px;
        }

        .weekday-count {
          font-size: 10px;
          color: var(--color-text-tertiary);
          font-family: var(--font-mono);
        }

        /* Status distribution */
        .status-bars {
          display: flex;
          flex-direction: column;
          gap: 10px;
        }

        .status-bar-row {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .status-bar-label {
          font-size: 12px;
          font-weight: 600;
          min-width: 80px;
        }

        .status-bar-track {
          flex: 1;
          height: 24px;
          background: var(--color-bg-tertiary);
          border-radius: 4px;
          overflow: hidden;
        }

        .status-bar-fill {
          height: 100%;
          border-radius: 4px;
          min-width: 4px;
          transition: width 0.4s ease;
        }

        .status-bar-count {
          font-size: 12px;
          color: var(--color-text-secondary);
          min-width: 80px;
          text-align: right;
          font-family: var(--font-mono);
        }
      `}</style>
    </div>
  );
}

// ── Sub-component ────────────────────────────────────────────

function SummaryCard({ label, value, icon, color }: {
  label: string;
  value: string | number;
  icon: string;
  color?: string;
}) {
  return (
    <div className="summary-card">
      <span className="summary-card-icon">{icon}</span>
      <span className="summary-card-label">{label}</span>
      <span className="summary-card-value" style={{ color: color || 'var(--color-text-primary)' }}>
        {value}
      </span>
    </div>
  );
}
