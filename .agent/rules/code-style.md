---
trigger: always_on
---

# Code Style Rules: Smivo Monorepo

This document covers code style for both the Flutter app (app/) and
the React admin dashboard (admin/).

---

## Part 1: Flutter + Dart (app/)

### Formatting

- Indentation: 2 spaces (no tabs)
- Max line length: 80 characters
- Always run dart format before considering a file complete
- Trailing commas required on all multi-line parameter lists and widget trees
(this ensures dart format produces clean diffs)

### Naming

- Classes, Widgets, Enums: PascalCase (e.g. ListingCard, OrderStatus)
- Variables, functions, parameters: camelCase (e.g. fetchListings, userId)
- Constants: lowerCamelCase with const keyword (e.g. const defaultPadding = 16.0)
- Files and folders: snake_case (e.g. listing_card.dart, home_screen.dart)
- Riverpod providers: suffix with Provider (e.g. authStateProvider, listingsProvider)
- Private members: prefix with underscore (e.g. _controller, _buildHeader())
- No abbreviations unless universally known (id, url, ui are fine; usr, btn are not)

### Dart Language

- Always use strong typing — never use dynamic or var unless type is truly unknown
- Prefer final for all local variables that are not reassigned
- Use const constructors wherever possible — improves Flutter rebuild performance
- Prefer named parameters for functions with 2+ parameters
- Prefer expression bodies (=>) for single-line functions and getters
- Never use null-unsafe patterns — handle nullability explicitly
- Use cascade notation (..) only when it improves readability, not by default

### Widgets

- One widget per file — no exceptions
- Keep build() methods short: if a section exceeds ~20 lines, extract it into
a private method or a separate widget
- Prefer StatelessWidget unless local ephemeral state is genuinely needed
- Never put business logic inside build() or initState() — delegate to providers
- Use const for all widgets that have no dynamic data
- Always provide semanticsLabel on Icon widgets (accessibility)

### Riverpod (State Management)

- Use Riverpod with code generation (@riverpod annotation)
- All providers defined in the relevant feature's provider file
- AsyncNotifierProvider for async data (API calls, Supabase queries)
- NotifierProvider for synchronous state
- Never call ref.read() inside build() — use ref.watch() for reactive UI
- Never put Supabase calls directly in widgets — always go through a provider
- Provider files named: [feature]_provider.dart (e.g. auth_provider.dart)

### GoRouter (Navigation)

- All routes defined in a single router.dart file under app/lib/core/router/
- Use named routes — never navigate by raw path string
- Route names defined as constants (e.g. AppRoutes.home, AppRoutes.listing)
- Guard protected routes in redirect callback — never check auth inside screens
- Pass only IDs through route params — fetch full data in the destination screen

### Asynchronous Code (Dart)

- Always use async/await — never use .then() chains
- Always handle loading, data, and error states for every async provider
- Never ignore a Future — always await or explicitly discard with unawaited()
- Use AsyncValue.when() to render loading/error/data states in UI

### Supabase (Dart)

- All Supabase calls in repository files under app/lib/data/repositories/
- Never import supabase_flutter directly in widgets or providers
- Repository methods return either a typed model or throw a typed AppException
- Always handle SupabaseException and convert to AppException before surfacing

### Comments (Dart)

- Comments explain WHY, not WHAT (per global rules)
- Public classes and public methods must have a doc comment (///)
- Use TODO / FIXME / NOTE / HACK markers consistently (per global rules)

### Imports (Dart)

- Order: dart: → package: → relative imports (separated by blank lines)
- No unused imports — remove immediately
- Use relative imports within the same feature folder
- Use package imports (package:smivo/...) across feature boundaries

---

## Part 2: React + TypeScript (admin/)

### Formatting

- Indentation: 2 spaces (no tabs)
- Max line length: 100 characters (more relaxed than Dart due to JSX verbosity)
- Use Prettier for auto-formatting (configured in project)
- Always use semicolons
- Use single quotes for strings (except in JSX attributes)

### Naming

- Components: PascalCase (e.g. UserTable, DashboardCard)
- Files: PascalCase for components (e.g. UserTable.tsx), camelCase for utils
  (e.g. supabaseClient.ts, formatDate.ts)
- Variables, functions, parameters: camelCase
- Constants: UPPER_SNAKE_CASE for environment-level constants (e.g. SUPABASE_URL),
  camelCase for app-level constants
- Types and Interfaces: PascalCase, prefer `interface` for object shapes,
  `type` for unions and aliases
- Custom hooks: prefix with `use` (e.g. useAuth, useListings)

### TypeScript

- Always use strict mode (strict: true in tsconfig)
- Prefer `interface` over `type` for object shapes (enables declaration merging)
- Never use `any` — use `unknown` when type is truly unknown, then narrow
- All function parameters and return types must be explicitly typed
- Use `as const` for literal tuples and enum-like objects
- Prefer optional chaining (?.) and nullish coalescing (??) over manual checks

### React

- Functional components only — no class components
- One component per file
- Keep components under ~100 lines — extract sub-components when exceeded
- Use named exports (not default exports) for all components and hooks
- Props interface named: `{ComponentName}Props` (e.g. `UserTableProps`)
- State management: React hooks (useState, useEffect, useContext) for local state,
  Supabase subscriptions for real-time data
- Never put raw Supabase queries directly in components — extract to hooks or
  service modules in admin/src/lib/

### Supabase (TypeScript)

- Supabase client initialized once in admin/src/lib/supabase.ts
- All database queries extracted to admin/src/lib/api/ or feature-specific hooks
- Type definitions in admin/src/types/ must mirror database schema
- Use generated Supabase types when available (supabase gen types)

### Comments (TypeScript)

- Same philosophy as Dart: explain WHY, not WHAT
- Use JSDoc (/** */) for exported functions and component props
- Use TODO / FIXME / NOTE / HACK markers consistently

### Imports (TypeScript)

- Order: React/external packages → internal modules → relative imports
  (separated by blank lines)
- Use path aliases (e.g. @/components, @/lib) configured in vite.config.ts
- No unused imports — ESLint will catch these

### Pre-Push Verification (CRITICAL)

- **Always run `cd admin && npx tsc -b` before pushing to remote.**
  `npm run dev` (Vite) uses esbuild which only transpiles — it does NOT
  perform type checking. This means code with type errors, unused variables,
  missing exports, or implicit `any` will work perfectly in local dev but
  **fail on Vercel** where `npm run build` runs `tsc -b && vite build`.
- The project's `tsconfig.app.json` enforces strict rules:
  `strict: true`, `noUnusedLocals: true`, `noUnusedParameters: true`.
  All of these are silently ignored by Vite's dev server.
- If `tsc -b` passes locally, Vercel deploy will succeed.