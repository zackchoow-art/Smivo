import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  final String email;

  /// Opens the device's default mail app using mailto scheme.
  Future<void> _openEmailApp(BuildContext context) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto');
    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open email app.')),
        );
      }
    }
  }

  /// Triggers a resend of the verification email via Supabase.
  Future<void> _resendEmail(WidgetRef ref, BuildContext context) async {
    try {
      await ref.read(authProvider.notifier).resendVerification(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent! Please check your inbox.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ─── Reactive Navigation ──────────────────────────────────────────
    // We don't need manual navigation or polling here. 
    // GoRouter (in router.dart) is watching authStateProvider.
    // When the user confirms their email (via deep link or refresh),
    // authStateProvider will emit a user with emailConfirmedAt != null,
    // and GoRouter's redirect will automatically send them to Home.
    // ──────────────────────────────────────────────────────────────────
    
    final authState = ref.watch(authProvider);
    final isResending = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Transactional Header (Back Button) ────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2B2A51).withOpacity(0.04),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Illustration Area ─────────────────────────────────
            Positioned(
              top: 96,
              left: 55,
              right: 55,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2B2A51).withOpacity(0.08),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset(
                        'assets/images/email_verification_illustration.png', 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(
                            Icons.mark_email_read_outlined,
                            size: 100,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Floating Accent Icon
                  Positioned(
                    right: -16,
                    bottom: -16,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF26FEDC),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 32,
                          color: Color(0xFF005D4F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Typography ────────────────────────────────────────
            Positioned(
              top: 416,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Text(
                    'Check your email',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We sent a verification link to:',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge,
                  ),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Actions ───────────────────────────────────────────
            Positioned(
              bottom: 48,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => _openEmailApp(context),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Open email app',
                        style: AppTextStyles.linkText.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: isResending ? null : () => _resendEmail(ref, context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        isResending 
                            ? "Resending..." 
                            : "Didn't receive email? Resend",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.footerText.copyWith(
                          fontSize: 14,
                          color: isResending 
                              ? AppColors.textTertiary 
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
