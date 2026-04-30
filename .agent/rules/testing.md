---
trigger: always_on
---

# Testing Rules: Smivo Monorepo

---

## Part 1: Flutter App (app/)

### Philosophy

- Test behavior, not implementation details
- A test should break only when the user-facing behavior changes,
not when internal code is refactored
- Do not test Supabase itself — mock the repository layer
- Do not write tests for generated code (freezed, riverpod_generator)

### What Must Be Tested

Priority order — always write these first:

1. Repository methods (all Supabase interactions, fully mocked)
2. Provider logic (state transitions, error handling, loading states)
3. Utility functions in core/utils/ (pure functions, no mocking needed)
4. Critical UI flows via widget tests (auth, create listing, submit order)

Widget tests for every screen are not required in Phase 1.
Focus test effort on data and logic layers, not pixel-level UI.

### Test File Location and Naming

- Mirror the app/lib/ structure under app/test/
(e.g. app/lib/features/auth/providers/auth_provider.dart
-> app/test/features/auth/providers/auth_provider_test.dart)
- Test files always end in _test.dart
- One test file per source file being tested

### Test Structure

Use the Arrange / Act / Assert pattern with clear blank line separation:

```dart
test('returns listing when fetch succeeds', () async {
  // Arrange
  final mockRepo = MockListingRepository();
  when(mockRepo.fetchListings()).thenAnswer((_) async => fakeListings);

  // Act
  final result = await mockRepo.fetchListings();

  // Assert
  expect(result, equals(fakeListings));
});
```

Group related tests with group() blocks named after the method or behavior.
Use descriptive test names: "returns X when Y" or "throws Z when W".
Never use test names like "test1" or "works correctly".

### Mocking

- Use mocktail package for all mocks (not mockito)
- Create mock classes in app/test/mocks/ and reuse across test files
- Never mock models — use real instances with fake data
- Fake data defined in app/test/fixtures/ as static factory methods

### Riverpod Provider Testing

- Use ProviderContainer directly — do not pump a full widget tree
- Override repositories with mocks via container overrides
- Always call container.dispose() in tearDown
- Test all three AsyncValue states: loading, data, error

Example:
```dart
final container = ProviderContainer(
  overrides: [
    listingRepositoryProvider.overrideWithValue(mockRepo),
  ],
);
addTearDown(container.dispose);
```

### Widget Tests

- Use flutter_test package (built-in, no extra dependency)
- Wrap widget under test in ProviderScope with mocked providers
- Test user interactions with tester.tap(), tester.enterText()
- Do not test exact colors, font sizes, or pixel positions
- Do test: text content, button presence, navigation triggers,
error message display, loading indicator visibility

### What Not To Test (Flutter)

- Generated code (*.freezed.dart, *.g.dart)
- Supabase SDK internals
- GoRouter redirect logic in isolation (covered by widget flow tests)
- Third-party package behavior (OneSignal, flutter_dotenv, etc.)

### Running Tests (Flutter)

```bash
cd app
flutter test
```

- Always fix failing tests before adding new features
- A passing test suite is required before any PR or deployment

---

## Part 2: React Admin (admin/)

### Philosophy

- Same behavior-first approach as Flutter
- Test hooks and service modules, not raw Supabase queries
- Component tests focus on user interactions, not DOM structure

### What Must Be Tested

Priority order:

1. API service modules (Supabase queries abstracted into hooks/services)
2. Custom hooks (state transitions, error states)
3. Critical admin flows (login, user ban, content moderation)

### Test File Location and Naming

- Co-locate test files next to source files:
  admin/src/components/UserTable.tsx → admin/src/components/UserTable.test.tsx
- Or use admin/src/__tests__/ for integration tests
- Test files end in .test.tsx or .test.ts

### Running Tests (React)

```bash
cd admin
npm test                 # When test runner is configured
```

### What Not To Test (React)

- Supabase JS SDK internals
- Vite build configuration
- Third-party component library behavior