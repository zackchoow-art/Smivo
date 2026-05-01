import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ChevronLeft,
  User,
  Smartphone,
  Globe,
  Code,
  Tag,
  Award,
  CheckCircle,
} from 'lucide-react';
import { useFeedback, useResolveFeedback } from '@/hooks/useFeedbacks';
import { useAuth } from '@/hooks/useAuth';
import { CONTRIBUTION_POINTS } from '@/lib/constants';

export function FeedbackDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { admin } = useAuth();
  const { data: feedback, isLoading, error } = useFeedback(id);
  const resolveMutation = useResolveFeedback();

  const [adminResponse, setAdminResponse] = useState('');

  if (isLoading) return <div className="loading-state">Loading feedback details...</div>;
  if (error || !feedback) return <div className="error-state">Feedback not found</div>;

  const handleResolve = async () => {
    if (!admin) return;
    try {
      await resolveMutation.mutateAsync({
        feedbackId: feedback.id,
        adminResponse,
        points: CONTRIBUTION_POINTS?.default ?? 10,
        adminId: admin.user_id,
        userId: feedback.user_id,
      });
      alert('Feedback resolved successfully');
      navigate('/feedback');
    } catch (err) {
      console.error(err);
      alert('Failed to resolve feedback');
    }
  };

  // NOTE: Technical context fields are nested inside device_info jsonb column
  const deviceInfo = (feedback.device_info ?? {}) as Record<string, string>;

  return (
    <div className="detail-container">
      <header className="detail-header">
        <button className="back-btn" onClick={() => navigate('/feedback')}>
          <ChevronLeft size={20} />
          Back to Feedback
        </button>
        <div className="header-info">
          <h1 className="page-title">{feedback.title || 'User Feedback'}</h1>
          <span className={`status-tag status-${feedback.status}`}>
            {feedback.status.toUpperCase()}
          </span>
        </div>
      </header>

      <div className="detail-grid">
        <div className="main-content">
          <section className="feedback-section">
            <h2 className="section-title">Feedback Content</h2>
            <div className="card content-card">
              {/* NOTE: DB column is 'description', not 'content' */}
              <p className="feedback-text">{feedback.description}</p>

              {/* NOTE: DB column is 'screenshot_url' (single text, not screenshots[]) */}
              {feedback.screenshot_url && (
                <div className="screenshot-gallery">
                  <img
                    src={feedback.screenshot_url}
                    alt="Screenshot"
                    className="screenshot-img"
                  />
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
                  {/* NOTE: Device fields live inside device_info jsonb, not top-level columns */}
                  <span className="meta-value">
                    {deviceInfo.device_model || 'Unknown'} ({deviceInfo.os_version || 'N/A'})
                  </span>
                </div>
              </div>
              <div className="meta-item">
                <div className="meta-icon"><Globe size={16} /></div>
                <div className="meta-info">
                  <span className="meta-label">App Version</span>
                  <span className="meta-value">{deviceInfo.app_version || 'Unknown'}</span>
                </div>
              </div>
              <div className="meta-item">
                <div className="meta-icon"><Code size={16} /></div>
                <div className="meta-info">
                  <span className="meta-label">Route</span>
                  <span className="meta-value">{deviceInfo.current_route || '/'}</span>
                </div>
              </div>
              <div className="meta-item">
                <div className="meta-icon"><Tag size={16} /></div>
                <div className="meta-info">
                  <span className="meta-label">Type</span>
                  {/* NOTE: DB column is 'type', not 'category' / 'feedback_type' */}
                  <span className="meta-value">{feedback.type.toUpperCase()}</span>
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
                  <img
                    src={feedback.user_avatar_url}
                    alt="Avatar"
                    className="user-avatar-img"
                  />
                ) : (
                  <div className="user-avatar-placeholder"><User size={24} /></div>
                )}
                <div className="user-details">
                  <div className="user-name">
                    {feedback.user_display_name || 'Anonymous User'}
                  </div>
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
                    {/* NOTE: DB column is 'admin_response', not 'admin_judgment' */}
                    <span>Response submitted</span>
                  </div>
                  {/* NOTE: DB column is 'points_awarded', not 'contribution_points' */}
                  <div className="reward-info">
                    Points Awarded: <strong>{feedback.points_awarded}</strong>
                  </div>
                  <div className="admin-reply-box">
                    <label>Admin Response:</label>
                    {/* NOTE: DB column is 'admin_response' */}
                    <p>{feedback.admin_response || 'No response recorded.'}</p>
                  </div>
                </div>
              ) : (
                <div className="resolution-form">
                  <div className="form-group">
                    <label>Admin Response</label>
                    <textarea
                      placeholder="Respond to the user, explain your decision..."
                      value={adminResponse}
                      onChange={(e) => setAdminResponse(e.target.value)}
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
        .status-reviewing { background: var(--color-info-light); color: var(--color-info); }
        .status-resolved { background: var(--color-success-light); color: var(--color-success); }
        .status-closed { background: var(--color-bg-tertiary); color: var(--color-text-tertiary); }

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
