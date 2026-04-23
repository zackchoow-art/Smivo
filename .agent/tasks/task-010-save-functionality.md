# Task 010: Activate Save/Bookmark Functionality

## Objective
Wire up the existing SavedRepository to the listing detail UI so users
can save/unsave listings. The SavedListing model and SavedRepository
already exist — we only need a provider and UI integration.

## STRICT SCOPE — Create/modify these files ONLY:

1. **CREATE** `lib/features/listing/providers/saved_listing_provider.dart`
2. **MODIFY** `lib/features/listing/screens/listing_detail_screen.dart`
3. **RUN** `dart run build_runner build --delete-conflicting-outputs`

**DO NOT** modify any other files.

---

## Step 1: Create saved_listing_provider.dart

Create `lib/features/listing/providers/saved_listing_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/repositories/saved_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'saved_listing_provider.g.dart';

/// Checks if a specific listing is saved by the current user.
@riverpod
Future<bool> isListingSaved(Ref ref, String listingId) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return false;
  
  final repo = ref.watch(savedRepositoryProvider);
  return repo.isListingSaved(userId: user.id, listingId: listingId);
}

/// Mutation provider for save/unsave actions.
@riverpod
class SavedListingActions extends _$SavedListingActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Toggle save state for a listing.
  Future<void> toggleSave(String listingId) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw StateError('Must be logged in');

      final repo = ref.read(savedRepositoryProvider);
      final isSaved = await repo.isListingSaved(
        userId: user.id,
        listingId: listingId,
      );

      if (isSaved) {
        await repo.unsaveListing(userId: user.id, listingId: listingId);
      } else {
        await repo.saveListing(userId: user.id, listingId: listingId);
      }

      // Invalidate the check provider so UI updates
      ref.invalidate(isListingSavedProvider(listingId));
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

## Step 2: Run build_runner

```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
```

## Step 3: Add Save button to listing detail screen

In `listing_detail_screen.dart`, add these imports at the top:

```dart
import 'package:smivo/features/listing/providers/saved_listing_provider.dart';
```

Then, inside the `Stack` children (added by Task 008), after the floating
back button `Positioned` widget, add a floating save button at top-right.

**Only show if `!isOwnListing`** (the seller should not see Save on their
own listing):

```dart
// Floating save button — hidden for own listings
if (!isOwnListing)
  Positioned(
    top: MediaQuery.of(context).padding.top + 8,
    right: 12,
    child: Consumer(
      builder: (context, ref, _) {
        final isSavedAsync = ref.watch(isListingSavedProvider(listing.id));
        final isSaved = isSavedAsync.valueOrNull ?? false;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? AppColors.primary : AppColors.onSurface,
            ),
            onPressed: () {
              final user = ref.read(authStateProvider).valueOrNull;
              if (user == null) {
                context.pushNamed(AppRoutes.login);
                return;
              }
              ref.read(savedListingActionsProvider.notifier)
                  .toggleSave(listing.id);
            },
          ),
        );
      },
    ),
  ),
```

## Step 4: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-010.md`.
