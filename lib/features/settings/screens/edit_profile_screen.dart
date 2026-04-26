import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/utils/image_upload_service.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _displayNameController;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: const CustomAppBar(showActions: false),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Error: $e', style: typo.bodyMedium.copyWith(color: colors.error)),
          ),
          data: (profile) {
            if (profile == null) {
              return Center(
                child: Text('No profile found.', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
              );
            }

            // NOTE: Initialize controller only once with real data
            // to avoid overwriting user edits on every rebuild.
            if (!_initialized) {
              _displayNameController = TextEditingController(text: profile.displayName ?? '');
              _initialized = true;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Profile',
                      style: typo.headlineLarge.copyWith(
                          color: colors.settingsText,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('Manage your campus identity.',
                      style: typo.bodyMedium
                          .copyWith(color: colors.settingsTextSecondary)),
                  const SizedBox(height: 32),

                  // Top Card: Avatar & Verification
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(radius.xl),
                      boxShadow: [
                        BoxShadow(
                            color: colors.shadow,
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(children: [
                      // Avatar with edit overlay
                      GestureDetector(
                        onTap: () => _pickAvatar(context),
                        child: Stack(children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: colors.surfaceContainerHigh,
                            backgroundImage: profile.avatarUrl != null
                                ? NetworkImage(profile.avatarUrl!)
                                : null,
                            child: profile.avatarUrl == null
                                ? Icon(Icons.person,
                                    size: 48,
                                    color: colors.onSurface
                                        .withValues(alpha: 0.4))
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLowest,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: colors.shadow,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Icon(Icons.edit,
                                  size: 16, color: colors.settingsIcon),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 24),

                      // Verification status
                      Text('Student Verification',
                          style: typo.titleMedium.copyWith(
                              color: colors.settingsText,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                        'Verify your .edu email to access exclusive\ncampus features.',
                        textAlign: TextAlign.center,
                        style: typo.bodySmall.copyWith(
                            color: colors.settingsTextSecondary, height: 1.3),
                      ),
                      const SizedBox(height: 16),

                      // Email + badge
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: profile.isVerified
                                    ? colors.successContainer
                                    : colors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      profile.isVerified
                                          ? Icons.verified
                                          : Icons.warning_amber_rounded,
                                      color: profile.isVerified
                                          ? colors.success
                                          : colors.error,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      profile.isVerified
                                          ? 'Verified'
                                          : 'Not Verified',
                                      style: typo.labelSmall.copyWith(
                                        color: profile.isVerified
                                            ? colors.success
                                            : colors.error,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ]),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                profile.email,
                                style: typo.bodySmall.copyWith(
                                    color: colors.settingsText
                                        .withValues(alpha: 0.8)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  // Form Fields Card — only Display Name
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(radius.xl),
                      boxShadow: [
                        BoxShadow(
                            color: colors.shadow,
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel(context, 'Display Name'),
                          TextFormField(
                            controller: _displayNameController,
                            style: typo.bodyLarge
                                .copyWith(color: colors.settingsText),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: colors.settingsIconBg,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(radius.card),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This is how you will appear to other students.',
                            style: typo.bodySmall.copyWith(
                                color: colors.settingsTextSecondary,
                                height: 1.3),
                          ),
                          const SizedBox(height: 32),
                          Divider(color: colors.dividerColor),
                          const SizedBox(height: 24),

                          // Cancel / Save buttons
                          Row(children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context.pop(),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  side:
                                      BorderSide(color: colors.dividerColor),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(radius.md)),
                                ),
                                child: Text('Cancel',
                                    style: typo.labelLarge.copyWith(
                                        color: colors.settingsIcon,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : () => _save(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(radius.md)),
                                ),
                                child: _isSaving
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colors.onPrimary),
                                      )
                                    : Text('Save',
                                        style: typo.labelLarge.copyWith(
                                            color: colors.onPrimary,
                                            fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ]),
                        ]),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: typo.bodyMedium.copyWith(
              color: colors.settingsText, fontWeight: FontWeight.w700)),
    );
  }

  /// Pick an avatar image, crop it, then upload via bytes.
  Future<void> _pickAvatar(BuildContext context) async {
    final xFile =
        await ImageUploadService().pickAndCropImage(context, isAvatar: true);
    if (xFile == null) return;
    if (!mounted) return;

    final bytes = await xFile.readAsBytes();
    final fileName = xFile.name;

    try {
      await ref
          .read(profileProvider.notifier)
          .updateAvatarFromBytes(bytes, fileName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Avatar updated'),
            ]),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to update avatar: $e')),
            ]),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Save the display name to Supabase.
  Future<void> _save(BuildContext context) async {
    final newName = _displayNameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Display name cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(profileProvider.notifier).updateDisplayName(newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Profile updated'),
            ]),
            backgroundColor: Colors.green,
          ),
        );

      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to save: $e')),
            ]),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
