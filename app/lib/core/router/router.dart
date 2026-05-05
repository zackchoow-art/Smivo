import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/features/profile/screens/profile_setup_screen.dart';

import 'package:smivo/features/auth/screens/register_screen.dart';
import 'package:smivo/features/auth/screens/login_screen.dart';
import 'package:smivo/features/auth/screens/forgot_password_screen.dart';
import 'package:smivo/features/auth/screens/email_verification_screen.dart';
import 'package:smivo/features/home/screens/home_screen.dart';
import 'package:smivo/features/listing/screens/listing_detail_screen.dart';
import 'package:smivo/features/listing/screens/create_listing_form_screen.dart';
import 'package:smivo/features/listing/screens/saved_listings_screen.dart';
import 'package:smivo/features/chat/screens/chat_list_screen.dart';
import 'package:smivo/features/orders/screens/orders_screen.dart';
import 'package:smivo/features/orders/screens/order_detail_screen.dart';
import 'package:smivo/features/chat/screens/chat_room_screen.dart';
import 'package:smivo/features/settings/screens/edit_profile_screen.dart';
import 'package:smivo/features/settings/screens/help_screen.dart';
import 'package:smivo/features/settings/screens/notification_settings_screen.dart';
import 'package:smivo/features/settings/screens/settings_screen.dart';
import 'package:smivo/features/settings/screens/system_settings_screen.dart';
import 'package:smivo/features/settings/screens/trust_and_safety_screen.dart';
import 'package:smivo/features/settings/screens/my_feedbacks_screen.dart';
import 'package:smivo/features/settings/screens/submit_feedback_screen.dart';
import 'package:smivo/features/settings/screens/my_contributions_screen.dart';
import 'package:smivo/features/seller/screens/seller_center_screen.dart';
import 'package:smivo/features/seller/screens/transaction_management_screen.dart';
import 'package:smivo/features/buyer/screens/buyer_center_screen.dart';
import 'package:smivo/features/settings/screens/debug_data_screen.dart';
import 'package:smivo/shared/widgets/app_shell.dart';
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
import 'package:smivo/features/admin/screens/admin_pickup_locations_screen.dart';
import 'package:smivo/features/admin/screens/admin_dictionary_screen.dart';
import 'package:smivo/features/admin/screens/admin_schools_screen.dart';
import 'package:smivo/features/admin/screens/admin_roles_screen.dart';
import 'package:smivo/features/admin/screens/admin_review_tags_screen.dart';
import 'package:smivo/core/router/router_notifier.dart';
import 'app_routes.dart';

part 'router.g.dart';

/// GoRouter configuration.
///
/// NOTE: keepAlive: true is CRITICAL here. Without it, the router provider
/// can be garbage-collected and recreated, which destroys the navigation
/// stack and drops the user to the home screen.
///
/// Auth/profile state changes are handled via RouterNotifier (Listenable),
/// which triggers GoRouter.redirect() re-evaluation WITHOUT recreating the
/// GoRouter instance. This is the correct pattern for GoRouter + Riverpod.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  // Obtain the notifier instance (stable object, never recreated).
  // NOTE: ref.watch on .notifier only re-runs this factory if the notifier
  // provider itself is disposed — which never happens with keepAlive: true.
  // Auth/profile changes are signalled via refreshListenable, not re-creation.
  final notifier = ref.watch(appRouterProvider.notifier);

  final goRouter = GoRouter(
    initialLocation: AppRoutes.homePath,
    debugLogDiagnostics: true,
    // NOTE: refreshListenable causes redirect() to be re-evaluated when
    // RouterNotifier fires (i.e. when auth/profile state changes), but the
    // GoRouter object itself is NOT recreated. Navigation stack is preserved.
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // ── Public Routes ────────────────────────────────────────────
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
        name: AppRoutes.forgotPassword,
        path: AppRoutes.forgotPasswordPath,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: AppRoutes.emailVerification,
        path: AppRoutes.emailVerificationPath,
        builder: (context, state) {
          final email =
              state.uri.queryParameters['email'] ?? 'your university email';
          return EmailVerificationScreen(email: email);
        },
      ),

      // ── Auth Required Routes ──────────────────────────────────────
      GoRoute(
        name: AppRoutes.profileSetup,
        path: AppRoutes.profileSetupPath,
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // ── Main App Shell (Stateful indexed stack) ───────────────────
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

      // ── Listings ──────────────────────────────────────────────────
      GoRoute(
        name: AppRoutes.createListing,
        path: AppRoutes.createListingPath,
        builder:
            (context, state) => CreateListingFormScreen(
              initialMode: state.uri.queryParameters['type'] ?? 'sale',
            ),
      ),
      GoRoute(
        name: AppRoutes.listingDetail,
        path: AppRoutes.listingDetailPath,
        builder:
            (context, state) =>
                ListingDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        name: AppRoutes.editListing,
        path: AppRoutes.editListingPath,
        builder:
            (context, state) =>
            // TODO: Create edit_listing_screen.dart (Stitch MCP)
            const _PlaceholderScreen(name: 'Edit Listing'),
      ),
      GoRoute(
        name: AppRoutes.myListings,
        path: AppRoutes.myListingsPath,
        builder:
            (context, state) =>
            // TODO: Create my_listings_screen.dart (Stitch MCP)
            const _PlaceholderScreen(name: 'My Listings'),
      ),

      // ── Chat ──────────────────────────────────────────────────────
      GoRoute(
        name: AppRoutes.chatRoom,
        path: AppRoutes.chatRoomPath,
        builder:
            (context, state) =>
                ChatRoomScreen(chatRoomId: state.pathParameters['id']!),
      ),

      // ── Orders ────────────────────────────────────────────────────
      GoRoute(
        name: AppRoutes.orderDetail,
        path: AppRoutes.orderDetailPath,
        builder:
            (context, state) =>
                OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),

      // ── Seller Center ─────────────────────────────────────────────
      GoRoute(
        name: AppRoutes.sellerCenter,
        path: AppRoutes.sellerCenterPath,
        builder: (context, state) => const SellerCenterScreen(),
      ),
      GoRoute(
        name: AppRoutes.transactionManagement,
        path: AppRoutes.transactionManagementPath,
        builder:
            (context, state) => TransactionManagementScreen(
              listingId: state.pathParameters['id']!,
              initialTab:
                  int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0,
            ),
      ),

      // ── Buyer Center ──────────────────────────────────────────────
      GoRoute(
        name: AppRoutes.buyerCenter,
        path: AppRoutes.buyerCenterPath,
        builder: (context, state) => const BuyerCenterScreen(),
      ),

      // ── Notification Center ───────────────────────────────────────
      GoRoute(
        name: AppRoutes.notificationCenter,
        path: AppRoutes.notificationCenterPath,
        builder: (context, state) => const NotificationCenterScreen(),
      ),

      // ── Saved Listings ────────────────────────────────────────────
      GoRoute(
        name: AppRoutes.savedListings,
        path: AppRoutes.savedListingsPath,
        builder: (context, state) => const SavedListingsScreen(),
      ),

      // ── Profile & Settings ────────────────────────────────────────
      GoRoute(
        name: AppRoutes.profile,
        path: AppRoutes.profilePath,
        builder:
            (context, state) =>
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
            name: AppRoutes.settingsDebug,
            path: AppRoutes.settingsDebugPath,
            builder: (context, state) => const DebugDataScreen(),
          ),
          GoRoute(
            name: AppRoutes.settingsHelp,
            path: AppRoutes.settingsHelpPath,
            builder: (context, state) => const HelpScreen(),
          ),
          GoRoute(
            name: AppRoutes.settingsTrustAndSafety,
            path: AppRoutes.settingsTrustAndSafetyPath,
            builder: (context, state) => const TrustAndSafetyScreen(),
          ),
          GoRoute(
            name: AppRoutes.myFeedbacks,
            path: AppRoutes.myFeedbacksPath,
            builder: (context, state) => const MyFeedbacksScreen(),
            routes: [
              GoRoute(
                name: AppRoutes.submitFeedback,
                path: AppRoutes.submitFeedbackPath,
                builder: (context, state) => const SubmitFeedbackScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: AppRoutes.myContributions,
        path: AppRoutes.myContributionsPath,
        builder: (context, state) => const MyContributionsScreen(),
      ),

      // ── Admin Login ───────────────────────────────────────────────
      GoRoute(
        name: AppRoutes.adminLogin,
        path: AppRoutes.adminLoginPath,
        builder: (context, state) => const AdminLoginScreen(),
      ),

      // ── Admin Shell ───────────────────────────────────────────────
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
            name: AppRoutes.adminPickupLocations,
            path: AppRoutes.adminPickupLocationsPath,
            builder: (context, state) => const AdminPickupLocationsScreen(),
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
          GoRoute(
            name: AppRoutes.adminRoles,
            path: AppRoutes.adminRolesPath,
            builder: (context, state) => const AdminRolesScreen(),
          ),
          GoRoute(
            name: AppRoutes.adminTags,
            path: AppRoutes.adminTagsPath,
            builder: (context, state) => const AdminReviewTagsScreen(),
          ),
        ],
      ),
    ],
  );

  // NOTE: Dispose GoRouter when provider is cleaned up (app shutdown only).
  ref.onDispose(goRouter.dispose);

  return goRouter;
}

/// Temporary placeholder until Stitch MCP designs replace each route.
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
