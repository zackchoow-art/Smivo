import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/constants/debug_constants.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/utils/validators.dart';
import 'package:smivo/data/models/school.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/shared/providers/system_urls_provider.dart';
import 'package:smivo/features/shared/providers/school_provider.dart';
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

  School? _selectedSchool;

  // Debug mode toggle - allows using whitelisted test emails
  bool _isDebugMode = false;
  Timer? _debugTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _debugTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final emailValue = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_isDebugMode && _selectedSchool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a school first'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // NOTE: Commit autofill result to iOS Keychain BEFORE the await so
    // the system can prompt to save the password.
    TextInput.finishAutofillContext();

    if (_isDebugMode) {
      await ref.read(authProvider.notifier).loginDebug(emailValue, password);
    } else {
      await ref
          .read(authProvider.notifier)
          .login(emailValue, _selectedSchool!.emailDomain, password);
    }

    // NOTE: GoRouter's refreshListenable (AppRouterNotifier) should handle
    // the redirect reactively, but we add a manual fallback here in case
    // the stream timing causes redirect() to be evaluated before the auth
    // state settles to a non-loading value.
    if (!mounted) return;
    final hasError = ref.read(authProvider).hasError;
    if (!hasError) {
      context.goNamed(AppRoutes.home);
    }
  }

  void _toggleDebugMode() {
    setState(() {
      _isDebugMode = !_isDebugMode;
      _emailController.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debug mode ${_isDebugMode ? "enabled" : "disabled"}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _startDebugTimer() {
    if (!kDebugBackdoorEnabled) return;
    _debugTimer?.cancel();
    _debugTimer = Timer(const Duration(seconds: 5), () {
      _toggleDebugMode();
    });
  }

  void _cancelDebugTimer() {
    _debugTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final activeSchoolsAsync = ref.watch(activeSchoolsProvider);
    final systemUrlsState = ref.watch(systemUrlsProvider);
    final systemUrls = systemUrlsState.value ?? {};

    final safetyUrlStr = systemUrls['safety'] ?? 'https://smivo.io/safety';
    final termsUrlStr =
        systemUrls['terms_of_service'] ?? 'https://smivo.io/terms';

    final isLoading = authState.isLoading;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    // Listen for auth errors and show SnackBar
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
      }
    });

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(AppRoutes.home);
              }
            },
            icon: Icon(Icons.close_rounded, color: colors.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);

            Widget body = SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: ContentWidthConstraint(
                  maxWidth: 420,
                  child: Column(
                    children: [
                      // ── Mobile Header Fragment (Simplified Branding) ──────
                      const SizedBox(height: 8),
                      Center(
                        child: GestureDetector(
                          onTapDown: (_) => _startDebugTimer(),
                          onTapUp: (_) => _cancelDebugTimer(),
                          onTapCancel: _cancelDebugTimer,
                          child: Text(
                            'Smivo',
                            style: typo.displayLarge.copyWith(
                              fontStyle: FontStyle.italic,
                              color: colors.primary,
                              fontSize: 48,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

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
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Headline ──────────────────────────────────
                              Text(
                                'Welcome back.',
                                textAlign: TextAlign.center,
                                style: typo.headlineLarge.copyWith(
                                  fontSize: 26,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Only valid university emails (.edu) are accepted to ensure a safe campus environment.',
                                textAlign: TextAlign.center,
                                style: typo.bodyMedium,
                              ),
                              const SizedBox(height: 24),

                              // ── School Selector ─────────────────────────────
                              if (!_isDebugMode) ...[
                                activeSchoolsAsync.when(
                                  data: (schools) {
                                    if (schools.isEmpty) {
                                      return const Text(
                                        'No schools available.',
                                      );
                                    }

                                    // Set default if null
                                    if (_selectedSchool == null) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (mounted)
                                              setState(
                                                () =>
                                                    _selectedSchool =
                                                        schools.first,
                                              );
                                          });
                                    }

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Text(
                                            'SELECT SCHOOL',
                                            style: typo.labelUppercase,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        DropdownButtonFormField<School>(
                                          value:
                                              _selectedSchool ?? schools.first,
                                          items:
                                              schools
                                                  .map(
                                                    (s) => DropdownMenuItem(
                                                      value: s,
                                                      child: Text(
                                                        s.name,
                                                        style: typo.bodyMedium,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(
                                                () => _selectedSchool = val,
                                              );
                                            }
                                          },
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                colors.surfaceContainerLow,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 18,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    radius.input,
                                                  ),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          icon: Icon(
                                            Icons.arrow_drop_down_rounded,
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  loading:
                                      () => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  error:
                                      (err, st) =>
                                          Text('Error loading schools: $err'),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // ── Email + Password (AutofillGroup for iOS Keychain) ──
                              AutofillGroup(
                                child: Column(
                                  children: [
                                    // ── Email Field ─────────────────────────────
                                    AppTextField(
                                      label: _isDebugMode ? 'Test Email' : null,
                                      hintText:
                                          _isDebugMode
                                              ? 'test@smivo.dev'
                                              : 'username',
                                      suffixText:
                                          _isDebugMode
                                              ? null
                                              : (_selectedSchool != null
                                                  ? '@${_selectedSchool!.emailDomain}'
                                                  : '@edu'),
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator:
                                          _isDebugMode
                                              ? Validators.eduEmail
                                              : Validators.emailPrefix,
                                      // NOTE: Both modes use AutofillHints.username to match the
                                      // hint used at registration. iOS only shows Strong Password
                                      // suggestions for 'username' + 'newPassword' groups, not
                                      // 'email' + 'newPassword'. Keychain saves the actual string
                                      // value regardless of hint type, so full emails are saved.
                                      autofillHints: const [AutofillHints.username],
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 16),

                                    // ── Password Field ──────────────────────
                                    AppTextField(
                                      hintText: '••••••••',
                                      controller: _passwordController,
                                      obscureText: true,
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                        size: 16,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _handleLogin(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    context.pushNamed(AppRoutes.forgotPassword);
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: typo.bodyMedium.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Sign In Button ────────────────────────────
                              Container(
                                height: 56,
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
                                  onPressed: isLoading ? null : _handleLogin,
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
                                                'Sign In',
                                                style: typo.labelLarge.copyWith(
                                                  color: colors.onPrimary,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 16,
                                                color: colors.onPrimary,
                                              ),
                                            ],
                                          ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ── Divider ───────────────────────────────────
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Divider(color: colors.dividerColor),
                                  Container(
                                    color: colors.surface,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'NEW TO THE QUAD?',
                                      style: typo.bodyLarge.copyWith(
                                        fontSize: 12,
                                        letterSpacing: 1.2,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // ── Join Button ───────────────────────────────
                              SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed:
                                      () =>
                                          context.pushNamed(AppRoutes.register),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: colors.outlineVariant,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        radius.xl,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.school_outlined,
                                        color: colors.primary,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Join with .edu email',
                                        style: typo.labelLarge.copyWith(
                                          color: colors.primary,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── Footer ────────────────────────────────────
                              Text.rich(
                                TextSpan(
                                  text: 'By signing in, you agree to the ',
                                  children: [
                                    TextSpan(
                                      text: 'Community Standards',
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer:
                                          TapGestureRecognizer()
                                            ..onTap = () async {
                                              final url = Uri.parse(
                                                safetyUrlStr,
                                              );
                                              if (await canLaunchUrl(url)) {
                                                await launchUrl(url);
                                              }
                                            },
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer:
                                          TapGestureRecognizer()
                                            ..onTap = () async {
                                              final url = Uri.parse(
                                                termsUrlStr,
                                              );
                                              if (await canLaunchUrl(url)) {
                                                await launchUrl(url);
                                              }
                                            },
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
                                ),
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
