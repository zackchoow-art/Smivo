import { useState } from 'react';
import { useAllListings, useSimulateAIReview } from '@/hooks/useListingModeration';
import { DEFAULT_PAGE_SIZE } from '@/lib/constants';
import { Filter, Bot, Eye } from 'lucide-react';
import { showToast } from '@/hooks/useToast';
import React from 'react';

const CATEGORIES = ['furniture', 'electronics', 'instruments', 'books', 'clothing', 'sports', 'other'];

export function AllListingsPage() {
  const [page, setPage] = useState(0);
  const [dateSort, setDateSort] = useState<'newest' | 'oldest'>('newest');
  const [categoryId, setCategoryId] = useState<string>('all');
  const [expandedId, setExpandedId] = useState<string | null>(null);

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
              {CATEGORIES.map((val) => (
                <option key={val} value={val}>{val.charAt(0).toUpperCase() + val.slice(1)}</option>
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
                          {listing.listing_images?.[0] ? (
                            <img className="lm-listing-thumb" src={listing.listing_images[0]} alt="" />
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
                        <span className="lm-badge lm-badge--neutral">{listing.category_id}</span>
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

function ListingDetailCard({ listing }: { listing: any }) {
  const [trigger, setTrigger] = useState('Weapons/Firearms');
  const [action, setAction] = useState('Auto-Take Down & Ban');
  const [priority, setPriority] = useState('urgent');
  
  const simulateMutation = useSimulateAIReview();

  const handleSimulate = async () => {
    try {
      await simulateMutation.mutateAsync({
        listingId: listing.id,
        trigger,
        action,
        priority
      });
      showToast('AI moderation simulated successfully! Flagged for system queue.', 'success');
    } catch (err) {
      showToast('Failed to simulate AI review.', 'error');
    }
  };

  return (
    <div className="card-expanded-content">
      <div className="detail-pane">
        <h3 className="pane-title">Listing Information</h3>
        <p className="detail-desc">{listing.description}</p>
        
        <div className="detail-grid">
          <div className="detail-item">
            <span className="label">Condition</span>
            <span className="value">{listing.condition}</span>
          </div>
          <div className="detail-item">
            <span className="label">Status</span>
            <span className="value">{listing.status}</span>
          </div>
          {listing.pickup_location && (
            <div className="detail-item">
              <span className="label">Pickup Location</span>
              <span className="value">{listing.pickup_location}</span>
            </div>
          )}
        </div>

        <div className="image-gallery">
          {listing.listing_images?.map((img: string, i: number) => (
            <img key={i} src={img} alt="listing" className="gallery-img" />
          ))}
        </div>
      </div>
      
      <div className="ai-sim-pane">
        <div className="ai-sim-header">
          <Bot size={18} className="ai-icon" />
          <h3 className="pane-title" style={{ margin: 0 }}>Secondary AI Simulation</h3>
        </div>
        <p className="ai-sim-desc">
          Manually trigger an AI flag to test the moderation pipeline. This will intercept the listing and send it to the System Queue.
        </p>

        <div className="form-group">
          <label className="form-label">Detected Issue (Tag)</label>
          <select className="form-select" value={trigger} onChange={e => setTrigger(e.target.value)}>
            <option value="Weapons/Firearms">Weapons / Firearms</option>
            <option value="Explicit Content">Explicit Content</option>
            <option value="Counterfeit Goods">Counterfeit Goods</option>
            <option value="Scam Language">Scam Language</option>
            <option value="Personal Information">Personal Info Leak</option>
          </select>
        </div>

        <div className="form-group">
          <label className="form-label">Recommended Action</label>
          <select className="form-select" value={action} onChange={e => setAction(e.target.value)}>
            <option value="Auto-Take Down & Ban">Auto-Take Down & Ban</option>
            <option value="Suspend Listing & Human Review">Suspend Listing & Human Review</option>
            <option value="Human Review (Low Priority)">Human Review (Low Priority)</option>
          </select>
        </div>

        <div className="form-group">
          <label className="form-label">Assign Priority</label>
          <select className="form-select" value={priority} onChange={e => setPriority(e.target.value)}>
            <option value="urgent">Urgent</option>
            <option value="normal">Normal</option>
            <option value="low">Low</option>
          </select>
        </div>

        <button 
          className="ai-sim-btn" 
          onClick={handleSimulate}
          disabled={simulateMutation.isPending || listing.moderation_status === 'pending_review'}
        >
          {simulateMutation.isPending ? 'Simulating...' : 
           listing.moderation_status === 'pending_review' ? 'Already in Queue' : 'Execute AI Flag'}
        </button>
      </div>

      <style>{`
        .card-expanded-content {
          display: flex;
          gap: 24px;
          padding: 24px 32px;
        }

        .detail-pane {
          flex: 2;
          padding-right: 24px;
          border-right: 1px solid var(--color-border);
        }

        .ai-sim-pane {
          flex: 1;
          min-width: 300px;
          background: rgba(139, 92, 246, 0.04);
          border: 1px solid rgba(139, 92, 246, 0.2);
          border-radius: var(--radius-md);
          padding: 20px;
        }

        .pane-title {
          font-size: 15px;
          font-weight: 600;
          color: var(--color-text-primary);
          margin-top: 0;
          margin-bottom: 12px;
        }

        .detail-desc {
          font-size: 13px;
          color: var(--color-text-secondary);
          line-height: 1.5;
          margin-bottom: 20px;
          white-space: pre-wrap;
        }

        .detail-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
          gap: 16px;
          margin-bottom: 20px;
        }

        .detail-item {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .detail-item .label {
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
          color: var(--color-text-tertiary);
        }

        .detail-item .value {
          font-size: 13px;
          color: var(--color-text-primary);
          font-weight: 500;
        }

        .image-gallery {
          display: flex;
          gap: 12px;
          overflow-x: auto;
          padding-bottom: 8px;
        }

        .gallery-img {
          width: 80px;
          height: 80px;
          border-radius: var(--radius-sm);
          object-fit: cover;
          border: 1px solid var(--color-border);
        }

        .ai-sim-header {
          display: flex;
          align-items: center;
          gap: 8px;
          margin-bottom: 8px;
          color: #8b5cf6;
        }

        .ai-icon {
          color: #8b5cf6;
        }

        .ai-sim-desc {
          font-size: 12px;
          color: var(--color-text-secondary);
          margin-bottom: 20px;
          line-height: 1.4;
        }

        .form-group {
          margin-bottom: 16px;
        }

        .form-label {
          display: block;
          font-size: 12px;
          font-weight: 600;
          color: var(--color-text-primary);
          margin-bottom: 6px;
        }

        .form-select {
          width: 100%;
          padding: 8px 12px;
          font-size: 13px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-sm);
          background: var(--color-bg-primary);
          color: var(--color-text-primary);
          outline: none;
        }

        .form-select:focus {
          border-color: #8b5cf6;
        }

        .ai-sim-btn {
          width: 100%;
          padding: 10px;
          background: #8b5cf6;
          color: white;
          border: none;
          border-radius: var(--radius-sm);
          font-size: 13px;
          font-weight: 600;
          cursor: pointer;
          transition: background 0.2s;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
        }

        .ai-sim-btn:hover:not(:disabled) {
          background: #7c3aed;
        }

        .ai-sim-btn:disabled {
          background: var(--color-bg-tertiary);
          color: var(--color-text-tertiary);
          cursor: not-allowed;
        }
      `}</style>
    </div>
  );
}
