import { Link } from 'react-router-dom';
import { useRecentPushJobs } from '@/hooks/usePush';

export function PushOverviewPage() {
  const { data: recentJobs, isLoading, error } = useRecentPushJobs(5);

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Push Notifications Overview</h1>
        <Link 
          to="/push/new" 
          className="px-4 py-2 bg-indigo-600 text-white rounded-md text-sm font-medium hover:bg-indigo-700"
        >
          Create New Push
        </Link>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        
        {/* Quick Actions / Stats Card */}
        <div className="bg-white rounded-lg shadow p-6 md:col-span-1 space-y-6">
          <h2 className="text-lg font-bold text-gray-900">Quick Actions</h2>
          <div className="space-y-4">
            <Link to="/push/new" className="block w-full text-center px-4 py-3 border border-indigo-600 text-indigo-600 rounded-md hover:bg-indigo-50 font-medium">
              Draft New Message
            </Link>
            <Link to="/push/history" className="block w-full text-center px-4 py-3 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50 font-medium">
              View Full History
            </Link>
          </div>

          <div className="border-t pt-6">
            <h3 className="text-sm font-medium text-gray-500 uppercase tracking-wider mb-4">Quick Stats (Last 30 Days)</h3>
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <span className="text-gray-600 text-sm">Messages Sent</span>
                <span className="font-bold text-gray-900">--</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-600 text-sm">Avg Open Rate</span>
                <span className="font-bold text-gray-900">--%</span>
              </div>
            </div>
          </div>
        </div>

        {/* Recent History */}
        <div className="bg-white rounded-lg shadow md:col-span-2 overflow-hidden">
          <div className="px-6 py-5 border-b border-gray-200 flex justify-between items-center">
            <h2 className="text-lg font-bold text-gray-900">Recent Activity</h2>
            <Link to="/push/history" className="text-sm text-indigo-600 hover:text-indigo-900 font-medium">View All</Link>
          </div>
          
          {isLoading ? (
            <div className="p-8 text-center text-gray-500">Loading recent activity...</div>
          ) : error ? (
            <div className="p-8 text-center text-red-500">Failed to load recent activity.</div>
          ) : recentJobs && recentJobs.length > 0 ? (
            <ul className="divide-y divide-gray-200">
              {recentJobs.map(job => (
                <li key={job.id} className="p-6 hover:bg-gray-50 flex items-center justify-between">
                  <div className="space-y-1">
                    <p className="text-sm font-medium text-gray-900">{job.title}</p>
                    <p className="text-xs text-gray-500 truncate max-w-md">{job.body}</p>
                    <p className="text-xs text-gray-400 mt-1">
                      {new Date(job.created_at).toLocaleString()}
                    </p>
                  </div>
                  <div className="text-right">
                    <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      job.status === 'sent' ? 'bg-green-100 text-green-800' :
                      job.status === 'draft' ? 'bg-gray-100 text-gray-800' :
                      job.status === 'failed' ? 'bg-red-100 text-red-800' :
                      'bg-blue-100 text-blue-800'
                    }`}>
                      {job.status}
                    </span>
                    <div className="text-xs text-gray-500 mt-2">
                      Audience: {job.audience_type}
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          ) : (
            <div className="p-8 text-center text-gray-500">No recent push jobs found.</div>
          )}
        </div>

      </div>
    </div>
  );
}
