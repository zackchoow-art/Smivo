import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ChevronLeft, User, AlertTriangle, Shield, CheckCircle, XCircle, ChevronRight, Ban } from 'lucide-react';
import { useListingReportsByListingId, useResolveListingReport, useGroupedListingReports } from '@/hooks/useListingReports';
import { useListingModerationDetail, useBatchModerateListings } from '@/hooks/useListingModeration';
import { useAuth } from '@/hooks/useAuth';
import { useDictItems } from '@/hooks/useDictionary';
import { UserSummaryPopup } from '@/components/users/UserSummaryPopup';
import { supabase } from '@/lib/supabase';
import { showToast } from '@/hooks/useToast';

export function ListingReportDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { admin } = useAuth();
  
  const [popupUser, setPopupUser] = useState<string | null>(null);
  
  const { data: reports, isLoading: reportsLoading, error: reportsError } = useListingReportsByListingId(id);
  const { data: listing, isLoading: listingLoading } = useListingModerationDetail(id);
  const { data: allGroupedReports } = useGroupedListingReports({ status: 'pending' });
  
  const resolveMutation = useResolveListingReport();
  const listingModerateMutation = useBatchModerateListings();

  const [selectedReportIndex, setSelectedReportIndex] = useState(0);
  const [note, setNote] = useState('');
  
  // Action 1: Listing Resolution
  const [listingAction, setListingAction] = useState<'dismiss' | 'takedown'>('dismiss');
  
  // Action 2: Optional User Penalty (only if Takedown)
  const [userPenalty, setUserPenalty] = useState<'none' | 'warn' | 'restrict'>('none');
  
  const [restrictionScope, setRestrictionScope] = useState('listing_ban');
  const [restrictionDuration, setRestrictionDuration] = useState('7');
  const [selectedQuickReplies, setSelectedQuickReplies] = useState<string[]>([]);
  
  const [giveReward, setGiveReward] = useState(true);
  const [rewardPoints, setRewardPoints] = useState(10);

  // Fetch quick replies based on selected penalty
  const { data: quickReplies } = useDictItems(`report_reply_${userPenalty === 'none' ? 'dismiss' : userPenalty}`);

  // Clear selected quick replies when penalty type changes
  useEffect(() => {
    setSelectedQuickReplies([]);
  }, [userPenalty]);

  // Reset form state when navigating to a new report
  useEffect(() => {
    setSelectedReportIndex(0);
    setNote('');
    setListingAction('dismiss');
    setUserPenalty('none');
    setRestrictionScope('listing_ban');
    setRestrictionDuration('7');
    setSelectedQuickReplies([]);
    setGiveReward(true);
    setRewardPoints(10);
    setPopupUser(null);
  }, [id]);

  if (reportsLoading || listingLoading) return <div className="loading-state">Loading report details...</div>;
  if (reportsError || !reports || reports.length === 0) return <div className="error-state">Reports not found</div>;

  const report = reports[selectedReportIndex];
  const pendingReports = reports.filter(r => r.status === 'pending');
  const hasPending = pendingReports.length > 0;

  // Next/Prev Logic
  const currentIndex = allGroupedReports ? allGroupedReports.findIndex(r => r.listing_id === id) : -1;
  const hasNext = allGroupedReports && currentIndex !== -1 && currentIndex < allGroupedReports.length - 1;
  const hasPrev = allGroupedReports && currentIndex > 0;

  const handleResolve = async () => {
    if (!admin) return;
    try {
      let extraNote = '';
      if (listingAction === 'takedown') {
        extraNote += '[LISTING TAKEN DOWN] ';
        if (userPenalty === 'restrict') {
          const durationText = restrictionDuration === '9999' ? 'Permanent' : `${restrictionDuration} days`;
          extraNote += `\n[USER PENALTY] Restriction applied: ${restrictionScope} (${durationText})`;
        } else if (userPenalty === 'warn') {
          extraNote += `\n[USER PENALTY] Formal warning issued`;
        }
      } else {
        extraNote += '[LISTING APPROVED / DISMISSED REPORT]';
      }

      const finalNote = [
        ...selectedQuickReplies,
        note.trim(),
        extraNote
      ].filter(Boolean).join('\n\n');

      // ── Step 1: Moderate the listing ─────────────────────────────
      if (id) {
        await listingModerateMutation.mutateAsync({
          ids: [id],
          action: listingAction === 'takedown' ? 'reject' : 'approve',
          adminId: admin.user_id
        });
      }

      // ── Step 2: Apply user penalty if takedown + penalty selected ─
      const sellerId = listing?.seller?.id;
      if (listingAction === 'takedown' && userPenalty !== 'none' && sellerId) {
        const isPermanent = restrictionDuration === '9999';
        const expiresAt = isPermanent
          ? null
          : new Date(Date.now() + parseFloat(restrictionDuration) * 86400 * 1000 + 60000).toISOString();

        await supabase.from('user_bans').insert({
          user_id: sellerId,
          college_id: (listing?.seller as any)?.school_id || '',
          scope: userPenalty === 'restrict' ? restrictionScope : 'listing_ban',
          ban_type: isPermanent ? 'permanent' : 'temporary',
          reason_code: 'listing_report',
          reason_detail: finalNote,
          banned_by: admin.user_id,
          banned_at: new Date().toISOString(),
          duration_days: isPermanent ? null : parseFloat(restrictionDuration),
          expires_at: expiresAt,
        });
      }

      // ── Step 3: Resolve reports + reward reporters ────────────────
      const reportsToResolve = pendingReports.length > 0 ? pendingReports : reports;
      const resolutionStatus = listingAction === 'takedown'
        ? (userPenalty === 'none' ? 'warn' : userPenalty)
        : 'dismiss';

      await Promise.all(reportsToResolve.map(async r => {
        await resolveMutation.mutateAsync({
          reportId: r.id,
          resolution: resolutionStatus as any,
          note: finalNote,
          adminId: admin.user_id,
          giveReward: giveReward && listingAction === 'takedown',
          rewardPoints,
        });

        if (giveReward && listingAction === 'takedown') {
          try {
            await supabase.rpc('admin_reward_user_points', {
              p_user_id: r.reporter_id,
              p_points: rewardPoints,
              p_source_type: 'report_resolved',
              p_source_id: r.id,
              p_description: `Reward for valid listing report: ${r.reason}`
            });
          } catch (rewardErr) {
            console.error('Failed to award points to', r.reporter_id, rewardErr);
          }
        }
      }));

      // ── Step 4: Notifications ─────────────────────────────────────
      // 4a. Notify each unique reporter
      const uniqueReporterIds = [...new Set(reportsToResolve.map(r => r.reporter_id))];
      const isTakedown = listingAction === 'takedown';

      await Promise.all(uniqueReporterIds.map(async (reporterId) => {
        const reporterTitle = isTakedown
          ? '✅ Your report has been reviewed'
          : 'Update on your report';
        const reporterBody = isTakedown
          ? `Thank you for keeping Smivo safe! The reported listing has been taken down.${giveReward ? ` +${rewardPoints} contribution points awarded.` : ''}`
          : 'We reviewed your report and found no violation at this time. Thank you for your help.';

        const { error: rErr } = await supabase.rpc('send_moderation_notification', {
          p_user_id: reporterId,
          p_type: isTakedown ? 'report_resolved' : 'report_dismissed',
          p_title: reporterTitle,
          p_body: reporterBody,
          p_action_type: 'route',
          p_action_url: '/settings/trust-and-safety',
        });
        if (rErr) console.error('[ListingReport] Reporter notification failed:', rErr);
      }));

      // 4b. Notify the listing seller if taken down
      if (isTakedown && sellerId) {
        let penaltyTitle: string;
        let penaltyBody: string;
        let penaltyType: string;

        if (userPenalty === 'restrict') {
          penaltyType = 'moderation_restricted';
          penaltyTitle = '🚫 Listing Removed & Account Restricted';
          penaltyBody = `Your listing "${listing?.title ?? 'an item'}" has been removed due to a community guideline violation. A ${restrictionScope.replace(/_/g, ' ')} restriction has been applied for ${restrictionDuration === '9999' ? 'permanently' : `${restrictionDuration} days`}. Contact support if you believe this is an error.`;
        } else if (userPenalty === 'warn') {
          penaltyType = 'moderation_warned';
          penaltyTitle = '⚠️ Listing Removed — Account Warning';
          penaltyBody = `Your listing "${listing?.title ?? 'an item'}" has been removed due to a community guideline violation. A formal warning has been issued. Please review our community guidelines to avoid further action.`;
        } else {
          penaltyType = 'moderation_warned';
          penaltyTitle = '📋 Listing Removed by Moderation';
          penaltyBody = `Your listing "${listing?.title ?? 'an item'}" has been removed following a moderation review. If you have questions, please contact support.`;
        }

        const { error: sellerErr } = await supabase.rpc('send_moderation_notification', {
          p_user_id: sellerId,
          p_type: penaltyType,
          p_title: penaltyTitle,
          p_body: penaltyBody,
          p_action_type: 'route',
          p_action_url: '/settings/trust-and-safety',
        });
        if (sellerErr) console.error('[ListingReport] Seller notification failed:', sellerErr);
      }

      showToast('Reports resolved successfully ✅', 'success');
      // NOTE: Auto-navigate after 1.5s to next report or back to list.
      setTimeout(() => {
        if (hasNext && allGroupedReports) {
          navigate(`/moderation/listing-reports/${allGroupedReports[currentIndex + 1].listing_id}`);
        } else {
          navigate('/moderation/listings', { state: { tab: 'user' } });
        }
      }, 1500);
    } catch (err) {
      console.error(err);
      showToast('Failed to resolve reports. Please try again.', 'error', 5000);
    }
  };


  return (
    <div className="detail-container">
      <header className="detail-header">
        <button className="back-btn" onClick={() => navigate('/moderation/listings', { state: { tab: 'user' } })}>
          <ChevronLeft size={20} />
          Back to Moderation
        </button>
        <div className="header-info">
          <h1 className="page-title">Listing Report Detail</h1>
          <span className={`status-tag status-${hasPending ? 'pending' : 'resolved'}`}>
            {hasPending ? 'PENDING' : 'RESOLVED'}
          </span>
        </div>
      </header>

      <div className="detail-grid">
        <div className="info-section main-info">
          <section className="report-content">
            <h2 className="section-title">Reported Content</h2>
            <div className="content-card">
              {reports.length > 1 && (
                <div className="reporter-avatars-scroll">
                  <div className="reporter-avatars-label">Reporters ({reports.length})</div>
                  <div className="reporter-avatars-container">
                    {reports.map((r, idx) => (
                      <button 
                        key={r.id} 
                        className={`reporter-avatar-btn ${selectedReportIndex === idx ? 'active' : ''}`}
                        onClick={() => setSelectedReportIndex(idx)}
                        title={`${r.reporter_name || 'Anonymous'} - ${new Date(r.created_at).toLocaleString()}`}
                      >
                        {r.reporter_avatar ? (
                          <img src={r.reporter_avatar} alt="Reporter" />
                        ) : (
                          <div className="fallback-avatar"><User size={16} /></div>
                        )}
                      </button>
                    ))}
                  </div>
                </div>
              )}

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

              {/* Listing Evidence Viewer */}
              <div className="evidence-listing">
                <h3 className="evidence-listing-title">Reported Listing Context</h3>
                {listing ? (
                  <div className="listing-evidence-card">
                    <div className="listing-header">
                      <span className="listing-title">{listing.title}</span>
                      <span className="listing-price">${listing.price}</span>
                    </div>
                    <div className="listing-meta">
                      <span>Category: {listing.category}</span>
                      <span>Condition: {listing.condition}</span>
                      <span>Type: {listing.listing_type}</span>
                    </div>
                    <p className="listing-description">{listing.description}</p>
                    {listing.images && listing.images.length > 0 && (
                      <div className="listing-image-gallery">
                        {listing.images.map((img: any, idx: number) => (
                          <img key={idx} src={img.image_url} alt="Listing" className="listing-img" />
                        ))}
                      </div>
                    )}
                  </div>
                ) : (
                  <div className="empty-evidence">
                    <p>The reported listing could not be found or has been deleted.</p>
                  </div>
                )}
              </div>
            </div>
          </section>

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
                  Reported User (Seller)
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
        </div>

        <aside className="action-section">
          <div className="action-card">
            <h2 className="section-title">Moderation Action</h2>
            
            {hasPending ? (
              <div className="resolution-form">
                <div className="form-group">
                  <label>Listing Action</label>
                  <div className="resolution-options" style={{ gridTemplateColumns: '1fr 1fr' }}>
                    <button 
                      className={`option-btn ${listingAction === 'dismiss' ? 'active' : ''}`}
                      onClick={() => setListingAction('dismiss')}
                    >
                      <CheckCircle size={16} /> Dismiss / Approve Listing
                    </button>
                    <button 
                      className={`option-btn ${listingAction === 'takedown' ? 'active takedown' : ''}`}
                      onClick={() => setListingAction('takedown')}
                    >
                      <Ban size={16} /> Takedown Listing
                    </button>
                  </div>
                </div>

                {listingAction === 'takedown' && (
                  <div className="form-group">
                    <label>Optional User Penalty</label>
                    <div className="resolution-options">
                      <button 
                        className={`option-btn ${userPenalty === 'none' ? 'active' : ''}`}
                        onClick={() => setUserPenalty('none')}
                      >
                        <XCircle size={16} /> None
                      </button>
                      <button 
                        className={`option-btn ${userPenalty === 'warn' ? 'active' : ''}`}
                        onClick={() => setUserPenalty('warn')}
                      >
                        <AlertTriangle size={16} /> Warn
                      </button>
                      <button 
                        className={`option-btn ${userPenalty === 'restrict' ? 'active restrict' : ''}`}
                        onClick={() => setUserPenalty('restrict')}
                      >
                        <Shield size={16} /> Restrict
                      </button>
                    </div>
                  </div>
                )}

                {listingAction === 'takedown' && userPenalty === 'restrict' && (
                  <div className="form-group restriction-config">
                    <label>Restriction Configuration</label>
                    <div className="restriction-grid">
                      <select 
                        value={restrictionScope} 
                        onChange={(e) => setRestrictionScope(e.target.value)}
                        className="form-select"
                      >
                        <option value="listing_ban">Listing Ban</option>
                        <option value="account_freeze">Account Freeze</option>
                      </select>
                      
                      <select 
                        value={restrictionDuration} 
                        onChange={(e) => setRestrictionDuration(e.target.value)}
                        className="form-select"
                      >
                        <option value="1">1 Day</option>
                        <option value="0.000694444">1 Minute (Test)</option>
                        <option value="0.003472222">5 Minutes (Test)</option>
                        <option value="3">3 Days</option>
                        <option value="7">7 Days</option>
                        <option value="30">30 Days</option>
                        <option value="9999">Permanent</option>
                      </select>
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
                    Reward reporter(s) for valid report
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
                  disabled={resolveMutation.isPending || listingModerateMutation.isPending}
                >
                  {(resolveMutation.isPending || listingModerateMutation.isPending) ? 'Processing...' : 'Confirm Resolution'}
                </button>
              </div>
            ) : (
              <div className="resolution-summary">
                <div className="resolved-banner">
                  <CheckCircle size={24} />
                  <div>
                    <div className="resolved-title">All Reports Resolved/Dismissed</div>
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
            
            {/* Next / Prev Navigation */}
            <div className="record-navigation" style={{ marginTop: 24, display: 'flex', justifyContent: 'space-between', gap: 12 }}>
              <button 
                className="nav-btn prev-btn" 
                disabled={!hasPrev}
                onClick={() => {
                  if (hasPrev && allGroupedReports) {
                    navigate(`/moderation/listing-reports/${allGroupedReports[currentIndex - 1].listing_id}`);
                  }
                }}
              >
                <ChevronLeft size={16} /> Previous Record
              </button>
              <button 
                className="nav-btn next-btn" 
                disabled={!hasNext}
                onClick={() => {
                  if (hasNext && allGroupedReports) {
                    navigate(`/moderation/listing-reports/${allGroupedReports[currentIndex + 1].listing_id}`);
                  }
                }}
              >
                Next Record <ChevronRight size={16} />
              </button>
            </div>
          </div>
        </aside>
      </div>

      <style>{`
        /* Reused styles from ChatReportDetailPage */
        .detail-container { padding: var(--spacing-page); max-width: 1200px; margin: 0 auto; }
        .detail-header { display: flex; flex-direction: column; gap: 16px; margin-bottom: 24px; }
        .back-btn { display: flex; align-items: center; gap: 4px; background: none; border: none; color: var(--color-text-tertiary); font-size: 14px; font-weight: 500; cursor: pointer; width: fit-content; }
        .back-btn:hover { color: var(--color-info); }
        .header-info { display: flex; align-items: center; gap: 16px; }
        .page-title { font-size: 28px; font-weight: 700; color: var(--color-text-primary); }
        .status-tag { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; letter-spacing: 0.5px; }
        .status-pending { background: var(--color-warning-light); color: var(--color-warning); }
        .status-resolved { background: var(--color-success-light); color: var(--color-success); }
        .status-dismissed { background: var(--color-bg-tertiary); color: var(--color-text-tertiary); }
        .detail-grid { display: grid; grid-template-columns: 1fr 350px; gap: 24px; }
        .section-title { font-size: 16px; font-weight: 600; color: var(--color-text-secondary); margin-bottom: 12px; text-transform: uppercase; letter-spacing: 0.5px; }
        .content-card { background: var(--color-bg-primary); border: 1px solid var(--color-border); border-radius: var(--radius-lg); padding: 24px; box-shadow: var(--shadow-card); }
        .reason-header { display: flex; justify-content: space-between; margin-bottom: 16px; border-bottom: 1px solid var(--color-border-light); padding-bottom: 12px; }
        .reason-label { font-weight: 700; color: var(--color-danger); }
        .timestamp { font-size: 13px; color: var(--color-text-tertiary); font-family: var(--font-mono); }
        .report-detail { font-size: 15px; line-height: 1.6; color: var(--color-text-primary); white-space: pre-wrap; margin-bottom: 20px; }
        .screenshot-gallery { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 12px; }
        .evidence-img { width: 100%; border-radius: var(--radius-md); border: 1px solid var(--color-border-light); }
        
        .evidence-listing { margin-top: 32px; border-top: 1px solid var(--color-border-light); padding-top: 24px; }
        .evidence-listing-title { font-size: 14px; font-weight: 700; color: var(--color-text-secondary); margin-bottom: 16px; text-transform: uppercase; }
        .listing-evidence-card { background: var(--color-bg-secondary); border-radius: var(--radius-md); padding: 16px; border: 1px solid var(--color-border); }
        .listing-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
        .listing-title { font-weight: 700; font-size: 18px; color: var(--color-text-primary); }
        .listing-price { font-weight: 600; font-size: 16px; color: var(--color-info); }
        .listing-meta { display: flex; gap: 16px; font-size: 12px; color: var(--color-text-secondary); margin-bottom: 12px; }
        .listing-description { font-size: 14px; color: var(--color-text-secondary); white-space: pre-wrap; margin-bottom: 16px; }
        .listing-image-gallery { display: flex; gap: 8px; overflow-x: auto; padding-bottom: 8px; }
        .listing-img { height: 100px; border-radius: var(--radius-sm); border: 1px solid var(--color-border-light); object-fit: cover; }
        
        .empty-evidence { padding: 32px; text-align: center; color: var(--color-text-tertiary); background: var(--color-bg-tertiary); border-radius: var(--radius-md); font-style: italic; font-size: 13px; }
        .involved-parties { margin-top: 32px; }
        .parties-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .party-card { background: var(--color-bg-primary); border: 1px solid var(--color-border); border-radius: var(--radius-lg); padding: 16px; }
        .party-card.highlight { border-color: var(--color-danger-light); background: var(--color-bg-secondary); }
        .party-label { font-size: 12px; font-weight: 700; color: var(--color-text-tertiary); text-transform: uppercase; margin-bottom: 12px; }
        .user-info { display: flex; align-items: center; gap: 12px; }
        .user-avatar { width: 40px; height: 40px; border-radius: 50%; background: var(--color-bg-tertiary); display: flex; align-items: center; justify-content: center; color: var(--color-text-secondary); overflow: hidden; }
        .avatar-img { width: 100%; height: 100%; object-fit: cover; }
        .user-name { font-weight: 600; color: var(--color-text-primary); }
        .user-email { font-size: 13px; color: var(--color-text-tertiary); }
        
        .action-card { background: var(--color-bg-primary); border: 1px solid var(--color-border); border-radius: var(--radius-lg); padding: 24px; position: sticky; top: 80px; box-shadow: var(--shadow-card); }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: var(--color-text-secondary); margin-bottom: 8px; }
        .resolution-options { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; }
        .option-btn { display: flex; flex-direction: column; align-items: center; gap: 6px; padding: 10px; border: 1px solid var(--color-border); background: var(--color-bg-primary); border-radius: var(--radius-md); font-size: 12px; font-weight: 600; color: var(--color-text-secondary); cursor: pointer; transition: all 0.2s; }
        .option-btn:hover { background: var(--color-bg-secondary); }
        .option-btn.active { border-color: var(--color-info); background: var(--color-info-light); color: var(--color-info); }
        .restriction-grid { display: flex; gap: 12px; }
        .form-select { flex: 1; padding: 10px 12px; border: 1px solid var(--color-border); border-radius: var(--radius-md); font-family: inherit; font-size: 13px; color: var(--color-text-primary); background: var(--color-bg-primary); outline: none; }
        .form-select:focus { border-color: var(--color-info); }
        .quick-replies-list { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 8px; }
        .quick-reply-btn { padding: 6px 12px; border-radius: 16px; border: 1px solid var(--color-border); background: var(--color-bg-secondary); color: var(--color-text-secondary); font-size: 12px; cursor: pointer; transition: all 0.2s; }
        .quick-reply-btn:hover { background: var(--color-border-light); }
        .quick-reply-btn.selected { background: var(--color-info); color: white; border-color: var(--color-info); }
        .no-quick-replies { font-size: 12px; color: var(--color-text-tertiary); font-style: italic; }
        textarea { width: 100%; padding: 12px; border: 1px solid var(--color-border); border-radius: var(--radius-md); font-family: inherit; font-size: 14px; resize: vertical; outline: none; }
        textarea:focus { border-color: var(--color-info); }
        .submit-btn { width: 100%; padding: 12px; background: var(--color-info); color: white; border: none; border-radius: var(--radius-md); font-size: 14px; font-weight: 700; cursor: pointer; transition: background-color 0.2s; }
        .submit-btn:hover { background: #3b5bdb; }
        .submit-btn:disabled { opacity: 0.6; cursor: not-allowed; }
        
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

        .resolved-banner { display: flex; align-items: center; gap: 12px; padding: 16px; background: var(--color-success-light); color: var(--color-success); border-radius: var(--radius-md); margin-bottom: 20px; }
        .resolved-title { font-weight: 700; font-size: 16px; }
        .resolved-subtitle { font-size: 12px; opacity: 0.8; }
        .summary-field { display: flex; justify-content: space-between; margin-bottom: 12px; font-size: 14px; }
        .summary-field .label { color: var(--color-text-tertiary); }
        .summary-field .value { font-weight: 600; color: var(--color-text-primary); }
        .summary-note { margin-top: 20px; padding-top: 16px; border-top: 1px solid var(--color-border-light); }
        .summary-note .label { display: block; font-size: 12px; font-weight: 700; color: var(--color-text-tertiary); text-transform: uppercase; margin-bottom: 8px; }
        .summary-note p { font-size: 14px; color: var(--color-text-secondary); line-height: 1.5; }
        
        .loading-state, .error-state { padding: 100px; text-align: center; color: var(--color-text-tertiary); font-size: 18px; }
        .reporter-avatars-scroll { margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid var(--color-border-light); }
        .reporter-avatars-label { display: block; font-size: 12px; font-weight: 600; color: var(--color-text-secondary); margin-bottom: 8px; text-transform: uppercase; }
        .reporter-avatars-container { display: flex; gap: 8px; overflow-x: auto; padding-bottom: 4px; }
        .reporter-avatar-btn { width: 40px; height: 40px; border-radius: 50%; padding: 0; border: 2px solid transparent; background: var(--color-bg-tertiary); cursor: pointer; flex-shrink: 0; overflow: hidden; transition: all 0.2s; }
        .reporter-avatar-btn.active { border-color: var(--color-info); transform: scale(1.05); }
        .reporter-avatar-btn img { width: 100%; height: 100%; object-fit: cover; }
        .fallback-avatar { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; color: var(--color-text-secondary); }
        
        .option-btn.active.takedown { border-color: var(--color-danger); background: var(--color-danger-light); color: var(--color-danger); }
        .option-btn.active.restrict { border-color: var(--color-danger); background: var(--color-danger-light); color: var(--color-danger); }
        
        .nav-btn { flex: 1; display: flex; align-items: center; justify-content: center; gap: 4px; padding: 10px; border-radius: var(--radius-md); font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s; }
        .nav-btn:not(:disabled) { background: var(--color-bg-secondary); color: var(--color-text-primary); border: 1px solid var(--color-border); }
        .nav-btn:not(:disabled):hover { background: var(--color-border-light); }
        .nav-btn:disabled { background: var(--color-bg-tertiary); color: var(--color-text-tertiary); border: 1px solid var(--color-border-light); cursor: not-allowed; }
      `}</style>
    </div>
  );
}
