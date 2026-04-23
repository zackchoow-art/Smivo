# Task 004: Condition Field UI Binding

## Objective
1. Add condition picker to the create listing form
2. Pass condition to createListingAction.submit()
3. Replace hardcoded "LIKE NEW" tag on listing detail with real condition
4. Do NOT add condition to home feed cards (not needed for MVP)

## STRICT SCOPE — Only modify these files:
1. `lib/features/listing/screens/create_listing_form_screen.dart` — add condition UI
2. `lib/features/listing/providers/create_listing_provider.dart` — add condition param
3. `lib/features/listing/screens/listing_detail_screen.dart` — use real condition

**DO NOT** modify any other files.

---

## Condition Values (from DB)
The `condition` column is a text field with these valid values:
- `new`
- `like_new`
- `good` (default)
- `fair`
- `poor`

Display labels should be:
- `new` → "New"
- `like_new` → "Like New"
- `good` → "Good"
- `fair` → "Fair"
- `poor` → "Poor"

---

## Step 1: Add condition state to create form

In `create_listing_form_screen.dart`, add a state variable in
`_CreateListingFormScreenState` (around line 36, after `_isSubmitting`):

```dart
  String _selectedCondition = 'good'; // Default condition
```

## Step 2: Add condition picker UI in the form

Insert a condition picker AFTER the Category section (after line ~173 where
`const SizedBox(height: AppSpacing.xl)` follows `_CategoryPicker()`), and
BEFORE the Pricing section (before `if (isSale)`).

Add this block:

```dart
            // Condition
            Text(
              'Condition',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2B2A51),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ConditionChip(
                  label: 'New',
                  value: 'new',
                  isSelected: _selectedCondition == 'new',
                  onTap: () => setState(() => _selectedCondition = 'new'),
                ),
                _ConditionChip(
                  label: 'Like New',
                  value: 'like_new',
                  isSelected: _selectedCondition == 'like_new',
                  onTap: () => setState(() => _selectedCondition = 'like_new'),
                ),
                _ConditionChip(
                  label: 'Good',
                  value: 'good',
                  isSelected: _selectedCondition == 'good',
                  onTap: () => setState(() => _selectedCondition = 'good'),
                ),
                _ConditionChip(
                  label: 'Fair',
                  value: 'fair',
                  isSelected: _selectedCondition == 'fair',
                  onTap: () => setState(() => _selectedCondition = 'fair'),
                ),
                _ConditionChip(
                  label: 'Poor',
                  value: 'poor',
                  isSelected: _selectedCondition == 'poor',
                  onTap: () => setState(() => _selectedCondition = 'poor'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
```

## Step 3: Add `_ConditionChip` widget class

Add this at the bottom of the file (after `_CategoryPicker`):

```dart
class _ConditionChip extends StatelessWidget {
  const _ConditionChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0546ED) : const Color(0xFFE2DFFF),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF585781),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
```

## Step 4: Pass condition in `_handleSubmit`

In `_handleSubmit`, find where `submit()` is called (around line 627):

```dart
      await ref.read(createListingActionProvider.notifier).submit(
```

Add `condition: _selectedCondition,` to the named parameters. Insert it after
`transactionType:`:

```dart
      await ref.read(createListingActionProvider.notifier).submit(
            title: _titleController.text,
            description: _descriptionController.text,
            category: selectedCategory,
            transactionType: isSale ? 'sale' : 'rental',
            condition: _selectedCondition,
            schoolId: profile.schoolId,
```

## Step 5: Add condition param to `create_listing_provider.dart`

In `lib/features/listing/providers/create_listing_provider.dart`, update the
`submit` method signature to accept `condition`:

After `required String transactionType,` (around line 86), add:
```dart
    String condition = 'good',
```

Then in the `Listing` draft (around line 147-169), add `condition` to the
constructor. Find the line:
```dart
        status: 'active',
```
And add `condition: condition,` right before it:
```dart
        condition: condition,
        status: 'active',
```

## Step 6: Fix listing detail screen hardcoded tag

In `lib/features/listing/screens/listing_detail_screen.dart`, find line ~102:

```dart
          final statusTag = isSale ? 'LIKE NEW' : 'AVAILABLE NOW';
```

**Replace** with:
```dart
          // NOTE: Show real condition for sale items, availability for rentals
          final statusTag = isSale ? _conditionLabel(listing.condition) : 'AVAILABLE NOW';
```

Then add this helper method. Since `ListingDetailScreen` is a
`ConsumerStatefulWidget`, add it as a static method or a top-level function.
The simplest approach: add a top-level function BEFORE the class definition:

```dart
String _conditionLabel(String condition) {
  switch (condition) {
    case 'new':
      return 'NEW';
    case 'like_new':
      return 'LIKE NEW';
    case 'good':
      return 'GOOD';
    case 'fair':
      return 'FAIR';
    case 'poor':
      return 'POOR';
    default:
      return condition.toUpperCase();
  }
}
```

## Step 7: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-004.md`.
