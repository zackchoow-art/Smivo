# Task 012: Fix Rental Period + Total Amount Overflow

## Objective
Fix the overflow issue in `_TotalRentBanner` where "Rental Period" text
and "Total: $xxx" collide on narrow screens. Change from a single Row
to a two-row Column layout.

## STRICT SCOPE — Only modify:
- `lib/features/listing/widgets/rental_options_section.dart`

**DO NOT** modify any other files.

---

## Change: Rewrite _TotalRentBanner

Find the `_TotalRentBanner` class (approximately lines 268-307) and
replace its `build` method body.

**Current code (problematic Row):**
```dart
child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      'Rental Period: $periodText',
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
    ),
    Text(
      'Total: \$${_formatTotal(totalAmount)}',
      style: AppTextStyles.titleMedium.copyWith(
        color: AppColors.primary, 
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),
```

**Replace with two-row Column layout:**
```dart
child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Rental Period: $periodText',
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.onSurface,
      ),
    ),
    const SizedBox(height: AppSpacing.xs),
    Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Total: \$${_formatTotal(totalAmount)}',
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),
```

This puts "Rental Period" on the first line and the total price
right-aligned on the second line, preventing overflow.

## Step 2: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-012.md`.
