# Task 003: Own Listing Detail — Hide Seller Card, Hide Order Button, Show Stats

## Objective
When the current user views their OWN listing's detail page, the UI should:
1. Hide the seller profile card (no need to show your own info)
2. Hide the "Place Order" / "Request to Rent" button
3. Show listing stats: view_count, save_count, inquiry_count

## STRICT SCOPE — Only modify this file:
1. `lib/features/listing/screens/listing_detail_screen.dart`

**DO NOT** modify any other files.

---

## Step 1: Get current user ID

Inside the `data: (listing) {` callback (around line 92), add this line right
after `final seller = listing.seller;`:

```dart
          final currentUserId = ref.watch(authStateProvider).valueOrNull?.id;
          final isOwnListing = currentUserId != null && currentUserId == listing.sellerId;
```

The `authStateProvider` import should already be present (it's used in the
onPressed handler).

## Step 2: Conditionally hide seller profile card

Find the seller section (around line 277):
```dart
                      // Seller Section
                      if (seller != null)
                        SellerProfileCard(
```

**Replace** with:
```dart
                      // Seller Section — hidden on own listing
                      if (seller != null && !isOwnListing)
                        SellerProfileCard(
```

## Step 3: Show stats section for own listing

Right AFTER the seller section block (after the SellerProfileCard closing
parenthesis and the `const SizedBox(height: AppSpacing.xl)` that follows it),
add a new stats section. It should go BEFORE the "Primary Action Button" comment.

Add this block:
```dart
                      // Stats Section — only visible on own listing
                      if (isOwnListing) ...[
                        Text(
                          'LISTING STATS',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.5),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            _StatCard(
                              icon: Icons.visibility_outlined,
                              label: 'Views',
                              count: listing.viewCount,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _StatCard(
                              icon: Icons.bookmark_outline,
                              label: 'Saves',
                              count: listing.saveCount,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _StatCard(
                              icon: Icons.chat_bubble_outline,
                              label: 'Inquiries',
                              count: listing.inquiryCount,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
```

## Step 4: Conditionally hide the order button

Find the "Primary Action Button" section (around line 328):
```dart
                      // Primary Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
```

Wrap it with a condition:
```dart
                      // Primary Action Button — hidden on own listing
                      if (!isOwnListing)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
```

**IMPORTANT**: Since this `SizedBox` contains the `ElevatedButton`, you only
need to add `if (!isOwnListing)` before the existing `SizedBox(`. Do NOT
restructure the widget tree — just add the `if` guard.

## Step 5: Add the _StatCard widget class

Add this private widget class at the BOTTOM of the file, before the closing of
the file but outside `_ListingDetailScreenState`:

```dart
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(
              count.toString(),
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.outlineVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Step 6: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-003.md`.
