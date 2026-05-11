import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

/// Three-step account deletion flow to prevent accidental deletions.
///
/// Step 1: Consequences — shows what will happen (listings, orders, chats).
/// Step 2: Confirmation — user must type "DELETE" to proceed.
/// Step 3: Execution — loading spinner + error feedback.
///
/// NOTE: Uses a bottom sheet instead of a dialog because the content
/// is too long for a standard AlertDialog on mobile screens.
class DeleteAccountBottomSheet extends ConsumerStatefulWidget {
  const DeleteAccountBottomSheet({super.key});

  /// Show the bottom sheet from any context.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DeleteAccountBottomSheet(),
    );
  }

  @override
  ConsumerState<DeleteAccountBottomSheet> createState() =>
      _DeleteAccountBottomSheetState();
}

class _DeleteAccountBottomSheetState
    extends ConsumerState<DeleteAccountBottomSheet> {
  int _step = 0; // 0 = consequences, 1 = type confirm, 2 = executing
  final _confirmController = TextEditingController();
  bool _isDeleting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (_step == 0) _buildConsequencesStep(colors, typo, radius),
              if (_step == 1) _buildConfirmStep(colors, typo, radius),
              if (_step == 2) _buildExecutingStep(colors, typo),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 0: Show consequences ──────────────────────────────────

  Widget _buildConsequencesStep(
    SmivoColors colors,
    SmivoTypography typo,
    SmivoRadius radius,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with warning icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: colors.error,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete Your Account',
                  style: typo.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'This action is permanent and cannot be undone. '
            'The following will happen immediately:',
            style: typo.bodyMedium.copyWith(
              color: colors.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),

          // Consequence list
          _consequenceItem(
            colors,
            typo,
            Icons.storefront_outlined,
            'All active listings will be delisted',
          ),
          _consequenceItem(
            colors,
            typo,
            Icons.receipt_long_outlined,
            'All pending orders will be cancelled',
          ),
          _consequenceItem(
            colors,
            typo,
            Icons.event_busy_outlined,
            'All active rentals will be terminated',
          ),
          _consequenceItem(
            colors,
            typo,
            Icons.chat_outlined,
            'Your chat partners will be notified',
          ),
          _consequenceItem(
            colors,
            typo,
            Icons.devices_outlined,
            'All devices will be signed out',
          ),
          _consequenceItem(
            colors,
            typo,
            Icons.history_outlined,
            'Completed orders preserved for counterparties',
            isNeutral: true,
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: colors.onSurface.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius.button),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: typo.labelLarge.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _step = 1),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: colors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius.button),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: typo.labelLarge.copyWith(color: colors.onPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _consequenceItem(
    SmivoColors colors,
    SmivoTypography typo,
    IconData icon,
    String text, {
    bool isNeutral = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isNeutral
                ? colors.onSurface.withValues(alpha: 0.5)
                : colors.error.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: typo.bodyMedium.copyWith(
                color: isNeutral
                    ? colors.onSurface.withValues(alpha: 0.5)
                    : colors.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Type "DELETE" to confirm ───────────────────────────

  Widget _buildConfirmStep(
    SmivoColors colors,
    SmivoTypography typo,
    SmivoRadius radius,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + title
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _step = 0;
                  _confirmController.clear();
                  _errorMessage = null;
                }),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Text(
                'Confirm Deletion',
                style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Instruction
          RichText(
            text: TextSpan(
              style: typo.bodyMedium.copyWith(
                color: colors.onSurface.withValues(alpha: 0.8),
              ),
              children: [
                const TextSpan(
                  text: 'To confirm, type ',
                ),
                TextSpan(
                  text: 'DELETE',
                  style: typo.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.error,
                    letterSpacing: 1.5,
                  ),
                ),
                const TextSpan(
                  text: ' in the field below:',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Text field
          ListenableBuilder(
            listenable: _confirmController,
            builder: (context, _) {
              final isValid =
                  _confirmController.text.trim().toUpperCase() == 'DELETE';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _confirmController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    style: typo.bodyLarge.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type DELETE here',
                      hintStyle: typo.bodyLarge.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.3),
                        letterSpacing: 2,
                      ),
                      filled: true,
                      fillColor: colors.error.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.button),
                        borderSide: BorderSide(
                          color: isValid
                              ? colors.error
                              : colors.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.button),
                        borderSide: BorderSide(
                          color: isValid
                              ? colors.error
                              : colors.onSurface.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),

                  // Error message from previous failed attempt
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: typo.bodySmall.copyWith(color: colors.error),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Delete button — only enabled when "DELETE" is typed
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isValid ? _executeDelete : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: colors.error,
                        disabledBackgroundColor:
                            colors.error.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius.button),
                        ),
                      ),
                      child: Text(
                        'Permanently Delete My Account',
                        style: typo.labelLarge.copyWith(
                          color: isValid
                              ? colors.onPrimary
                              : colors.onPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Step 2: Executing deletion ─────────────────────────────────

  Widget _buildExecutingStep(SmivoColors colors, SmivoTypography typo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colors.error.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Deleting your account...',
            style: typo.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we process your request.',
            style: typo.bodyMedium.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Execute ────────────────────────────────────────────────────

  Future<void> _executeDelete() async {
    if (_isDeleting) return;

    setState(() {
      _step = 2;
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).deleteAccount();

      // Account deleted — navigate to home.
      // NOTE: signOut(local) already happened inside deleteAccount().
      if (mounted) {
        Navigator.pop(context);
        context.goNamed(AppRoutes.home);
      }
    } catch (e) {
      // Return to step 1 with error message so user can retry.
      if (mounted) {
        setState(() {
          _step = 1;
          _isDeleting = false;
          _errorMessage = 'Failed to delete account. Please try again.';
        });
      }
    }
  }
}
