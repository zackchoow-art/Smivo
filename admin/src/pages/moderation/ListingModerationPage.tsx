import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useListingsModeration, useBatchModerateListings } from '@/hooks/useListingModeration';
import { DEFAULT_PAGE_SIZE, MODERATION_STATUS, MODERATION_PRIORITY } from '@/lib/constants';
import type { ModerationStatus } from '@/types';
import { useAuth } from '@/hooks/useAuth'; // Assumed to exist for getting admin ID

export function ListingModerationPage() {
  const [page, setPage] = useState(0);
  const [statusFilter, setStatusFilter] = useState<ModerationStatus | 'all'>('pending_review');
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  
  const { data, isLoading, error } = useListingsModeration(page, { status: statusFilter });
  const batchModerate = useBatchModerateListings();
  const { admin } = useAuth(); // Assume we get the logged in admin user

  const handleSelectAll = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.checked) {
      const allIds = new Set(data?.data.map((l: any) => l.id) || []);
      setSelectedIds(allIds);
    } else {
      setSelectedIds(new Set());
    }
  };

  const handleSelectOne = (id: string, checked: boolean) => {
    const newSet = new Set(selectedIds);
    if (checked) {
      newSet.add(id);
    } else {
      newSet.delete(id);
    }
    setSelectedIds(newSet);
  };

  const handleBatchAction = async (action: 'approve' | 'reject') => {
    if (selectedIds.size === 0 || !admin) return;
    try {
      await batchModerate.mutateAsync({
        ids: Array.from(selectedIds),
        action,
        adminId: admin?.user_id ?? ""
      });
      setSelectedIds(new Set());
    } catch (err) {
      console.error('Batch action failed', err);
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case MODERATION_PRIORITY.URGENT: return 'bg-red-100 text-red-800 border-red-200';
      case MODERATION_PRIORITY.NORMAL: return 'bg-blue-100 text-blue-800 border-blue-200';
      case MODERATION_PRIORITY.LOW: return 'bg-gray-100 text-gray-800 border-gray-200';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case MODERATION_STATUS.PENDING_REVIEW: return 'bg-yellow-100 text-yellow-800';
      case MODERATION_STATUS.APPROVED: return 'bg-green-100 text-green-800';
      case MODERATION_STATUS.REJECTED: return 'bg-red-100 text-red-800';
      case MODERATION_STATUS.TAKEN_DOWN: return 'bg-gray-100 text-gray-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Listing Moderation</h1>
        
        <div className="flex items-center space-x-4">
          <select 
            value={statusFilter} 
            onChange={(e) => {
              setStatusFilter(e.target.value as any);
              setPage(0);
              setSelectedIds(new Set());
            }}
            className="border-gray-300 rounded-md shadow-sm text-sm focus:ring-indigo-500 focus:border-indigo-500"
          >
            <option value="all">All Statuses</option>
            <option value={MODERATION_STATUS.PENDING_REVIEW}>Pending Review</option>
            <option value={MODERATION_STATUS.APPROVED}>Approved</option>
            <option value={MODERATION_STATUS.REJECTED}>Rejected</option>
            <option value={MODERATION_STATUS.TAKEN_DOWN}>Taken Down</option>
          </select>

          <button
            onClick={() => handleBatchAction('approve')}
            disabled={selectedIds.size === 0 || batchModerate.isPending}
            className="px-4 py-2 bg-green-600 text-white rounded-md text-sm font-medium disabled:opacity-50"
          >
            Batch Approve
          </button>
          <button
            onClick={() => handleBatchAction('reject')}
            disabled={selectedIds.size === 0 || batchModerate.isPending}
            className="px-4 py-2 bg-red-600 text-white rounded-md text-sm font-medium disabled:opacity-50"
          >
            Batch Reject
          </button>
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center p-12">Loading listings...</div>
      ) : error ? (
        <div className="text-red-500 p-4 bg-red-50 rounded-md">Error loading listings.</div>
      ) : (
        <div className="bg-white shadow overflow-hidden sm:rounded-lg">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <input 
                    type="checkbox" 
                    onChange={handleSelectAll}
                    checked={(data?.data?.length ?? 0) > 0 && selectedIds.size === (data?.data?.length ?? 0)}
                    className="rounded border-gray-300 text-indigo-600 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
                  />
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Seller</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Price</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Priority</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Submitted</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {data?.data.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-6 py-4 text-center text-sm text-gray-500">
                    No listings found.
                  </td>
                </tr>
              ) : (
                data?.data.map((listing: any) => (
                  <tr key={listing.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <input 
                        type="checkbox" 
                        checked={selectedIds.has(listing.id)}
                        onChange={(e) => handleSelectOne(listing.id, e.target.checked)}
                        className="rounded border-gray-300 text-indigo-600 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
                      />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900 truncate max-w-xs">{listing.title}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        {listing.seller?.avatar_url && (
                          <img className="h-6 w-6 rounded-full mr-2" src={listing.seller.avatar_url} alt="" />
                        )}
                        <div className="text-sm text-gray-900">{listing.seller?.display_name || 'Unknown'}</div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      ${listing.price}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(listing.moderation_status)}`}>
                        {listing.moderation_status.replace('_', ' ')}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full border ${getPriorityColor(listing.moderation_priority)}`}>
                        {listing.moderation_priority}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {new Date(listing.created_at).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <Link to={`/moderation/listings/${listing.id}`} className="text-indigo-600 hover:text-indigo-900">
                        Review
                      </Link>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* Pagination Controls */}
      {data && data.count > DEFAULT_PAGE_SIZE && (
        <div className="mt-4 flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6 rounded-lg shadow">
          <div className="flex flex-1 justify-between sm:hidden">
            <button onClick={() => setPage(p => Math.max(0, p - 1))} disabled={page === 0} className="relative inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">Previous</button>
            <button onClick={() => setPage(p => p + 1)} disabled={(page + 1) * DEFAULT_PAGE_SIZE >= data.count} className="relative ml-3 inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">Next</button>
          </div>
          <div className="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
            <div>
              <p className="text-sm text-gray-700">
                Showing <span className="font-medium">{page * DEFAULT_PAGE_SIZE + 1}</span> to <span className="font-medium">{Math.min((page + 1) * DEFAULT_PAGE_SIZE, data.count)}</span> of <span className="font-medium">{data.count}</span> results
              </p>
            </div>
            <div>
              <nav className="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
                <button
                  onClick={() => setPage(p => Math.max(0, p - 1))}
                  disabled={page === 0}
                  className="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0 disabled:opacity-50"
                >
                  <span className="sr-only">Previous</span>
                  &larr;
                </button>
                <button
                  onClick={() => setPage(p => p + 1)}
                  disabled={(page + 1) * DEFAULT_PAGE_SIZE >= data.count}
                  className="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0 disabled:opacity-50"
                >
                  <span className="sr-only">Next</span>
                  &rarr;
                </button>
              </nav>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
