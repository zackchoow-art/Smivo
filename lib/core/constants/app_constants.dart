/// App-wide constants for table names, categories, and bucket names.
///
/// All magic strings are centralized here to prevent typos and enable
/// easy refactoring when names change.
class AppConstants {
  AppConstants._();

  // ── App Info ───────────────────────────────────────────────
  static const String appName = 'Smivo';
  static const String appBundleId = 'com.smivo';
  static const String defaultSchool = 'Smith College';

  // ── Database Table Names ───────────────────────────────────
  static const String tableUserProfiles = 'user_profiles';
  static const String tableListings = 'listings';
  static const String tableListingImages = 'listing_images';
  static const String tableSavedListings = 'saved_listings';
  static const String tableOrders = 'orders';
  static const String tableChatRooms = 'chat_rooms';
  static const String tableMessages = 'messages';
  static const String tableOrderEvidence = 'order_evidence';

  // ── Storage Bucket Names ───────────────────────────────────
  static const String bucketListingImages = 'listing-images';
  static const String bucketAvatars = 'avatars';
  static const String bucketChatImages = 'chat-images';
  static const String bucketOrderEvidence = 'order-evidence';

  // ── Item Categories ────────────────────────────────────────
  static const List<String> categories = [
    'furniture',
    'electronics',
    'instruments',
    'books',
    'clothing',
    'sports',
    'other',
  ];

  // ── Transaction Types ──────────────────────────────────────
  static const String transactionSale = 'sale';
  static const String transactionRental = 'rental';

  // ── Listing Statuses ───────────────────────────────────────
  static const String listingActive = 'active';
  static const String listingInactive = 'inactive';
  static const String listingSold = 'sold';
  static const String listingRented = 'rented';

  // ── Order Statuses ─────────────────────────────────────────
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderCompleted = 'completed';
  static const String orderCancelled = 'cancelled';

  // ── Validation ─────────────────────────────────────────────
  static const String eduEmailSuffix = '.edu';
  static const int maxListingImages = 10;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 2000;
}
