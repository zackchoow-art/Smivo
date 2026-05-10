import { useState } from 'react';
import { useAllListings, useListingOrders } from '@/hooks/useListingModeration';
import { useTargetModerationLogs } from '@/hooks/useBackendModerationLogs';
import { DEFAULT_PAGE_SIZE } from '@/lib/constants';
import { Filter, Eye, FileText, CheckCircle, XCircle } from 'lucide-react';

import { useColleges } from '@/hooks/useColleges';
import { useSchoolDictItems } from '@/hooks/useSchoolDictData';
import React from 'react';

export function AllListingsPage() {
  const [page, setPage] = useState(0);
  const [dateSort, setDateSort] = useState<'newest' | 'oldest'>('newest');
  const [categoryId, setCategoryId] = useState<string>('all');
  const [expandedId, setExpandedId] = useState<string | null>(null);

  // NOTE: Dynamically fetch categories from school_categories table
  // so the filter dropdown always reflects admin-managed categories.
  const { data: categoryItems } = useSchoolDictItems('category');

  const { data, isLoading, error } = useAllListings(page, { dateSort, categoryId });

  return (
    <div className="lm-container">
      <div className="lm-header">
        <div>
          <h1 className="lm-page-title">All Listings</h1>
          <p className="lm-page-subtitle">View all platform listings and simulate AI moderation.</p>
        </div>
      </div>

      <div className="lm-actions-row">
        <div className="lm-filters">
          <div className="lm-filter-group">
            <Filter size={14} />
            <select 
              className="lm-filter-select-inline"
              value={categoryId} 
              onChange={(e) => { setCategoryId(e.target.value); setPage(0); }}
            >
              <option value="all">All Categories</option>
              {(categoryItems ?? []).map((cat) => (
                <option key={cat.dict_key} value={cat.dict_key}>{cat.dict_value}</option>
              ))}
            </select>
          </div>
          <div className="lm-filter-group">
            <select 
              className="lm-filter-select-inline"
              value={dateSort} 
              onChange={(e) => { setDateSort(e.target.value as any); setPage(0); }}
            >
              <option value="newest">Newest First</option>
              <option value="oldest">Oldest First</option>
            </select>
          </div>
        </div>
      </div>

      {isLoading ? (
        <div className="lm-state-msg">Loading all listings...</div>
      ) : error ? (
        <div className="lm-state-error">Error loading listings.</div>
      ) : (
        <div className="lm-table-wrap">
          <table className="lm-table">
            <thead className="lm-thead">
              <tr>
                <th className="lm-th">Listing</th>
                <th className="lm-th">Seller</th>
                <th className="lm-th">Price</th>
                <th className="lm-th">Category</th>
                <th className="lm-th">Created At</th>
                <th className="lm-th lm-th--right">Action</th>
              </tr>
            </thead>
            <tbody>
              {data?.data.length === 0 ? (
                <tr>
                  <td colSpan={6} className="lm-td-empty">No listings found.</td>
                </tr>
              ) : (
                data?.data.map((listing: any) => (
                  <React.Fragment key={listing.id}>
                    <tr 
                      className={`lm-tr clickable-row ${expandedId === listing.id ? 'active-row' : ''}`}
                      onClick={() => setExpandedId(expandedId === listing.id ? null : listing.id)}
                    >
                      <td className="lm-td">
                        <div className="lm-listing-cell">
                          {listing.images?.[0]?.image_url ? (
                            <img className="lm-listing-thumb" src={listing.images[0].image_url} alt="" />
                          ) : (
                            <div className="lm-listing-thumb-placeholder">No Img</div>
                          )}
                          <div className="lm-cell-title">{listing.title}</div>
                        </div>
                      </td>
                      <td className="lm-td">
                        <div className="lm-user-info">
                          <span className="lm-cell-text">{listing.seller?.display_name || 'Unknown'}</span>
                          <span className="lm-cell-muted" style={{fontSize: 11}}>{listing.seller?.email}</span>
                        </div>
                      </td>
                      <td className="lm-td lm-cell-text">${listing.price}</td>
                      <td className="lm-td">
                        <span className="lm-badge lm-badge--neutral">{listing.category}</span>
                      </td>
                      <td className="lm-td lm-cell-muted">{new Date(listing.created_at).toLocaleDateString()}</td>
                      <td className="lm-td lm-td--right">
                        <button 
                          className="lm-btn lm-btn--ghost"
                          onClick={(e) => {
                            e.stopPropagation();
                            setExpandedId(expandedId === listing.id ? null : listing.id);
                          }}
                        >
                          <Eye size={16} /> Details
                        </button>
                      </td>
                    </tr>
                    {expandedId === listing.id && (
                      <tr>
                        <td colSpan={6} className="expanded-details-cell">
                          <ListingDetailCard listing={listing} />
                        </td>
                      </tr>
                    )}
                  </React.Fragment>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {data && data.count > DEFAULT_PAGE_SIZE && (
        <div className="lm-pagination">
          <p className="lm-pagination-info">
            Showing <strong>{page * DEFAULT_PAGE_SIZE + 1}</strong> to{' '}
            <strong>{Math.min((page + 1) * DEFAULT_PAGE_SIZE, data.count)}</strong> of{' '}
            <strong>{data.count}</strong> results
          </p>
          <div className="lm-pagination-nav">
            <button
              onClick={() => setPage(p => Math.max(0, p - 1))}
              disabled={page === 0}
              className="lm-page-btn lm-page-btn--left"
            >
              &larr; Previous
            </button>
            <button
              onClick={() => setPage(p => p + 1)}
              disabled={(page + 1) * DEFAULT_PAGE_SIZE >= data.count}
              className="lm-page-btn lm-page-btn--right"
            >
              Next &rarr;
            </button>
          </div>
        </div>
      )}

      <style>{`
        .lm-container { padding: var(--spacing-page); max-width: 1280px; margin: 0 auto; }
        .lm-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid var(--color-border-light); }
        .lm-page-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0 0 4px 0; }
        .lm-page-subtitle { font-size: 14px; color: var(--color-text-tertiary); margin: 0; }
        
        .lm-actions-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .lm-filters { display: flex; gap: 12px; }
        .lm-filter-group { display: flex; align-items: center; gap: 8px; background: var(--color-bg-primary); border: 1px solid var(--color-border); border-radius: var(--radius-md); padding: 6px 12px; color: var(--color-text-tertiary); }
        .lm-filter-select-inline { border: none; background: transparent; font-size: 13px; color: var(--color-text-primary); outline: none; cursor: pointer; }
        
        .lm-state-msg { padding: 48px; text-align: center; color: var(--color-text-secondary); font-size: 14px; }
        .lm-state-error { padding: 16px; background: var(--color-danger-light); color: var(--color-danger); border-radius: var(--radius-sm); font-size: 14px; }
        .lm-table-wrap { background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); overflow: hidden; }
        .lm-table { width: 100%; border-collapse: collapse; }
        .lm-thead { background: var(--color-bg-secondary); }
        .lm-th { padding: 12px 20px; text-align: left; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--color-text-secondary); border-bottom: 1px solid var(--color-border-light); }
        .lm-th--right { text-align: right; }
        
        .lm-tr { transition: background 0.2s; border-bottom: 1px solid var(--color-border-light); }
        .lm-tr:hover { background: var(--color-bg-secondary); }
        .active-row { background: var(--color-bg-tertiary) !important; border-bottom: none; }
        .clickable-row { cursor: pointer; }
        
        .lm-td { padding: 14px 20px; font-size: 13px; white-space: nowrap; }
        .lm-td--right { text-align: right; }
        .lm-td-empty { padding: 24px; text-align: center; font-size: 13px; color: var(--color-text-secondary); }
        
        .lm-cell-title { font-weight: 500; color: var(--color-text-primary); max-width: 240px; overflow: hidden; text-overflow: ellipsis; }
        .lm-cell-text { color: var(--color-text-primary); font-weight: 500; }
        .lm-cell-muted { color: var(--color-text-secondary); }
        .lm-user-info { display: flex; flex-direction: column; gap: 2px; }
        .lm-listing-cell { display: flex; align-items: center; gap: 12px; }
        .lm-listing-thumb { width: 40px; height: 40px; border-radius: 4px; object-fit: cover; }
        .lm-listing-thumb-placeholder { width: 40px; height: 40px; border-radius: 4px; background: var(--color-bg-tertiary); display: flex; align-items: center; justify-content: center; font-size: 10px; color: var(--color-text-tertiary); }
        
        .lm-badge { display: inline-flex; align-items: center; padding: 2px 8px; font-size: 11px; font-weight: 600; border-radius: 999px; white-space: nowrap; text-transform: capitalize; }
        .lm-badge--neutral { background: var(--color-bg-tertiary); color: var(--color-text-secondary); }
        
        .lm-btn { display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; border: none; border-radius: var(--radius-sm); font-size: 13px; font-weight: 500; cursor: pointer; transition: all 0.2s; }
        .lm-btn--ghost { background: transparent; color: var(--color-info); border: 1px solid var(--color-border); }
        .lm-btn--ghost:hover { background: var(--color-info-light); border-color: var(--color-info); }
        
        .expanded-details-cell { padding: 0; border-bottom: 1px solid var(--color-border-light); background: var(--color-bg-tertiary); }
        
        .lm-pagination { margin-top: 16px; display: flex; align-items: center; justify-content: space-between; background: var(--color-bg-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-card); padding: 12px 20px; }
        .lm-pagination-info { font-size: 13px; color: var(--color-text-secondary); margin: 0; }
        .lm-pagination-nav { display: flex; gap: 4px; }
        .lm-page-btn { padding: 6px 12px; font-size: 13px; border: 1px solid var(--color-border); background: var(--color-bg-primary); color: var(--color-text-secondary); cursor: pointer; }
        .lm-page-btn--left  { border-radius: var(--radius-sm) 0 0 var(--radius-sm); }
        .lm-page-btn--right { border-radius: 0 var(--radius-sm) var(--radius-sm) 0; }
        .lm-page-btn:hover:not(:disabled) { background: var(--color-bg-secondary); }
        .lm-page-btn:disabled { opacity: 0.5; cursor: not-allowed; }
      `}</style>
    </div>
  );
}

// ── Image Lightbox Overlay ─────────────────────────────────────────────────
import { useEffect, useCallback } from 'react';

function ImageLightbox({ images, currentIndex, onClose, onNavigate }: {
  images: string[];
  currentIndex: number;
  onClose: () => void;
  onNavigate: (index: number) => void;
}) {
  const hasPrev = currentIndex > 0;
  const hasNext = currentIndex < images.length - 1;

  const goPrev = useCallback(() => { if (hasPrev) onNavigate(currentIndex - 1); }, [hasPrev, currentIndex, onNavigate]);
  const goNext = useCallback(() => { if (hasNext) onNavigate(currentIndex + 1); }, [hasNext, currentIndex, onNavigate]);

  // Keyboard navigation
  useEffect(() => {
    const handleKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
      if (e.key === 'ArrowLeft') goPrev();
      if (e.key === 'ArrowRight') goNext();
    };
    window.addEventListener('keydown', handleKey);
    return () => window.removeEventListener('keydown', handleKey);
  }, [onClose, goPrev, goNext]);

  return (
    <div className="lightbox-overlay" onClick={onClose}>
      <div className="lightbox-content" onClick={(e) => e.stopPropagation()}>
        {/* Close button */}
        <button className="lightbox-close" onClick={onClose} title="Close (Esc)">✕</button>

        {/* Counter */}
        <div className="lightbox-counter">{currentIndex + 1} / {images.length}</div>

        {/* Navigation arrows */}
        {hasPrev && (
          <button className="lightbox-arrow lightbox-arrow--left" onClick={goPrev} title="Previous (←)">‹</button>
        )}
        {hasNext && (
          <button className="lightbox-arrow lightbox-arrow--right" onClick={goNext} title="Next (→)">›</button>
        )}

        {/* Full-size image */}
        <img src={images[currentIndex]} alt={`Image ${currentIndex + 1}`} className="lightbox-img" />
      </div>

      <style>{`
        .lightbox-overlay {
          position: fixed; inset: 0; z-index: 9999;
          background: rgba(0, 0, 0, 0.85);
          display: flex; align-items: center; justify-content: center;
          animation: lightbox-fadein 0.15s ease;
        }
        @keyframes lightbox-fadein { from { opacity: 0; } to { opacity: 1; } }

        .lightbox-content {
          position: relative;
          max-width: 90vw; max-height: 90vh;
          display: flex; align-items: center; justify-content: center;
        }

        .lightbox-img {
          max-width: 90vw; max-height: 85vh;
          object-fit: contain;
          border-radius: 8px;
          box-shadow: 0 8px 40px rgba(0,0,0,0.5);
          user-select: none;
        }

        .lightbox-close {
          position: fixed; top: 16px; right: 20px;
          background: rgba(255,255,255,0.12); color: white;
          border: none; border-radius: 50%;
          width: 40px; height: 40px; font-size: 20px;
          cursor: pointer; display: flex; align-items: center; justify-content: center;
          transition: background 0.15s;
          z-index: 10000;
        }
        .lightbox-close:hover { background: rgba(255,255,255,0.25); }

        .lightbox-counter {
          position: fixed; top: 20px; left: 50%; transform: translateX(-50%);
          color: rgba(255,255,255,0.7); font-size: 14px; font-weight: 500;
          z-index: 10000;
        }

        .lightbox-arrow {
          position: fixed; top: 50%; transform: translateY(-50%);
          background: rgba(255,255,255,0.1); color: white;
          border: none; border-radius: 50%;
          width: 48px; height: 48px; font-size: 32px; line-height: 1;
          cursor: pointer; display: flex; align-items: center; justify-content: center;
          transition: background 0.15s;
          z-index: 10000;
        }
        .lightbox-arrow:hover { background: rgba(255,255,255,0.25); }
        .lightbox-arrow--left { left: 16px; }
        .lightbox-arrow--right { right: 16px; }
      `}</style>
    </div>
  );
}

function ListingDetailCard({ listing }: { listing: any }) {
  const { data: colleges = [] } = useColleges();
  const { data: orders = [] } = useListingOrders(listing.id);
  const isRental = listing.listing_type === 'rental';

  // Build a status timeline from order history
  const statusTimeline = buildStatusTimeline(listing, orders);

  // Lightbox state for image preview
  const [lightboxIndex, setLightboxIndex] = useState<number | null>(null);
  const images: { image_url: string }[] = listing.images ?? [];

  return (
    <div className="card-expanded-content">
      {/* ── Left Column: Basic Info + Images ── */}
      <div className="detail-col detail-col--left">
        <h3 className="pane-title">Listing Information</h3>
        <p className="detail-desc">{listing.description}</p>
        
        <div className="detail-grid detail-grid--2col">
          <div className="detail-item">
            <span className="label">Type</span>
            <span className="value" style={{ textTransform: 'capitalize' }}>{listing.listing_type || 'Sale'}</span>
          </div>
          <div className="detail-item">
            <span className="label">Condition</span>
            <span className="value">{listing.condition?.replace('_', ' ')}</span>
          </div>
          <div className="detail-item">
            <span className="label">Status</span>
            <span className="value" style={{ textTransform: 'capitalize' }}>{listing.status}</span>
          </div>
          <div className="detail-item">
            <span className="label">Category</span>
            <span className="value" style={{ textTransform: 'capitalize' }}>{listing.category}</span>
          </div>
          <div className="detail-item">
            <span className="label">Listed Date</span>
            <span className="value">{new Date(listing.created_at).toLocaleString()}</span>
          </div>
          <div className="detail-item">
            <span className="label">Available Date</span>
            <span className="value">{listing.available_date ? new Date(listing.available_date).toLocaleDateString() : 'Immediately'}</span>
          </div>
          {listing.pickup_location && (
            <div className="detail-item" style={{ gridColumn: '1 / -1' }}>
              <span className="label">Pickup Location</span>
              <span className="value">{listing.pickup_location}, {colleges.find((c: any) => c.id === listing.college_id)?.name || listing.college_id}</span>
            </div>
          )}
        </div>

        <h3 className="pane-title" style={{ marginTop: '20px' }}>Images</h3>
        <div className="image-gallery">
          {images.map((img, i) => (
            <img
              key={i}
              src={img.image_url}
              alt={`listing ${i + 1}`}
              className="gallery-img gallery-img--clickable"
              onClick={() => setLightboxIndex(i)}
            />
          ))}
          {images.length === 0 && (
            <div style={{ fontSize: '13px', color: 'var(--color-text-tertiary)' }}>No images available.</div>
          )}
        </div>

        {/* Image Lightbox Overlay */}
        {lightboxIndex !== null && (
          <ImageLightbox
            images={images.map((img) => img.image_url)}
            currentIndex={lightboxIndex}
            onClose={() => setLightboxIndex(null)}
            onNavigate={setLightboxIndex}
          />
        )}

        {/* ── Order History (moved from right column for better readability) ── */}
        {orders && orders.length > 0 && (
          <>
            <h3 className="pane-title" style={{ marginTop: '20px' }}>Order History</h3>
            <div className="orders-compact">
              {orders.map((order: any) => (
                <div key={order.id} className="order-compact-card">
                  <div className="order-compact-left">
                    {order.buyer?.avatar_url ? (
                      <img src={order.buyer.avatar_url} alt="" className="buyer-avatar" />
                    ) : (
                      <div className="buyer-avatar placeholder-avatar" />
                    )}
                    <div>
                      <div className="order-compact-buyer">{order.buyer?.display_name || 'Unknown'}</div>
                      <div className="order-compact-date">{new Date(order.created_at).toLocaleDateString()}</div>
                    </div>
                  </div>
                  <span className={`order-status status-${order.status}`}>{order.status}</span>
                </div>
              ))}
            </div>
          </>
        )}

        <AiLogsPanel listingId={listing.id} />
      </div>

      {/* ── Right Column: Pricing + Engagement + Timeline ── */}
      <div className="detail-col detail-col--right">
        <h3 className="pane-title">Pricing</h3>
        <div className="detail-grid detail-grid--2col">
          {!isRental ? (
            <div className="detail-item">
              <span className="label">Sale Price</span>
              <span className="value" style={{ fontSize: '16px', fontWeight: 600, color: '#10b981' }}>${listing.price}</span>
            </div>
          ) : (
            <>
              {listing.daily_rate != null && (
                <div className="detail-item">
                  <span className="label">Daily Rate</span>
                  <span className="value" style={{ color: '#10b981', fontWeight: 600 }}>${listing.daily_rate}/day</span>
                </div>
              )}
              {listing.weekly_rate != null && (
                <div className="detail-item">
                  <span className="label">Weekly Rate</span>
                  <span className="value" style={{ color: '#10b981', fontWeight: 600 }}>${listing.weekly_rate}/week</span>
                </div>
              )}
              {listing.monthly_rate != null && (
                <div className="detail-item">
                  <span className="label">Monthly Rate</span>
                  <span className="value" style={{ color: '#10b981', fontWeight: 600 }}>${listing.monthly_rate}/month</span>
                </div>
              )}
              {listing.deposit != null && (
                <div className="detail-item">
                  <span className="label">Deposit</span>
                  <span className="value" style={{ fontWeight: 600 }}>${listing.deposit}</span>
                </div>
              )}
            </>
          )}
        </div>

        <h3 className="pane-title" style={{ marginTop: '20px' }}>Engagement</h3>
        <div className="engagement-row">
          <div className="engagement-stat"><span className="engagement-num">{listing.view_count || 0}</span><span className="engagement-lbl">Views</span></div>
          <div className="engagement-stat"><span className="engagement-num">{listing.save_count || 0}</span><span className="engagement-lbl">Saves</span></div>
          <div className="engagement-stat"><span className="engagement-num">{orders?.length || 0}</span><span className="engagement-lbl">Orders</span></div>
        </div>

        {/* ── Status Timeline ── */}
        <h3 className="pane-title" style={{ marginTop: '20px' }}>Status Timeline</h3>
        {statusTimeline.length === 0 ? (
          <div style={{ fontSize: '13px', color: 'var(--color-text-tertiary)' }}>No status changes recorded.</div>
        ) : (
          <div className="status-timeline">
            {statusTimeline.map((event, i) => (
              <div key={i} className="timeline-item">
                <div className="timeline-dot-col">
                  <div className={`timeline-dot timeline-dot--${event.type}`} />
                  {i < statusTimeline.length - 1 && <div className="timeline-line" />}
                </div>
                <div className="timeline-content">
                  <div className="timeline-event">{event.label}</div>
                  <div className="timeline-time">{new Date(event.time).toLocaleString()}</div>
                  {event.counterparty && (
                    <div className="timeline-counterparty">{event.counterparty}</div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}

        {/* NOTE: Order History and AI Logs moved to left column */}
      </div>

      <style>{`
        .card-expanded-content {
          display: flex;
          gap: 24px;
          padding: 24px 32px;
          margin: 16px;
          background: var(--color-bg-secondary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        }
        .detail-col { flex: 1; min-width: 0; }
        .detail-col--left { flex: 1.2; }
        .detail-col--right {
          flex: 1;
          border-left: 1px solid var(--color-border-light);
          padding-left: 24px;
        }
        @media (max-width: 900px) {
          .card-expanded-content { flex-direction: column; }
          .detail-col--right { border-left: none; border-top: 1px solid var(--color-border-light); padding-left: 0; padding-top: 20px; }
        }
        .pane-title {
          font-size: 14px;
          font-weight: 600;
          color: var(--color-text-primary);
          margin-top: 0;
          margin-bottom: 10px;
        }
        .detail-desc {
          font-size: 13px;
          color: var(--color-text-secondary);
          line-height: 1.5;
          margin-bottom: 16px;
          white-space: pre-wrap;
        }
        .detail-grid {
          display: grid;
          gap: 12px;
          margin-bottom: 16px;
        }
        .detail-grid--2col { grid-template-columns: 1fr 1fr; }
        .detail-item {
          display: flex;
          flex-direction: column;
          gap: 2px;
        }
        .detail-item .label {
          font-size: 10px;
          font-weight: 600;
          text-transform: uppercase;
          color: var(--color-text-tertiary);
          letter-spacing: 0.03em;
        }
        .detail-item .value {
          font-size: 13px;
          color: var(--color-text-primary);
          font-weight: 500;
        }
        .image-gallery {
          display: flex;
          gap: 8px;
          overflow-x: auto;
          padding-bottom: 8px;
        }
        .gallery-img {
          width: 72px;
          height: 72px;
          border-radius: var(--radius-sm);
          object-fit: cover;
          border: 1px solid var(--color-border);
          transition: transform 0.15s, border-color 0.15s, box-shadow 0.15s;
        }
        .gallery-img--clickable {
          cursor: pointer;
        }
        .gallery-img--clickable:hover {
          transform: scale(1.08);
          border-color: var(--color-info);
          box-shadow: 0 2px 8px rgba(0,0,0,0.15);
        }

        /* Engagement row */
        .engagement-row {
          display: flex;
          gap: 24px;
          margin-bottom: 16px;
        }
        .engagement-stat {
          display: flex;
          flex-direction: column;
          align-items: center;
        }
        .engagement-num {
          font-size: 20px;
          font-weight: 700;
          color: var(--color-text-primary);
        }
        .engagement-lbl {
          font-size: 11px;
          color: var(--color-text-tertiary);
          margin-top: 2px;
        }

        /* Timeline */
        .status-timeline {
          display: flex;
          flex-direction: column;
          margin-bottom: 16px;
        }
        .timeline-item {
          display: flex;
          gap: 12px;
          min-height: 40px;
        }
        .timeline-dot-col {
          display: flex;
          flex-direction: column;
          align-items: center;
          width: 12px;
          flex-shrink: 0;
        }
        .timeline-dot {
          width: 10px;
          height: 10px;
          border-radius: 50%;
          flex-shrink: 0;
          margin-top: 4px;
        }
        .timeline-dot--created { background: var(--color-info); }
        .timeline-dot--pending { background: var(--color-warning); }
        .timeline-dot--confirmed { background: var(--color-success); }
        .timeline-dot--completed { background: #10b981; }
        .timeline-dot--cancelled { background: var(--color-danger); }
        .timeline-dot--missed { background: #9ca3af; }
        .timeline-dot--active { background: #8b5cf6; }
        .timeline-line {
          width: 2px;
          flex: 1;
          background: var(--color-border-light);
          margin: 4px 0;
        }
        .timeline-content {
          flex: 1;
          padding-bottom: 12px;
        }
        .timeline-event {
          font-size: 13px;
          font-weight: 500;
          color: var(--color-text-primary);
        }
        .timeline-time {
          font-size: 11px;
          color: var(--color-text-tertiary);
          margin-top: 2px;
        }
        .timeline-counterparty {
          font-size: 11px;
          color: var(--color-text-secondary);
          margin-top: 2px;
          font-style: italic;
        }

        /* Compact orders */
        .orders-compact {
          display: flex;
          flex-direction: column;
          gap: 8px;
          max-height: 240px;
          overflow-y: auto;
        }
        .order-compact-card {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 8px 12px;
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-sm);
          background: var(--color-bg-primary);
        }
        .order-compact-left {
          display: flex;
          align-items: center;
          gap: 8px;
        }
        .buyer-avatar {
          width: 24px;
          height: 24px;
          border-radius: 50%;
          object-fit: cover;
        }
        .placeholder-avatar {
          background: var(--color-bg-tertiary);
        }
        .order-compact-buyer {
          font-size: 13px;
          font-weight: 500;
          color: var(--color-text-primary);
        }
        .order-compact-date {
          font-size: 11px;
          color: var(--color-text-tertiary);
        }
        .order-status {
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
          padding: 2px 8px;
          border-radius: 12px;
          background: var(--color-bg-tertiary);
          color: var(--color-text-secondary);
        }
        .order-status.status-completed { background: #d1fae5; color: #065f46; }
        .order-status.status-pending { background: #fef3c7; color: #92400e; }
        .order-status.status-confirmed { background: #dbeafe; color: #1e40af; }
        .order-status.status-cancelled,
        .order-status.status-missed { background: #fee2e2; color: #991b1b; }
      `}</style>
    </div>
  );
}

/**
 * Build a status timeline from the listing creation and its order history.
 * Each entry: { label, time, type, counterparty? }
 */
function buildStatusTimeline(listing: any, orders: any[]) {
  const events: { label: string; time: string; type: string; counterparty?: string }[] = [];

  // 1. Listing creation
  events.push({
    label: 'Listing Created',
    time: listing.created_at,
    type: 'created',
  });

  // 2. Add moderation status change if applicable
  if (listing.moderation_status === 'approved' || listing.moderation_status === 'auto_approved') {
    events.push({
      label: listing.moderation_status === 'auto_approved' ? 'Auto-Approved by AI' : 'Approved by Admin',
      time: listing.updated_at || listing.created_at,
      type: 'confirmed',
    });
  } else if (listing.moderation_status === 'rejected') {
    events.push({
      label: 'Rejected',
      time: listing.updated_at || listing.created_at,
      type: 'cancelled',
    });
  }

  // 3. Add order lifecycle events
  orders?.forEach((order: any) => {
    const buyerName = order.buyer?.display_name || order.buyer?.email || 'Unknown Buyer';
    events.push({
      label: `Order placed (${order.status})`,
      time: order.created_at,
      type: order.status === 'cancelled' || order.status === 'missed' ? 'cancelled' :
            order.status === 'completed' ? 'completed' :
            order.status === 'confirmed' ? 'confirmed' : 'pending',
      counterparty: `Buyer: ${buyerName}`,
    });

    // If order has been updated, add the latest status change
    if (order.updated_at && order.updated_at !== order.created_at) {
      events.push({
        label: `Status → ${order.status}`,
        time: order.updated_at,
        type: order.status === 'cancelled' || order.status === 'missed' ? 'cancelled' :
              order.status === 'completed' ? 'completed' :
              order.status === 'confirmed' ? 'confirmed' : 'active',
        counterparty: `Buyer: ${buyerName}`,
      });
    }
  });

  // Sort by time
  events.sort((a, b) => new Date(a.time).getTime() - new Date(b.time).getTime());
  return events;
}

/**
 * Shows a collapsible list of AI moderation logs for a specific listing.
 */
function AiLogsPanel({ listingId }: { listingId: string }) {
  const [expanded, setExpanded] = useState(false);
  const { data: logs, isLoading } = useTargetModerationLogs(expanded ? listingId : null);

  return (
    <div className="ai-logs-panel">
      <button className="ai-logs-toggle" onClick={() => setExpanded(!expanded)}>
        <FileText size={15} />
        AI Moderation History
        <span style={{ marginLeft: 'auto', fontSize: 12, opacity: 0.6 }}>
          {expanded ? '▲' : '▼'}
        </span>
      </button>

      {expanded && (
        <div className="ai-logs-body">
          {isLoading ? (
            <div style={{ padding: 16, fontSize: 13, color: 'var(--color-text-secondary)' }}>Loading logs...</div>
          ) : !logs || logs.length === 0 ? (
            <div style={{ padding: 16, fontSize: 13, color: 'var(--color-text-tertiary)' }}>No AI reviews recorded for this listing.</div>
          ) : (
            <table className="ai-logs-table">
              <thead>
                <tr>
                  <th>Time</th>
                  <th>Engine</th>
                  <th>Result</th>
                  <th>Action</th>
                  <th>Details</th>
                </tr>
              </thead>
              <tbody>
                {logs.map((log) => {
                  const flaggedImgs = log.image_details?.filter(i => i.flagged) || [];
                  const textWords = log.text_details?.matched_words || [];
                  const reasons = [
                    ...textWords.map((w: string) => `word: ${w}`),
                    ...flaggedImgs.flatMap(i => i.reasons.map(r => `img#${i.index}: ${r}`)),
                  ];

                  return (
                    <tr key={log.id}>
                      <td style={{ fontSize: 11 }}>{new Date(log.created_at).toLocaleString()}</td>
                      <td>
                        <span className="ai-engine-tag">{log.engine.replace('_', ' ')}</span>
                      </td>
                      <td>
                        {log.result === 'pass' ? (
                          <CheckCircle size={14} color="var(--color-success)" />
                        ) : (
                          <XCircle size={14} color="var(--color-danger)" />
                        )}
                      </td>
                      <td style={{ textTransform: 'capitalize' }}>{log.action_taken}</td>
                      <td>
                        {reasons.length === 0 ? (
                          <span style={{ color: 'var(--color-text-tertiary)' }}>—</span>
                        ) : (
                          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 3 }}>
                            {reasons.map((r, idx) => (
                              <span key={idx} className="ai-detail-tag">{r}</span>
                            ))}
                          </div>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          )}
        </div>
      )}

      <style>{`
        .ai-logs-panel {
          width: 100%;
          margin-top: 16px;
          border-top: 1px solid var(--color-border-light);
        }
        .ai-logs-toggle {
          display: flex;
          align-items: center;
          gap: 8px;
          width: 100%;
          padding: 12px 0;
          background: none;
          border: none;
          font-size: 13px;
          font-weight: 600;
          color: #8b5cf6;
          cursor: pointer;
        }
        .ai-logs-toggle:hover { opacity: 0.8; }
        .ai-logs-body {
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-sm);
          overflow: hidden;
          margin-bottom: 8px;
        }
        .ai-logs-table {
          width: 100%;
          border-collapse: collapse;
          font-size: 12px;
        }
        .ai-logs-table th {
          text-align: left;
          padding: 8px 12px;
          background: var(--color-bg-secondary);
          color: var(--color-text-secondary);
          font-weight: 600;
          font-size: 10px;
          text-transform: uppercase;
          letter-spacing: 0.04em;
        }
        .ai-logs-table td {
          padding: 8px 12px;
          border-top: 1px solid var(--color-border-light);
          color: var(--color-text-primary);
        }
        .ai-engine-tag {
          display: inline-flex;
          padding: 1px 6px;
          font-size: 10px;
          background: rgba(139, 92, 246, 0.1);
          color: #8b5cf6;
          border-radius: 4px;
          text-transform: capitalize;
        }
        .ai-detail-tag {
          display: inline-flex;
          padding: 1px 5px;
          font-size: 10px;
          background: var(--color-danger-light);
          color: var(--color-danger);
          border-radius: 3px;
        }
      `}</style>
    </div>
  );
}
