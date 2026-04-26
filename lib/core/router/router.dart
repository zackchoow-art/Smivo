import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/features/profile/screens/profile_setup_screen.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';

import 'package:smivo/features/auth/screens/register_screen.dart';
import 'package:smivo/features/auth/screens/login_screen.dart';
import 'package:smivo/features/auth/screens/email_verification_screen.dart';
import 'package:smivo/features/home/screens/home_screen.dart';
import 'package:smivo/features/listing/screens/listing_detail_screen.dart';
import 'package:smivo/features/listing/screens/create_listing_form_screen.dart';
import 'package:smivo/features/chat/screens/chat_list_screen.dart';
import 'package:smivo/features/orders/screens/orders_screen.dart';
import 'package:smivo/features/orders/screens/order_detail_screen.dart';
import 'package:smivo/features/chat/screens/chat_room_screen.dart';
import 'package:smivo/features/settings/screens/edit_profile_screen.dart';
import 'package:smivo/features/settings/screens/help_screen.dart';
import 'package:smivo/features/settings/screens/notification_settings_screen.dart';
import 'package:smivo/features/settings/screens/settings_screen.dart';
import 'package:smivo/features/settings/screens/system_settings_screen.dart';
import 'package:smivo/features/seller/screens/seller_center_screen.dart';
import 'package:smivo/features/seller/screens/transaction_management_screen.dart';
import 'package:smivo/features/buyer/screens/buyer_center_screen.dart';
import 'package:smivo/shared/widgets/app_shell.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/notifications/screens/notification_center_screen.dart';
import 'package:smivo/features/admin/screens/admin_shell_screen.dart';
import 'package:smivo/features/admin/screens/admin_login_screen.dart';
import 'package:smivo/features/admin/screens/admin_dashboard_screen.dart';
import 'package:smivo/features/admin/screens/admin_users_screen.dart';
import 'package:smivo/features/admin/screens/admin_listings_screen.dart';
import 'package:smivo/features/admin/screens/admin_orders_screen.dart';
import 'package:smivo/features/admin/screens/admin_faqs_screen.dart';
import 'package:smivo/features/admin/screens/admin_categories_screen.dart';
import 'package:smivo/features/admin/screens/admin_conditions_screen.dart';
import 'package:smivo/features/admin/screens/admin_dictionary_screen.dart';
import 'package:smivo/features/admin/screens/admin_schools_screen.dart';
import 'app_routes.dart';

part 'router.g.dart';

/// Routes that guests can access without authentication.
const _publicRoutes = {
  AppRoutes.homePath,
  AppRoutes.loginPath,
  AppRoutes.registerPath,
  AppRoutes.emailVerificationPath,
};

/// Returns true if [path] matches a public route pattern.
///
/// Listing detail is also public (guest browsing), so we check
/// for the /listing/ prefix but exclude /listing/create.
bool _isPublicRoute(String path) {
  if (_publicRoutes.contains(path)) return true;
  // NOTE: Listing detail (/listing/:id) is public for guest browsing,
  // but /listing/create requires auth.
  if (path.startsWith('/listing/') && path != '/listing/create') {
    // Exclude /listing/:id/edit which requires auth
    if (!path.endsWith('/edit')) return true;
  }
  // NOTE: Admin routes bypass normal auth — admin has its own login.
  if (path.startsWith('/admin')) return true;
  return false;
}

/// GoRouter configuration with reactive auth redirect guard.
///
/// Handles four authentication/onboarding states:
/// 1. Guest: Access to home, listing details, login, and register.
/// 2. Unverified: Logged in but email not confirmed. Restricted to verification screen.
/// 3. Needs Onboarding: Logged in, verified, but display name is missing.
/// 4. Authenticated: Full access. Redirects away from auth screens to home.
@riverpod
GoRouter router(Ref ref) {
  // Watch auth state to trigger router refreshes automatically
  final authStateValue = ref.watch(authStateProvider);
  final user = authStateValue.valueOrNull;
  final isLoggedIn = user != null;
  final isEmailVerified = user?.emailConfirmedAt != null;

  // Watch profile state to handle onboarding redirect
  final profileValue = ref.watch(profileProvider);
  final profile = profileValue.valueOrNull;
  final needsOnboarding = profile != null && profile.displayName == null;

  return GoRouter(
    initialLocation: AppRoutes.homePath,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final currentPath = state.matchedLocation;

      // ─── STATE 1: Fully Authenticated & Onboarded ───────
      if (isLoggedIn && isEmailVerified && !needsOnboarding) {
        // Prevent authenticated users from going back to login/register/setup
        if (currentPath == AppRoutes.loginPath ||
            currentPath == AppRoutes.registerPath ||
            currentPath == AppRoutes.profileSetupPath) {
          return AppRoutes.homePath;
        }
        return null;
      }

      // ─── STATE 2: Logged in & Verified but Needs Onboarding ───
      if (isLoggedIn && isEmailVerified && needsOnboarding) {
        if (currentPath == AppRoutes.profileSetupPath) {
          return null;
        }
        return AppRoutes.profileSetupPath;
      }

      // ─── STATE 3: Logged in but NOT Verified ────────────
      if (isLoggedIn && !isEmailVerified) {
        // Only allow access to the verification screen and login (for logout)
        if (currentPath == AppRoutes.emailVerificationPath ||
            currentPath == AppRoutes.loginPath) {
          return null;
        }
        final email = user.email ?? '';
        return '${AppRoutes.emailVerificationPath}?email=$email';
      }

      // ─── STATE 4: Guest (Not Logged In) ──────────────────
      if (!isLoggedIn) {
        // Allow access to public routes
        if (_isPublicRoute(currentPath)) {
          return null;
        }
        // Redirect protected routes to login with returnTo param
        // URL encode the returnTo path to be safe
        final encodedPath = Uri.encodeComponent(currentPath);
        return '${AppRoutes.loginPath}?returnTo=$encodedPath';
      }

      return null;
    },
    routes: [
      // ── Public Routes ────────────────────────────────────
      GoRoute(
        name: AppRoutes.login,
        path: AppRoutes.loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: AppRoutes.register,
        path: AppRoutes.registerPath,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: AppRoutes.emailVerification,
        path: AppRoutes.emailVerificationPath,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? 'your university email';
          return EmailVerificationScreen(email: email);
        },
      ),

      // ── Auth Required Routes ─────────────────────────────
      GoRoute(
        name: AppRoutes.profileSetup,
        path: AppRoutes.profileSetupPath,
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // ── Main App (Stateful Shell) ────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.home,
                path: AppRoutes.homePath,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.chatList,
                path: AppRoutes.chatListPath,
                builder: (context, state) => const ChatListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.orders,
                path: AppRoutes.ordersPath,
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Listings ─────────────────────────────────────────
      GoRoute(
        name: AppRoutes.createListing,
        path: AppRoutes.createListingPath,
        builder: (context, state) => CreateListingFormScreen(
          initialMode: state.uri.queryParameters['type'] ?? 'sale',
        ),
      ),
      GoRoute(
        name: AppRoutes.listingDetail,
        path: AppRoutes.listingDetailPath,
        builder: (context, state) =>
            ListingDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        name: AppRoutes.editListing,
        path: AppRoutes.editListingPath,
        builder: (context, state) =>
            // TODO: Create edit_listing_screen.dart (Stitch MCP)
            const _PlaceholderScreen(name: 'Edit Listing'),
      ),
      GoRoute(
        name: AppRoutes.myListings,
        path: AppRoutes.myListingsPath,
        builder: (context, state) =>
            // TODO: Create my_listings_screen.dart (Stitch MCP)
            const _PlaceholderScreen(name: 'My Listings'),
      ),

      // ── Chat (auth required) ─────────────────────────────

      GoRoute(
        name: AppRoutes.chatRoom,
        path: AppRoutes.chatRoomPath,
        builder: (context, state) =>
            ChatRoomScreen(chatRoomId: state.pathParameters['id']!),
      ),

      // ── Orders (auth required) ───────────────────────────

      GoRoute(
        name: AppRoutes.orderDetail,
        path: AppRoutes.orderDetailPath,
        builder: (context, state) =>
            OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),

      // ── Seller Center ─────────────────────────────────────
      GoRoute(
        name: AppRoutes.sellerCenter,
        path: AppRoutes.sellerCenterPath,
        builder: (context, state) => const SellerCenterScreen(),
      ),

      GoRoute(
        name: AppRoutes.transactionManagement,
        path: AppRoutes.transactionManagementPath,
        builder: (context, state) => TransactionManagementScreen(
          listingId: state.pathParameters['id']!,
          initialTab: int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0,
        ),
      ),

      // ── Buyer Center ─────────────────────────────────────
      GoRoute(
        name: AppRoutes.buyerCenter,
        path: AppRoutes.buyerCenterPath,
        builder: (context, state) => const BuyerCenterScreen(),
      ),

      // ── Notification Center ──────────────────────────────
      GoRoute(
        name: AppRoutes.notificationCenter,
        path: AppRoutes.notificationCenterPath,
        builder: (context, state) => const NotificationCenterScreen(),
      ),

      // ── Profile & Settings (auth required) ────────────────
      GoRoute(
        name: AppRoutes.profile,
        path: AppRoutes.profilePath,
        builder: (context, state) =>
            // TODO: Create profile_screen.dart (Stitch MCP)
            const _PlaceholderScreen(name: 'Profile'),
      ),
      GoRoute(
        name: AppRoutes.settings,
        path: AppRoutes.settingsPath,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            name: AppRoutes.settingsProfile,
            path: AppRoutes.settingsProfilePath,
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            name: AppRoutes.settingsSystem,
            path: AppRoutes.settingsSystemPath,
            builder: (context, state) => const SystemSettingsScreen(),
          ),
          GoRoute(
            name: AppRoutes.settingsNotifications,
            path: AppRoutes.settingsNotificationsPath,
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            name: AppRoutes.settingsHelp,
            path: AppRoutes.settingsHelpPath,
            builder: (context, state) => const HelpScreen(),
          ),
        ],
      ),

      // ── Admin Login ──────────────────────────────────────────
      GoRoute(
        name: AppRoutes.adminLogin,
        path: AppRoutes.adminLoginPath,
        builder: (context, state) => const AdminLoginScreen(),
      ),

      // ── Admin Shell (sidebar + content) ────────────────────
      ShellRoute(
        builder: (context, state, child) => AdminShellScreen(child: child),
        routes: [
          GoRoute(
            name: AppRoutes.adminDashboard,
            path: AppRoutes.adminDashboardPath,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            name: AppRoutes.adminUsers,
            path: AppRoutes.adminUsersPath,
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            name: AppRoutes.adminListings,
            path: AppRoutes.adminListingsPath,
            builder: (context, state) => const AdminListingsScreen(),
          ),
          GoRoute(
            name: AppRoutes.adminOrders,
            path: AppRoutes.adminOrdersPath,
            builder: (context, state) => const AdminOrdersScreen(),
          ),
          GoRoute(
            name: AppRoutes.adminSchools,
            path: AppRoutes.adminSchoolsPath,
            builder: (context, state) => const AdminSchoolsScreen(),
          ),
          GoRoute(
            name: AppRoutes.adminCategories,
            path: AppRoutes.adminCategoriesPath,
            builder: (context, state) => const AdminCategoriesScreen(),
          ),
          GoRoute(
            name: AppRoutes.adminConditions,
            path: AppRoutes.adminConditionsPath,
            builder: (context, state) => const AdminConditionsScreen(),
          ),
          GoRoute(
            name: AppRoutes.adminFaqs,
            path: AppRoutes.adminFaqsPath,
            builder: (context, state) => const AdminFaqsScreen(),
          ),
          GoRoute(
            name: AppRoutes.adminDictionary,
            path: AppRoutes.adminDictionaryPath,
            builder: (context, state) => const AdminDictionaryScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Temporary screen shown until Stitch MCP designs replace each route.
///
/// Each route will be replaced with the real screen widget once we
/// fetch and implement the corresponding Stitch design via MCP.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Text(
          '$name\n(Awaiting Stitch MCP design)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
