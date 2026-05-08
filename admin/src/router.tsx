/**
 * Router configuration — all routes per 04_ADMIN_WEB_SPEC.md §4.4.
 * Pages not yet implemented use PlaceholderPage.
 */
import { createBrowserRouter, Navigate } from 'react-router-dom';
import { AppShell } from '@/components/layout/AppShell';
import { PlaceholderPage } from '@/pages/PlaceholderPage';
import { LoginPage } from '@/pages/LoginPage';
import { DashboardPage } from '@/pages/DashboardPage';
import { AnalyticsPage } from '@/pages/AnalyticsPage';
import { FeatureFlagsPage } from '@/pages/settings/FeatureFlagsPage';
import { ProfilePage } from '@/pages/settings/ProfilePage';
import { CollegesPage } from '@/pages/settings/CollegesPage';
import { DictionaryListPage } from '@/pages/settings/DictionaryListPage';
import { DictionaryItemsPage } from '@/pages/settings/DictionaryItemsPage';
import { SystemConfigsPage } from '@/pages/settings/SystemConfigsPage';
import { AdminsPage } from '@/pages/settings/AdminsPage';
import { SensitiveWordsPage } from '@/pages/moderation/SensitiveWordsPage';
import { AuditLogPage } from '@/pages/AuditLogPage';
import { ChatReportsPage } from '@/pages/moderation/ChatReportsPage';
import { ChatReportDetailPage } from '@/pages/moderation/ChatReportDetailPage';
import { BansPage } from '@/pages/users/BansPage';
import { UsersPage } from '@/pages/users/UsersPage';
import { UserDetailPage } from '@/pages/users/UserDetailPage';
import { FeedbackListPage } from '@/pages/feedback/FeedbackListPage';
import { FeedbackDetailPage } from '@/pages/feedback/FeedbackDetailPage';
import { AllListingsPage } from '@/pages/moderation/AllListingsPage';
import { ListingModerationPage } from '@/pages/moderation/ListingModerationPage';
import { ListingModerationDetailPage } from '@/pages/moderation/ListingModerationDetailPage';
import { ListingReportDetailPage } from '@/pages/moderation/ListingReportDetailPage';
import { PushOverviewPage } from '@/pages/push/PushOverviewPage';
import { PushCreatePage } from '@/pages/push/PushCreatePage';
import { PushHistoryPage } from '@/pages/push/PushHistoryPage';
import { TestDataCleanupPage } from '@/pages/settings/TestDataCleanupPage';


export const router = createBrowserRouter([
  // Public routes
  {
    path: '/login',
    element: <LoginPage />,
  },

  // Protected routes — wrapped in AppShell (handles auth guard)
  {
    element: <AppShell />,
    children: [
      // Root redirect
      { index: true, element: <Navigate to="/dashboard" replace /> },

      // 01 Dashboard
      { path: 'dashboard', element: <DashboardPage /> },

      // 02-05 Content Moderation
      { path: 'moderation/all-listings', element: <AllListingsPage /> },
      { path: 'moderation/listings', element: <ListingModerationPage /> },
      { path: 'moderation/listings/:id', element: <ListingModerationDetailPage /> },
      { path: 'moderation/listing-reports/:id', element: <ListingReportDetailPage /> },
      { path: 'moderation/user-reports', element: <PlaceholderPage /> },
      { path: 'moderation/chat-reports', element: <ChatReportsPage /> },
      { path: 'moderation/chat-reports/:id', element: <ChatReportDetailPage /> },
      { path: 'moderation/sensitive-words', element: <SensitiveWordsPage /> },
      { path: 'moderation/ai-reviewed', element: <PlaceholderPage /> },

      // 06-08 User Management
      { path: 'users', element: <UsersPage /> },
      { path: 'users/:id', element: <UserDetailPage /> },
      { path: 'bans', element: <BansPage /> },

      // 09-10 User Engagement
      { path: 'feedback', element: <FeedbackListPage /> },
      { path: 'feedback/:id', element: <FeedbackDetailPage /> },
      { path: 'push', element: <PushOverviewPage /> },
      { path: 'push/new', element: <PushCreatePage /> },
      { path: 'push/history', element: <PushHistoryPage /> },

      // 11 Analytics
      { path: 'analytics', element: <AnalyticsPage /> },

      // 12-15 System Configuration
      { path: 'settings/dictionary', element: <DictionaryListPage /> },
      { path: 'settings/dictionary/:dictCode', element: <DictionaryItemsPage /> },
      { path: 'settings/configs', element: <SystemConfigsPage /> },
      { path: 'settings/feature-flags', element: <FeatureFlagsPage /> },
      { path: 'settings/admins', element: <AdminsPage /> },
      { path: 'settings/colleges', element: <CollegesPage /> },
      { path: 'settings/profile', element: <ProfilePage /> },
      { path: 'settings/cleanup', element: <TestDataCleanupPage /> },


      // 16 Audit Log
      { path: 'audit-log', element: <AuditLogPage /> },

      // Catch-all 404
      { path: '*', element: <Navigate to="/dashboard" replace /> },
    ],
  },
]);
