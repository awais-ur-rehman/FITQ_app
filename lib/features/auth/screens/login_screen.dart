import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    ctx.read<AuthBloc>().add(LoginRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, curr) =>
          curr.status == AuthStatus.authenticated ||
          curr.status == AuthStatus.failure,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(RouteNames.home);
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Login failed')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // ── Brand mark ──────────────────────────────
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.neonMint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'FQ',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.deepCarbon,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'FITQ',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.pureWhite,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    Text(
                      'Welcome\nback.',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.pureWhite,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to your account.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Email ───────────────────────────────────
                    CustomTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        final emailRx = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRx.hasMatch(v.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ── Password ────────────────────────────────
                    CustomTextField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      obscureText: true,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(context),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 8) return 'At least 8 characters';
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // ── Forgot password ─────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            context.push(RouteNames.forgotPassword),
                        child: const Text('Forgot password?'),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Login button ────────────────────────────
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (prev, curr) =>
                          curr.status == AuthStatus.loading ||
                          prev.status == AuthStatus.loading,
                      builder: (context, state) {
                        return CustomButton(
                          label: 'Sign In',
                          isLoading: state.status == AuthStatus.loading,
                          onPressed: () => _submit(context),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Divider ─────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: AppColors.border),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Sign up ─────────────────────────────────
                    CustomButton.outlined(
                      label: 'Create an Account',
                      onPressed: () => context.go(RouteNames.signup),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
