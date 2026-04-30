import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useListingModerationDetail, useModerateListing } from '@/hooks/useListingModeration';
import { useAuth } from '@/hooks/useAuth';
import { MODERATION_STATUS } from '@/lib/constants';

export function ListingModerationDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { admin } = useAuth();

  const { data: listing, isLoading, error } = useListingModerationDetail(id);
  const moderateMutation = useModerateListing();

  const [rejectReason, setRejectReason] = useState('');
  const [showRejectForm, setShowRejectForm] = useState(false);
  const [activeImageIndex, setActiveImageIndex] = useState(0);

  const handleAction = async (action: 'approve' | 'reject' | 'takedown') => {
    if (!admin || !listing) return;

    if (action === 'reject' && !showRejectForm) {
      setShowRejectForm(true);
      return;
    }

    if (action === 'reject' && showRejectForm && !rejectReason.trim()) {
      alert('Please provide a rejection reason');
      return;
    }

    try {
      await moderateMutation.mutateAsync({
        id: listing.id,
        action,
        reason: action === 'reject' ? rejectReason : undefined,
        adminId: admin?.user_id ?? ""
      });
      // Option 1: navigate back to list
      navigate('/moderation/listings');
      // Option 2: stay on page and show success msg
    } catch (err) {
      console.error('Moderation action failed', err);
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
                    className="lmd-image"
                  />
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
              <div className="lmd-seller-section">
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
                    <div className="lmd-seller-stat-value">—</div>
                  </div>
                  <div className="lmd-seller-stat">
                    <div className="lmd-seller-stat-label">Orders</div>
                    <div className="lmd-seller-stat-value">—</div>
                  </div>
                  <div className="lmd-seller-stat">
                    <div className="lmd-seller-stat-label">Reports</div>
                    <div className="lmd-seller-stat-value lmd-seller-stat-value--danger">—</div>
                  </div>
                  <div className="lmd-seller-stat">
                    <div className="lmd-seller-stat-label">Bans</div>
                    <div className="lmd-seller-stat-value lmd-seller-stat-value--danger">—</div>
                  </div>
                </div>
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
                <textarea
                  rows={3}
                  className="lmd-textarea"
                  placeholder="Explain why this listing is rejected..."
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
                    onClick={() => setShowRejectForm(false)}
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
        .lmd-image-wrap { background: var(--color-bg-secondary); aspect-ratio: 16/9; position: relative; display: flex; align-items: center; justify-content: center; }
        .lmd-image { max-height: 100%; object-fit: contain; }
        .lmd-dot-nav { position: absolute; bottom: 16px; left: 0; right: 0; display: flex; justify-content: center; gap: 8px; }
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
      `}</style>
    </div>
  );
}
