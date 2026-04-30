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

  if (isLoading) return <div className="p-12 text-center">Loading listing details...</div>;
  if (error || !listing) return <div className="p-12 text-center text-red-500">Failed to load listing.</div>;

  return (
    <div className="p-6 max-w-5xl mx-auto space-y-6">
      <div className="flex items-center space-x-4 mb-4">
        <button onClick={() => navigate(-1)} className="text-gray-500 hover:text-gray-900">
          &larr; Back to List
        </button>
        <h1 className="text-2xl font-bold text-gray-900 flex-1">Review Listing</h1>
        <span className="px-3 py-1 bg-gray-100 text-gray-800 rounded-full text-sm font-medium">
          Status: {listing.moderation_status}
        </span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        
        {/* Main Content (Images & Info) */}
        <div className="md:col-span-2 space-y-6">
          <div className="bg-white rounded-lg shadow overflow-hidden">
            {/* Image Carousel */}
            <div className="bg-gray-100 aspect-video relative flex items-center justify-center">
              {listing.images && listing.images.length > 0 ? (
                <>
                  <img 
                    src={listing.images[activeImageIndex].image_url} 
                    alt={`Listing image ${activeImageIndex + 1}`}
                    className="max-h-full object-contain"
                  />
                  {listing.images.length > 1 && (
                    <div className="absolute bottom-4 left-0 right-0 flex justify-center space-x-2">
                      {listing.images.map((img, idx) => (
                        <button 
                          key={img.id}
                          onClick={() => setActiveImageIndex(idx)}
                          className={`w-2 h-2 rounded-full ${idx === activeImageIndex ? 'bg-indigo-600' : 'bg-gray-300'}`}
                        />
                      ))}
                    </div>
                  )}
                </>
              ) : (
                <div className="text-gray-400">No images</div>
              )}
            </div>
            
            <div className="p-6 space-y-4">
              <div>
                <h2 className="text-xl font-bold text-gray-900">{listing.title}</h2>
                <p className="text-xl text-indigo-600 font-semibold mt-1">${listing.price}</p>
              </div>
              
              <div className="grid grid-cols-2 gap-4 text-sm text-gray-600">
                <div><span className="font-medium text-gray-900">Category:</span> {listing.category}</div>
                <div><span className="font-medium text-gray-900">Condition:</span> {listing.condition}</div>
                <div><span className="font-medium text-gray-900">Type:</span> {listing.listing_type}</div>
                {listing.pickup_location && <div><span className="font-medium text-gray-900">Pickup:</span> {listing.pickup_location}</div>}
              </div>

              <div>
                <h3 className="font-medium text-gray-900 mb-1">Description</h3>
                <p className="text-gray-700 whitespace-pre-wrap text-sm">{listing.description || 'No description provided.'}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Sidebar (Seller Info & Actions) */}
        <div className="space-y-6">
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="font-bold text-gray-900 mb-4 text-lg">Seller Profile</h3>
            {listing.seller ? (
              <div className="space-y-4">
                <div className="flex items-center space-x-3">
                  {listing.seller.avatar_url ? (
                    <img src={listing.seller.avatar_url} alt="" className="w-12 h-12 rounded-full" />
                  ) : (
                    <div className="w-12 h-12 rounded-full bg-gray-200 flex items-center justify-center text-gray-500 font-bold">
                      {listing.seller.email[0].toUpperCase()}
                    </div>
                  )}
                  <div>
                    <div className="font-medium text-gray-900">{listing.seller.display_name || 'No name'}</div>
                    <div className="text-xs text-gray-500">{listing.seller.email}</div>
                  </div>
                </div>
                
                <div className="grid grid-cols-2 gap-2 text-xs border-t pt-4">
                  <div className="bg-gray-50 p-2 rounded">
                    <div className="text-gray-500">Listings</div>
                    <div className="font-bold text-gray-900 text-base">—</div>
                  </div>
                  <div className="bg-gray-50 p-2 rounded">
                    <div className="text-gray-500">Orders</div>
                    <div className="font-bold text-gray-900 text-base">—</div>
                  </div>
                  <div className="bg-gray-50 p-2 rounded">
                    <div className="text-gray-500">Reports</div>
                    <div className="font-bold text-red-600 text-base">—</div>
                  </div>
                  <div className="bg-gray-50 p-2 rounded">
                    <div className="text-gray-500">Bans</div>
                    <div className="font-bold text-red-600 text-base">—</div>
                  </div>
                </div>
              </div>
            ) : (
              <div className="text-gray-500 text-sm">Seller info missing</div>
            )}
          </div>

          <div className="bg-white rounded-lg shadow p-6 space-y-4">
            <h3 className="font-bold text-gray-900 mb-4 text-lg">Moderation Action</h3>
            
            {showRejectForm ? (
              <div className="space-y-3">
                <label className="block text-sm font-medium text-gray-700">Reason for Rejection</label>
                <textarea
                  rows={3}
                  className="w-full border-gray-300 rounded-md shadow-sm focus:ring-red-500 focus:border-red-500 sm:text-sm"
                  placeholder="Explain why this listing is rejected..."
                  value={rejectReason}
                  onChange={(e) => setRejectReason(e.target.value)}
                />
                <div className="flex space-x-2">
                  <button 
                    onClick={() => handleAction('reject')}
                    disabled={moderateMutation.isPending}
                    className="flex-1 bg-red-600 text-white py-2 rounded-md font-medium text-sm hover:bg-red-700 disabled:opacity-50"
                  >
                    Confirm Reject
                  </button>
                  <button 
                    onClick={() => setShowRejectForm(false)}
                    className="px-3 bg-gray-100 text-gray-700 py-2 rounded-md font-medium text-sm hover:bg-gray-200"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            ) : (
              <div className="space-y-3">
                <button 
                  onClick={() => handleAction('approve')}
                  disabled={moderateMutation.isPending || listing.moderation_status === MODERATION_STATUS.APPROVED}
                  className="w-full bg-green-600 text-white py-2.5 rounded-md font-medium hover:bg-green-700 disabled:opacity-50"
                >
                  Approve Listing
                </button>
                
                <button 
                  onClick={() => handleAction('reject')}
                  disabled={moderateMutation.isPending || listing.moderation_status === MODERATION_STATUS.REJECTED}
                  className="w-full bg-red-50 text-red-700 border border-red-200 py-2.5 rounded-md font-medium hover:bg-red-100 disabled:opacity-50"
                >
                  Reject Listing
                </button>
                
                {listing.moderation_status === MODERATION_STATUS.APPROVED && (
                  <button 
                    onClick={() => handleAction('takedown')}
                    disabled={moderateMutation.isPending}
                    className="w-full bg-orange-600 text-white py-2.5 rounded-md font-medium hover:bg-orange-700 disabled:opacity-50"
                  >
                    Force Takedown
                  </button>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
