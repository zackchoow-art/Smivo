import { Link } from 'react-router-dom';
import { useRecentPushJobs } from '@/hooks/usePush';

export function PushOverviewPage() {
  const { data: recentJobs, isLoading, error } = useRecentPushJobs(5);

  const getJobStatusClass = (status: string) => {
    if (status === 'sent')   return 'po-badge po-badge--success';
    if (status === 'draft')  return 'po-badge po-badge--neutral';
    if (status === 'failed') return 'po-badge po-badge--danger';
    return 'po-badge po-badge--info';
  };

  return (
    <div className="po-container">
      <div className="po-header">
        <h1 className="po-page-title">Push Notifications Overview</h1>
        <Link to="/push/new" className="po-btn-create">Create New Push</Link>
      </div>

      <div className="po-layout">

        {/* Quick Actions / Stats Card */}
        <div className="po-quick-card">
          <h2 className="po-card-title">Quick Actions</h2>
          <div className="po-action-links">
            <Link to="/push/new" className="po-action-link po-action-link--primary">
              Draft New Message
            </Link>
            <Link to="/push/history" className="po-action-link po-action-link--ghost">
              View Full History
            </Link>
          </div>

          <div className="po-stats-section">
            <h3 className="po-stats-label">Quick Stats (Last 30 Days)</h3>
            <div className="po-stat-row">
              <span className="po-stat-name">Messages Sent</span>
              <span className="po-stat-val">--</span>
            </div>
            <div className="po-stat-row">
              <span className="po-stat-name">Avg Open Rate</span>
              <span className="po-stat-val">--%</span>
            </div>
          </div>
        </div>

        {/* Recent History */}
        <div className="po-recent-card">
          <div className="po-recent-header">
            <h2 className="po-card-title">Recent Activity</h2>
            <Link to="/push/history" className="po-view-all-link">View All</Link>
          </div>

          {isLoading ? (
            <div className="po-state-msg">Loading recent activity...</div>
          ) : error ? (
            <div className="po-state-msg po-state-error">Failed to load recent activity.</div>
          ) : recentJobs && recentJobs.length > 0 ? (
            <ul className="po-activity-list">
              {recentJobs.map(job => (
                <li key={job.id} className="po-activity-item">
                  <div className="po-activity-info">
                    <p className="po-activity-title">{job.title}</p>
                    <p className="po-activity-body">{job.body}</p>
                    <p className="po-activity-date">{new Date(job.created_at).toLocaleString()}</p>
                  </div>
                  <div className="po-activity-meta">
                    <span className={getJobStatusClass(job.status)}>{job.status}</span>
                    <div className="po-activity-audience">Audience: {job.audience_type}</div>
                  </div>
                </li>
              ))}
            </ul>
          ) : (
            <div className="po-state-msg">No recent push jobs found.</div>
          )}
        </div>

      </div>

      <style>{`
        .po-container { padding: var(--spacing-page); max-width: 1280px; margin: 0 auto; display: flex; flex-direction: column; gap: 24px; }
        .po-header { display: flex; justify-content: space-between; align-items: center; }
        .po-page-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .po-btn-create { padding: 8px 16px; background: var(--color-info); color: #fff; border-radius: var(--radius-sm); font-size: 13px; font-weight: 500; text-decoration: none; }
        .po-btn-create:hover { opacity: 0.88; }
        .po-layout { display: grid; grid-template-columns: 1fr 2fr; gap: 24px; }
        @media (max-width: 768px) { .po-layout { grid-template-columns: 1fr; } }

        /* Quick actions card */
        .po-quick-card { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); padding: 24px; display: flex; flex-direction: column; gap: 24px; }
        .po-card-title { font-size: 17px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .po-action-links { display: flex; flex-direction: column; gap: 12px; }
        .po-action-link { display: block; text-align: center; padding: 12px 16px; border-radius: var(--radius-sm); font-weight: 500; font-size: 14px; text-decoration: none; }
        .po-action-link--primary { border: 1px solid var(--color-info); color: var(--color-info); background: transparent; }
        .po-action-link--primary:hover { background: var(--color-info-light); }
        .po-action-link--ghost { border: 1px solid var(--color-border); color: var(--color-text-primary); background: transparent; }
        .po-action-link--ghost:hover { background: var(--color-bg-secondary); }
        .po-stats-section { border-top: 1px solid var(--color-border-light); padding-top: 24px; display: flex; flex-direction: column; gap: 12px; }
        .po-stats-label { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--color-text-secondary); margin: 0 0 4px; }
        .po-stat-row { display: flex; justify-content: space-between; align-items: center; }
        .po-stat-name { font-size: 13px; color: var(--color-text-secondary); }
        .po-stat-val { font-size: 14px; font-weight: 700; color: var(--color-text-primary); }

        /* Recent activity card */
        .po-recent-card { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); overflow: hidden; }
        .po-recent-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid var(--color-border-light); }
        .po-view-all-link { font-size: 13px; color: var(--color-info); font-weight: 500; text-decoration: none; }
        .po-view-all-link:hover { text-decoration: underline; }
        .po-state-msg { padding: 32px; text-align: center; color: var(--color-text-secondary); font-size: 14px; }
        .po-state-error { color: var(--color-danger); }
        .po-activity-list { list-style: none; padding: 0; margin: 0; }
        .po-activity-item { display: flex; align-items: center; justify-content: space-between; padding: 16px 24px; border-bottom: 1px solid var(--color-border-light); }
        .po-activity-item:last-child { border-bottom: none; }
        .po-activity-item:hover { background: var(--color-bg-secondary); }
        .po-activity-info { display: flex; flex-direction: column; gap: 4px; }
        .po-activity-title { font-size: 13px; font-weight: 500; color: var(--color-text-primary); margin: 0; }
        .po-activity-body { font-size: 12px; color: var(--color-text-secondary); max-width: 400px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin: 0; }
        .po-activity-date { font-size: 11px; color: var(--color-text-tertiary); margin: 0; }
        .po-activity-meta { display: flex; flex-direction: column; align-items: flex-end; gap: 8px; }
        .po-activity-audience { font-size: 11px; color: var(--color-text-secondary); }
        .po-badge { display: inline-flex; padding: 2px 8px; font-size: 11px; font-weight: 600; border-radius: 999px; }
        .po-badge--success { background: var(--color-success-light); color: var(--color-success); }
        .po-badge--neutral { background: var(--color-bg-tertiary);   color: var(--color-text-secondary); }
        .po-badge--danger  { background: var(--color-danger-light);  color: var(--color-danger); }
        .po-badge--info    { background: var(--color-info-light);    color: var(--color-info); }
      `}</style>
    </div>
  );
}
