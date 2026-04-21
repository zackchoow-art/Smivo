# Listings Feature Integration Analysis

## Task 1: Status Report

| File | Data Source | Existing Logic / Methods | Missing Fields / Issues |
| :--- | :--- | :--- | :--- |
| `lib/data/models/listing.dart` | Real (Supabase) | `fromJson`, `toJson`, Basic factory | Missing `save_count`, `inquiry_count`. No support for joined images. |
| `lib/data/models/category.dart` | Static | `ItemCategory` enum with UI labels | Matches DB check constraints perfectly. |
| `lib/data/repositories/listing_repository.dart` | Real (Supabase) | `fetchListings`, `fetchListing`, `create`, `update`, `delete`, `search`, `fetchMyListings` | Complete repository structure, but doesn't handle image fetching/uploading yet. |
| `lib/features/home/providers/home_provider.dart` | **Mock** | `HomeListings` returns hardcoded `_mockListings`. Uses extensions for images. | Does not call `ListingRepository`. Logic is purely local filtering. |
| `lib/features/listing/providers/create_listing_provider.dart` | **Mock** | `ListingPhotos` (local file paths), `ListingFormMode`, `SelectedListingCategory`. | No logic to actually call `listingRepository.createListing`. |
| `lib/features/listing/providers/listing_detail_provider.dart` | **Mock** | `listingDetail` fetches from home mock data. Extensions for seller/images/location. | Does not call `ListingRepository`. Data is purely synthetic. |
| `lib/features/home/screens/home_screen.dart` | Mock State | Featured vs Compact card split. | Wired to `homeListingsProvider` (Mock). |
| `lib/features/listing/screens/listing_detail_screen.dart` | Mock State | Carousel, Rental options, Seller card. | Wired to `listingDetailProvider` (Mock). |
| `lib/features/listing/screens/create_listing_form_screen.dart` | Mock State | Multi-step form UI. | Submit button just shows a success dialog; no data is sent to DB. |

---

## Task 2: Schema Mapping Analysis

### Listings Table (`listings`)

| DB Column | Dart Field | Match Status | Notes |
| :--- | :--- | :--- | :--- |
| `id` (uuid) | `String id` | ✅ Match | |
| `seller_id` (uuid) | `String sellerId` | ✅ Match | |
| `title` (text) | `String title` | ✅ Match | |
| `description` (text) | `String? description`| ✅ Match | |
| `category` (text) | `String category` | ✅ Match | Enum `ItemCategory` used in UI. |
| `price` (numeric) | `double price` | ⚠️ Mismatch | DB is numeric(10,2). Dart double is fine for MVP. |
| `transaction_type` (text)| `String transactionType`| ✅ Match | 'sale' or 'rental'. |
| `status` (text) | `String status` | ✅ Match | Default 'active'. |
| `view_count` (int) | `int viewCount` | ✅ Match | |
| `save_count` (int) | **MISSING** | ❌ Missing | Add `int saveCount`. |
| `inquiry_count` (int) | **MISSING** | ❌ Missing | Add `int inquiryCount`. |
| `allow_pickup_change` | `bool allowPickupChange`| ✅ Match | |
| `rental_daily_price` | `double? rentalDailyPrice`| ✅ Match | |
| `rental_weekly_price` | `double? rentalWeeklyPrice`| ✅ Match | |
| `rental_monthly_price`| `double? rentalMonthlyPrice`| ✅ Match | |
| `is_pinned` (bool) | `bool isPinned` | ✅ Match | |
| `pinned_days` (int) | `int? pinnedDays` | ✅ Match | |
| `created_at` | `DateTime createdAt` | ✅ Match | |
| `updated_at` | `DateTime updatedAt` | ✅ Match | |

### Listing Images Table (`listing_images`)

| DB Column | Dart Field | Match Status | Notes |
| :--- | :--- | :--- | :--- |
| `id` (uuid) | N/A | ❌ Missing | Model for `ListingImage` not yet created. |
| `listing_id` (uuid) | N/A | ❌ Missing | |
| `image_url` (text) | N/A | ❌ Missing | |
| `sort_order` (int) | N/A | ❌ Missing | |

**Conclusion**: We need a `ListingImage` model and we need to decide if `Listing` should include `List<ListingImage> images` in its constructor (recommended for easy UI consumption).

---

## Task 3: Query Pattern Inventory

1.  **Home Feed**: `ListingRepository.fetchListings(category: selectedCategory)`
    *   **Used in**: `HomeListings` provider.
    *   **Data Shape**: `List<Listing>`.
    *   **Joins**: Needs `listing_images` (at least the first one) to show in the card.

2.  **Keyword Search**: `ListingRepository.searchListings(query)`
    *   **Used in**: `HomeListings` provider (triggered by `SearchQuery`).
    *   **Data Shape**: `List<Listing>`.
    *   **Joins**: `listing_images`.

3.  **Detail Fetch**: `ListingRepository.fetchListing(id)`
    *   **Used in**: `listingDetailProvider`.
    *   **Data Shape**: `Listing` object with nested `List<ListingImage>` and joined `UserProfile` (seller).
    *   **Joins**: `listing_images`, `user_profiles` (for seller info).

4.  **My Listings**: `ListingRepository.fetchMyListings(userId)`
    *   **Used in**: My Listings screen (to be built).
    *   **Data Shape**: `List<Listing>`.

5.  **Create Listing**: `ListingRepository.createListing(Listing)`
    *   **Used in**: `CreateListingFormScreen`.
    *   **Logic**: Needs to upload files to Storage first, then insert `listings` row, then insert `listing_images` rows.

---

## Task 4: Provider Refactor Draft

```dart
// lib/features/home/providers/home_provider.dart

// 1. Rename to be repository-driven
@riverpod
class HomeListings extends _$HomeListings {
  @override
  Future<List<Listing>> build() async {
    final category = ref.watch(selectedCategoryProvider);
    final query = ref.watch(searchQueryProvider);
    
    final repo = ref.watch(listingRepositoryProvider);
    
    if (query.isNotEmpty) {
      return repo.searchListings(query);
    }
    
    return repo.fetchListings(
      category: category == 'All' ? null : category.toLowerCase()
    );
  }
}

// lib/features/listing/providers/listing_detail_provider.dart

@riverpod
Future<Listing> listingDetail(ListingDetailRef ref, String id) {
  // Should return a "FullListing" that includes images and seller profile
  return ref.watch(listingRepositoryProvider).fetchListingWithDetails(id);
}

// lib/features/listing/providers/create_listing_provider.dart

@riverpod
class CreateListingController extends _$CreateListingController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> submit({
    required ListingDraft draft,
    required List<File> photos,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. Upload photos to Storage -> get URLs
      // 2. repo.createListing(...)
      // 3. repo.addImages(...)
    });
  }
}
```

---

## Task 5: Dependencies and Imports Check

- `supabase_flutter`: ✅ In `pubspec.yaml`.
- `riverpod`: ✅ In `pubspec.yaml`.
- `freezed`: ✅ In `pubspec.yaml`.
- `image_picker`: ✅ In `pubspec.yaml`.
- `image_cropper`: ✅ In `pubspec.yaml`.
- `path`: ❌ **MISSING**. Needed for filename manipulation during upload.
- `uuid`: ❌ **MISSING**. Useful for local unique IDs, though Supabase handles UUIDs on insert.

---

## Task 6: Known Issues and Risks

1.  **Image Upload Sequence**: If images upload but the listing insertion fails, we end up with "orphan" files in Storage. Need to handle errors gracefully or use a cleaner cleanup strategy.
2.  **Category Case Sensitivity**: The DB uses lowercase check constraints (`furniture`, `electronics`). The UI chips use Title Case (`Furniture`, `Electronics`). Transformation must be consistent.
3.  **Rental Prices**: `rental_daily_price`, `rental_weekly_price`, etc., are optional in the DB but required by the UI if `transaction_type == 'rental'`. Validation must be enforced in the Dart layer.
4.  **RLS - Storage**: The `listing-images` bucket RLS requires the path to start with `auth.uid()`. We must ensure the upload service prepends the user's ID to the filename/path.
5.  **Numeric Types**: Supabase `numeric` returns as `double` or `num` in Dart. We should ensure `price` is always handled as `double` to avoid dynamic type errors.
6.  **Joins**: `listingRepository.fetchListing` needs to use `.select('*, seller:user_profiles(*), images:listing_images(*)')` to fetch all data in a single round trip. The `Listing` model needs to be updated to handle these nested objects.
