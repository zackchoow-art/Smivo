import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useListingModerationDetail, useModerateListing } from '@/hooks/useListingModeration';
import { useAuth } from '@/hooks/useAuth';
import { useUserSummary } from '@/hooks/useUsers';
import { MODERATION_STATUS } from '@/lib/constants';
import { UserSummaryPopup } from '@/components/users/UserSummaryPopup';
import { showToast } from '@/hooks/useToast';

const REJECT_PRESETS = [
  'Inappropriate content',
  'Prohibited item',
  'Spam or misleading',
  'Wrong category',
  'Not college-related',
  'Counterfeit or fake'
];

export function ListingModerationDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { admin } = useAuth();

  const { data: listing, isLoading, error } = useListingModerationDetail(id);
  const moderateMutation = useModerateListing();
  
  const { data: sellerSummary } = useUserSummary(listing?.seller?.id || null);

  const [rejectReason, setRejectReason] = useState('');
  const [selectedPreset, setSelectedPreset] = useState('');
  const [showRejectForm, setShowRejectForm] = useState(false);
  const [activeImageIndex, setActiveImageIndex] = useState(0);
  const [popupUser, setPopupUser] = useState<string | null>(null);
  const [showActivity, setShowActivity] = useState(false);
  const [isBlurred, setIsBlurred] = useState(true);

  const handleAction = async (action: 'approve' | 'reject' | 'takedown') => {
    if (!admin || !listing) return;

    if (action === 'reject' && !showRejectForm) {
      setShowRejectForm(true);
      return;
    }

    if (action === 'reject' && showRejectForm && !rejectReason.trim() && !selectedPreset) {
      showToast('Please select a preset reason or provide a custom reason before submitting.', 'warning');
      return;
    }

    try {
      const finalReason = action === 'reject' 
        ? [selectedPreset, rejectReason.trim()].filter(Boolean).join(' - ') 
        : undefined;

      await moderateMutation.mutateAsync({
        id: listing.id,
        action,
        reason: finalReason,
        adminId: admin?.user_id ?? ""
      });
      
      showToast(`Listing successfully ${action}ed.`, 'success');
      
      if (listing.next_id) {
        navigate(`/moderation/listings/${listing.next_id}`);
        setShowRejectForm(false);
        setRejectReason('');
        setSelectedPreset('');
      } else {
        navigate('/moderation/listings');
      }
    } catch (err) {
      console.error('Moderation action failed', err);
      showToast('Failed to perform moderation action', 'error');
    }
  };

  if (isLoading) return <div className="lmd-state-msg">Loading listing details...</div>;
  if (error || !listing) return <div className="lmd-state-msg lmd-state-error">Failed to load listing.</div>;

  return (
    <div className="lmd-container">
      <div className="lmd-header">
        <button onClick={() => navigate(-1)} className="lmd-btn-back">&larr; Back to List</button>
        <h1 className="lmd-page-title">Review Listing</h1>
        <span className="lmd-status-badge">Status: {listing.moderation_status}</span>
      </div>

      <div className="lmd-layout">
        {/* Main Content (Images & Info) */}
        <div className="lmd-main-col">
          <div className="lmd-content-card">
            {/* Image Carousel */}
            <div className="lmd-image-wrap">
              {listing.images && listing.images.length > 0 ? (
                <>
                  <img
                    src={listing.images[activeImageIndex].image_url}
                    alt={`Listing image ${activeImageIndex + 1}`}
                    className={`lmd-image ${isBlurred ? 'lmd-image--blurred' : ''}`}
                  />
                  
                  <button 
                    className={`lmd-blur-toggle ${!isBlurred ? 'active' : ''}`}
                    onClick={() => setIsBlurred(!isBlurred)}
                    title={isBlurred ? "Show original image" : "Blur image"}
                  >
                    {isBlurred ? <Eye size={18} /> : <Bot size={18} />}
                    <span>{isBlurred ? 'Reveal Content' : 'Hide Content'}</span>
                  </button>

                  {listing.images.length > 1 && (
                    <div className="lmd-dot-nav">
                      {listing.images.map((img, idx) => (
                        <button
                          key={img.id}
                          onClick={() => setActiveImageIndex(idx)}
                          className={`lmd-dot${idx === activeImageIndex ? ' lmd-dot--active' : ''}`}
                        />
                      ))}
                    </div>
                  )}
                </>
              ) : (
                <div className="lmd-no-image">No images</div>
              )}
            </div>

            <div className="lmd-info-section">
              <div>
                <h2 className="lmd-listing-title">{listing.title}</h2>
                <p className="lmd-listing-price">${listing.price}</p>
              </div>

              <div className="lmd-meta-grid">
                <div><span className="lmd-meta-key">Category:</span> {listing.category}</div>
                <div><span className="lmd-meta-key">Condition:</span> {listing.condition}</div>
                <div><span className="lmd-meta-key">Type:</span> {listing.listing_type}</div>
                {listing.pickup_location && <div><span className="lmd-meta-key">Pickup:</span> {listing.pickup_location}</div>}
              </div>

              <div>
                <h3 className="lmd-desc-label">Description</h3>
                <p className="lmd-desc-text">{listing.description || 'No description provided.'}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Sidebar (Seller Info & Actions) */}
        <div className="lmd-sidebar">
          <div className="lmd-sidebar-card">
            <h3 className="lmd-sidebar-title">Seller Profile</h3>
            {listing.seller ? (
              <div 
                className="lmd-seller-section" 
                style={{ position: 'relative', cursor: 'pointer' }}
                onClick={() => {
                  if (listing.seller?.id) setPopupUser(listing.seller.id);
                }}
              >
                <div className="lmd-seller-identity">
                  {listing.seller.avatar_url ? (
                    <img src={listing.seller.avatar_url} alt="" className="lmd-seller-avatar" />
                  ) : (
                    <div className="lmd-seller-avatar-placeholder">
                      {listing.seller.email[0].toUpperCase()}
                    </div>
                  )}
                  <div>
                    <div className="lmd-seller-name">{listing.seller.display_name || 'No name'}</div>
                    <div className="lmd-seller-email">{listing.seller.email}</div>
                  </div>
                </div>

                <div className="lmd-seller-stats">
                  <div className="lmd-seller-stat">
                    <div className="lmd-seller-stat-label">Listings</div>
                    <div className="lmd-seller-stat-value">{sellerSummary?.listingsCount ?? '—'}</div>
                  </div>
                  <div className="lmd-seller-stat">
                    <div className="lmd-seller-stat-label">Orders</div>
                    <div className="lmd-seller-stat-value">{sellerSummary?.purchasesCount ?? '—'}</div>
                  </div>
                  <div className="lmd-seller-stat">
                    <div className="lmd-seller-stat-label">Reports</div>
                    <div className={`lmd-seller-stat-value ${sellerSummary && sellerSummary.reportsCount > 0 ? 'lmd-seller-stat-value--danger' : ''}`}>
                      {sellerSummary?.reportsCount ?? '—'}
                    </div>
                  </div>
                  <div className="lmd-seller-stat">
                    <div className="lmd-seller-stat-label">Bans</div>
                    <div className={`lmd-seller-stat-value ${sellerSummary && sellerSummary.punishmentsCount > 0 ? 'lmd-seller-stat-value--danger' : ''}`}>
                      {sellerSummary?.punishmentsCount ?? '—'}
                    </div>
                  </div>
                </div>
                
                {sellerSummary?.activeBans && sellerSummary.activeBans.length > 0 && (
                  <div className="lmd-active-bans" style={{ marginTop: '12px', padding: '12px', background: 'var(--color-danger-light)', borderRadius: 'var(--radius-sm)' }}>
                    <div style={{ fontSize: '12px', fontWeight: 600, color: 'var(--color-danger)', marginBottom: '8px' }}>Active Restrictions</div>
                    {sellerSummary.activeBans.map((ban, i) => (
                      <div key={i} style={{ fontSize: '13px', color: 'var(--color-danger)', display: 'flex', justifyContent: 'space-between' }}>
                        <span style={{ textTransform: 'capitalize' }}>{ban.scope.replace('_', ' ')}</span>
                        <span>{ban.expires_at ? new Date(ban.expires_at).toLocaleDateString() : 'Permanent'}</span>
                      </div>
                    ))}
                  </div>
                )}

                {sellerSummary && (
                  <div className="lmd-activity-section" style={{ marginTop: '8px' }}>
                    <button 
                      className="lmd-btn lmd-btn--cancel"
                      onClick={(e) => {
                        e.stopPropagation();
                        setShowActivity(!showActivity);
                      }}
                      style={{ width: '100%', fontSize: '13px', padding: '8px' }}
                    >
                      {showActivity ? 'Hide Recent Activity' : 'View Recent Activity'}
                    </button>

                    {showActivity && (
                      <div className="lmd-activity-list" onClick={(e) => e.stopPropagation()}>
                        {sellerSummary.recentActivity.length === 0 ? (
                          <div className="lmd-empty-activity">No recent activity found.</div>
                        ) : (
                          sellerSummary.recentActivity.map((activity: any) => {
                            const isBuyer = activity.buyer_id === listing.seller?.id;
                            const roleLabel = isBuyer ? 'Bought' : 'Sold';
                            return (
                              <div key={activity.id} className="lmd-activity-item">
                                <div className="lmd-activity-header">
                                  <span className={`lmd-role-badge ${isBuyer ? 'buyer' : 'seller'}`}>{roleLabel}</span>
                                  <span className="lmd-activity-date">{new Date(activity.created_at).toLocaleDateString()}</span>
                                </div>
                                <div className="lmd-activity-title">{activity.listing?.title || 'Unknown Item'}</div>
                                <div className="lmd-activity-status">
                                  <span>Status: {activity.status}</span>
                                  <span style={{ fontWeight: 'bold' }}>${Number(activity.total_price).toFixed(2)}</span>
                                </div>
                              </div>
                            );
                          })
                        )}
                      </div>
                    )}
                  </div>
                )}
                {popupUser === listing.seller.id && (
                  <UserSummaryPopup userId={listing.seller.id} onClose={() => {
                    setPopupUser(null);
                  }} />
                )}
              </div>
            ) : (
              <div className="lmd-missing-msg">Seller info missing</div>
            )}
          </div>

          <div className="lmd-sidebar-card">
            <h3 className="lmd-sidebar-title">Moderation Action</h3>

            {showRejectForm ? (
              <div className="lmd-action-group">
                <label className="lmd-form-label">Reason for Rejection</label>
                <div className="lmd-presets">
                  {REJECT_PRESETS.map(preset => (
                    <button
                      key={preset}
                      className={`lmd-preset-tag ${selectedPreset === preset ? 'lmd-preset-tag--active' : ''}`}
                      onClick={() => setSelectedPreset(preset === selectedPreset ? '' : preset)}
                    >
                      {preset}
                    </button>
                  ))}
                </div>
                <textarea
                  rows={3}
                  className="lmd-textarea"
                  placeholder="Additional details (optional if preset selected)..."
                  value={rejectReason}
                  onChange={(e) => setRejectReason(e.target.value)}
                />
                <div className="lmd-confirm-row">
                  <button
                    onClick={() => handleAction('reject')}
                    disabled={moderateMutation.isPending}
                    className="lmd-btn lmd-btn--reject-confirm"
                  >
                    Confirm Reject
                  </button>
                  <button
                    onClick={() => {
                      setShowRejectForm(false);
                      setRejectReason('');
                      setSelectedPreset('');
                    }}
                    className="lmd-btn lmd-btn--cancel"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            ) : (
              <div className="lmd-action-group">
                <button
                  onClick={() => handleAction('approve')}
                  disabled={moderateMutation.isPending || listing.moderation_status === MODERATION_STATUS.APPROVED}
                  className="lmd-btn lmd-btn--approve"
                >
                  Approve Listing
                </button>

                <button
                  onClick={() => handleAction('reject')}
                  disabled={moderateMutation.isPending || listing.moderation_status === MODERATION_STATUS.REJECTED}
                  className="lmd-btn lmd-btn--reject"
                >
                  Reject Listing
                </button>

                {listing.moderation_status === MODERATION_STATUS.APPROVED && (
                  <button
                    onClick={() => handleAction('takedown')}
                    disabled={moderateMutation.isPending}
                    className="lmd-btn lmd-btn--takedown"
                  >
                    Force Takedown
                  </button>
                )}
              </div>
            )}
            
            <div className="lmd-nav-actions" style={{ display: 'flex', gap: '8px', marginTop: '24px', paddingTop: '16px', borderTop: '1px solid var(--color-border-light)' }}>
              <button
                className="lmd-btn lmd-btn--cancel"
                disabled={!listing.prev_id}
                onClick={() => listing.prev_id && navigate(`/moderation/listings/${listing.prev_id}`)}
                style={{ flex: 1, padding: '8px' }}
              >
                &larr; Prev
              </button>
              <button
                className="lmd-btn lmd-btn--cancel"
                disabled={!listing.next_id}
                onClick={() => listing.next_id && navigate(`/moderation/listings/${listing.next_id}`)}
                style={{ flex: 1, padding: '8px' }}
              >
                Next &rarr;
              </button>
            </div>
          </div>
        </div>
      </div>

      <style>{`
        .lmd-container { padding: var(--spacing-page); max-width: 1024px; margin: 0 auto; }
        .lmd-state-msg { padding: 48px; text-align: center; color: var(--color-text-secondary); font-size: 14px; }
        .lmd-state-error { color: var(--color-danger); }
        .lmd-header { display: flex; align-items: center; gap: 16px; margin-bottom: 24px; }
        .lmd-btn-back { background: none; border: none; cursor: pointer; color: var(--color-text-secondary); font-size: 14px; padding: 0; }
        .lmd-btn-back:hover { color: var(--color-text-primary); }
        .lmd-page-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); flex: 1; margin: 0; }
        .lmd-status-badge { padding: 4px 12px; background: var(--color-bg-tertiary); color: var(--color-text-primary); border-radius: 999px; font-size: 13px; font-weight: 500; }
        .lmd-layout { display: grid; grid-template-columns: 2fr 1fr; gap: 24px; }
        @media (max-width: 768px) { .lmd-layout { grid-template-columns: 1fr; } }

        /* Main content card */
        .lmd-main-col { display: flex; flex-direction: column; gap: 24px; }
        .lmd-content-card { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); overflow: hidden; }
        .lmd-image-wrap { background: var(--color-bg-secondary); aspect-ratio: 16/9; position: relative; display: flex; align-items: center; justify-content: center; overflow: hidden; }
        .lmd-image { max-height: 100%; object-fit: contain; transition: filter 0.3s ease; }
        .lmd-image--blurred { filter: blur(20px); }
        
        .lmd-blur-toggle {
          position: absolute;
          top: 16px;
          right: 16px;
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 8px 12px;
          background: rgba(0, 0, 0, 0.6);
          backdrop-filter: blur(4px);
          color: #fff;
          border: 1px solid rgba(255, 255, 255, 0.2);
          border-radius: var(--radius-sm);
          cursor: pointer;
          font-size: 13px;
          font-weight: 500;
          z-index: 10;
          transition: all 0.2s;
        }
        .lmd-blur-toggle:hover { background: rgba(0, 0, 0, 0.8); }
        .lmd-blur-toggle.active { background: var(--color-info); border-color: transparent; }
        
        .lmd-dot-nav { position: absolute; bottom: 16px; left: 0; right: 0; display: flex; justify-content: center; gap: 8px; z-index: 5; }
        .lmd-dot { width: 8px; height: 8px; border-radius: 50%; border: none; background: var(--color-border); cursor: pointer; padding: 0; }
        .lmd-dot--active { background: var(--color-info); }
        .lmd-no-image { color: var(--color-text-tertiary); font-size: 14px; }
        .lmd-info-section { padding: 24px; display: flex; flex-direction: column; gap: 16px; }
        .lmd-listing-title { font-size: 20px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .lmd-listing-price { font-size: 20px; font-weight: 600; color: var(--color-info); margin: 4px 0 0; }
        .lmd-meta-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; font-size: 13px; color: var(--color-text-secondary); }
        .lmd-meta-key { font-weight: 500; color: var(--color-text-primary); }
        .lmd-desc-label { font-size: 14px; font-weight: 500; color: var(--color-text-primary); margin: 0 0 4px; }
        .lmd-desc-text { font-size: 13px; color: var(--color-text-secondary); white-space: pre-wrap; margin: 0; }

        /* Sidebar */
        .lmd-sidebar { display: flex; flex-direction: column; gap: 24px; }
        .lmd-sidebar-card { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); padding: 24px; }
        .lmd-sidebar-title { font-size: 17px; font-weight: 700; color: var(--color-text-primary); margin: 0 0 16px; }
        .lmd-seller-section { display: flex; flex-direction: column; gap: 16px; }
        .lmd-seller-identity { display: flex; align-items: center; gap: 12px; }
        .lmd-seller-avatar { width: 48px; height: 48px; border-radius: 50%; object-fit: cover; }
        .lmd-seller-avatar-placeholder { width: 48px; height: 48px; border-radius: 50%; background: var(--color-bg-tertiary); display: flex; align-items: center; justify-content: center; font-weight: 700; color: var(--color-text-secondary); }
        .lmd-seller-name { font-weight: 500; color: var(--color-text-primary); font-size: 14px; }
        .lmd-seller-email { font-size: 12px; color: var(--color-text-secondary); }
        .lmd-seller-stats { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; border-top: 1px solid var(--color-border-light); padding-top: 16px; }
        .lmd-seller-stat { background: var(--color-bg-secondary); border-radius: var(--radius-sm); padding: 8px; }
        .lmd-seller-stat-label { font-size: 11px; color: var(--color-text-secondary); }
        .lmd-seller-stat-value { font-size: 16px; font-weight: 700; color: var(--color-text-primary); }
        .lmd-seller-stat-value--danger { color: var(--color-danger); }
        .lmd-missing-msg { font-size: 13px; color: var(--color-text-secondary); }

        /* Action panel */
        .lmd-action-group { display: flex; flex-direction: column; gap: 10px; }
        .lmd-form-label { font-size: 13px; font-weight: 500; color: var(--color-text-primary); }
        .lmd-presets { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 4px; }
        .lmd-preset-tag { padding: 4px 10px; border-radius: 999px; border: 1px solid var(--color-border); background: var(--color-bg-secondary); font-size: 12px; color: var(--color-text-secondary); cursor: pointer; transition: all 0.2s; }
        .lmd-preset-tag:hover { background: var(--color-border); }
        .lmd-preset-tag--active { background: var(--color-info-light); border-color: var(--color-info); color: var(--color-info); }
        .lmd-textarea { width: 100%; border: 1px solid var(--color-border); border-radius: var(--radius-sm); padding: 8px; font-size: 13px; resize: vertical; box-sizing: border-box; }
        .lmd-textarea:focus { outline: none; border-color: var(--color-border-focus); }
        .lmd-confirm-row { display: flex; gap: 8px; }
        .lmd-btn { padding: 10px 16px; border: none; border-radius: var(--radius-sm); font-size: 14px; font-weight: 500; cursor: pointer; width: 100%; text-align: center; }
        .lmd-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .lmd-btn--approve       { background: var(--color-success); color: #fff; }
        .lmd-btn--approve:hover:not(:disabled) { opacity: 0.88; }
        .lmd-btn--reject        { background: var(--color-danger-light); color: var(--color-danger); border: 1px solid var(--color-danger); }
        .lmd-btn--reject:hover:not(:disabled)  { background: #fcd0d1; }
        .lmd-btn--takedown      { background: var(--color-warning); color: #fff; }
        .lmd-btn--takedown:hover:not(:disabled) { opacity: 0.88; }
        .lmd-btn--reject-confirm { background: var(--color-danger); color: #fff; flex: 1; }
        .lmd-btn--cancel        { background: var(--color-bg-tertiary); color: var(--color-text-primary); padding: 10px 12px; width: auto; }

        /* Activity List */
        .lmd-activity-list { display: flex; flex-direction: column; gap: 8px; margin-top: 12px; max-height: 250px; overflow-y: auto; }
        .lmd-empty-activity { font-size: 13px; color: var(--color-text-tertiary); text-align: center; padding: 12px 0; }
        .lmd-activity-item { padding: 12px; background: var(--color-bg-secondary); border-radius: var(--radius-sm); font-size: 13px; }
        .lmd-activity-header { display: flex; justify-content: space-between; margin-bottom: 6px; }
        .lmd-role-badge { padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; text-transform: uppercase; }
        .lmd-role-badge.buyer { background: #dbeafe; color: #1e3a8a; }
        .lmd-role-badge.seller { background: #dcfce7; color: #166534; }
        .lmd-activity-date { color: var(--color-text-tertiary); font-size: 12px; }
        .lmd-activity-title { font-weight: 600; color: var(--color-text-primary); margin-bottom: 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .lmd-activity-status { color: var(--color-text-secondary); text-transform: capitalize; display: flex; justify-content: space-between; }
      `}</style>
    </div>
  );
}
