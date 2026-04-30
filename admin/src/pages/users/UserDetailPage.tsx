import { useParams, useNavigate } from 'react-router-dom';
import { useUserDetail } from '@/hooks/useUsers';

export function UserDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data, isLoading, error } = useUserDetail(id);

  if (isLoading) return <div className="p-12 text-center">Loading user details...</div>;
  if (error || !data) return <div className="p-12 text-center text-red-500">Failed to load user.</div>;

  const { user, listings, orders } = data;

  const handleBan = () => {
    // TBD: Integrate with ban mutation / dialog
    alert(`Ban user dialog for ${user.id} would open here.`);
  };

  return (
    <div className="p-6 max-w-5xl mx-auto space-y-6">
      <div className="flex items-center space-x-4 mb-4">
        <button onClick={() => navigate(-1)} className="text-gray-500 hover:text-gray-900">
          &larr; Back to Users
        </button>
        <h1 className="text-2xl font-bold text-gray-900 flex-1">User Details</h1>
        <button 
          onClick={handleBan}
          className="px-4 py-2 bg-red-600 text-white rounded-md text-sm font-medium hover:bg-red-700"
        >
          Ban User
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Profile Card */}
        <div className="bg-white rounded-lg shadow p-6 md:col-span-1 space-y-4">
          <div className="flex flex-col items-center">
            {user.avatar_url ? (
              <img src={user.avatar_url} alt="Avatar" className="w-24 h-24 rounded-full mb-4" />
            ) : (
              <div className="w-24 h-24 rounded-full bg-indigo-100 flex items-center justify-center text-indigo-600 text-3xl font-bold mb-4">
                {user.email[0].toUpperCase()}
              </div>
            )}
            <h2 className="text-xl font-bold text-gray-900">{user.display_name || 'No Name'}</h2>
            <p className="text-gray-500 text-sm">{user.email}</p>
          </div>
          
          <div className="border-t pt-4 space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-gray-500">School ID</span>
              <span className="font-medium text-gray-900">{user.college_id}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-500">Status</span>
              <span className="font-medium text-green-600">Active</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-500">Registered</span>
              <span className="font-medium text-gray-900">{new Date(user.created_at).toLocaleDateString()}</span>
            </div>
          </div>
        </div>

        {/* Stats and Lists */}
        <div className="md:col-span-2 space-y-6">
          
          {/* Stats Grid */}
          <div className="grid grid-cols-3 gap-4">
            <div className="bg-white rounded-lg shadow p-4 text-center">
              <div className="text-gray-500 text-sm font-medium mb-1">Listings</div>
              <div className="text-2xl font-bold text-gray-900">{listings.length}</div>
            </div>
            <div className="bg-white rounded-lg shadow p-4 text-center">
              <div className="text-gray-500 text-sm font-medium mb-1">Orders</div>
              <div className="text-2xl font-bold text-gray-900">{orders.length}</div>
            </div>
            <div className="bg-white rounded-lg shadow p-4 text-center border-t-4 border-red-500">
              <div className="text-gray-500 text-sm font-medium mb-1">Reports Against</div>
              <div className="text-2xl font-bold text-red-600">0</div>
            </div>
          </div>

          {/* Recent Listings */}
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-200">
              <h3 className="text-lg font-medium text-gray-900">Recent Listings</h3>
            </div>
            {listings.length === 0 ? (
              <div className="p-6 text-center text-gray-500 text-sm">No listings found.</div>
            ) : (
              <ul className="divide-y divide-gray-200">
                {listings.map((l: any) => (
                  <li key={l.id} className="px-6 py-4 flex items-center justify-between hover:bg-gray-50">
                    <div>
                      <p className="text-sm font-medium text-gray-900">{l.title}</p>
                      <p className="text-xs text-gray-500">{new Date(l.created_at).toLocaleDateString()}</p>
                    </div>
                    <div className="flex items-center space-x-4">
                      <span className="text-sm font-medium text-gray-900">${l.price}</span>
                      <span className="px-2 py-1 text-xs rounded-full bg-gray-100 text-gray-800">{l.moderation_status}</span>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>

          {/* Recent Orders */}
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-200">
              <h3 className="text-lg font-medium text-gray-900">Recent Orders</h3>
            </div>
            {orders.length === 0 ? (
              <div className="p-6 text-center text-gray-500 text-sm">No orders found.</div>
            ) : (
              <ul className="divide-y divide-gray-200">
                {orders.map((o: any) => (
                  <li key={o.id} className="px-6 py-4 flex items-center justify-between hover:bg-gray-50">
                    <div>
                      <p className="text-sm font-medium text-gray-900">Order for: {o.listing?.title || 'Unknown Item'}</p>
                      <p className="text-xs text-gray-500">{new Date(o.created_at).toLocaleDateString()}</p>
                    </div>
                    <div className="flex items-center space-x-4">
                      <span className="text-sm font-medium text-gray-900">${o.total_price}</span>
                      <span className="px-2 py-1 text-xs rounded-full bg-blue-50 text-blue-700">{o.status}</span>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
