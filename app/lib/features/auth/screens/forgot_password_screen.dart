import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/constants/debug_constants.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/utils/validators.dart';
import 'package:smivo/data/models/school.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/shared/providers/school_provider.dart';
import 'package:smivo/shared/widgets/app_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  School? _selectedSchool;

  // Debug mode toggle
  bool _isDebugMode = false;
  Timer? _debugTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _debugTimer?.cancel();
    super.dispose();
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

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isDebugMode && _selectedSchool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a school first'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final emailValue = _emailController.text.trim();
    if (_isDebugMode) {
      await ref.read(authProvider.notifier).resetPasswordDebug(emailValue);
    } else {
      await ref
          .read(authProvider.notifier)
          .resetPassword(emailValue, _selectedSchool!.emailDomain);
    }

    if (mounted && !ref.read(authProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Password reset email sent. Please check your inbox.',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final activeSchoolsAsync = ref.watch(activeSchoolsProvider);

    final isLoading = authState.isLoading;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

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
                          GestureDetector(
                            onTapDown: (_) => _startDebugTimer(),
                            onTapUp: (_) => _cancelDebugTimer(),
                            onTapCancel: _cancelDebugTimer,
                            child: Text(
                              'Smivo',
                              style: typo.displayLarge.copyWith(
                                fontSize: 24,
                                fontStyle: FontStyle.italic,
                                color: colors.primary,
                              ),
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
                              Text(
                                'Forgot Password',
                                textAlign: TextAlign.center,
                                style: typo.headlineLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Enter your university username and select your school to receive a reset link.',
                                textAlign: TextAlign.center,
                                style: typo.bodyLarge,
                              ),
                              const SizedBox(height: 32),

                              // ── School Selector ─────────────────────────────
                              if (!_isDebugMode) ...[
                                activeSchoolsAsync.when(
                                  data: (schools) {
                                    if (schools.isEmpty) {
                                      return const Text(
                                        'No schools available.',
                                      );
                                    }

                                    if (_selectedSchool == null) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (mounted) {
                                              setState(
                                                () =>
                                                    _selectedSchool =
                                                        schools.first,
                                              );
                                            }
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
                                          initialValue:
                                              _selectedSchool ?? schools.first,
                                          items:
                                              schools
                                                  .map(
                                                    (s) => DropdownMenuItem<School>(
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
                                const SizedBox(height: 24),
                              ],

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
                              ),
                              const SizedBox(height: 32),

                              // ── Reset Button ────────────────────────────
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
                                  onPressed: isLoading ? null : _handleReset,
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
                                                'Send Reset Link',
                                                style: typo.labelLarge.copyWith(
                                                  color: colors.onPrimary,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.email_outlined,
                                                size: 18,
                                                color: colors.onPrimary,
                                              ),
                                            ],
                                          ),
                                ),
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
