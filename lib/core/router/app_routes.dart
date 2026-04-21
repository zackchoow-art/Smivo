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
}
