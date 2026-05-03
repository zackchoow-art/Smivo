/**
 * Root App component — wires up React Query + Router.
 * No Supabase provider needed as we use a singleton client.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { RouterProvider } from 'react-router-dom';
import { router } from './router';
import { ToastContainer } from '@/components/ui/ToastContainer';

// NOTE: Stale time = 30s default for admin dashboards.
// Data freshness is more important than in consumer apps.
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30 * 1000,
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
      {/* NOTE: ToastContainer is fixed-position, renders outside the router tree */}
      <ToastContainer />
    </QueryClientProvider>
  );
}

