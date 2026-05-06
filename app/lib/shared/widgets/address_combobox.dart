import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/listing/providers/saved_location_provider.dart';

/// A combobox-style address input that combines a free-text field with
/// a dropdown overlay showing the user's saved address history.
///
/// Features:
///  - Tap to open a dropdown of previously saved addresses.
///  - Each history item has a delete icon on the right.
///  - After the user types a new address and submits (via keyboard action or
///    focus loss), the value is auto-saved to `user_saved_locations` if it
///    is non-empty and not a duplicate.
///  - Uses [savedLocationsProvider] so the list is shared / reactive
///    across the entire feature.
class AddressComboBox extends ConsumerStatefulWidget {
  const AddressComboBox({
    super.key,
    required this.controller,
    this.hintText = 'Enter a specific meeting spot...',
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;

  /// Called whenever the text changes (including after selecting from history).
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field (keyboard Done / Go).
  /// The caller is responsible for calling [saveCurrentValue] if needed.
  final ValueChanged<String>? onSubmitted;

  @override
  ConsumerState<AddressComboBox> createState() => AddressComboBoxState();

  // Expose a static helper so the parent screen can trigger a save easily.
}

class AddressComboBoxState extends ConsumerState<AddressComboBox> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      // Save when focus is lost with a non-empty value.
      _autoSave(widget.controller.text.trim());
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final entry = OverlayEntry(builder: (context) => _buildOverlay());
    _overlayEntry = entry;
    Overlay.of(context).insert(entry);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _refreshOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  Widget _buildOverlay() {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Positioned(
      width: 0,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 56),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(radius.card),
          color: colors.surfaceContainerHigh,
          child: Consumer(
            builder: (context, ref, _) {
              final savedAsync = ref.watch(savedLocationsProvider);
              return savedAsync.when(
                loading:
                    () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                error: (_, __) => const SizedBox.shrink(),
                data: (saved) {
                  if (saved.isEmpty) return const SizedBox.shrink();

                  // Filter by current text input for a search-as-you-type feel.
                  final query = widget.controller.text.trim().toLowerCase();
                  final filtered =
                      query.isEmpty
                          ? saved
                          : saved
                              .where((a) => a.toLowerCase().contains(query))
                              .toList();

                  if (filtered.isEmpty) return const SizedBox.shrink();

                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final addr = filtered[i];
                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          leading: Icon(
                            Icons.history,
                            size: 16,
                            color: colors.onSurfaceVariant,
                          ),
                          title: Text(addr, style: typo.bodyMedium),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: colors.onSurfaceVariant,
                            ),
                            tooltip: 'Remove',
                            onPressed: () {
                              ref
                                  .read(savedLocationsProvider.notifier)
                                  .delete(addr);
                              _refreshOverlay();
                            },
                          ),
                          onTap: () {
                            widget.controller.text = addr;
                            widget.onChanged?.call(addr);
                            _removeOverlay();
                            _focusNode.unfocus();
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Saves [value] to the database if it is non-empty.
  /// The upsert RPC is idempotent — duplicates are silently ignored.
  void _autoSave(String value) {
    if (value.isEmpty) return;
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    // NOTE: Fire-and-forget. The notifier invalidates the cache on success
    // so the history list is always up-to-date.
    ref.read(savedLocationsProvider.notifier).save(value);
  }

  /// Public API for the parent to trigger a save on form submit.
  void saveCurrentValue() => _autoSave(widget.controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final radius = context.smivoRadius;
    final typo = context.smivoTypo;

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.done,
        onChanged: (v) {
          widget.onChanged?.call(v);
          _refreshOverlay();
        },
        onSubmitted: (v) {
          _autoSave(v.trim());
          widget.onSubmitted?.call(v.trim());
          _removeOverlay();
        },
        style: typo.bodyMedium.copyWith(color: colors.onSurface),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
          filled: true,
          fillColor: colors.surfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          suffixIcon: Icon(
            Icons.arrow_drop_down,
            color: colors.onSurfaceVariant,
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
    );
  }
}
