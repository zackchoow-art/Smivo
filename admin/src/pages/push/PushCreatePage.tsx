import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useCreatePushJob } from '@/hooks/usePush';
import { useAuth } from '@/hooks/useAuth';
import type { PushAudienceType, PushStatus } from '@/types';

export function PushCreatePage() {
  const navigate = useNavigate();
  const { admin } = useAuth();
  const createMutation = useCreatePushJob();

  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [deepLink, setDeepLink] = useState('');
  const [audienceType, setAudienceType] = useState<PushAudienceType>('all');
  const [isScheduled, setIsScheduled] = useState(false);
  const [scheduledAt, setScheduledAt] = useState('');

  const handleSubmit = async (e: React.FormEvent, status: PushStatus) => {
    e.preventDefault();
    if (!title.trim() || !body.trim()) {
      alert('Title and body are required.');
      return;
    }

    try {
      await createMutation.mutateAsync({
        title,
        body,
        deep_link: deepLink || null,
        channels: ['push'],
        audience_type: audienceType,
        audience_filter: null,
        audience_user_ids: null,
        college_id: null,
        scheduled_at: isScheduled && scheduledAt ? new Date(scheduledAt).toISOString() : null,
        status,
        created_by: admin?.user_id || null,
      });
      navigate('/push/history');
    } catch (err) {
      console.error('Failed to create push job', err);
      alert('Failed to create push job.');
    }
  };

  return (
    <div className="pc-container">
      <div className="pc-header">
        <button onClick={() => navigate(-1)} className="pc-btn-back">&larr; Back</button>
        <h1 className="pc-page-title">Create Push Notification</h1>
      </div>

      <div className="pc-form-card">
        <form className="pc-form">

          <div className="pc-section">
            <h2 className="pc-section-title">Content</h2>

            <div className="pc-form-group">
              <label className="pc-label">Notification Title</label>
              <input
                type="text"
                required
                value={title}
                onChange={e => setTitle(e.target.value)}
                className="pc-input"
                placeholder="E.g., Special Weekend Sale!"
              />
            </div>

            <div className="pc-form-group">
              <label className="pc-label">Message Body</label>
              <textarea
                required
                rows={3}
                value={body}
                onChange={e => setBody(e.target.value)}
                className="pc-input pc-textarea"
                placeholder="E.g., Don't miss out on these limited time offers."
              />
            </div>

            <div className="pc-form-group">
              <label className="pc-label">Deep Link (Optional)</label>
              <input
                type="text"
                value={deepLink}
                onChange={e => setDeepLink(e.target.value)}
                className="pc-input"
                placeholder="smivo://app/listings/123"
              />
            </div>
          </div>

          <div className="pc-section">
            <h2 className="pc-section-title">Audience</h2>
            <div className="pc-form-group">
              <label className="pc-label">Select Target Audience</label>
              <div className="pc-radio-group">
                <label className="pc-radio-label">
                  <input
                    type="radio"
                    checked={audienceType === 'all'}
                    onChange={() => setAudienceType('all')}
                    className="pc-radio"
                  />
                  <span>All Registered Users</span>
                </label>
                <br />
                <label className="pc-radio-label pc-radio-label--disabled">
                  <input
                    type="radio"
                    checked={audienceType === 'filter'}
                    onChange={() => setAudienceType('filter')}
                    className="pc-radio"
                    disabled
                  />
                  <span>Custom Filter (Coming Soon)</span>
                </label>
              </div>
            </div>
          </div>

          <div className="pc-section">
            <h2 className="pc-section-title">Schedule</h2>
            <div className="pc-checkbox-row">
              <input
                id="schedule_toggle"
                type="checkbox"
                checked={isScheduled}
                onChange={e => setIsScheduled(e.target.checked)}
                className="pc-checkbox"
              />
              <label htmlFor="schedule_toggle" className="pc-checkbox-label">
                Send at a specific time
              </label>
            </div>

            {isScheduled && (
              <div className="pc-form-group">
                <input
                  type="datetime-local"
                  value={scheduledAt}
                  onChange={e => setScheduledAt(e.target.value)}
                  className="pc-input pc-input--narrow"
                />
              </div>
            )}
          </div>

          <div className="pc-form-footer">
            <button
              type="button"
              onClick={() => navigate(-1)}
              className="pc-btn pc-btn--ghost"
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={(e) => handleSubmit(e, 'draft')}
              disabled={createMutation.isPending}
              className="pc-btn pc-btn--secondary"
            >
              Save as Draft
            </button>
            <button
              type="submit"
              onClick={(e) => handleSubmit(e, isScheduled ? 'scheduled' : 'draft')}
              disabled={createMutation.isPending}
              className="pc-btn pc-btn--primary"
            >
              {isScheduled ? 'Schedule Push' : 'Create & Send Now'}
            </button>
          </div>

        </form>
      </div>

      <style>{`
        .pc-container { padding: var(--spacing-page); max-width: 768px; margin: 0 auto; }
        .pc-header { display: flex; align-items: center; gap: 16px; margin-bottom: 24px; }
        .pc-btn-back { background: none; border: none; cursor: pointer; color: var(--color-text-secondary); font-size: 14px; padding: 0; }
        .pc-btn-back:hover { color: var(--color-text-primary); }
        .pc-page-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .pc-form-card { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); overflow: hidden; }
        .pc-form { padding: 24px; display: flex; flex-direction: column; gap: 32px; }
        .pc-section { display: flex; flex-direction: column; gap: 16px; }
        .pc-section-title { font-size: 16px; font-weight: 500; color: var(--color-text-primary); margin: 0; padding-bottom: 8px; border-bottom: 1px solid var(--color-border-light); }
        .pc-form-group { display: flex; flex-direction: column; gap: 6px; }
        .pc-label { font-size: 13px; font-weight: 500; color: var(--color-text-primary); }
        .pc-input { border: 1px solid var(--color-border); border-radius: var(--radius-sm); padding: 8px 10px; font-size: 13px; color: var(--color-text-primary); background: var(--color-bg-primary); width: 100%; box-sizing: border-box; }
        .pc-input:focus { outline: none; border-color: var(--color-border-focus); }
        .pc-textarea { resize: vertical; }
        .pc-input--narrow { max-width: 280px; }
        .pc-radio-group { display: flex; flex-direction: column; gap: 8px; }
        .pc-radio-label { display: inline-flex; align-items: center; gap: 8px; font-size: 13px; color: var(--color-text-primary); cursor: pointer; }
        .pc-radio-label--disabled { opacity: 0.5; cursor: not-allowed; }
        .pc-radio { accent-color: var(--color-info); width: 16px; height: 16px; }
        .pc-checkbox-row { display: flex; align-items: center; gap: 8px; }
        .pc-checkbox { accent-color: var(--color-info); width: 16px; height: 16px; }
        .pc-checkbox-label { font-size: 13px; color: var(--color-text-primary); cursor: pointer; }
        .pc-form-footer { display: flex; align-items: center; justify-content: flex-end; gap: 12px; border-top: 1px solid var(--color-border-light); padding-top: 24px; }
        .pc-btn { padding: 8px 16px; border-radius: var(--radius-sm); font-size: 13px; font-weight: 500; cursor: pointer; white-space: nowrap; }
        .pc-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .pc-btn--ghost     { background: var(--color-bg-primary); border: 1px solid var(--color-border); color: var(--color-text-primary); }
        .pc-btn--ghost:hover:not(:disabled) { background: var(--color-bg-secondary); }
        .pc-btn--secondary { background: var(--color-bg-primary); border: 1px solid var(--color-border); color: var(--color-info); }
        .pc-btn--secondary:hover:not(:disabled) { background: var(--color-info-light); }
        .pc-btn--primary   { background: var(--color-info); border: 1px solid transparent; color: #fff; }
        .pc-btn--primary:hover:not(:disabled) { opacity: 0.88; }
      `}</style>
    </div>
  );
}
