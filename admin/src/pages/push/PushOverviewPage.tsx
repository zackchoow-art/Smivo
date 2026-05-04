import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useRecentPushJobs, usePendingRentalReminders, useTriggerRentalReminders } from '@/hooks/usePush';
import { showToast } from '@/hooks/useToast';

export function PushOverviewPage() {
  const { data: recentJobs, isLoading, error } = useRecentPushJobs(5);
  const { data: pendingReminders, isLoading: remindersLoading, refetch: refetchReminders } = usePendingRentalReminders();
  const triggerMutation = useTriggerRentalReminders();

  // Track expanded rows for notification preview
  const [expandedRows, setExpandedRows] = useState<Set<string>>(new Set());

  const toggleRow = (orderId: string) => {
    setExpandedRows(prev => {
      const next = new Set(prev);
      if (next.has(orderId)) next.delete(orderId);
      else next.add(orderId);
      return next;
    });
  };

  const getJobStatusClass = (status: string) => {
    if (status === 'sent')   return 'po-badge po-badge--success';
    if (status === 'draft')  return 'po-badge po-badge--neutral';
    if (status === 'failed') return 'po-badge po-badge--danger';
    return 'po-badge po-badge--info';
  };

  // Returns the label and CSS class for how soon the push will fire.
  // Uses days_until_send (relative to today) for the pill style,
  // and scheduled_send_date for the precise formatted date.
  const getScheduleSendLabel = (daysUntilSend: number) => {
    if (daysUntilSend < 0)   return { text: 'Overdue',  cls: 'rr-send-badge rr-send-badge--overdue' };
    if (daysUntilSend === 0) return { text: 'Today',    cls: 'rr-send-badge rr-send-badge--today' };
    if (daysUntilSend === 1) return { text: 'Tomorrow', cls: 'rr-send-badge rr-send-badge--soon' };
    return { text: `In ${daysUntilSend}d`, cls: 'rr-send-badge rr-send-badge--future' };
  };

  const handleTriggerReminders = async () => {
    try {
      const result = await triggerMutation.mutateAsync();
      showToast(result.message, 'success');
      refetchReminders();
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      showToast(`Failed to trigger reminders: ${message}`, 'error');
    }
  };

  const reminderCount = pendingReminders?.length ?? 0;

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

      {/* ── Rental Reminder Queue ─────────────────────────────── */}
      <div className="rr-card">
        <div className="rr-card-header">
          <div className="rr-header-left">
            <div className="rr-title-row">
              <h2 className="rr-card-title">Rental Reminder Queue</h2>
              {reminderCount > 0 && (
                <span className="rr-count-badge">{reminderCount} pending</span>
              )}
            </div>
            <p className="rr-card-subtitle">
              Active rentals whose reminder window has arrived. Run the scheduler to dispatch push notifications.
            </p>
          </div>
          <button
            className="rr-trigger-btn"
            onClick={handleTriggerReminders}
            disabled={triggerMutation.isPending || reminderCount === 0}
          >
            {triggerMutation.isPending ? (
              <>
                <span className="rr-spinner" />
                Processing...
              </>
            ) : (
              <>
                ▶ Run Scheduler Now
              </>
            )}
          </button>
        </div>

        {remindersLoading ? (
          <div className="rr-state-msg">Loading reminder queue...</div>
        ) : reminderCount === 0 ? (
          <div className="rr-state-empty">
            <div className="rr-empty-icon">🎉</div>
            <div className="rr-empty-text">No pending rental reminders</div>
            <div className="rr-empty-sub">All reminders are up to date or no rentals are expiring within the reminder window.</div>
          </div>
        ) : (
          <div className="rr-table-wrap">
            <table className="rr-table">
              <thead className="rr-thead">
                <tr>
                  <th className="rr-th">Buyer</th>
                  <th className="rr-th">Item / Order</th>
                  <th className="rr-th">Rental Expiry</th>
                  <th className="rr-th rr-th--highlight">Scheduled Push</th>
                  <th className="rr-th">Channels</th>
                  <th className="rr-th">Notification Preview</th>
                </tr>
              </thead>
              <tbody>
                {pendingReminders?.map((reminder) => (
                  <>
                    <tr
                      key={reminder.order_id}
                      className="rr-tr"
                      onClick={() => toggleRow(reminder.order_id)}
                    >
                      {/* Buyer */}
                      <td className="rr-td">
                        <div className="rr-buyer-name">{reminder.buyer_name}</div>
                        <div className="rr-buyer-email">{reminder.buyer_email}</div>
                      </td>

                      {/* Item / Order */}
                      <td className="rr-td">
                        <div className="rr-listing-title">{reminder.listing_title}</div>
                        <div className="rr-order-id">#{reminder.order_id.slice(0, 8)}</div>
                      </td>

                      {/* Rental expiry date */}
                      <td className="rr-td rr-td--nowrap">
                        <div className="rr-expiry-date">
                          {new Date(reminder.rental_end_date).toLocaleDateString(undefined, {
                            month: 'short', day: 'numeric', year: 'numeric',
                          })}
                        </div>
                        <div className="rr-expiry-sub">
                          {reminder.days_until_expiry === 0
                            ? 'expires today'
                            : `in ${reminder.days_until_expiry} day${reminder.days_until_expiry === 1 ? '' : 's'}`}
                        </div>
                      </td>

                      {/* Scheduled Push — the exact date the cron will fire */}
                      <td className="rr-td rr-td--nowrap">
                        <div className="rr-send-date">
                          {reminder.scheduled_send_date.toLocaleDateString(undefined, {
                            month: 'short', day: 'numeric', year: 'numeric',
                          })}
                          <span className="rr-send-time">~08:00 UTC</span>
                        </div>
                        {(() => {
                          const { text, cls } = getScheduleSendLabel(reminder.days_until_send);
                          return <span className={cls}>{text}</span>;
                        })()}
                      </td>

                      {/* Channels */}
                      <td className="rr-td">
                        <div className="rr-channels">
                          <span className="rr-channel-badge rr-channel-badge--push">Push</span>
                          {reminder.reminder_email && (
                            <span className="rr-channel-badge rr-channel-badge--email">Email</span>
                          )}
                        </div>
                      </td>

                      {/* Preview toggle */}
                      <td className="rr-td rr-td--preview">
                        <div className="rr-preview-toggle">
                          <span className="rr-preview-text">{reminder.notification_preview}</span>
                          <span className="rr-chevron">
                            {expandedRows.has(reminder.order_id) ? '▲' : '▼'}
                          </span>
                        </div>
                      </td>
                    </tr>

                    {/* Expanded detail row — notification template */}
                    {expandedRows.has(reminder.order_id) && (
                      <tr key={`${reminder.order_id}-detail`} className="rr-detail-row">
                        <td colSpan={6} className="rr-detail-td">
                          <div className="rr-detail-grid">
                            <div className="rr-detail-block">
                              <div className="rr-detail-label">PUSH NOTIFICATION TEMPLATE</div>
                              <div className="rr-notification-card">
                                <div className="rr-notif-app">Smivo</div>
                                <div className="rr-notif-title">Rental Expiring Soon</div>
                                <div className="rr-notif-body">{reminder.notification_preview}</div>
                              </div>
                            </div>
                            <div className="rr-detail-block">
                              <div className="rr-detail-label">DELIVERY SETTINGS</div>
                              <div className="rr-detail-rows">
                                <div className="rr-detail-row-item">
                                  <span className="rr-detail-key">Scheduled Push Date</span>
                                  <span className="rr-detail-val rr-detail-val--highlight">
                                    {reminder.scheduled_send_date.toLocaleDateString(undefined, {
                                      weekday: 'short', year: 'numeric', month: 'long', day: 'numeric',
                                    })}
                                    {' '}at 08:00 UTC
                                  </span>
                                </div>
                                <div className="rr-detail-row-item">
                                  <span className="rr-detail-key">Reminder Window</span>
                                  <span className="rr-detail-val">
                                    {reminder.reminder_days_before} day{reminder.reminder_days_before !== 1 ? 's' : ''} before expiry
                                  </span>
                                </div>
                                <div className="rr-detail-row-item">
                                  <span className="rr-detail-key">Push Notification</span>
                                  <span className="rr-detail-val rr-detail-val--yes">✓ Enabled</span>
                                </div>
                                <div className="rr-detail-row-item">
                                  <span className="rr-detail-key">Email Notification</span>
                                  <span className={reminder.reminder_email ? 'rr-detail-val rr-detail-val--yes' : 'rr-detail-val rr-detail-val--no'}>
                                    {reminder.reminder_email ? '✓ Requested' : '✗ Not requested'}
                                  </span>
                                </div>
                                <div className="rr-detail-row-item">
                                  <span className="rr-detail-key">Rental End Date</span>
                                  <span className="rr-detail-val">
                                    {new Date(reminder.rental_end_date).toLocaleDateString(undefined, {
                                      weekday: 'short', year: 'numeric', month: 'long', day: 'numeric',
                                    })}
                                  </span>
                                </div>
                              </div>
                            </div>
                          </div>
                        </td>
                      </tr>
                    )}
                  </>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <style>{`
        /* ─── Existing layout ─── */
        .po-container { padding: var(--spacing-page); max-width: 1280px; margin: 0 auto; display: flex; flex-direction: column; gap: 24px; }
        .po-header { display: flex; justify-content: space-between; align-items: center; }
        .po-page-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .po-btn-create { padding: 8px 16px; background: var(--color-info); color: #fff; border-radius: var(--radius-sm); font-size: 13px; font-weight: 500; text-decoration: none; }
        .po-btn-create:hover { opacity: 0.88; }
        .po-layout { display: grid; grid-template-columns: 1fr 2fr; gap: 24px; }
        @media (max-width: 768px) { .po-layout { grid-template-columns: 1fr; } }

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

        /* ─── Rental Reminder Queue Card ─── */
        .rr-card { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); overflow: hidden; }
        .rr-card-header { display: flex; justify-content: space-between; align-items: flex-start; padding: 20px 24px; border-bottom: 1px solid var(--color-border-light); gap: 16px; }
        .rr-header-left { display: flex; flex-direction: column; gap: 4px; }
        .rr-title-row { display: flex; align-items: center; gap: 10px; }
        .rr-card-title { font-size: 17px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .rr-card-subtitle { font-size: 13px; color: var(--color-text-secondary); margin: 0; }
        .rr-count-badge { display: inline-flex; align-items: center; padding: 2px 10px; background: var(--color-warning-light); color: var(--color-warning); font-size: 12px; font-weight: 700; border-radius: 999px; }

        .rr-trigger-btn {
          display: flex; align-items: center; gap: 8px;
          padding: 10px 20px; border: none; border-radius: var(--radius-sm);
          background: var(--color-info); color: #fff;
          font-size: 13px; font-weight: 600; cursor: pointer;
          white-space: nowrap; transition: opacity 0.15s;
          flex-shrink: 0;
        }
        .rr-trigger-btn:hover:not(:disabled) { opacity: 0.88; }
        .rr-trigger-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .rr-spinner {
          width: 14px; height: 14px; border: 2px solid rgba(255,255,255,0.3);
          border-top-color: #fff; border-radius: 50%;
          animation: rr-spin 0.7s linear infinite;
          display: inline-block; flex-shrink: 0;
        }
        @keyframes rr-spin { to { transform: rotate(360deg); } }

        .rr-state-msg { padding: 32px; text-align: center; color: var(--color-text-secondary); font-size: 14px; }
        .rr-state-empty { display: flex; flex-direction: column; align-items: center; gap: 8px; padding: 48px 24px; }
        .rr-empty-icon { font-size: 36px; }
        .rr-empty-text { font-size: 15px; font-weight: 600; color: var(--color-text-primary); }
        .rr-empty-sub { font-size: 13px; color: var(--color-text-secondary); text-align: center; max-width: 400px; }

        .rr-table-wrap { overflow-x: auto; }
        .rr-table { width: 100%; border-collapse: collapse; }
        .rr-thead { background: var(--color-bg-secondary); }
        .rr-th { padding: 10px 16px; text-align: left; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--color-text-secondary); border-bottom: 1px solid var(--color-border-light); }
        .rr-tr { cursor: pointer; transition: background 0.1s; }
        .rr-tr:hover { background: var(--color-bg-secondary); }
        .rr-td { padding: 12px 16px; font-size: 13px; border-bottom: 1px solid var(--color-border-light); vertical-align: middle; }
        .rr-td--nowrap { white-space: nowrap; }
        .rr-td--preview { min-width: 220px; }

        .rr-buyer-name { font-weight: 500; color: var(--color-text-primary); }
        .rr-buyer-email { font-size: 12px; color: var(--color-text-secondary); margin-top: 2px; }
        .rr-listing-title { font-weight: 500; color: var(--color-text-primary); max-width: 180px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .rr-order-id { font-size: 12px; color: var(--color-text-tertiary); font-family: monospace; margin-top: 2px; }

        .rr-urgency { display: inline-flex; padding: 3px 10px; font-size: 11px; font-weight: 700; border-radius: 999px; }
        .rr-urgency--critical { background: #ffe3e3; color: #c92a2a; }
        .rr-urgency--high     { background: #fff3cd; color: #c67e00; }
        .rr-urgency--normal   { background: var(--color-info-light); color: var(--color-info); }

        .rr-channels { display: flex; gap: 6px; flex-wrap: wrap; }
        .rr-channel-badge { padding: 2px 8px; font-size: 11px; font-weight: 600; border-radius: 4px; }
        .rr-channel-badge--push  { background: #dbe4ff; color: #4263eb; }
        .rr-channel-badge--email { background: #e6fcf5; color: #087f5b; }

        .rr-preview-toggle { display: flex; align-items: center; justify-content: space-between; gap: 8px; }
        .rr-preview-text { font-size: 12px; color: var(--color-text-secondary); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 180px; }
        .rr-chevron { font-size: 10px; color: var(--color-text-tertiary); flex-shrink: 0; }

        /* Expanded detail row */
        .rr-detail-row { background: var(--color-bg-secondary); }
        .rr-detail-td { padding: 16px 24px; border-bottom: 1px solid var(--color-border-light); }
        .rr-detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
        @media (max-width: 900px) { .rr-detail-grid { grid-template-columns: 1fr; } }
        .rr-detail-block { display: flex; flex-direction: column; gap: 12px; }
        .rr-detail-label { font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: var(--color-text-tertiary); }

        /* Push notification preview card */
        .rr-notification-card {
          background: #fff; border: 1px solid #e9ecef; border-radius: 12px;
          padding: 12px 16px; display: flex; flex-direction: column; gap: 2px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.08); max-width: 320px;
        }
        .rr-notif-app { font-size: 10px; font-weight: 700; color: #868e96; text-transform: uppercase; letter-spacing: 0.05em; }
        .rr-notif-title { font-size: 13px; font-weight: 700; color: #212529; }
        .rr-notif-body { font-size: 12px; color: #495057; }

        .rr-detail-rows { display: flex; flex-direction: column; gap: 8px; }
        .rr-detail-row-item { display: flex; justify-content: space-between; align-items: center; font-size: 13px; }
        .rr-detail-key { color: var(--color-text-secondary); }
        .rr-detail-val { font-weight: 500; color: var(--color-text-primary); }
        .rr-detail-val--yes { color: var(--color-success); }
        .rr-detail-val--no  { color: var(--color-text-tertiary); }
        .rr-detail-val--highlight { color: var(--color-info); font-weight: 700; }

        /* Scheduled Push column */
        .rr-th--highlight { color: var(--color-info); }
        .rr-expiry-date { font-size: 13px; font-weight: 500; color: var(--color-text-primary); }
        .rr-expiry-sub  { font-size: 11px; color: var(--color-text-secondary); margin-top: 2px; }
        .rr-send-date {
          display: flex; align-items: baseline; gap: 6px;
          font-size: 13px; font-weight: 700; color: var(--color-info);
          margin-bottom: 4px;
        }
        .rr-send-time { font-size: 11px; font-weight: 400; color: var(--color-text-tertiary); }
        .rr-send-badge {
          display: inline-flex; padding: 2px 8px; font-size: 11px;
          font-weight: 700; border-radius: 999px;
        }
        .rr-send-badge--overdue { background: #ffe3e3; color: #c92a2a; }
        .rr-send-badge--today   { background: #fff3cd; color: #b36200; }
        .rr-send-badge--soon    { background: #dbe4ff; color: #3b5bdb; }
        .rr-send-badge--future  { background: var(--color-bg-tertiary); color: var(--color-text-secondary); }
      `}</style>
    </div>
  );
}
