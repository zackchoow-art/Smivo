---
trigger: always_on
---

# Testing Rules: Flutter

## Philosophy

- Test behavior, not implementation details
- A test should break only when the user-facing behavior changes,
not when internal code is refactored
- Do not test Supabase itself — mock the repository layer
- Do not write tests for generated code (freezed, riverpod_generator)

## What Must Be Tested

Priority order — always write these first:

1. Repository methods (all Supabase interactions, fully mocked)
2. Provider logic (state transitions, error handling, loading states)
3. Utility functions in core/utils/ (pure functions, no mocking needed)
4. Critical UI flows via widget tests (auth, create listing, submit order)

Widget tests for every screen are not required in Phase 1.
Focus test effort on data and logic layers, not pixel-level UI.

## Test File Location and Naming

- Mirror the lib/ structure under test/
(e.g. lib/features/auth/providers/auth_provider.dart
-> test/features/auth/providers/auth_provider_test.dart)
- Test files always end in _test.dart
- One test file per source file being tested

## Test Structure

Use the Arrange / Act / Assert pattern with clear blank line separation:

test('returns listing when fetch succeeds', () async {
// Arrange
final mockRepo = MockListingRepository();
when(mockRepo.fetchListings()).thenAnswer((_) async => fakeListings);

```
// Act
final result = await mockRepo.fetchListings();

// Assert
expect(result, equals(fakeListings));
```

});

Group related tests with group() blocks named after the method or behavior.
Use descriptive test names: "returns X when Y" or "throws Z when W".
Never use test names like "test1" or "works correctly".

## Mocking

- Use mocktail package for all mocks (not mockito)
- Create mock classes in test/mocks/ and reuse across test files
- Never mock models — use real instances with fake data
- Fake data defined in test/fixtures/ as static factory methods

## Riverpod Provider Testing

- Use ProviderContainer directly — do not pump a full widget tree
- Override repositories with mocks via container overrides
- Always call container.dispose() in tearDown
- Test all three AsyncValue states: loading, data, error

Example:
final container = ProviderContainer(
overrides: [
listingRepositoryProvider.overrideWithValue(mockRepo),
],
);
addTearDown(container.dispose);

## Widget Tests

- Use flutter_test package (built-in, no extra dependency)
- Wrap widget under test in ProviderScope with mocked providers
- Test user interactions with tester.tap(), tester.enterText()
- Do not test exact colors, font sizes, or pixel positions
- Do test: text content, button presence, navigation triggers,
error message display, loading indicator visibility

## What Not To Test

- Generated code (*.freezed.dart, *.g.dart)
- Supabase SDK internals
- GoRouter redirect logic in isolation (covered by widget flow tests)
- Third-party package behavior (OneSignal, flutter_dotenv, etc.)

## Running Tests

- Unit and widget tests: flutter test
- Always fix failing tests before adding new features
- A passing test suite is required before any PR or deployment