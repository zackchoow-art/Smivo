import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useCreatePushJob } from '@/hooks/usePush';
import { useAuth } from '@/hooks/useAuth';
import type { PushAudienceType, PushStatus } from '@/types';

export function PushCreatePage() {
  const navigate = useNavigate();
  const { admin } = useAuth();
  const createMutation = useCreatePushJob();

  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [deepLink, setDeepLink] = useState('');
  const [audienceType, setAudienceType] = useState<PushAudienceType>('all');
  const [isScheduled, setIsScheduled] = useState(false);
  const [scheduledAt, setScheduledAt] = useState('');

  const handleSubmit = async (e: React.FormEvent, status: PushStatus) => {
    e.preventDefault();
    if (!title.trim() || !body.trim()) {
      alert('Title and body are required.');
      return;
    }
    
    try {
      await createMutation.mutateAsync({
        title,
        body,
        deep_link: deepLink || null,
        channels: ['push'],
        audience_type: audienceType,
        audience_filter: null,
        audience_user_ids: null,
        college_id: null,
        scheduled_at: isScheduled && scheduledAt ? new Date(scheduledAt).toISOString() : null,
        status,
        created_by: admin?.user_id || null,
      });
      navigate('/push/history');
    } catch (err) {
      console.error('Failed to create push job', err);
      alert('Failed to create push job.');
    }
  };

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <div className="flex items-center space-x-4 mb-6">
        <button onClick={() => navigate(-1)} className="text-gray-500 hover:text-gray-900">
          &larr; Back
        </button>
        <h1 className="text-2xl font-bold text-gray-900">Create Push Notification</h1>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <form className="p-6 space-y-6">
          
          <div className="space-y-4">
            <h2 className="text-lg font-medium text-gray-900 border-b pb-2">Content</h2>
            
            <div>
              <label className="block text-sm font-medium text-gray-700">Notification Title</label>
              <input
                type="text"
                required
                value={title}
                onChange={e => setTitle(e.target.value)}
                className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                placeholder="E.g., Special Weekend Sale!"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700">Message Body</label>
              <textarea
                required
                rows={3}
                value={body}
                onChange={e => setBody(e.target.value)}
                className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                placeholder="E.g., Don't miss out on these limited time offers."
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Deep Link (Optional)</label>
              <input
                type="text"
                value={deepLink}
                onChange={e => setDeepLink(e.target.value)}
                className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                placeholder="smivo://app/listings/123"
              />
            </div>
          </div>

          <div className="space-y-4">
            <h2 className="text-lg font-medium text-gray-900 border-b pb-2 mt-8">Audience</h2>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Select Target Audience</label>
              <div className="space-y-2">
                <label className="inline-flex items-center">
                  <input
                    type="radio"
                    checked={audienceType === 'all'}
                    onChange={() => setAudienceType('all')}
                    className="form-radio h-4 w-4 text-indigo-600"
                  />
                  <span className="ml-2 text-sm text-gray-700">All Registered Users</span>
                </label>
                <br />
                <label className="inline-flex items-center disabled:opacity-50">
                  <input
                    type="radio"
                    checked={audienceType === 'filter'}
                    onChange={() => setAudienceType('filter')}
                    className="form-radio h-4 w-4 text-indigo-600"
                    disabled
                  />
                  <span className="ml-2 text-sm text-gray-700">Custom Filter (Coming Soon)</span>
                </label>
              </div>
            </div>
          </div>

          <div className="space-y-4">
            <h2 className="text-lg font-medium text-gray-900 border-b pb-2 mt-8">Schedule</h2>
            <div className="flex items-center">
              <input
                id="schedule_toggle"
                type="checkbox"
                checked={isScheduled}
                onChange={e => setIsScheduled(e.target.checked)}
                className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
              />
              <label htmlFor="schedule_toggle" className="ml-2 block text-sm text-gray-900">
                Send at a specific time
              </label>
            </div>
            
            {isScheduled && (
              <div>
                <input
                  type="datetime-local"
                  value={scheduledAt}
                  onChange={e => setScheduledAt(e.target.value)}
                  className="mt-1 block w-full sm:max-w-xs border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                />
              </div>
            )}
          </div>

          <div className="pt-6 flex items-center justify-end space-x-4 border-t border-gray-200">
            <button
              type="button"
              onClick={() => navigate(-1)}
              className="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none"
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={(e) => handleSubmit(e, 'draft')}
              disabled={createMutation.isPending}
              className="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-indigo-700 hover:bg-indigo-50 focus:outline-none disabled:opacity-50"
            >
              Save as Draft
            </button>
            <button
              type="submit"
              onClick={(e) => handleSubmit(e, isScheduled ? 'scheduled' : 'draft')}
              disabled={createMutation.isPending}
              className="bg-indigo-600 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white hover:bg-indigo-700 focus:outline-none disabled:opacity-50"
            >
              {isScheduled ? 'Schedule Push' : 'Create & Send Now'}
            </button>
          </div>
          
        </form>
      </div>
    </div>
  );
}
