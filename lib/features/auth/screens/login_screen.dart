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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Debug mode toggle - allows using whitelisted test emails
  bool _isDebugMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final emailValue = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isDebugMode) {
      await ref.read(authProvider.notifier).loginDebug(emailValue, password);
    } else {
      await ref.read(authProvider.notifier).login(emailValue, password);
    }

    // NOTE: Navigation is handled reactively by router.dart watching authStateProvider.
    // We don't need to manually context.go() here.
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
              // ── Mobile Header Fragment (Simplified Branding) ──────
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Smivo',
                  style: AppTextStyles.logo,
                ),
              ),
              const SizedBox(height: 24),

              // ── Main Card ────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2B2A51).withOpacity(0.06),
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
                        'Welcome back.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sign in to access your university\'s exclusive hub.',
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
                        headerAction: GestureDetector(
                          onTap: () {
                            // TODO: Implement Forgot Password flow
                          },
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.linkText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Sign In Button ────────────────────────────
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
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
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
                                      'Sign In',
                                      style: AppTextStyles.buttonLarge,
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
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
                            _isDebugMode ? 'Switch to Normal Mode' : 'Switch to Debug Mode',
                            style: AppTextStyles.footerText.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // ── Divider ───────────────────────────────────
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Divider(color: AppColors.divider),
                          Container(
                            color: AppColors.surface,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'NEW TO THE QUAD?',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontSize: 12,
                                letterSpacing: 1.2,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ── Join Button ───────────────────────────────
                      SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.pushNamed(AppRoutes.register),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.borderLight,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.school_outlined,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Join with smith.edu email',
                                style: AppTextStyles.buttonSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Footer ────────────────────────────────────
                      Text.rich(
                        TextSpan(
                          text: 'By signing in, you agree to the ',
                          children: [
                            TextSpan(
                              text: 'Community Standards',
                              style: const TextStyle(decoration: TextDecoration.underline),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(decoration: TextDecoration.underline),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
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
