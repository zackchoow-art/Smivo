# Task 009: Create Listing Form — Visual Simplification

## Objective
Simplify the create listing form per requirements #7:
- Remove the top page title and fake message icon from the app bar
- Remove the pinning checkbox and fee calculation

## STRICT SCOPE — Only modify:
- `lib/features/listing/screens/create_listing_form_screen.dart`

**DO NOT** modify any other files.

---

## Change 1: Replace CustomAppBar with minimal back-only AppBar

Find line ~103:
```dart
appBar: const CustomAppBar(title: 'List Item', showBackButton: true),
```

Replace with a simple back-arrow-only AppBar (no title, no message icon):
```dart
appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
    onPressed: () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    },
  ),
),
```

Also remove the now-unused import of `CustomAppBar`:
```dart
import 'package:smivo/shared/widgets/custom_app_bar.dart';
```

## Change 2: Remove pinning checkbox and slider

Delete the entire pinning section (approximately lines 457-488):
```dart
            // Pinning Section
            CheckboxListTile(
              title: const Text('Pin this listing to top of feed'),
              subtitle: const Text('Increase visibility for your item'),
              value: _isPinned,
              onChanged: (bool? value) {
                setState(() {
                  _isPinned = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            if (_isPinned) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pin for ${_pinnedDays.toInt()} days (\$${(_pinnedDays * 1.5).toStringAsFixed(2)})',
                style: AppTextStyles.bodyMedium,
              ),
              Slider(
                value: _pinnedDays,
                min: 1,
                max: 14,
                divisions: 13,
                label: _pinnedDays.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _pinnedDays = value;
                  });
                },
              ),
            ],
```

## Change 3: Remove unused state variables

Remove these two lines from the state class (approximately lines 33-34):
```dart
  bool _isPinned = false;
  double _pinnedDays = 1.0;
```

## Change 4: Clean up submit references to pinned

Find in the `_handleSubmit` method where `isPinned` and `pinnedDays` are
passed (approximately lines 735-736):
```dart
            isPinned: _isPinned,
            pinnedDays: _isPinned ? _pinnedDays.toInt() : null,
```

Replace with:
```dart
            isPinned: false,
            pinnedDays: null,
```

Or if the `createListing` action accepts these as optional with defaults,
simply remove these two lines entirely.

## Step 5: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-009.md`.
