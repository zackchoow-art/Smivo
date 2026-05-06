import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/core/providers/preferences_provider.dart';
import 'package:smivo/data/models/pickup_location.dart';
import 'package:smivo/features/listing/providers/saved_location_provider.dart';
import 'package:smivo/features/shared/providers/school_provider.dart';

// ── Sentinel value used to signal "Specify Address" selection ─────────────────
const _kSpecifyKey = '__specify__';

/// A structured address dropdown for listing creation / editing / buyer changes.
///
/// Dropdown structure (in order):
///   1. School preset locations  (from [myPickupLocationsProvider])
///   2. User custom addresses    (from [savedLocationsProvider])
///   3. "Specify Address" item   (sentinel — reveals a text field)
///
/// Behaviour:
/// - Defaults to last used item ([lastPickupLocationIdProvider]) or the
///   first item in the list if nothing was saved yet.
/// - School names are NOT shown next to addresses — kept for multi-school
///   readiness; callers display the school name separately.
/// - When "Specify Address" is selected, a text field is revealed.
///   Saving occurs ONLY on keyboard submit (Enter / Done) — not on focus-loss.
///   On submit: deduplication check → save → auto-select the new entry →
///   hide the text field.
/// - [onAddressChanged] is called whenever the effective resolved address
///   string changes (preset name OR confirmed custom text).
/// - [onPickupIdChanged] is called with the preset [PickupLocation.id] when
///   a preset is selected, or null when custom text is active.
class PickupAddressSelector extends ConsumerStatefulWidget {
  const PickupAddressSelector({
    super.key,
    this.initialAddress,
    this.initialPickupId,
    this.onAddressChanged,
    this.onPickupIdChanged,
  });

  /// Pre-fill the selector with a known address string (e.g. edit mode).
  final String? initialAddress;

  /// Pre-fill the selector with a known preset pickup location ID.
  final String? initialPickupId;

  /// Called whenever the resolved address text is confirmed.
  final ValueChanged<String>? onAddressChanged;

  /// Called whenever the selected preset pickup ID changes.
  /// Null means custom text / "Specify Address" is active.
  final ValueChanged<String?>? onPickupIdChanged;

  @override
  ConsumerState<PickupAddressSelector> createState() =>
      PickupAddressSelectorState();
}

class PickupAddressSelectorState
    extends ConsumerState<PickupAddressSelector> {
  // Currently selected dropdown key:
  //   • A PickupLocation.id for presets
  //   • '_custom_' + label  for user custom items
  //   • _kSpecifyKey  for the "Specify Address" row
  String? _selectedKey;

  final _specifyController = TextEditingController();
  final _specifyFocus = FocusNode();
  bool _initialized = false;
  // Whether the Specify text field is currently visible.
  bool _showSpecifyField = false;

  @override
  void initState() {
    super.initState();
    // NOTE: No focus-loss listener — we only save on keyboard submit.
  }

  @override
  void dispose() {
    _specifyController.dispose();
    _specifyFocus.dispose();
    super.dispose();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Called by parent before form submission as a safety net.
  /// Does nothing unless "Specify Address" is visible with non-empty text.
  void saveIfSpecifying() {
    if (_showSpecifyField) _onSpecifySubmit(_specifyController.text);
  }

  // ── Callbacks ──────────────────────────────────────────────────────────────

  /// Handles keyboard submit from the Specify field.
  /// 1. Trim input.
  /// 2. Deduplicate against current custom list.
  /// 3. Save if new, then select & notify.
  /// 4. Hide the text field.
  Future<void> _onSpecifySubmit(String rawValue) async {
    final text = rawValue.trim();
    if (text.isEmpty) return;

    final customs =
        ref.read(savedLocationsProvider).value ?? <String>[];

    // Check for duplicates (case-insensitive).
    final isDuplicate = customs
        .any((c) => c.toLowerCase() == text.toLowerCase());

    if (!isDuplicate) {
      // Persist new entry.
      await ref.read(savedLocationsProvider.notifier).save(text);
      // Wait for provider to refresh so the new entry appears in the list.
      await ref.read(savedLocationsProvider.future);
    }

    // Auto-select the address (use canonical casing from saved list when dup).
    final canonical = isDuplicate
        ? customs.firstWhere((c) => c.toLowerCase() == text.toLowerCase())
        : text;

    widget.onPickupIdChanged?.call(null);
    widget.onAddressChanged?.call(canonical);
    ref.read(lastPickupLocationIdProvider.notifier).save(canonical);

    setState(() {
      _selectedKey = '_custom_$canonical';
      _showSpecifyField = false;
    });

    _specifyController.clear();
  }

  void _onDropdownChanged(
    String? key,
    List<PickupLocation> presets,
  ) {
    if (key == null) return;

    if (key == _kSpecifyKey) {
      setState(() {
        _selectedKey = key;
        _showSpecifyField = true;
      });
      widget.onPickupIdChanged?.call(null);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _specifyFocus.requestFocus();
      });
    } else if (key.startsWith('_custom_')) {
      final label = key.substring('_custom_'.length);
      setState(() {
        _selectedKey = key;
        _showSpecifyField = false;
      });
      widget.onPickupIdChanged?.call(null);
      widget.onAddressChanged?.call(label);
      // Bump last_used_at so this entry stays at the top.
      ref.read(savedLocationsProvider.notifier).save(label);
      ref.read(lastPickupLocationIdProvider.notifier).save(label);
    } else {
      // Preset selected.
      setState(() {
        _selectedKey = key;
        _showSpecifyField = false;
      });
      widget.onPickupIdChanged?.call(key);
      final preset = presets.where((p) => p.id == key).firstOrNull;
      if (preset != null) widget.onAddressChanged?.call(preset.name);
      ref.read(lastPickupLocationIdProvider.notifier).save(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final presetsAsync = ref.watch(myPickupLocationsProvider);
    final customsAsync = ref.watch(savedLocationsProvider);

    return presetsAsync.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          Text('Failed to load locations: $e', style: typo.bodySmall),
      data: (presets) {
        return customsAsync.when(
          loading: () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) =>
              _buildDropdown(context, presets, [], colors, typo, radius),
          data: (customs) =>
              _buildDropdown(context, presets, customs, colors, typo, radius),
        );
      },
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    List<PickupLocation> presets,
    List<String> customs,
    dynamic colors,
    dynamic typo,
    dynamic radius,
  ) {
    // ── One-time initialisation ───────────────────────────────────────────────
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _initializeSelection(presets, customs);
      });
    }

    // ── Build dropdown items ──────────────────────────────────────────────────
    final items = <DropdownMenuItem<String>>[];

    // Group 1: School presets
    for (final loc in presets) {
      if (loc.name.toLowerCase().startsWith('other')) continue;
      items.add(
        DropdownMenuItem<String>(
          value: loc.id,
          child: Text(loc.name, style: typo.bodyMedium),
        ),
      );
    }

    // Thin divider between presets and custom addresses.
    if (items.isNotEmpty && customs.isNotEmpty) {
      items.add(
        DropdownMenuItem<String>(
          value: '_divider_',
          enabled: false,
          // NOTE: height=0 + zero padding keeps the divider visually thin and tight.
          child: Divider(color: colors.outlineVariant, height: 0),
        ),
      );
    }

    // Group 2: User custom addresses
    for (final addr in customs) {
      items.add(
        DropdownMenuItem<String>(
          value: '_custom_$addr',
          child: Row(
            children: [
              Icon(Icons.history, size: 13, color: colors.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  addr,
                  style: typo.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Thin divider before "Specify Address".
    if (items.isNotEmpty) {
      items.add(
        DropdownMenuItem<String>(
          value: '_divider2_',
          enabled: false,
          child: Divider(color: colors.outlineVariant, height: 0),
        ),
      );
    }

    // Group 3: Specify Address sentinel
    items.add(
      DropdownMenuItem<String>(
        value: _kSpecifyKey,
        child: Row(
          children: [
            Icon(Icons.edit_location_alt_outlined,
                size: 15, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              'Specify Address',
              style: typo.bodyMedium.copyWith(color: colors.primary),
            ),
          ],
        ),
      ),
    );

    // Resolve the current dropdown value — must be a valid key.
    final validKeys = items
        .where((i) => i.enabled != false)
        .map((i) => i.value)
        .toSet();
    String? dropdownValue = _selectedKey;
    if (dropdownValue != null && !validKeys.contains(dropdownValue)) {
      dropdownValue = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main Dropdown ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(radius.input),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: dropdownValue,
              isExpanded: true,
              hint: Text(
                'Select pickup location',
                style: typo.bodyMedium
                    .copyWith(color: colors.onSurfaceVariant),
              ),
              icon:
                  Icon(Icons.arrow_drop_down, color: colors.onSurfaceVariant),
              style: typo.bodyMedium.copyWith(color: colors.onSurface),
              onChanged: (key) => _onDropdownChanged(key, presets),
              items: items,
            ),
          ),
        ),

        // ── Specify Address text field ────────────────────────────────────────
        if (_showSpecifyField) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _specifyController,
            focusNode: _specifyFocus,
            textInputAction: TextInputAction.done,
            style: typo.bodyMedium.copyWith(color: colors.onSurface),
            // NOTE: No onChanged notification — we only notify on confirmed submit.
            onSubmitted: _onSpecifySubmit,
            decoration: InputDecoration(
              hintText: 'Type a specific meeting spot…',
              hintStyle:
                  typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
              filled: true,
              fillColor: colors.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.input),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.input),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.input),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _initializeSelection(
    List<PickupLocation> presets,
    List<String> customs,
  ) {
    // NOTE: Strict priority order. Each branch returns immediately so only
    // the highest-priority match sets the state.

    // 1. Honour explicit initialPickupId (edit-listing mode).
    if (widget.initialPickupId != null) {
      final match =
          presets.where((p) => p.id == widget.initialPickupId).firstOrNull;
      if (match != null) {
        setState(() => _selectedKey = match.id);
        widget.onPickupIdChanged?.call(match.id);
        widget.onAddressChanged?.call(match.name);
        return;
      }
    }

    // 2. Honour initialAddress — check if it matches a saved custom entry.
    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      final customMatch = customs
          .where((c) => c.toLowerCase() == widget.initialAddress!.toLowerCase())
          .firstOrNull;
      if (customMatch != null) {
        setState(() => _selectedKey = '_custom_$customMatch');
        widget.onPickupIdChanged?.call(null);
        widget.onAddressChanged?.call(customMatch);
        return;
      }
      // Initial address provided but not in history → show specify field.
      setState(() {
        _selectedKey = _kSpecifyKey;
        _showSpecifyField = true;
        _specifyController.text = widget.initialAddress!;
      });
      widget.onPickupIdChanged?.call(null);
      widget.onAddressChanged?.call(widget.initialAddress!);
      return;
    }

    // 3. Use last-used preset ID from SharedPreferences.
    final lastId = ref.read(lastPickupLocationIdProvider);
    if (lastId != null && lastId.isNotEmpty) {
      // Try matching as a preset ID.
      final presetMatch = presets.where((p) => p.id == lastId).firstOrNull;
      if (presetMatch != null) {
        setState(() => _selectedKey = presetMatch.id);
        widget.onPickupIdChanged?.call(presetMatch.id);
        widget.onAddressChanged?.call(presetMatch.name);
        return;
      }
      // Try matching as a custom label (case-insensitive).
      final customMatch = customs.where((c) => c.toLowerCase() == lastId.toLowerCase()).firstOrNull;
      if (customMatch != null) {
        setState(() => _selectedKey = '_custom_$customMatch');
        widget.onPickupIdChanged?.call(null);
        widget.onAddressChanged?.call(customMatch);
        return;
      }
      
      // If we reach here, lastId existed but wasn't found in presets or customs.
      // This means the user previously used an address that was since deleted.
      // Fallback to Specify Address as requested.
      setState(() {
        _selectedKey = _kSpecifyKey;
        _showSpecifyField = true;
      });
      widget.onPickupIdChanged?.call(null);
      widget.onAddressChanged?.call('');
      return;
    }

    // 4. Fall back to first available preset (excluding 'other' sentinels).
    final firstPreset = presets
        .where((p) => !p.name.toLowerCase().startsWith('other'))
        .firstOrNull;
    if (firstPreset != null) {
      setState(() => _selectedKey = firstPreset.id);
      widget.onPickupIdChanged?.call(firstPreset.id);
      widget.onAddressChanged?.call(firstPreset.name);
      return;
    }

    // 5. Fall back to first custom address.
    if (customs.isNotEmpty) {
      setState(() => _selectedKey = '_custom_${customs.first}');
      widget.onPickupIdChanged?.call(null);
      widget.onAddressChanged?.call(customs.first);
      return;
    }

    // 6. Nothing available → default to "Specify Address".
    setState(() {
      _selectedKey = _kSpecifyKey;
      _showSpecifyField = true;
    });
  }
}
