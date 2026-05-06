import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/utils/image_upload_service.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smivo/features/settings/widgets/avatar_customization_dialog.dart';
import 'package:smivo/shared/widgets/collapsing_title_app_bar.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:smivo/shared/widgets/action_success_dialog.dart';
import 'package:smivo/features/shared/widgets/user_rating_badge.dart';
import 'package:smivo/features/settings/widgets/address_management_section.dart';

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
      body: SelectionArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: typo.bodyMedium.copyWith(color: colors.error),
                ),
              ),
          data: (profile) {
            if (profile == null) {
              return Center(
                child: Text(
                  'No profile found.',
                  style: typo.bodyMedium.copyWith(color: colors.outlineVariant),
                ),
              );
            }

            if (!_initialized) {
              _displayNameController = TextEditingController(
                text: profile.displayName ?? '',
              );
              _initialized = true;
            }

            return Center(
              child: ContentWidthConstraint(
                maxWidth: 640,
                child: CustomScrollView(
                  slivers: [
                    const CollapsingTitleAppBar(
                      title: 'Edit Profile',
                      subtitle: 'Manage your campus identity.',
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

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
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Avatar with edit overlay
                                  GestureDetector(
                                    onTap: () => _pickAvatar(context),
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundColor:
                                              colors.surfaceContainerHigh,
                                          backgroundImage:
                                              profile.avatarUrl != null
                                                  ? NetworkImage(
                                                    profile.avatarUrl!,
                                                  )
                                                  : null,
                                          child:
                                              profile.avatarUrl == null
                                                  ? Icon(
                                                    Icons.person,
                                                    size: 48,
                                                    color: colors.onSurface
                                                        .withValues(alpha: 0.4),
                                                  )
                                                  : null,
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color:
                                                  colors.surfaceContainerLowest,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: colors.shadow,
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: colors.settingsIcon,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Verified Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          profile.isVerified
                                              ? colors.successContainer
                                              : colors.error.withValues(
                                                alpha: 0.1,
                                              ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          profile.isVerified
                                              ? Icons.verified
                                              : Icons.warning_amber_rounded,
                                          color:
                                              profile.isVerified
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
                                            color:
                                                profile.isVerified
                                                    ? colors.success
                                                    : colors.error,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Email
                                  Text(
                                    profile.email,
                                    style: typo.bodyMedium.copyWith(
                                      color: colors.onSurface.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 24), // empty line
                                  // Ratings and Contributions
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      UserRatingBadge(
                                        user: profile,
                                        role: 'seller',
                                      ),
                                      const SizedBox(width: 8),
                                      UserRatingBadge(
                                        user: profile,
                                        role: 'buyer',
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withAlpha(20),
                                          borderRadius: BorderRadius.circular(
                                            radius.sm,
                                          ),
                                        ),
                                        child: Text(
                                          '🎖️ Lv.${profile.contributionLevel} (${profile.contributionScore} pts)',
                                          style: typo.labelSmall.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Display Name',
                                        style: typo.bodyMedium.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _displayNameController,
                                          style: typo.bodyLarge.copyWith(
                                            color: colors.onSurface,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: colors.settingsIconBg,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    radius.card,
                                                  ),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _isSaving
                                          ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                          : IconButton(
                                            icon: const Icon(
                                              Icons.check_circle,
                                            ),
                                            color: colors.primary,
                                            iconSize: 32,
                                            onPressed: () => _save(context),
                                          ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This is how you will appear to other students.',
                                    style: typo.bodySmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Address Management ─────────────────────────
                            const AddressManagementSection(),

                            const SizedBox(height: 32),
                            // Delete Account — destructive action with confirmation dialog
                            Center(
                              child: Consumer(
                                builder: (context, ref, child) {
                                  return TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (dialogContext) => AlertDialog(
                                              title: const Text(
                                                'Delete Account',
                                              ),
                                              content: const Text(
                                                'This action is permanent and cannot be undone. '
                                                'All your listings, orders, messages, and profile data will be deleted.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        dialogContext,
                                                      ),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(
                                                      dialogContext,
                                                    );
                                                    await ref
                                                        .read(
                                                          authProvider.notifier,
                                                        )
                                                        .deleteAccount();
                                                    if (context.mounted) {
                                                      context.goNamed(
                                                        AppRoutes.home,
                                                      );
                                                    }
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        colors.error,
                                                  ),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                    child: Text(
                                      'Delete Account',
                                      style: typo.labelLarge.copyWith(
                                        color: colors.error.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Pick an avatar image, crop it, then upload via bytes, or generate via Open Peeps.
  Future<void> _pickAvatar(BuildContext context) async {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.surfaceContainerLowest,
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!kIsWeb)
                    ListTile(
                      leading: Icon(Icons.camera_alt, color: colors.primary),
                      title: Text('Take a Photo', style: typo.bodyLarge),
                      onTap: () => Navigator.pop(ctx, 'camera'),
                    ),
                  ListTile(
                    leading: Icon(Icons.photo_library, color: colors.primary),
                    title: Text('Choose from Gallery', style: typo.bodyLarge),
                    onTap: () => Navigator.pop(ctx, 'gallery'),
                  ),
                  ListTile(
                    leading: Icon(Icons.face, color: colors.primary),
                    title: Text('Customize Avatar', style: typo.bodyLarge),
                    onTap: () => Navigator.pop(ctx, 'customize'),
                  ),
                ],
              ),
            ),
          ),
    );

    if (result == null) return;
    if (!context.mounted) return;

    if (result == 'camera' || result == 'gallery') {
      XFile? xFile;
      if (result == 'camera') {
        xFile = await ImageUploadService().takePhotoAndCrop(
          context,
          isAvatar: true,
        );
      } else {
        xFile = await ImageUploadService().pickAndCropImage(
          context,
          isAvatar: true,
        );
      }
      if (xFile == null) return;
      if (!context.mounted) return;

      final bytes = await xFile.readAsBytes();
      final fileName = xFile.name;

      try {
        await ref
            .read(profileProvider.notifier)
            .updateAvatarFromBytes(bytes, fileName);
        _showSuccess('Avatar updated');
      } catch (e) {
        _showError('Failed to update avatar: $e');
      }
    } else if (result == 'customize') {
      final seed = DateTime.now().millisecondsSinceEpoch.toString();
      final url = await showDialog<String>(
        context: context,
        builder: (context) => AvatarCustomizationDialog(initialSeed: seed),
      );
      if (url != null) {
        try {
          await ref.read(profileProvider.notifier).updateAvatarUrl(url);
          _showSuccess('Avatar updated');
        } catch (e) {
          _showError('Failed to update avatar: $e');
        }
      }
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => ActionSuccessDialog(
        title: 'Success',
        message: 'Submitted successfully. Under platform review.',
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Save the display name to Supabase.
  Future<void> _save(BuildContext context) async {
    final newName = _displayNameController.text.trim();
    if (newName.isEmpty) {
      _showError('Display name cannot be empty.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(profileProvider.notifier).updateDisplayName(newName);
      _showSuccess('Profile updated');
    } catch (e) {
      _showError('Failed to save: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
