import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ChevronLeft, User, Smartphone, Globe, Code, Tag, Award,  CheckCircle } from 'lucide-react';
import { useFeedback, useResolveFeedback } from '@/hooks/useFeedbacks';
import { useAuth } from '@/hooks/useAuth';
import { FEEDBACK_JUDGMENTS, CONTRIBUTION_POINTS } from '@/lib/constants';
import type { FeedbackJudgment } from '@/types/feedback';

export function FeedbackDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { admin } = useAuth();
  const { data: feedback, isLoading, error } = useFeedback(id);
  const resolveMutation = useResolveFeedback();

  const [judgment, setJudgment] = useState<FeedbackJudgment>('confirmed_bug');
  const [adminReply, setAdminReply] = useState('');

  if (isLoading) return <div className="loading-state">Loading feedback details...</div>;
  if (error || !feedback) return <div className="error-state">Feedback not found</div>;

  const handleResolve = async () => {
    if (!admin) return;
    try {
      await resolveMutation.mutateAsync({
        feedbackId: feedback.id,
        judgment,
        adminReply,
        points: CONTRIBUTION_POINTS[judgment] || 0,
        adminId: admin.user_id,
        userId: feedback.user_id,
        collegeId: feedback.college_id
      });
      alert('Feedback resolved successfully');
      navigate('/feedback');
    } catch (err) {
      console.error(err);
      alert('Failed to resolve feedback');
    }
  };

  return (
    <div className="detail-container">
      <header className="detail-header">
        <button className="back-btn" onClick={() => navigate('/feedback')}>
          <ChevronLeft size={20} />
          Back to Feedback
        </button>
        <div className="header-info">
          <h1 className="page-title">{feedback.title || 'User Feedback'}</h1>
          <span className={`status-tag status-${feedback.status}`}>{feedback.status.toUpperCase()}</span>
        </div>
      </header>

      <div className="detail-grid">
        <div className="main-content">
          <section className="feedback-section">
            <h2 className="section-title">Feedback Content</h2>
            <div className="card content-card">
              <p className="feedback-text">{feedback.content}</p>
              
              {feedback.screenshot_urls && feedback.screenshot_urls.length > 0 && (
                <div className="screenshot-gallery">
                  {feedback.screenshot_urls.map((url, idx) => (
                    <img key={idx} src={url} alt={`Screenshot ${idx + 1}`} className="screenshot-img" />
                  ))}
                </div>
              )}
            </div>
          </section>

          <section className="metadata-section">
            <h2 className="section-title">Technical Context</h2>
            <div className="metadata-grid">
              <div className="meta-item">
                <div className="meta-icon"><Smartphone size={16} /></div>
                <div className="meta-info">
                  <span className="meta-label">Device</span>
                  <span className="meta-value">{feedback.device_model || 'Unknown'} ({feedback.os_version || 'N/A'})</span>
                </div>
              </div>
              <div className="meta-item">
                <div className="meta-icon"><Globe size={16} /></div>
                <div className="meta-info">
                  <span className="meta-label">App Version</span>
                  <span className="meta-value">{feedback.app_version || 'Unknown'}</span>
                </div>
              </div>
              <div className="meta-item">
                <div className="meta-icon"><Code size={16} /></div>
                <div className="meta-info">
                  <span className="meta-label">Route</span>
                  <span className="meta-value">{feedback.current_route || '/'}</span>
                </div>
              </div>
              <div className="meta-item">
                <div className="meta-icon"><Tag size={16} /></div>
                <div className="meta-info">
                  <span className="meta-label">Type</span>
                  <span className="meta-value">{feedback.feedback_type.toUpperCase()}</span>
                </div>
              </div>
            </div>
          </section>
        </div>

        <aside className="sidebar-content">
          <section className="user-section">
            <h2 className="section-title">User Info</h2>
            <div className="card user-card">
              <div className="user-profile">
                {feedback.user_avatar_url ? (
                  <img src={feedback.user_avatar_url} alt="Avatar" className="user-avatar-img" />
                ) : (
                  <div className="user-avatar-placeholder"><User size={24} /></div>
                )}
                <div className="user-details">
                  <div className="user-name">{feedback.user_display_name || 'Anonymous User'}</div>
                  <div className="user-email">{feedback.user_email}</div>
                </div>
              </div>
            </div>
          </section>

          <section className="moderation-section">
            <h2 className="section-title">Action</h2>
            <div className="card action-card">
              {feedback.status === 'resolved' ? (
                <div className="resolved-info">
                  <div className="judgment-badge">
                    <Award size={16} />
                    <span>Judgment: {feedback.judgment?.replace('_', ' ').toUpperCase()}</span>
                  </div>
                  <div className="reward-info">Points Awarded: <strong>{feedback.contribution_awarded}</strong></div>
                  <div className="admin-reply-box">
                    <label>Admin Reply:</label>
                    <p>{feedback.admin_reply || 'No reply sent.'}</p>
                  </div>
                </div>
              ) : (
                <div className="resolution-form">
                  <div className="form-group">
                    <label>Judgment</label>
                    <select 
                      value={judgment} 
                      onChange={(e) => setJudgment(e.target.value as FeedbackJudgment)}
                    >
                      {Object.entries(FEEDBACK_JUDGMENTS).map(([key, value]) => (
                        <option key={key} value={value}>
                          {value.replace('_', ' ').toUpperCase()} ({CONTRIBUTION_POINTS[value]} pts)
                        </option>
                      ))}
                    </select>
                  </div>

                  <div className="form-group">
                    <label>Reply to User</label>
                    <textarea 
                      placeholder="Thank the user and explain your decision..."
                      value={adminReply}
                      onChange={(e) => setAdminReply(e.target.value)}
                      rows={5}
                    />
                  </div>

                  <button 
                    className="submit-btn" 
                    onClick={handleResolve}
                    disabled={resolveMutation.isPending}
                  >
                    <CheckCircle size={16} />
                    {resolveMutation.isPending ? 'Processing...' : 'Submit Decision'}
                  </button>
                </div>
              )}
            </div>
          </section>
        </aside>
      </div>

      <style>{`
        .detail-container {
          padding: var(--spacing-page);
          max-width: 1200px;
          margin: 0 auto;
        }

        .detail-header {
          margin-bottom: 32px;
        }

        .back-btn {
          display: flex;
          align-items: center;
          gap: 8px;
          background: none;
          border: none;
          color: var(--color-text-tertiary);
          font-weight: 500;
          cursor: pointer;
          margin-bottom: 16px;
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
          font-size: 11px;
          font-weight: 700;
          letter-spacing: 0.5px;
        }

        .status-pending { background: var(--color-warning-light); color: var(--color-warning); }
        .status-processing { background: var(--color-info-light); color: var(--color-info); }
        .status-resolved { background: var(--color-success-light); color: var(--color-success); }
        .status-dismissed { background: var(--color-bg-tertiary); color: var(--color-text-tertiary); }

        .detail-grid {
          display: grid;
          grid-template-columns: 1fr 360px;
          gap: 32px;
        }

        .section-title {
          font-size: 13px;
          font-weight: 600;
          color: var(--color-text-tertiary);
          text-transform: uppercase;
          margin-bottom: 12px;
          letter-spacing: 1px;
        }

        .card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-lg);
          padding: 24px;
          box-shadow: var(--shadow-card);
        }

        .feedback-text {
          font-size: 16px;
          line-height: 1.6;
          color: var(--color-text-primary);
          white-space: pre-wrap;
          margin-bottom: 24px;
        }

        .screenshot-gallery {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
          gap: 16px;
        }

        .screenshot-img {
          width: 100%;
          border-radius: var(--radius-md);
          border: 1px solid var(--color-border-light);
          cursor: zoom-in;
        }

        .metadata-section {
          margin-top: 32px;
        }

        .metadata-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
          gap: 16px;
        }

        .meta-item {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 16px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
        }

        .meta-icon {
          color: var(--color-text-tertiary);
        }

        .meta-label {
          display: block;
          font-size: 11px;
          color: var(--color-text-tertiary);
          text-transform: uppercase;
        }

        .meta-value {
          font-size: 13px;
          font-weight: 600;
          color: var(--color-text-secondary);
        }

        .user-card {
          margin-bottom: 24px;
        }

        .user-profile {
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .user-avatar-img {
          width: 48px;
          height: 48px;
          border-radius: 50%;
          object-fit: cover;
        }

        .user-avatar-placeholder {
          width: 48px;
          height: 48px;
          border-radius: 50%;
          background: var(--color-bg-tertiary);
          display: flex;
          align-items: center;
          justify-content: center;
          color: var(--color-text-secondary);
        }

        .user-name {
          font-weight: 700;
          font-size: 15px;
          color: var(--color-text-primary);
        }

        .user-email {
          font-size: 13px;
          color: var(--color-text-tertiary);
        }

        .action-card {
          position: sticky;
          top: 80px;
        }

        .judgment-badge {
          display: flex;
          align-items: center;
          gap: 8px;
          background: var(--color-success-light);
          color: var(--color-success);
          padding: 8px 12px;
          border-radius: var(--radius-md);
          font-weight: 700;
          font-size: 14px;
          margin-bottom: 12px;
        }

        .reward-info {
          font-size: 14px;
          color: var(--color-text-secondary);
          margin-bottom: 20px;
        }

        .admin-reply-box {
          border-top: 1px solid var(--color-border-light);
          padding-top: 16px;
        }

        .admin-reply-box label {
          display: block;
          font-size: 12px;
          font-weight: 700;
          color: var(--color-text-tertiary);
          text-transform: uppercase;
          margin-bottom: 8px;
        }

        .admin-reply-box p {
          font-size: 14px;
          line-height: 1.5;
          color: var(--color-text-secondary);
        }

        .form-group {
          margin-bottom: 20px;
        }

        .form-group label {
          display: block;
          font-size: 12px;
          font-weight: 700;
          color: var(--color-text-tertiary);
          text-transform: uppercase;
          margin-bottom: 8px;
        }

        select, textarea {
          width: 100%;
          padding: 12px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          font-family: inherit;
          font-size: 14px;
          outline: none;
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
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
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

