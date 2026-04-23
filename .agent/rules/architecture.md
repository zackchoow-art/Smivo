---
trigger: always_on
---

# Architecture Rules: Flutter + Riverpod + Supabase

## Folder Structure

lib/
  core/
    constants/      # App-wide constants (table names, bucket names, etc.)
    exceptions/     # AppException types (Network, Auth, Database, Storage)
    providers/      # Core Riverpod providers (SupabaseClient, etc.)
    router/         # GoRouter configuration and route constants
    theme/          # AppTheme, colors, text styles, spacing, breakpoints
    utils/          # Generic helpers (date formatting, validators, image upload)
  data/
    models/         # Pure Dart data classes (freezed, no Flutter imports)
    repositories/   # All Supabase calls live here — nowhere else
  features/
    auth/           # Login, register, email verification
      screens/
      widgets/
      providers/
    buyer/          # Buyer Center (order tracking by buyer role)
      screens/
      providers/
    chat/           # 1-on-1 messaging tied to listings
      screens/
      widgets/
      providers/
    home/           # Home feed, search, category filters
      screens/
      widgets/
      providers/
    listing/        # Create listing, listing detail, saved listings
      screens/
      widgets/
      providers/
    notifications/  # In-app notification center
      providers/
    orders/         # Orders hub, order detail, evidence photos, chat history
      screens/
      widgets/
      providers/
    profile/        # Profile setup
      screens/
      providers/
    seller/         # Seller Center, transaction management dashboard
      screens/
      providers/
    settings/       # User settings, edit profile, help, notifications
      screens/
      widgets/
      providers/
    shared/         # Cross-feature providers (e.g. school data)
      providers/
  shared/
    widgets/        # Reusable UI components used across features

## Layering Rules

The only permitted dependency direction is: screens → providers → repositories → Supabase

- Screens may only read state from providers (ref.watch / ref.read)
- Providers may only call repositories — never import supabase_flutter directly
- Repositories are the only layer that imports and calls supabase_flutter
- Models have zero dependencies — no Flutter, no Riverpod, no Supabase
- Shared widgets have no business logic — display only, driven by props

Violations of this order are never acceptable, even for "quick" solutions.

## Feature Folder Rules

Each feature folder contains only: screens/, widgets/, providers/
No feature may import directly from another feature's internal files.
Cross-feature data sharing goes through a provider, not direct import.

## Models

- Immutable data classes using freezed package
- Every model has: fromJson(), toJson(), copyWith()
- Model names match the database table in singular form
(e.g. table listings → model Listing)
- No business logic inside models — models are data containers only
- Nullable fields must be explicitly typed (String? not String)
- Current models: Listing, ListingImage, Order, OrderEvidence,
  OrderListingPreview, ChatRoom, ChatListingPreview, Message,
  UserProfile, SavedListing, PickupLocation, School, Notification, Category

## Providers (Riverpod)

- Use @riverpod code generation for all providers
- One provider file per concern — multiple provider files per feature are OK
  (e.g. orders_provider.dart, order_evidence_provider.dart, order_chat_provider.dart)
- AsyncNotifierProvider for anything that touches Supabase
- StateProvider only for simple local UI state (e.g. selected tab index)
- Provider scope: always ProviderScope at app root, never nested scopes
- Never use globalProviderContainer outside of tests

## Repositories

- One repository class per domain entity
  (e.g. ListingRepository, OrderRepository, ChatRepository,
   OrderEvidenceRepository, SavedRepository, etc.)
- All methods are async and return typed results
- Catch SupabaseException at repository boundary, rethrow as AppException
- Repository constructor receives SupabaseClient via Riverpod injection —
  never instantiate Supabase.instance directly inside a repository
- Current repositories: AuthRepository, ChatRepository, ListingRepository,
  NotificationRepository, OrderEvidenceRepository, OrderRepository,
  PickupLocationRepository, ProfileRepository, SavedRepository,
  SchoolRepository, StorageRepository

## Error Handling

- Define typed exceptions in core/exceptions/app_exception.dart
- Categories: NetworkException, AuthException, DatabaseException,
  AppStorageException
- Every AsyncNotifierProvider must handle all three AsyncValue states:
  loading, data, error — no unhandled error states in UI
- Never show raw Supabase or Dart error messages to the user
  — always map to a user-friendly message in Chinese or English

## Navigation

- All route paths and names are constants in AppRoutes class
- Route configuration lives entirely in core/router/router.dart
- Auth guard implemented once in GoRouter redirect — not duplicated in screens
- Deep link support stubbed from day one (even if not active in Phase 1)
- Current top-level routes: home, chat, orders (hub), sellerCenter,
  buyerCenter, listingDetail, createListing, orderDetail,
  transactionManagement, settings, editProfile, help,
  notificationSettings, systemSettings, profileSetup

## Order Status Machine

Orders follow this lifecycle:

### Sale Orders:
  pending → confirmed → completed
  pending → cancelled (by buyer or seller)
  confirmed → cancelled (by buyer or seller)

### Rental Orders:
  pending → confirmed → (dual delivery confirmation) →
  rental_status: active → return_requested → returned → deposit_refunded →
  completed

Rental status field (rental_status) is NULL for sale orders.

## Supabase Storage Buckets

- `listing-images`: Product photos (public read, owner-path upload)
- `avatars`: User avatars (public read, authenticated upload)
- `order-evidence`: Delivery evidence photos (public read, authenticated upload)

## Supabase Realtime

- Subscribe to Realtime channels in the relevant provider's build() method
- Always cancel channel subscriptions in the provider's onDispose
- Never subscribe to the same channel twice — check before subscribing
- Active channels: orders_list (INSERT/UPDATE), messages (INSERT),
  chat_rooms (stream)

## Assets and Constants

- All image/icon assets declared in pubspec.yaml and accessed via
  generated AppAssets class (use flutter_gen package)
- No magic strings anywhere — route names, table names, column names,
  storage bucket names all defined as constants in AppConstants
- Environment variables (Supabase URL, anon key) loaded via
  flutter_dotenv — never hardcoded in source files

## Platform-Specific Code

- Use kIsWeb, Platform.isIOS, Platform.isAndroid only in:
  core/utils/ or dedicated platform adapter files
- Never write platform checks inside widgets or providers
- Web-specific layout breakpoints defined in core/theme/breakpoints.dart:
  mobile: < 600px, tablet: 600–1024px, desktop: > 1024px
- Use LayoutBuilder or AdaptiveLayout to switch between layouts —
  never hardcode pixel sizes in widget files

## Dependency Injection

- All dependencies injected via Riverpod — no manual service locators
- SupabaseClient provided as a top-level provider in core/
- Repositories provided as providers, consumed by feature providers

## Database Migrations

- All migrations stored in supabase/migrations/
- Naming: 00NNN_description.sql (sequential numbering)
- Current range: 00001–00020 (20 migrations applied)
- SQL must be executed manually in Supabase Dashboard or via `supabase db push`
- Agent creates .sql files; user is responsible for execution