import 'dart:io';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:smivo/shared/widgets/app_text_field.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  File? _selectedImage;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _initializeName(String email) {
    if (_isInitialized) return;
    // Extract prefix from email: jsmith@smith.edu -> jsmith
    final prefix = email.split('@').first;
    _nameController.text = prefix;
    _isInitialized = true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _handleComplete() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    await ref.read(profileProvider.notifier).completeProfileSetup(
          displayName: name,
          avatarFile: _selectedImage,
        );
    
    // Navigation is reactive via router.dart watching profile status
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('No profile found'));
          
          _initializeName(profile.email);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Set up your Profile',
                    style: AppTextStyles.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Help your campus community identify you.',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // ── Avatar Picker ──────────────────────────────────
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              width: 4,
                            ),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImage == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 64,
                                  color: AppColors.textTertiary,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── Name Input ─────────────────────────────────────
                  AppTextField(
                    label: 'Display Name',
                    hintText: 'How others see you',
                    controller: _nameController,
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── School Info (Read-only) ────────────────────────
                  AppTextField(
                    label: 'University',
                    hintText: 'University',
                    initialValue: profile.school,
                    enabled: false,
                    prefixIcon: const Icon(
                      Icons.school_outlined,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your school is locked based on your email domain.',
                    style: AppTextStyles.footerText,
                  ),
                  const SizedBox(height: 48),

                  // ── Save Button ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: profileAsync.isLoading ? null : _handleComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: profileAsync.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Finish Setup',
                              style: AppTextStyles.buttonLarge,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
