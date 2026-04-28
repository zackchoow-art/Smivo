/// Route name and path constants for GoRouter.
///
/// All navigation uses these constants — never raw path strings.
/// This makes route changes a single-point edit.
class AppRoutes {
  AppRoutes._();

  // ── Route Names ────────────────────────────────────────────
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String emailVerification = 'email-verification';
  static const String profileSetup = 'profileSetup';
  static const String home = 'home';
  static const String listingDetail = 'listingDetail';
  static const String createListing = 'createListing';
  static const String editListing = 'editListing';
  static const String myListings = 'myListings';
  static const String chatList = 'chatList';
  static const String chatRoom = 'chatRoom';
  static const String orders = 'orders';
  static const String orderDetail = 'orderDetail';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String settingsProfile = 'settingsProfile';
  static const String settingsSystem = 'settingsSystem';
  static const String settingsNotifications = 'settingsNotifications';
  static const String settingsHelp = 'settingsHelp';
  static const String settingsBlocked = 'settingsBlocked';
  static const String settingsReported = 'settingsReported';
  static const String sellerCenter = 'sellerCenter';
  static const String buyerCenter = 'buyerCenter';
  static const String transactionManagement = 'transactionManagement';
  static const String notificationCenter = 'notificationCenter';
  static const String savedListings = 'savedListings';

  // ── Route Paths ────────────────────────────────────────────
  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String emailVerificationPath = '/verify-email';
  static const String profileSetupPath = '/profile-setup';
  static const String homePath = '/home';
  static const String listingDetailPath = '/listing/:id';
  static const String createListingPath = '/listing/create';
  static const String editListingPath = '/listing/:id/edit';
  static const String myListingsPath = '/my-listings';
  static const String chatListPath = '/chats';
  static const String chatRoomPath = '/chats/:id';
  static const String ordersPath = '/orders';
  static const String orderDetailPath = '/orders/:id';
  static const String profilePath = '/profile';
  static const String settingsPath = '/settings';
  static const String settingsProfilePath = 'profile';
  static const String settingsSystemPath = 'system';
  static const String settingsNotificationsPath = 'notifications';
  static const String settingsHelpPath = 'help';
  static const String settingsBlockedPath = 'blocked';
  static const String settingsReportedPath = 'reported';
  static const String sellerCenterPath = '/seller-center';
  static const String buyerCenterPath = '/buyer-center';
  static const String transactionManagementPath = '/listing/:id/transactions';
  static const String notificationCenterPath = '/notifications';
  static const String savedListingsPath = '/saved-listings';

  // ── Admin Routes ───────────────────────────────────────────
  static const String adminLogin = 'adminLogin';
  static const String adminDashboard = 'adminDashboard';
  static const String adminUsers = 'adminUsers';
  static const String adminListings = 'adminListings';
  static const String adminOrders = 'adminOrders';
  static const String adminSchools = 'adminSchools';
  static const String adminCategories = 'adminCategories';
  static const String adminConditions = 'adminConditions';
  static const String adminPickupLocations = 'adminPickupLocations';
  static const String adminFaqs = 'adminFaqs';
  static const String adminDictionary = 'adminDictionary';
  static const String adminRoles = 'adminRoles';

  static const String adminLoginPath = '/admin';
  static const String adminDashboardPath = '/admin/dashboard';
  static const String adminUsersPath = '/admin/users';
  static const String adminListingsPath = '/admin/listings';
  static const String adminOrdersPath = '/admin/orders';
  static const String adminSchoolsPath = '/admin/schools';
  static const String adminCategoriesPath = '/admin/categories';
  static const String adminConditionsPath = '/admin/conditions';
  static const String adminPickupLocationsPath = '/admin/pickup-locations';
  static const String adminFaqsPath = '/admin/faqs';
  static const String adminDictionaryPath = '/admin/dictionary';
  static const String adminRolesPath = '/admin/roles';
}
