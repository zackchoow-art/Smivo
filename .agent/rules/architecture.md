---
trigger: always_on
---

# Architecture Rules: Flutter + Riverpod + Supabase

## Folder Structure

lib/
core/
router/         # GoRouter configuration and route constants
theme/          # AppTheme, colors, text styles, spacing constants
utils/          # Generic helpers (date formatting, validators, etc.)
exceptions/     # AppException types
constants/      # App-wide constants (no magic strings or numbers)
data/
models/         # Pure Dart data classes (no Flutter imports)
repositories/   # All Supabase calls live here — nowhere else
features/
auth/
screens/
widgets/
providers/
home/
listing/
chat/
orders/
profile/
settings/
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

## Providers (Riverpod)

- Use @riverpod code generation for all providers
- One provider file per feature: [feature]_provider.dart
- AsyncNotifierProvider for anything that touches Supabase
- StateProvider only for simple local UI state (e.g. selected tab index)
- Provider scope: always ProviderScope at app root, never nested scopes
- Never use globalProviderContainer outside of tests

## Repositories

- One repository class per domain entity
(e.g. ListingRepository, OrderRepository, ChatRepository)
- All methods are async and return typed results
- Catch SupabaseException at repository boundary, rethrow as AppException
- Repository constructor receives SupabaseClient via Riverpod injection —
never instantiate Supabase.instance directly inside a repository

## Error Handling

- Define typed exceptions in core/exceptions/app_exception.dart
- Categories: NetworkException, AuthException, DatabaseException, StorageException
- Every AsyncNotifierProvider must handle all three AsyncValue states:
loading, data, error — no unhandled error states in UI
- Never show raw Supabase or Dart error messages to the user
— always map to a user-friendly message in Chinese or English

## Navigation

- All route paths and names are constants in AppRoutes class
- Route configuration lives entirely in core/router/router.dart
- Auth guard implemented once in GoRouter redirect — not duplicated in screens
- Deep link support stubbed from day one (even if not active in Phase 1)

## Platform-Specific Code

- Use kIsWeb, Platform.isIOS, Platform.isAndroid only in:
core/utils/ or dedicated platform adapter files
- Never write platform checks inside widgets or providers
- Web-specific layout breakpoints defined in core/theme/breakpoints.dart:
mobile: < 600px, tablet: 600–1024px, desktop: > 1024px
- Use LayoutBuilder or AdaptiveLayout to switch between layouts —
never hardcode pixel sizes in widget files

## Supabase Realtime (Chat)

- Subscribe to Realtime channels in the relevant provider's build() method
- Always cancel channel subscriptions in the provider's onDispose
- Never subscribe to the same channel twice — check before subscribing

## Assets and Constants

- All image/icon assets declared in pubspec.yaml and accessed via
generated AppAssets class (use flutter_gen package)
- No magic strings anywhere — route names, table names, column names,
storage bucket names all defined as constants
- Environment variables (Supabase URL, anon key) loaded via
flutter_dotenv — never hardcoded in source files

## Dependency Injection

- All dependencies injected via Riverpod — no manual service locators
- SupabaseClient provided as a top-level provider in core/
- Repositories provided as providers, consumed by feature providers