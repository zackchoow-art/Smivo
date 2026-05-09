import { useState } from 'react';
import { useBackendModerationLogs, type BackendModerationLog, type LogFilters } from '@/hooks/useBackendModerationLogs';
import { DEFAULT_PAGE_SIZE } from '@/lib/constants';
import { Filter, Bot, CheckCircle, XCircle } from 'lucide-react';

export function AiReviewedPage() {
  const [aiPage, setAiPage] = useState(0);
  const [logFilters, setLogFilters] = useState<LogFilters>({ targetType: 'all', result: 'all', engine: 'all' });
  const { data: logsData, isLoading, error } = useBackendModerationLogs(aiPage, logFilters);

  return (
    <div className="lm-container">
      <div className="lm-header">
        <h1 className="lm-page-title">
          <Bot size={20} style={{ marginRight: 8, verticalAlign: 'middle' }} />
          AI Reviewed
        </h1>
      </div>

      <div className="lm-actions-row">
        <div className="lm-filters">
          <div className="lm-filter-group">
            <Filter size={14} />
            <select
              className="lm-filter-select-inline"
              value={logFilters.targetType}
              onChange={(e) => { setLogFilters(f => ({ ...f, targetType: e.target.value as any })); setAiPage(0); }}
            >
              <option value="all">All Types</option>
              <option value="listing">Listings</option>
              <option value="message">Messages</option>
              <option value="profile">Profiles</option>
            </select>
          </div>
          <div className="lm-filter-group">
            <select
              className="lm-filter-select-inline"
              value={logFilters.result}
              onChange={(e) => { setLogFilters(f => ({ ...f, result: e.target.value as any })); setAiPage(0); }}
            >
              <option value="all">All Results</option>
              <option value="pass">Pass</option>
              <option value="fail">Fail</option>
            </select>
          </div>
          <div className="lm-filter-group">
            <select
              className="lm-filter-select-inline"
              value={logFilters.engine}
              onChange={(e) => { setLogFilters(f => ({ ...f, engine: e.target.value as any })); setAiPage(0); }}
            >
              <option value="all">All Engines</option>
              <option value="openai">OpenAI</option>
              <option value="google_vision">Google Vision</option>
              <option value="sensitive_words">Sensitive Words</option>
            </select>
          </div>
        </div>
        {logsData?.count !== undefined && logsData.count > 0 && (
          <span className="lm-ai-count-label">{logsData.count} logs</span>
        )}
      </div>

      {isLoading ? (
        <div className="lm-state-msg">Loading AI review logs...</div>
      ) : error ? (
        <div className="lm-state-error">Error loading logs.</div>
      ) : (
        <div className="lm-table-wrap">
          <table className="lm-table">
            <thead className="lm-thead">
              <tr>
                <th className="lm-th">Time</th>
                <th className="lm-th">Engine</th>
                <th className="lm-th">Type</th>
                <th className="lm-th">User</th>
                <th className="lm-th">Result</th>
                <th className="lm-th">Action</th>
                <th className="lm-th">Reason</th>
              </tr>
            </thead>
            <tbody>
              {logsData?.data.length === 0 ? (
                <tr><td colSpan={7} className="lm-td-empty">No AI review logs found.</td></tr>
              ) : (
                logsData?.data.map((log: BackendModerationLog) => {
                  const flaggedImages = log.image_details?.filter(i => i.flagged) || [];
                  const textWords = log.text_details?.matched_words || [];
                  const aiCategories = Object.entries(log.text_details?.ai_text?.categories || {})
                    .filter(([, v]) => v).map(([k]) => k);
                  const reasons: string[] = [
                    ...textWords.map((w: string) => `word: ${w}`),
                    ...aiCategories.map(c => `text: ${c}`),
                    ...flaggedImages.flatMap(i => i.reasons.map(r => `img#${i.index}: ${r}`)),
                  ];
                  return (
                    <tr key={log.id} className="lm-tr">
                      <td className="lm-td lm-cell-muted" style={{ fontSize: 12 }}>
                        {new Date(log.created_at).toLocaleString()}
                      </td>
                      <td className="lm-td">
                        <span className="lm-badge lm-badge--engine">{log.engine.replace('_', ' ')}</span>
                      </td>
                      <td className="lm-td">
                        <span className="lm-badge lm-badge--neutral" style={{ textTransform: 'capitalize' }}>
                          {log.target_type}
                        </span>
                      </td>
                      <td className="lm-td">
                        <div className="lm-user-info">
                          <span className="lm-cell-text">{log.user_profile?.display_name || 'Unknown'}</span>
                          <span className="lm-cell-muted" style={{ fontSize: 11 }}>{log.user_profile?.email}</span>
                        </div>
                      </td>
                      <td className="lm-td">
                        {log.result === 'pass'
                          ? <span className="lm-badge lm-badge--success"><CheckCircle size={12} style={{ marginRight: 4 }} /> Pass</span>
                          : <span className="lm-badge lm-badge--danger"><XCircle size={12} style={{ marginRight: 4 }} /> Fail</span>
                        }
                      </td>
                      <td className="lm-td">
                        <span className={`lm-badge ${
                          log.action_taken === 'approve' ? 'lm-badge--success'
                          : log.action_taken === 'reject' ? 'lm-badge--danger'
                          : log.action_taken === 'blur' ? 'lm-badge--info'
                          : 'lm-badge--warning'
                        }`}>{log.action_taken}</span>
                      </td>
                      <td className="lm-td">
                        <div className="ai-reasons-cell">
                          {reasons.length === 0
                            ? <span className="lm-cell-muted">—</span>
                            : reasons.slice(0, 3).map((r, idx) => <span key={idx} className="ai-reason-tag">{r}</span>)
                          }
                          {reasons.length > 3 && <span className="ai-reason-more">+{reasons.length - 3} more</span>}
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      )}

      {logsData && logsData.count > DEFAULT_PAGE_SIZE && (
        <div className="lm-pagination">
          <p className="lm-pagination-info">
            Showing <strong>{aiPage * DEFAULT_PAGE_SIZE + 1}</strong> to{' '}
            <strong>{Math.min((aiPage + 1) * DEFAULT_PAGE_SIZE, logsData.count)}</strong> of{' '}
            <strong>{logsData.count}</strong> logs
          </p>
          <div className="lm-pagination-nav">
            <button onClick={() => setAiPage(p => Math.max(0, p - 1))} disabled={aiPage === 0} className="lm-page-btn lm-page-btn--left">&larr; Previous</button>
            <button onClick={() => setAiPage(p => p + 1)} disabled={(aiPage + 1) * DEFAULT_PAGE_SIZE >= logsData.count} className="lm-page-btn lm-page-btn--right">Next &rarr;</button>
          </div>
        </div>
      )}

      <style>{`
        .lm-container { padding: var(--spacing-page); max-width: 1280px; margin: 0 auto; }
        .lm-header { margin-bottom: 24px; }
        .lm-page-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0; display: flex; align-items: center; }
        .lm-actions-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .lm-filters { display: flex; gap: 12px; }
        .lm-filter-group { display: flex; align-items: center; gap: 8px; background: var(--color-bg-primary); border: 1px solid var(--color-border); border-radius: var(--radius-md); padding: 6px 12px; color: var(--color-text-tertiary); }
        .lm-filter-select-inline { border: none; background: transparent; font-size: 13px; color: var(--color-text-primary); outline: none; cursor: pointer; }
        .lm-ai-count-label { background: #f0f4ff; color: #4338ca; font-size: 11px; font-weight: 500; padding: 4px 10px; border-radius: 4px; border: 1px solid #e0e7ff; }
        .lm-state-msg { padding: 48px; text-align: center; color: var(--color-text-secondary); font-size: 14px; }
        .lm-state-error { padding: 16px; background: var(--color-danger-light); color: var(--color-danger); border-radius: var(--radius-sm); font-size: 14px; }
        .lm-table-wrap { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); overflow: hidden; }
        .lm-table { width: 100%; border-collapse: collapse; }
        .lm-thead { background: var(--color-bg-secondary); }
        .lm-th { padding: 12px 20px; text-align: left; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--color-text-secondary); border-bottom: 1px solid var(--color-border-light); }
        .lm-tr:hover { background: var(--color-bg-secondary); }
        .lm-td { padding: 14px 20px; font-size: 13px; border-bottom: 1px solid var(--color-border-light); white-space: nowrap; }
        .lm-td-empty { padding: 24px; text-align: center; font-size: 13px; color: var(--color-text-secondary); }
        .lm-cell-text { color: var(--color-text-primary); }
        .lm-cell-muted { color: var(--color-text-secondary); }
        .lm-user-info { display: flex; flex-direction: column; gap: 2px; }
        .lm-badge { display: inline-flex; align-items: center; padding: 2px 8px; font-size: 11px; font-weight: 600; border-radius: 999px; white-space: nowrap; }
        .lm-badge--warning { background: var(--color-warning-light); color: var(--color-warning); }
        .lm-badge--success { background: var(--color-success-light); color: var(--color-success); }
        .lm-badge--danger  { background: var(--color-danger-light);  color: var(--color-danger); }
        .lm-badge--info    { background: var(--color-info-light);    color: var(--color-info); }
        .lm-badge--neutral { background: var(--color-bg-tertiary);   color: var(--color-text-secondary); }
        .lm-badge--engine  { background: rgba(139,92,246,0.1); color: #8b5cf6; text-transform: capitalize; }
        .lm-pagination { margin-top: 16px; display: flex; align-items: center; justify-content: space-between; background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); padding: 12px 20px; }
        .lm-pagination-info { font-size: 13px; color: var(--color-text-secondary); margin: 0; }
        .lm-pagination-nav { display: flex; gap: 4px; }
        .lm-page-btn { padding: 6px 12px; font-size: 13px; border: 1px solid var(--color-border); background: var(--color-bg-primary); color: var(--color-text-secondary); cursor: pointer; }
        .lm-page-btn--left  { border-radius: var(--radius-sm) 0 0 var(--radius-sm); }
        .lm-page-btn--right { border-radius: 0 var(--radius-sm) var(--radius-sm) 0; }
        .lm-page-btn:hover:not(:disabled) { background: var(--color-bg-secondary); }
        .lm-page-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .ai-reasons-cell { display: flex; flex-wrap: wrap; gap: 4px; max-width: 280px; }
        .ai-reason-tag { display: inline-flex; padding: 2px 6px; font-size: 10px; font-weight: 500; background: var(--color-danger-light); color: var(--color-danger); border-radius: 4px; white-space: nowrap; }
        .ai-reason-more { font-size: 10px; color: var(--color-text-tertiary); align-self: center; }
      `}</style>
    </div>
  );
}
