# Task 01 — Move Transaction Tag on CompactListingCard

## Assigned Agent
Gemini 3 Flash

## Status
PENDING

## Objective
Move the "Sale" / "Rent" `TransactionTag` widget out of the image area
and place it above the product title in the right-side info column,
left-aligned.

## File to Modify
`lib/features/home/widgets/compact_listing_card.dart`

## Current Layout (lines 70–88)
The `TransactionTag` is currently inside the image `Container` as a
`Positioned` child of a `Stack`:

```dart
child: Stack(
  fit: StackFit.expand,
  children: [
    if (imageUrl == null) Center(child: Icon(...)),
    Positioned(
      top: 4,
      right: 4,
      child: TransactionTag(transactionType: listing.transactionType),
    ),
  ],
),
```

## Required Change
1. Remove the `Positioned(TransactionTag(...))` from inside the image `Stack`.
2. Since the `Stack` now has only the conditional fallback icon child,
   revert the image container's `child` back to the simpler form:
   ```dart
   child: imageUrl == null
       ? Center(child: Icon(...))
       : null,
   ```
3. In the right-side `Column` (the `Expanded` child after the image),
   add `TransactionTag` as the **first** item, before the title `Row`,
   aligned to the left:
   ```dart
   TransactionTag(transactionType: listing.transactionType),
   const SizedBox(height: 4),
   // ... existing title Row ...
   ```

## Strict Boundaries — DO NOT:
- Modify any other file.
- Change font sizes, colors, spacing, or any other visual property.
- Add or remove any other widgets.
- Change the price display logic.
- Run `flutter pub get` or `build_runner`.

## Validation
After making the change, run:
```
flutter analyze
```
There must be zero **errors**. Info-level warnings are acceptable.

## Report
Write the execution report to:
`.agent/reports/task_01_report.md`

Report must include:
- Summary of changes made (with line numbers)
- Full output of `flutter analyze`
- Status: DONE / FAILED
