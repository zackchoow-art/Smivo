import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ChevronLeft, User, AlertTriangle, Shield, CheckCircle, XCircle } from 'lucide-react';
import { useChatReport, useResolveReport } from '@/hooks/useChatReports';
import { useAuth } from '@/hooks/useAuth';

export function ChatReportDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { admin } = useAuth();
  const { data: report, isLoading, error } = useChatReport(id);
  const resolveMutation = useResolveReport();

  const [note, setNote] = useState('');
  const [resolution, setResolution] = useState<'dismiss' | 'warn' | 'ban'>('dismiss');

  if (isLoading) return <div className="loading-state">Loading report details...</div>;
  if (error || !report) return <div className="error-state">Report not found</div>;

  const handleResolve = async () => {
    if (!admin) return;
    try {
      await resolveMutation.mutateAsync({
        reportId: report.id,
        resolution,
        note,
        adminId: admin.user_id
      });
      alert('Report resolved successfully');
      navigate('/moderation/chat-reports');
    } catch (err) {
      console.error(err);
      alert('Failed to resolve report');
    }
  };

  return (
    <div className="detail-container">
      <header className="detail-header">
        <button className="back-btn" onClick={() => navigate('/moderation/chat-reports')}>
          <ChevronLeft size={20} />
          Back to Reports
        </button>
        <div className="header-info">
          <h1 className="page-title">Report Detail</h1>
          <span className={`status-tag status-${report.status}`}>{report.status.toUpperCase()}</span>
        </div>
      </header>

      <div className="detail-grid">
        <div className="info-section main-info">
          <section className="report-content">
            <h2 className="section-title">Reported Content</h2>
            <div className="content-card">
              <div className="reason-header">
                <span className="reason-label">Reason: {report.reason.toUpperCase()}</span>
                <span className="timestamp">{new Date(report.created_at).toLocaleString()}</span>
              </div>
              <p className="report-detail">{report.detail || 'No detailed description provided.'}</p>
              
              {report.screenshot_urls && report.screenshot_urls.length > 0 && (
                <div className="screenshot-gallery">
                  {report.screenshot_urls.map((url, idx) => (
                    <img key={idx} src={url} alt={`Evidence ${idx + 1}`} className="evidence-img" />
                  ))}
                </div>
              )}
            </div>
          </section>

          <section className="involved-parties">
            <h2 className="section-title">Involved Parties</h2>
            <div className="parties-grid">
              <div className="party-card">
                <h3 className="party-label">Reporter</h3>
                <div className="user-info">
                  <div className="user-avatar"><User size={20} /></div>
                  <div>
                    <div className="user-name">{report.reporter_name || 'Anonymous'}</div>
                    <div className="user-email">{report.reporter_email}</div>
                  </div>
                </div>
              </div>
              <div className="party-card highlight">
                <h3 className="party-label">Reported User</h3>
                <div className="user-info">
                  <div className="user-avatar"><User size={20} /></div>
                  <div>
                    <div className="user-name">{report.reported_name || 'Unknown'}</div>
                    <div className="user-email">{report.reported_email}</div>
                  </div>
                </div>
              </div>
            </div>
          </section>
        </div>

        <aside className="action-section">
          <div className="action-card">
            <h2 className="section-title">Moderation Action</h2>
            
            {report.status === 'pending' ? (
              <div className="resolution-form">
                <div className="form-group">
                  <label>Resolution Type</label>
                  <div className="resolution-options">
                    <button 
                      className={`option-btn ${resolution === 'dismiss' ? 'active' : ''}`}
                      onClick={() => setResolution('dismiss')}
                    >
                      <XCircle size={16} /> Dismiss
                    </button>
                    <button 
                      className={`option-btn ${resolution === 'warn' ? 'active' : ''}`}
                      onClick={() => setResolution('warn')}
                    >
                      <AlertTriangle size={16} /> Warn
                    </button>
                    <button 
                      className={`option-btn ${resolution === 'ban' ? 'active' : ''}`}
                      onClick={() => setResolution('ban')}
                    >
                      <Shield size={16} /> Ban
                    </button>
                  </div>
                </div>

                <div className="form-group">
                  <label>Resolution Note</label>
                  <textarea 
                    placeholder="Add an internal note about this decision..."
                    value={note}
                    onChange={(e) => setNote(e.target.value)}
                    rows={4}
                  />
                </div>

                <button 
                  className="submit-btn" 
                  onClick={handleResolve}
                  disabled={resolveMutation.isPending}
                >
                  {resolveMutation.isPending ? 'Processing...' : 'Confirm Resolution'}
                </button>
              </div>
            ) : (
              <div className="resolution-summary">
                <div className="resolved-banner">
                  <CheckCircle size={24} />
                  <div>
                    <div className="resolved-title">Report {report.status === 'dismissed' ? 'Dismissed' : 'Resolved'}</div>
                    <div className="resolved-subtitle">by System Admin</div>
                  </div>
                </div>
                <div className="summary-field">
                  <span className="label">Resolution:</span>
                  <span className="value">{report.resolution?.toUpperCase() || 'N/A'}</span>
                </div>
                <div className="summary-field">
                  <span className="label">Resolved At:</span>
                  <span className="value">{report.resolved_at ? new Date(report.resolved_at).toLocaleString() : 'N/A'}</span>
                </div>
                <div className="summary-note">
                  <span className="label">Internal Note:</span>
                  <p>{report.resolution_note || 'No note provided.'}</p>
                </div>
              </div>
            )}
          </div>
        </aside>
      </div>

      <style>{`
        .detail-container {
          padding: var(--spacing-page);
          max-width: 1200px;
          margin: 0 auto;
        }

        .detail-header {
          display: flex;
          flex-direction: column;
          gap: 16px;
          margin-bottom: 24px;
        }

        .back-btn {
          display: flex;
          align-items: center;
          gap: 4px;
          background: none;
          border: none;
          color: var(--color-text-tertiary);
          font-size: 14px;
          font-weight: 500;
          cursor: pointer;
          width: fit-content;
        }

        .back-btn:hover {
          color: var(--color-info);
        }

        .header-info {
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .page-title {
          font-size: 28px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .status-tag {
          padding: 4px 12px;
          border-radius: 20px;
          font-size: 12px;
          font-weight: 700;
          letter-spacing: 0.5px;
        }

        .status-pending { background: var(--color-warning-light); color: var(--color-warning); }
        .status-resolved { background: var(--color-success-light); color: var(--color-success); }
        .status-dismissed { background: var(--color-bg-tertiary); color: var(--color-text-tertiary); }

        .detail-grid {
          display: grid;
          grid-template-columns: 1fr 350px;
          gap: 24px;
        }

        .section-title {
          font-size: 16px;
          font-weight: 600;
          color: var(--color-text-secondary);
          margin-bottom: 12px;
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        .content-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-lg);
          padding: 24px;
          box-shadow: var(--shadow-card);
        }

        .reason-header {
          display: flex;
          justify-content: space-between;
          margin-bottom: 16px;
          border-bottom: 1px solid var(--color-border-light);
          padding-bottom: 12px;
        }

        .reason-label {
          font-weight: 700;
          color: var(--color-danger);
        }

        .timestamp {
          font-size: 13px;
          color: var(--color-text-tertiary);
          font-family: var(--font-mono);
        }

        .report-detail {
          font-size: 15px;
          line-height: 1.6;
          color: var(--color-text-primary);
          white-space: pre-wrap;
          margin-bottom: 20px;
        }

        .screenshot-gallery {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
          gap: 12px;
        }

        .evidence-img {
          width: 100%;
          border-radius: var(--radius-md);
          border: 1px solid var(--color-border-light);
        }

        .involved-parties {
          margin-top: 32px;
        }

        .parties-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 16px;
        }

        .party-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-lg);
          padding: 16px;
        }

        .party-card.highlight {
          border-color: var(--color-danger-light);
          background: var(--color-bg-secondary);
        }

        .party-label {
          font-size: 12px;
          font-weight: 700;
          color: var(--color-text-tertiary);
          text-transform: uppercase;
          margin-bottom: 12px;
        }

        .user-info {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .user-avatar {
          width: 40px;
          height: 40px;
          border-radius: 50%;
          background: var(--color-bg-tertiary);
          display: flex;
          align-items: center;
          justify-content: center;
          color: var(--color-text-secondary);
        }

        .user-name {
          font-weight: 600;
          color: var(--color-text-primary);
        }

        .user-email {
          font-size: 13px;
          color: var(--color-text-tertiary);
        }

        .action-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-lg);
          padding: 24px;
          position: sticky;
          top: 80px;
          box-shadow: var(--shadow-card);
        }

        .form-group {
          margin-bottom: 20px;
        }

        .form-group label {
          display: block;
          font-size: 13px;
          font-weight: 600;
          color: var(--color-text-secondary);
          margin-bottom: 8px;
        }

        .resolution-options {
          display: grid;
          grid-template-columns: 1fr 1fr 1fr;
          gap: 8px;
        }

        .option-btn {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 6px;
          padding: 10px;
          border: 1px solid var(--color-border);
          background: var(--color-bg-primary);
          border-radius: var(--radius-md);
          font-size: 12px;
          font-weight: 600;
          color: var(--color-text-secondary);
          cursor: pointer;
          transition: all 0.2s;
        }

        .option-btn:hover {
          background: var(--color-bg-secondary);
        }

        .option-btn.active {
          border-color: var(--color-info);
          background: var(--color-info-light);
          color: var(--color-info);
        }

        textarea {
          width: 100%;
          padding: 12px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          font-family: inherit;
          font-size: 14px;
          resize: vertical;
          outline: none;
        }

        textarea:focus {
          border-color: var(--color-info);
        }

        .submit-btn {
          width: 100%;
          padding: 12px;
          background: var(--color-info);
          color: white;
          border: none;
          border-radius: var(--radius-md);
          font-size: 14px;
          font-weight: 700;
          cursor: pointer;
          transition: background-color 0.2s;
        }

        .submit-btn:hover {
          background: #3b5bdb;
        }

        .submit-btn:disabled {
          opacity: 0.6;
          cursor: not-allowed;
        }

        .resolved-banner {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 16px;
          background: var(--color-success-light);
          color: var(--color-success);
          border-radius: var(--radius-md);
          margin-bottom: 20px;
        }

        .resolved-title {
          font-weight: 700;
          font-size: 16px;
        }

        .resolved-subtitle {
          font-size: 12px;
          opacity: 0.8;
        }

        .summary-field {
          display: flex;
          justify-content: space-between;
          margin-bottom: 12px;
          font-size: 14px;
        }

        .summary-field .label {
          color: var(--color-text-tertiary);
        }

        .summary-field .value {
          font-weight: 600;
          color: var(--color-text-primary);
        }

        .summary-note {
          margin-top: 20px;
          padding-top: 16px;
          border-top: 1px solid var(--color-border-light);
        }

        .summary-note .label {
          display: block;
          font-size: 12px;
          font-weight: 700;
          color: var(--color-text-tertiary);
          text-transform: uppercase;
          margin-bottom: 8px;
        }

        .summary-note p {
          font-size: 14px;
          color: var(--color-text-secondary);
          line-height: 1.5;
        }

        .loading-state, .error-state {
          padding: 100px;
          text-align: center;
          color: var(--color-text-tertiary);
          font-size: 18px;
        }
      `}</style>
    </div>
  );
}
