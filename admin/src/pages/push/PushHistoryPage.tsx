import { useState } from 'react';
import { Link } from 'react-router-dom';
import { usePushJobs } from '@/hooks/usePush';
import { DEFAULT_PAGE_SIZE, PUSH_STATUS } from '@/lib/constants';
import type { PushStatus } from '@/types';

export function PushHistoryPage() {
  const [page, setPage] = useState(0);
  const [statusFilter, setStatusFilter] = useState<PushStatus | 'all'>('all');

  const { data, isLoading, error } = usePushJobs(page, { status: statusFilter });

  const getStatusColor = (status: string) => {
    switch (status) {
      case PUSH_STATUS.DRAFT: return 'bg-gray-100 text-gray-800';
      case PUSH_STATUS.SCHEDULED: return 'bg-blue-100 text-blue-800';
      case PUSH_STATUS.SENDING: return 'bg-yellow-100 text-yellow-800';
      case PUSH_STATUS.SENT: return 'bg-green-100 text-green-800';
      case PUSH_STATUS.FAILED: return 'bg-red-100 text-red-800';
      case PUSH_STATUS.CANCELLED: return 'bg-gray-100 text-gray-600';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center space-x-4">
          <Link to="/push" className="text-gray-500 hover:text-gray-900">&larr; Back to Overview</Link>
          <h1 className="text-2xl font-bold text-gray-900">Push History</h1>
        </div>
        
        <div className="flex items-center space-x-4">
          <select 
            value={statusFilter} 
            onChange={(e) => {
              setStatusFilter(e.target.value as any);
              setPage(0);
            }}
            className="border-gray-300 rounded-md shadow-sm text-sm focus:ring-indigo-500 focus:border-indigo-500"
          >
            <option value="all">All Statuses</option>
            <option value={PUSH_STATUS.DRAFT}>Draft</option>
            <option value={PUSH_STATUS.SCHEDULED}>Scheduled</option>
            <option value={PUSH_STATUS.SENDING}>Sending</option>
            <option value={PUSH_STATUS.SENT}>Sent</option>
            <option value={PUSH_STATUS.FAILED}>Failed</option>
            <option value={PUSH_STATUS.CANCELLED}>Cancelled</option>
          </select>

          <Link 
            to="/push/new" 
            className="px-4 py-2 bg-indigo-600 text-white rounded-md text-sm font-medium hover:bg-indigo-700"
          >
            Create Push
          </Link>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        {isLoading ? (
          <div className="p-12 text-center text-gray-500">Loading history...</div>
        ) : error ? (
          <div className="p-12 text-center text-red-500">Failed to load push jobs.</div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title / Content</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Audience</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created / Scheduled</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Stats</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {data?.data.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-6 py-12 text-center text-gray-500 text-sm">
                    No push jobs found matching criteria.
                  </td>
                </tr>
              ) : (
                data?.data.map((job) => (
                  <tr key={job.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div className="text-sm font-medium text-gray-900">{job.title}</div>
                      <div className="text-xs text-gray-500 truncate max-w-sm mt-1">{job.body}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="text-sm text-gray-900 capitalize">{job.audience_type}</span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(job.status)}`}>
                        {job.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <div>Created: {new Date(job.created_at).toLocaleDateString()}</div>
                      {job.scheduled_at && <div className="text-indigo-600">Scheduled: {new Date(job.scheduled_at).toLocaleString()}</div>}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm">
                      {job.status === 'sent' || job.status === 'sending' ? (
                        <div className="space-y-1">
                          <div className="text-gray-900">Delivered: {job.delivered_count}</div>
                          <div className="text-green-600">Opened: {job.opened_count}</div>
                        </div>
                      ) : (
                        <span className="text-gray-400">--</span>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        )}

        {/* Pagination */}
        {data && data.count > DEFAULT_PAGE_SIZE && (
          <div className="flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6">
            <div className="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
              <div>
                <p className="text-sm text-gray-700">
                  Showing <span className="font-medium">{page * DEFAULT_PAGE_SIZE + 1}</span> to <span className="font-medium">{Math.min((page + 1) * DEFAULT_PAGE_SIZE, data.count)}</span> of <span className="font-medium">{data.count}</span>
                </p>
              </div>
              <div>
                <nav className="isolate inline-flex -space-x-px rounded-md shadow-sm">
                  <button
                    onClick={() => setPage(p => Math.max(0, p - 1))}
                    disabled={page === 0}
                    className="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0 disabled:opacity-50"
                  >
                    Previous
                  </button>
                  <button
                    onClick={() => setPage(p => p + 1)}
                    disabled={(page + 1) * DEFAULT_PAGE_SIZE >= data.count}
                    className="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0 disabled:opacity-50"
                  >
                    Next
                  </button>
                </nav>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
