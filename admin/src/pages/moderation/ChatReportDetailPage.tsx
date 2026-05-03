import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ChevronLeft, User, AlertTriangle, Shield, CheckCircle, XCircle } from 'lucide-react';
import { useChatReport, useResolveReport } from '@/hooks/useChatReports';
import { useAuth } from '@/hooks/useAuth';
import { useDictItems } from '@/hooks/useDictionary';
import { UserSummaryPopup } from '@/components/users/UserSummaryPopup';
import { supabase } from '@/lib/supabase';
import { showToast } from '@/hooks/useToast';

export function ChatReportDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { admin } = useAuth();
  const { data: report, isLoading, error } = useChatReport(id);
  const resolveMutation = useResolveReport();

  const [note, setNote] = useState('');
  const [resolution, setResolution] = useState<'dismiss' | 'warn' | 'restrict'>('dismiss');
  const [restrictions, setRestrictions] = useState<Record<string, string>>({ 'chat_mute': '7' });
  const [selectedQuickReplies, setSelectedQuickReplies] = useState<string[]>([]);
  const [contextMessages, setContextMessages] = useState<any[] | null>(null);
  const [isFetchingContext, setIsFetchingContext] = useState(false);
  const [popupUser, setPopupUser] = useState<string | null>(null);
  
  const [giveReward, setGiveReward] = useState(true);
  const [rewardPoints, setRewardPoints] = useState(10);

  // Fetch quick replies based on selected resolution
  const { data: quickReplies } = useDictItems(`report_reply_${resolution}`);

  // Clear selected quick replies when resolution type changes
  useEffect(() => {
    setSelectedQuickReplies([]);
  }, [resolution]);

  // Reset form state when navigating to a new report
  useEffect(() => {
    setNote('');
    setResolution('dismiss');
    setRestrictions({ 'chat_mute': '7' });
    setSelectedQuickReplies([]);
    setContextMessages(null);
    setPopupUser(null);
    setGiveReward(true);
    setRewardPoints(10);
  }, [id]);

  if (isLoading) return <div className="loading-state">Loading report details...</div>;
  if (error || !report) return <div className="error-state">Report not found</div>;

  const fetchSurroundingContext = async () => {
    if (!report?.chat_room_id) {
      showToast('No chat room associated with this report.', 'warning');
      return;
    }
    setIsFetchingContext(true);
    try {
      let firstDate: string;
      let lastDate: string;
      const evidenceMsgs = (report.evidence as any)?.messages as any[] | undefined;
      
      if (evidenceMsgs && evidenceMsgs.length > 0) {
        firstDate = evidenceMsgs[0].created_at;
        lastDate = evidenceMsgs[evidenceMsgs.length - 1].created_at;
      } else {
        // Fallback: just fetch 20 latest
        const { data, error } = await supabase.from('messages')
          .select('*')
          .eq('chat_room_id', report.chat_room_id)
          .order('created_at', { ascending: false })
          .limit(20);
        if (error) throw error;
        setContextMessages((data || []).reverse());
        return;
      }

      // Fetch 10 before
      const { data: beforeData, error: err1 } = await supabase.from('messages')
        .select('*')
        .eq('chat_room_id', report.chat_room_id)
        .lt('created_at', firstDate)
        .order('created_at', { ascending: false })
        .limit(10);
      if (err1) throw err1;

      // Fetch 10 after
      const { data: afterData, error: err2 } = await supabase.from('messages')
        .select('*')
        .eq('chat_room_id', report.chat_room_id)
        .gt('created_at', lastDate)
        .order('created_at', { ascending: true })
        .limit(10);
      if (err2) throw err2;

      // Fetch the middle
      const { data: middleData, error: err3 } = await supabase.from('messages')
        .select('*')
        .eq('chat_room_id', report.chat_room_id)
        .gte('created_at', firstDate)
        .lte('created_at', lastDate)
        .order('created_at', { ascending: true });
      if (err3) throw err3;

      const combined = [
        ...(beforeData || []).reverse(), 
        ...(middleData || []), 
        ...(afterData || [])
      ];
      
      const unique = Array.from(new Map(combined.map(item => [item.id, item])).values());
      unique.sort((a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime());
      
      setContextMessages(unique);
    } catch (err) {
      console.error(err);
      showToast('Failed to fetch chat history', 'error', 4000);
    } finally {
      setIsFetchingContext(false);
    }
  };

  const handleResolve = async () => {
    if (!admin) return;
    try {
      let extraNote = '';
      if (resolution === 'restrict') {
        const configs = Object.entries(restrictions).map(([scope, duration]) => {
          const durationText = duration === '9999' ? 'Permanent' : `${duration} days`;
          return `${scope} (${durationText})`;
        });
        const configsText = configs.length > 0 ? configs.join(', ') : 'None selected';
        extraNote = `Restrictions applied: ${configsText}`;
      } else if (resolution === 'warn') {
        extraNote = 'Formal warning issued.';
      }

      const finalNote = [
        ...selectedQuickReplies,
        note.trim(),
        extraNote
      ].filter(Boolean).join('\n\n');

      // NOTE: The hook now handles all enforcement internally:
      // - user_bans insert (warn/restrict)
      // - admin_hide_messages RPC (for selected_message_ids)
      // - admin_reward_user_points RPC (if giveReward)
      await resolveMutation.mutateAsync({
        reportId: report.id,
        resolution: resolution as any,
        note: finalNote,
        adminId: admin.user_id,
        // Enforcement fields
        reportedUserId: report.reported_user_id,
        reporterUserId: report.reporter_id,
        selectedMessageIds: report.selected_message_ids ?? [],
        restrictionScopes: resolution === 'restrict' ? restrictions : undefined,
        giveReward,
        rewardPoints,
        collegeId: report.college_id,
      });
      
      showToast('Report resolved successfully ✅', 'success');
      // NOTE: Auto-navigate after 1.5s — gives toast time to appear before route change.
      // Navigate to next pending report if available, otherwise back to list.
      setTimeout(() => {
        if (report.next_id) {
          navigate(`/moderation/chat-reports/${report.next_id}`);
        } else {
          navigate('/moderation/chat-reports');
        }
      }, 1500);
    } catch (err) {
      console.error(err);
      showToast('Failed to resolve report. Please try again.', 'error', 5000);
    }
  };

  const handleScopeToggle = (scope: string) => {

    setRestrictions(prev => {
      const next = { ...prev };
      if (next[scope]) {
        delete next[scope];
      } else {
        next[scope] = '7'; // Default to 7 days
      }
      return next;
    });
  };

  const handleDurationChange = (scope: string, duration: string) => {
    setRestrictions(prev => ({ ...prev, [scope]: duration }));
  };

  const displayMessages = contextMessages || (report.evidence as any)?.messages || [];

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
          <section className="involved-parties">
            <h2 className="section-title">Involved Parties</h2>
            <div className="parties-grid">
              <div 
                className="party-card highlight"
                style={{ position: 'relative', cursor: 'pointer' }}
                onClick={() => setPopupUser(report.reported_user_id)}
              >
                <h3 className="party-label text-danger">
                  <AlertTriangle size={14} style={{ display: 'inline', marginRight: 4, verticalAlign: 'text-bottom' }} />
                  Reported User
                </h3>
                <div className="user-info">
                  <div className="user-avatar">
                    {report.reported_avatar ? (
                      <img src={report.reported_avatar} alt="Avatar" className="avatar-img" />
                    ) : (
                      <User size={20} />
                    )}
                  </div>
                  <div>
                    <div className="user-name">{report.reported_name || 'Unknown'}</div>
                    <div className="user-email">{report.reported_email}</div>
                  </div>
                </div>
                {popupUser === report.reported_user_id && (
                  <UserSummaryPopup 
                    userId={report.reported_user_id} 
                    onClose={() => setPopupUser(null)} 
                  />
                )}
              </div>
              <div 
                className="party-card"
                style={{ position: 'relative', cursor: 'pointer' }}
                onClick={() => setPopupUser(report.reporter_id)}
              >
                <h3 className="party-label">Reporter</h3>
                <div className="user-info">
                  <div className="user-avatar">
                    {report.reporter_avatar ? (
                      <img src={report.reporter_avatar} alt="Avatar" className="avatar-img" />
                    ) : (
                      <User size={20} />
                    )}
                  </div>
                  <div>
                    <div className="user-name">{report.reporter_name || 'Anonymous'}</div>
                    <div className="user-email">{report.reporter_email}</div>
                  </div>
                </div>
                {popupUser === report.reporter_id && (
                  <UserSummaryPopup 
                    userId={report.reporter_id} 
                    onClose={() => setPopupUser(null)} 
                  />
                )}
              </div>
            </div>
          </section>

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

              {/* Chat Evidence Viewer */}
              <div className="evidence-chatroom">
                <div className="evidence-chatroom-header">
                  <h3 className="evidence-chatroom-title">Chat Evidence Context</h3>
                  {report.chat_room_id && !contextMessages && admin?.role?.startsWith('platform_') && (
                    <button 
                      className="btn btn-secondary btn-sm" 
                      onClick={fetchSurroundingContext}
                      disabled={isFetchingContext}
                    >
                      {isFetchingContext ? 'Loading...' : 'View Chat History'}
                    </button>
                  )}
                </div>
                {displayMessages.length > 0 ? (
                  <div className="evidence-messages-container">
                    {displayMessages.map((msg: any) => {
                      const isReporter = msg.sender_id === report.reporter_id;
                      const isReported = msg.sender_id === report.reported_user_id;
                      const isSelected = report.selected_message_ids?.includes(msg.id);
                      
                      let senderName = 'Unknown User';
                      if (isReporter) senderName = report.reporter_name || 'Reporter';
                      if (isReported) senderName = report.reported_name || 'Reported User';

                      return (
                        <div key={msg.id} className={`chat-message-row ${isReported ? 'row-left' : 'row-right'}`}>
                          <div className={`chat-bubble ${isSelected ? 'selected-bubble' : ''} ${isReported ? 'bubble-reported' : 'bubble-reporter'}`}>
                            <div className="msg-header">
                              <span className="msg-sender">
                                {senderName} {(isReported && isSelected) && <AlertTriangle size={12} className="selected-icon" />}
                              </span>
                              <span className="msg-time">
                                {new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                              </span>
                            </div>
                            <div className="msg-body">
                              {msg.content && <p>{msg.content}</p>}
                              {msg.image_url && <img src={msg.image_url} alt="Chat attachment" className="msg-attachment" />}
                            </div>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                ) : (
                  <div className="empty-evidence">
                    <p>No chat history was captured for this report.</p>
                  </div>
                )}
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
                      className={`option-btn ${resolution === 'restrict' ? 'active' : ''}`}
                      onClick={() => setResolution('restrict')}
                    >
                      <Shield size={16} /> Restrict
                    </button>
                  </div>
                </div>

                {resolution === 'restrict' && (
                  <div className="form-group restriction-config">
                    <label>Restriction Configuration</label>
                    <div className="restriction-layout">
                      <div className="restriction-scopes">
                        {[
                          { id: 'chat_mute', label: 'Mute Chat' },
                          { id: 'listing_ban', label: 'Listing Ban' },
                          { id: 'feedback_ban', label: 'Feedback Ban' },
                          { id: 'account_freeze', label: 'Account Freeze' }
                        ].map(scope => {
                          const isSelected = !!restrictions[scope.id];
                          return (
                            <div key={scope.id} className="restriction-item-row">
                              <label className="scope-checkbox-label">
                                <input 
                                  type="checkbox" 
                                  checked={isSelected}
                                  onChange={() => handleScopeToggle(scope.id)}
                                />
                                <span>{scope.label}</span>
                              </label>
                              
                              {isSelected && (
                                <select 
                                  value={restrictions[scope.id]} 
                                  onChange={(e) => handleDurationChange(scope.id, e.target.value)}
                                  className="form-select duration-select-small"
                                >
                                  <option value="1">1 Day</option>
                                  <option value="0.000694444">1 Minute (Test)</option>
                                  <option value="0.003472222">5 Minutes (Test)</option>
                                  <option value="3">3 Days</option>
                                  <option value="7">7 Days</option>
                                  <option value="30">30 Days</option>
                                  <option value="9999">Permanent</option>
                                </select>
                              )}
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  </div>
                )}

                <div className="form-group">
                  <label>Quick Replies (Optional)</label>
                  <div className="quick-replies-list">
                    {quickReplies?.map((item) => {
                      const isSelected = selectedQuickReplies.includes(item.dict_value);
                      return (
                        <button
                          key={item.id}
                          className={`quick-reply-btn ${isSelected ? 'selected' : ''}`}
                          onClick={() => {
                            if (isSelected) {
                              setSelectedQuickReplies(prev => prev.filter(v => v !== item.dict_value));
                            } else {
                              setSelectedQuickReplies(prev => [...prev, item.dict_value]);
                            }
                          }}
                        >
                          {item.dict_key}
                        </button>
                      );
                    })}
                    {(!quickReplies || quickReplies.length === 0) && (
                      <div className="no-quick-replies">No quick replies configured for this resolution type.</div>
                    )}
                  </div>
                </div>

                <div className="form-group">
                  <label>Custom Note</label>
                  <textarea 
                    placeholder="Add an internal note about this decision..."
                    value={note}
                    onChange={(e) => setNote(e.target.value)}
                    rows={4}
                  />
                </div>

                <div className="form-group reward-group">
                  <label className="reward-label">
                    <input 
                      type="checkbox" 
                      checked={giveReward} 
                      onChange={(e) => setGiveReward(e.target.checked)} 
                    />
                    Reward reporter for valid report
                  </label>
                  {giveReward && (
                    <div className="reward-input-container">
                      <span className="reward-text">Points:</span>
                      <div className="number-input">
                        <button 
                          className="num-btn"
                          onClick={() => setRewardPoints(Math.max(10, rewardPoints - 10))}
                        >-</button>
                        <input 
                          type="number" 
                          min={10} 
                          max={50} 
                          value={rewardPoints}
                          readOnly
                        />
                        <button 
                          className="num-btn"
                          onClick={() => setRewardPoints(Math.min(50, rewardPoints + 10))}
                        >+</button>
                      </div>
                    </div>
                  )}
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
                  <span className="value">
                    {report.action_taken ? report.action_taken.toUpperCase() : (report.status === 'dismissed' ? 'DISMISSED' : 'RESOLVED')}
                  </span>
                </div>
                <div className="summary-field">
                  <span className="label">Resolved At:</span>
                  <span className="value">{report.updated_at ? new Date(report.updated_at).toLocaleString() : 'N/A'}</span>
                </div>
                <div className="summary-note">
                  <span className="label">Internal Note:</span>
                  <p>{report.resolution_note || 'No note provided.'}</p>
                </div>
              </div>
            )}
            
            <div className="report-nav-actions">
              <button 
                className="nav-btn prev-btn" 
                disabled={!report.prev_id}
                onClick={() => report.prev_id && navigate(`/moderation/chat-reports/${report.prev_id}`)}
              >
                &laquo; Previous Record
              </button>
              <button 
                className="nav-btn next-btn" 
                disabled={!report.next_id}
                onClick={() => report.next_id && navigate(`/moderation/chat-reports/${report.next_id}`)}
              >
                Next Record &raquo;
              </button>
            </div>
          </div>
        </aside>
      </div>

      <style>{`
        .report-nav-actions {
          display: flex;
          gap: 12px;
          margin-top: 24px;
          border-top: 1px solid var(--color-border);
          padding-top: 16px;
        }
        .nav-btn {
          flex: 1;
          padding: 10px;
          border: 1px solid var(--color-border-strong);
          border-radius: var(--radius-md);
          background: transparent;
          color: var(--color-text-secondary);
          cursor: pointer;
          font-weight: 500;
        }
        .nav-btn:hover:not(:disabled) {
          background: var(--color-bg-tertiary);
          color: var(--color-text-primary);
        }
        .nav-btn:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

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

        .evidence-chatroom {
          margin-top: 32px;
          border-top: 1px solid var(--color-border-light);
          padding-top: 24px;
        }

        .evidence-chatroom-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 16px;
        }

        .evidence-chatroom-title {
          font-size: 14px;
          font-weight: 700;
          color: var(--color-text-secondary);
          text-transform: uppercase;
        }

        .evidence-messages-container {
          display: flex;
          flex-direction: column;
          gap: 12px;
          background: var(--color-bg-secondary);
          padding: 16px;
          border-radius: var(--radius-lg);
          border: 1px solid var(--color-border);
          max-height: 500px;
          overflow-y: auto;
        }

        .empty-evidence {
          padding: 32px;
          text-align: center;
          color: var(--color-text-tertiary);
          background: var(--color-bg-tertiary);
          border-radius: var(--radius-md);
          font-style: italic;
          font-size: 13px;
        }

        .chat-message-row {
          display: flex;
          width: 100%;
        }

        .row-left {
          justify-content: flex-start;
        }

        .row-right {
          justify-content: flex-end;
        }

        .chat-bubble {
          max-width: 75%;
          padding: 10px 14px;
          border-radius: 16px;
          font-size: 14px;
          line-height: 1.4;
          box-shadow: var(--shadow-sm);
        }

        .bubble-reported {
          background: var(--color-bg-primary);
          color: var(--color-text-primary);
          border-bottom-left-radius: 4px;
          border: 1px solid var(--color-border);
        }

        .bubble-reporter {
          background: var(--color-info);
          color: white;
          border-bottom-right-radius: 4px;
        }

        .selected-bubble {
          outline: 2px solid var(--color-danger);
          outline-offset: 2px;
        }

        .selected-icon {
          color: var(--color-danger);
          vertical-align: middle;
        }

        .msg-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          gap: 12px;
          margin-bottom: 4px;
          font-size: 11px;
          opacity: 0.8;
        }

        .bubble-reporter .msg-header {
          color: rgba(255, 255, 255, 0.9);
        }

        .bubble-reported .msg-header {
          color: var(--color-text-tertiary);
        }

        .msg-sender {
          font-weight: 700;
          display: flex;
          align-items: center;
          gap: 6px;
        }

        .text-primary { color: var(--color-text-primary); }
        .text-danger { color: var(--color-danger); }

        .msg-time {
          color: inherit;
        }

        .msg-body {
          font-size: 14px;
          word-break: break-word;
        }
        
        .msg-body p {
          margin: 0;
        }

        .msg-attachment {
          max-width: 200px;
          border-radius: 8px;
          margin-top: 8px;
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
          overflow: hidden;
        }

        .avatar-img {
          width: 100%;
          height: 100%;
          object-fit: cover;
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

        .restriction-layout {
          display: flex;
          flex-direction: column;
          gap: 16px;
        }

        .restriction-scopes {
          display: flex;
          flex-direction: column;
          gap: 12px;
        }

        .restriction-item-row {
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .scope-checkbox-label {
          display: flex;
          align-items: center;
          gap: 6px;
          font-size: 13px;
          color: var(--color-text-primary);
          cursor: pointer;
          min-width: 140px;
        }

        .scope-checkbox-label input[type="checkbox"] {
          margin: 0;
          cursor: pointer;
        }

        .duration-select-small {
          width: 120px;
          padding: 6px 10px;
        }

        .form-select {
          flex: 1;
          padding: 10px 12px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          font-family: inherit;
          font-size: 13px;
          color: var(--color-text-primary);
          background: var(--color-bg-primary);
          outline: none;
        }

        .form-select:focus {
          border-color: var(--color-info);
        }

        .quick-replies-list {
          display: flex;
          flex-wrap: wrap;
          gap: 8px;
          margin-bottom: 8px;
        }

        .quick-reply-btn {
          padding: 6px 12px;
          border-radius: 16px;
          border: 1px solid var(--color-border);
          background: var(--color-bg-secondary);
          color: var(--color-text-secondary);
          font-size: 12px;
          cursor: pointer;
          transition: all 0.2s;
        }

        .quick-reply-btn:hover {
          background: var(--color-border-light);
        }

        .quick-reply-btn.selected {
          background: var(--color-info);
          color: white;
          border-color: var(--color-info);
        }

        .no-quick-replies {
          font-size: 12px;
          color: var(--color-text-tertiary);
          font-style: italic;
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

        .reward-group { background: var(--color-bg-secondary); padding: 16px; border-radius: var(--radius-md); border: 1px solid var(--color-border); margin-bottom: 24px; }
        .reward-label { display: flex !important; align-items: center; gap: 8px; margin-bottom: 0 !important; cursor: pointer; font-size: 14px !important; color: var(--color-text-primary) !important; }
        .reward-label input { width: 16px; height: 16px; accent-color: var(--color-info); }
        .reward-input-container { display: flex; align-items: center; gap: 12px; margin-top: 12px; padding-top: 12px; border-top: 1px solid var(--color-border-light); }
        .reward-text { font-size: 13px; color: var(--color-text-secondary); font-weight: 600; }
        .number-input { display: flex; align-items: center; border: 1px solid var(--color-border); border-radius: var(--radius-md); overflow: hidden; background: var(--color-bg-primary); }
        .num-btn { background: none; border: none; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; cursor: pointer; color: var(--color-text-secondary); font-weight: bold; transition: background 0.2s; }
        .num-btn:hover { background: var(--color-bg-secondary); color: var(--color-text-primary); }
        .number-input input { width: 48px; height: 32px; text-align: center; border: none; border-left: 1px solid var(--color-border); border-right: 1px solid var(--color-border); font-family: inherit; font-size: 14px; background: transparent; outline: none; -moz-appearance: textfield; pointer-events: none; }
        .number-input input::-webkit-outer-spin-button, .number-input input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }

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
