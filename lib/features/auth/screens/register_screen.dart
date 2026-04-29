import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/constants/debug_constants.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/utils/validators.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/shared/widgets/app_text_field.dart';
import 'package:smivo/core/router/app_routes.dart';

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

  bool _agreedToEula = false;

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
    if (!_agreedToEula) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Action Required'),
              content: const Text(
                'You must read and agree to the zero tolerance policy for objectionable content and abusive users before creating an account.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    // Listen for auth errors and show SnackBar, or navigate on success
    ref.listen(authProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final message =
            error is AppException
                ? error.message
                : 'Something went wrong. Please try again';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: colors.error),
        );
      } else if (!next.isLoading &&
          !next.hasError &&
          previous != null &&
          previous.isLoading) {
        // Successful registration!
        // We navigate manually because Supabase doesn't issue a session immediately
        // for unverified emails, so router.dart won't pick it up automatically yet.
        final emailPrefix = _emailController.text.trim();
        final fullEmail = _isDebugMode ? emailPrefix : '$emailPrefix@smith.edu';
        // GoRouter redirect doesn't trigger, so we manually go to verification screen.
        context.goNamed(
          AppRoutes.emailVerification,
          queryParameters: {'email': fullEmail},
        );
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);

            Widget body = SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 38),
              child: Center(
                child: ContentWidthConstraint(
                  maxWidth: 420,
                  child: Column(
                    children: [
                      // ── Back Button & Branding ───────────────────────────
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            color: colors.onSurface,
                          ),
                          const Spacer(),
                          Text(
                            'Smivo',
                            style: typo.displayLarge.copyWith(
                              fontSize: 24,
                              fontStyle: FontStyle.italic,
                              color: colors.primary,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48), // Balance for back button
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Main Card ────────────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(radius.xl),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow,
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
                                style: typo.headlineLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Create your account with your university email.',
                                textAlign: TextAlign.center,
                                style: typo.bodyLarge,
                              ),
                              const SizedBox(height: 32),

                              // ── Email Field ───────────────────────────────
                              AppTextField(
                                label:
                                    _isDebugMode
                                        ? 'Test Email'
                                        : 'University Username',
                                hintText:
                                    _isDebugMode
                                        ? 'test@smivo.dev'
                                        : 'username',
                                suffixText: _isDebugMode ? null : '@smith.edu',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator:
                                    _isDebugMode
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
                                validator: Validators.password,
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  size: 16,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── Confirm Password Field ────────────────────
                              AppTextField(
                                label: 'Confirm Password',
                                hintText: '••••••••',
                                controller: _confirmPasswordController,
                                obscureText: true,
                                validator:
                                    (val) => Validators.confirmPassword(
                                      _passwordController.text,
                                      val,
                                    ),
                                prefixIcon: Icon(
                                  Icons.verified_user_outlined,
                                  size: 16,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── EULA Checkbox ─────────────────────────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _agreedToEula,
                                      onChanged: (val) {
                                        setState(
                                          () => _agreedToEula = val ?? false,
                                        );
                                      },
                                      activeColor: colors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        text:
                                            'I agree to the Terms of Use and acknowledge that there is ',
                                        style: typo.bodySmall.copyWith(
                                          color: colors.onSurfaceVariant,
                                          height: 1.4,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                'zero tolerance for objectionable content or abusive users',
                                            style: typo.bodySmall.copyWith(
                                              color: colors.primary,
                                              fontWeight: FontWeight.w600,
                                              height: 1.4,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer:
                                                TapGestureRecognizer()
                                                  ..onTap = () async {
                                                    final url = Uri.parse(
                                                      'https://zackchoow-art.github.io/Smivo/safety.html',
                                                    );
                                                    if (await canLaunchUrl(
                                                      url,
                                                    )) {
                                                      await launchUrl(url);
                                                    }
                                                  },
                                          ),
                                          const TextSpan(text: '.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // ── Register Button ───────────────────────────
                              Container(
                                height: 60,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    radius.xl,
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      colors.gradientStart,
                                      colors.gradientEnd,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.primary.withValues(
                                        alpha: 0.2,
                                      ),
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
                                      borderRadius: BorderRadius.circular(
                                        radius.xl,
                                      ),
                                    ),
                                  ),
                                  child:
                                      isLoading
                                          ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: colors.onPrimary,
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Create Account',
                                                style: typo.labelLarge.copyWith(
                                                  color: colors.onPrimary,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.person_add_alt_1_rounded,
                                                size: 18,
                                                color: colors.onPrimary,
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
                                    _isDebugMode
                                        ? Icons.bug_report
                                        : Icons.bug_report_outlined,
                                    size: 18,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  label: Text(
                                    _isDebugMode
                                        ? 'Switch to Normal'
                                        : 'Switch to Debug',
                                    style: typo.bodySmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 32),

                              // ── Divider ───────────────────────────────────
                              Divider(color: colors.dividerColor),
                              const SizedBox(height: 24),

                              // ── Switch to Login ───────────────────────────
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: typo.bodyLarge.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Sign In',
                                        style: typo.bodyMedium.copyWith(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                style: typo.bodySmall,
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

            if (isDesktop) {
              return Center(child: body);
            }
            return body;
          },
        ),
      ),
    );
  }
}
