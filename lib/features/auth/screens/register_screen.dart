import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/constants/debug_constants.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/utils/validators.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/shared/widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Debug mode toggle - allows using whitelisted test emails for signup
  bool _isDebugMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final emailValue = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isDebugMode) {
      await ref.read(authProvider.notifier).signUpDebug(emailValue, password);
    } else {
      await ref.read(authProvider.notifier).signUp(emailValue, password);
    }

    // Navigation is reactive via router.dart watching authStateProvider.
    // If successful, user is redirected to verification or home.
  }

  void _toggleDebugMode() {
    setState(() {
      _isDebugMode = !_isDebugMode;
      _emailController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    // Listen for auth errors and show SnackBar
    ref.listen(authProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final message = error is AppException 
            ? error.message 
            : 'Something went wrong. Please try again';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 38),
          child: Column(
            children: [
              // ── Back Button & Branding ───────────────────────────
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.textPrimary,
                  ),
                  const Spacer(),
                  Text(
                    'Smivo',
                    style: AppTextStyles.logo.copyWith(fontSize: 24),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
              const SizedBox(height: 24),

              // ── Main Card ────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2B2A51).withValues(alpha: 0.06),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Headline ──────────────────────────────────
                      Text(
                        'Join the Quad.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create your account with your university email.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 32),

                      // ── Email Field ───────────────────────────────
                      AppTextField(
                        label: _isDebugMode ? 'Test Email' : 'University Username',
                        hintText: _isDebugMode ? 'test@smivo.dev' : 'username',
                        suffixText: _isDebugMode ? null : '@smith.edu',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _isDebugMode 
                            ? Validators.eduEmail 
                            : Validators.emailPrefix,
                      ),
                      const SizedBox(height: 24),

                      // ── Password Field ────────────────────────────
                      AppTextField(
                        label: 'Password',
                        hintText: '••••••••',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Confirm Password Field ────────────────────
                      AppTextField(
                        label: 'Confirm Password',
                        hintText: '••••••••',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        prefixIcon: const Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Register Button ───────────────────────────
                      Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Create Account',
                                      style: AppTextStyles.buttonLarge,
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      size: 18,
                                      color: Color(0xFFF2F1FF),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      // ── Debug Backdoor Toggle ─────────────────────
                      if (kDebugBackdoorEnabled) ...[
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _toggleDebugMode,
                          icon: Icon(
                            _isDebugMode ? Icons.bug_report : Icons.bug_report_outlined,
                            size: 18,
                            color: AppColors.textTertiary,
                          ),
                          label: Text(
                            _isDebugMode ? 'Switch to Normal' : 'Switch to Debug',
                            style: AppTextStyles.footerText.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // ── Divider ───────────────────────────────────
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 24),

                      // ── Switch to Login ───────────────────────────
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: AppTextStyles.linkText,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Footer ────────────────────────────────────
                      Text(
                        'Only valid university emails (.edu) are accepted to ensure a safe campus environment.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.footerText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
