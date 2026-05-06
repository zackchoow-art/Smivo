import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/core/providers/preferences_provider.dart';
import 'package:smivo/data/models/pickup_location.dart';
import 'package:smivo/features/listing/providers/saved_location_provider.dart';
import 'package:smivo/features/shared/providers/school_provider.dart';

// ── Sentinel value used to signal "Specify Address" selection ─────────────────
const _kSpecifyKey = '__specify__';

/// A structured address dropdown for listing creation / editing.
///
/// Dropdown structure (in order):
///   1. School preset locations  (from [myPickupLocationsProvider])
///   2. User custom addresses    (from [savedLocationsProvider])
///   3. "Specify Address" item   (sentinel — reveals a text field)
///
/// Behaviour:
/// - Defaults to last used item ([lastPickupLocationIdProvider]) or the
///   first item in the list if nothing was saved yet.
/// - School names are intentionally NOT shown next to addresses so the
///   widget stays clean for single-campus use and ready for multi-school.
/// - When "Specify Address" is selected a text field is revealed; on
///   focus-loss or submit the value is auto-saved to [savedLocationsProvider].
/// - [onAddressChanged] is called whenever the effective resolved address
///   string changes (preset name OR custom typed text).
/// - [onPickupIdChanged] is called with the preset [PickupLocation.id] when
///   a preset is selected, or null when "Specify Address" is chosen.
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

  /// Called whenever the resolved address text changes.
  final ValueChanged<String>? onAddressChanged;

  /// Called whenever the selected preset pickup ID changes.
  /// Null means "Specify Address" (custom text) is active.
  final ValueChanged<String?>? onPickupIdChanged;

  @override
  ConsumerState<PickupAddressSelector> createState() =>
      PickupAddressSelectorState();
}

class PickupAddressSelectorState
    extends ConsumerState<PickupAddressSelector> {
  // Currently selected dropdown key:
  //   • A PickupLocation.id for presets
  //   • A saved-address label (prefixed '_custom_') for user custom items
  //   • _kSpecifyKey for the "Specify Address" row
  String? _selectedKey;

  final _specifyController = TextEditingController();
  final _specifyFocus = FocusNode();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _specifyFocus.addListener(_onSpecifyFocusChange);
  }

  @override
  void dispose() {
    _specifyController.dispose();
    _specifyFocus.removeListener(_onSpecifyFocusChange);
    _specifyFocus.dispose();
    super.dispose();
  }

  void _onSpecifyFocusChange() {
    if (!_specifyFocus.hasFocus) {
      _autoSaveSpecify();
    }
  }

  void _autoSaveSpecify() {
    final text = _specifyController.text.trim();
    if (text.isEmpty) return;
    ref.read(savedLocationsProvider.notifier).save(text);
    widget.onAddressChanged?.call(text);
  }

  /// Public API: force-save the current specify field value.
  /// Call this before form submission as a safety net.
  void saveIfSpecifying() => _autoSaveSpecify();

  /// Public API: return the currently resolved address string.
  String get currentAddress {
    if (_selectedKey == _kSpecifyKey || _selectedKey == null) {
      return _specifyController.text.trim();
    }
    // Could be a preset ID or a custom label.
    return _selectedKey!.startsWith('_custom_')
        ? _selectedKey!.substring('_custom_'.length)
        : _selectedKey!; // caller resolves preset name via ID
  }

  void _onDropdownChanged(
    String? key,
    List<PickupLocation> presets,
    List<String> customs,
  ) {
    if (key == null) return;
    setState(() => _selectedKey = key);

    if (key == _kSpecifyKey) {
      widget.onPickupIdChanged?.call(null);
      // Emit the current specify text immediately if non-empty.
      final text = _specifyController.text.trim();
      if (text.isNotEmpty) widget.onAddressChanged?.call(text);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _specifyFocus.requestFocus();
      });
    } else if (key.startsWith('_custom_')) {
      // Custom address selected — no preset ID.
      final label = key.substring('_custom_'.length);
      widget.onPickupIdChanged?.call(null);
      widget.onAddressChanged?.call(label);
      // Persist last used (we re-use the upsert to bump last_used_at).
      ref.read(savedLocationsProvider.notifier).save(label);
    } else {
      // Preset selected.
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
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Failed to load locations: $e'),
      data: (presets) {
        return customsAsync.when(
          loading: () => const SizedBox(
            height: 56,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => _buildDropdown(context, presets, [], colors, typo, radius),
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
    // ── One-time initialisation: determine default selection ──────────────────
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _initializeSelection(presets, customs);
      });
    }

    // Determine if "Specify Address" is currently active.
    final isSpecify =
        _selectedKey == null || _selectedKey == _kSpecifyKey;

    // Build dropdown items ────────────────────────────────────────────────────
    final items = <DropdownMenuItem<String>>[];

    // Group 1: School presets (excluding any 'other' sentinel rows from DB)
    for (final loc in presets) {
      if (loc.name.toLowerCase().startsWith('other')) continue;
      items.add(
        DropdownMenuItem<String>(
          value: loc.id,
          child: Text(loc.name, style: typo.bodyMedium),
        ),
      );
    }

    // Divider between groups — only shown when both groups are non-empty
    if (items.isNotEmpty && customs.isNotEmpty) {
      items.add(
        DropdownMenuItem<String>(
          value: '_divider_',
          enabled: false,
          child: Divider(
            color: colors.outlineVariant,
            height: 1,
          ),
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
              Icon(
                Icons.history,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
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

    // Divider before "Specify Address"
    if (items.isNotEmpty) {
      items.add(
        DropdownMenuItem<String>(
          value: '_divider2_',
          enabled: false,
          child: Divider(color: colors.outlineVariant, height: 1),
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
                size: 16, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              'Specify Address',
              style: typo.bodyMedium.copyWith(color: colors.primary),
            ),
          ],
        ),
      ),
    );

    // Resolve the current dropdown value — must be a valid key in items.
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
        // ── Main Dropdown ──────────────────────────────────────────────────
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
                style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
              ),
              icon: Icon(Icons.arrow_drop_down, color: colors.onSurfaceVariant),
              style: typo.bodyMedium.copyWith(color: colors.onSurface),
              onChanged: (key) => _onDropdownChanged(key, presets, customs),
              items: items,
            ),
          ),
        ),

        // ── Specify Address text field (shown when isSpecify) ─────────────
        if (isSpecify) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _specifyController,
            focusNode: _specifyFocus,
            textInputAction: TextInputAction.done,
            style: typo.bodyMedium.copyWith(color: colors.onSurface),
            onChanged: (v) => widget.onAddressChanged?.call(v.trim()),
            onSubmitted: (_) => _autoSaveSpecify(),
            decoration: InputDecoration(
              hintText: 'Type a specific meeting spot…',
              hintStyle:
                  typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
              filled: true,
              fillColor: colors.surfaceContainerLow,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
    // 1. Honour explicit initialPickupId (edit-listing mode).
    if (widget.initialPickupId != null) {
      final match =
          presets.where((p) => p.id == widget.initialPickupId).firstOrNull;
      if (match != null) {
        setState(() => _selectedKey = match.id);
        return;
      }
    }

    // 2. Honour initialAddress that matches a custom saved entry.
    if (widget.initialAddress != null) {
      final customMatch =
          customs.where((c) => c == widget.initialAddress).firstOrNull;
      if (customMatch != null) {
        setState(() => _selectedKey = '_custom_$customMatch');
        return;
      }
      // 3. Initial address provided but not in history → show specify field.
      setState(() {
        _selectedKey = _kSpecifyKey;
        _specifyController.text = widget.initialAddress!;
      });
      return;
    }

    // 4. Use last-used preset ID from SharedPreferences.
    final lastId = ref.read(lastPickupLocationIdProvider);
    if (lastId != null) {
      final match = presets.where((p) => p.id == lastId).firstOrNull;
      if (match != null) {
        setState(() => _selectedKey = match.id);
        widget.onPickupIdChanged?.call(match.id);
        widget.onAddressChanged?.call(match.name);
        return;
      }
      // Last used was a custom — check customs list.
      if (customs.isNotEmpty) {
        // lastId may be a label stored as lastPickupLocationId (old behaviour);
        // try matching by label.
        final customMatch = customs.where((c) => c == lastId).firstOrNull;
        if (customMatch != null) {
          setState(() => _selectedKey = '_custom_$customMatch');
          widget.onPickupIdChanged?.call(null);
          widget.onAddressChanged?.call(customMatch);
          return;
        }
      }
    }

    // 5. Fall back to first available preset.
    final firstPreset =
        presets.where((p) => !p.name.toLowerCase().startsWith('other')).firstOrNull;
    if (firstPreset != null) {
      setState(() => _selectedKey = firstPreset.id);
      widget.onPickupIdChanged?.call(firstPreset.id);
      widget.onAddressChanged?.call(firstPreset.name);
      return;
    }

    // 6. Fall back to first custom address.
    if (customs.isNotEmpty) {
      setState(() => _selectedKey = '_custom_${customs.first}');
      widget.onPickupIdChanged?.call(null);
      widget.onAddressChanged?.call(customs.first);
      return;
    }

    // 7. Nothing available → default to "Specify Address".
    setState(() => _selectedKey = _kSpecifyKey);
  }
}
