---
trigger: always_on
---

# Code Style Rules: Flutter + Dart

## Formatting

- Indentation: 2 spaces (no tabs)
- Max line length: 80 characters
- Always run dart format before considering a file complete
- Trailing commas required on all multi-line parameter lists and widget trees
(this ensures dart format produces clean diffs)

## Naming

- Classes, Widgets, Enums: PascalCase (e.g. ListingCard, OrderStatus)
- Variables, functions, parameters: camelCase (e.g. fetchListings, userId)
- Constants: lowerCamelCase with const keyword (e.g. const defaultPadding = 16.0)
- Files and folders: snake_case (e.g. listing_card.dart, home_screen.dart)
- Riverpod providers: suffix with Provider (e.g. authStateProvider, listingsProvider)
- Private members: prefix with underscore (e.g. _controller, _buildHeader())
- No abbreviations unless universally known (id, url, ui are fine; usr, btn are not)

## Dart Language

- Always use strong typing — never use dynamic or var unless type is truly unknown
- Prefer final for all local variables that are not reassigned
- Use const constructors wherever possible — improves Flutter rebuild performance
- Prefer named parameters for functions with 2+ parameters
- Prefer expression bodies (=>) for single-line functions and getters
- Never use null-unsafe patterns — handle nullability explicitly
- Use cascade notation (..) only when it improves readability, not by default

## Widgets

- One widget per file — no exceptions
- Keep build() methods short: if a section exceeds ~20 lines, extract it into
a private method or a separate widget
- Prefer StatelessWidget unless local ephemeral state is genuinely needed
- Never put business logic inside build() or initState() — delegate to providers
- Use const for all widgets that have no dynamic data
- Always provide semanticsLabel on Icon widgets (accessibility)

## Riverpod (State Management)

- Use Riverpod with code generation (@riverpod annotation)
- All providers defined in the relevant feature's provider file
- AsyncNotifierProvider for async data (API calls, Supabase queries)
- NotifierProvider for synchronous state
- Never call ref.read() inside build() — use ref.watch() for reactive UI
- Never put Supabase calls directly in widgets — always go through a provider
- Provider files named: [feature]_provider.dart (e.g. auth_provider.dart)

## GoRouter (Navigation)

- All routes defined in a single router.dart file under lib/core/router/
- Use named routes — never navigate by raw path string
- Route names defined as constants (e.g. AppRoutes.home, AppRoutes.listing)
- Guard protected routes in redirect callback — never check auth inside screens
- Pass only IDs through route params — fetch full data in the destination screen

## Asynchronous Code

- Always use async/await — never use .then() chains
- Always handle loading, data, and error states for every async provider
- Never ignore a Future — always await or explicitly discard with unawaited()
- Use AsyncValue.when() to render loading/error/data states in UI

## Supabase

- All Supabase calls in repository files under lib/data/repositories/
- Never import supabase_flutter directly in widgets or providers
- Repository methods return either a typed model or throw a typed AppException
- Always handle SupabaseException and convert to AppException before surfacing

## Comments

- Comments explain WHY, not WHAT (per global rules)
- Public classes and public methods must have a doc comment (///)
- Use TODO / FIXME / NOTE / HACK markers consistently (per global rules)

## Imports

- Order: dart: → package: → relative imports (separated by blank lines)
- No unused imports — remove immediately
- Use relative imports within the same feature folder
- Use package imports (package:app_name/...) across feature boundaries