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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    ctx.read<AuthBloc>().add(SignupRequested(
          name: _nameCtrl.text.trim(),
          username: _usernameCtrl.text.trim().toLowerCase(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, curr) =>
          curr.status == AuthStatus.otpSent ||
          curr.status == AuthStatus.failure,
      listener: (context, state) {
        if (state.status == AuthStatus.otpSent) {
          context.push(RouteNames.otp, extra: state.email);
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Signup failed')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => context.go(RouteNames.login),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  Text(
                    'Create your\naccount.',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.pureWhite,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Join thousands rating their fits daily.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Full name ───────────────────────────────
                  CustomTextField(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    hint: 'Alex Kim',
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _usernameFocus.requestFocus(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (v.trim().length < 2) return 'At least 2 characters';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Username ────────────────────────────────
                  CustomTextField(
                    controller: _usernameCtrl,
                    label: 'Username',
                    hint: 'alexkim',
                    focusNode: _usernameFocus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Username is required';
                      }
                      final rx = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
                      if (!rx.hasMatch(v.trim())) {
                        return '3–20 characters: letters, numbers, underscores';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Email ───────────────────────────────────
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'you@example.com',
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      final rx = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!rx.hasMatch(v.trim())) {
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
                      if (!RegExp(r'[A-Z]').hasMatch(v)) {
                        return 'Include at least one uppercase letter';
                      }
                      if (!RegExp(r'[0-9]').hasMatch(v)) {
                        return 'Include at least one number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Min. 8 characters with a number and uppercase letter.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Submit ──────────────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (prev, curr) =>
                        curr.status == AuthStatus.loading ||
                        prev.status == AuthStatus.loading,
                    builder: (context, state) {
                      return CustomButton(
                        label: 'Create Account',
                        isLoading: state.status == AuthStatus.loading,
                        onPressed: () => _submit(context),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Login link ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(RouteNames.login),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
