import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  // 0 = email, 1 = OTP, 2 = new password
  int _step = 0;
  String _capturedEmail = '';
  String _capturedOtp = '';
  int _secondsLeft = 300;
  Timer? _timer;

  final _resetFormKey = GlobalKey<FormState>();
  final _pinCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _timer?.cancel();
    _pinCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 300);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
      }
    });
  }

  /// Called by _EmailStep once its form is validated.
  void _onEmailSubmitted(BuildContext ctx, String email) {
    _capturedEmail = email;
    ctx.read<AuthBloc>().add(ForgotPasswordRequested(email: email));
  }

  void _submitReset(BuildContext ctx) {
    if (!_resetFormKey.currentState!.validate()) return;
    ctx.read<AuthBloc>().add(
          PasswordResetRequested(
            email: _capturedEmail,
            otp: _capturedOtp,
            newPassword: _newPasswordCtrl.text,
          ),
        );
  }

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr.status != prev.status &&
          (curr.status == AuthStatus.otpSent ||
              curr.status == AuthStatus.passwordResetSuccess ||
              curr.status == AuthStatus.failure),
      listener: (context, state) {
        if (state.status == AuthStatus.otpSent && _step == 0) {
          setState(() => _step = 1);
          _startTimer();
        } else if (state.status == AuthStatus.passwordResetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset! Please sign in.'),
            ),
          );
          context.go(RouteNames.login);
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Something went wrong'),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () {
              if (_step > 0) {
                setState(() => _step--);
              } else {
                context.pop();
              }
            },
          ),
          title: Text(
            _stepTitle,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.pureWhite,
            ),
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _step == 0
                ? _EmailStep(
                    key: const ValueKey(0),
                    onSubmit: _onEmailSubmitted,
                  )
                : _step == 1
                    ? _OtpStep(
                        key: const ValueKey(1),
                        pinCtrl: _pinCtrl,
                        timerLabel: _timerLabel,
                        secondsLeft: _secondsLeft,
                        email: _capturedEmail,
                        onOtpComplete: (otp) =>
                            setState(() {
                              _capturedOtp = otp;
                              _step = 2;
                            }),
                        onResend: (ctx) {
                          _pinCtrl.clear();
                          _startTimer();
                          ctx.read<AuthBloc>().add(
                                ForgotPasswordRequested(email: _capturedEmail),
                              );
                        },
                      )
                    : _NewPasswordStep(
                        key: const ValueKey(2),
                        formKey: _resetFormKey,
                        newPasswordCtrl: _newPasswordCtrl,
                        confirmPasswordCtrl: _confirmPasswordCtrl,
                        confirmFocus: _confirmFocus,
                        onSubmit: _submitReset,
                      ),
          ),
        ),
      ),
    );
  }

  String get _stepTitle => switch (_step) {
        0 => 'Forgot Password',
        1 => 'Enter Code',
        _ => 'New Password',
      };
}

// ─────────────────────────────────────────────────────────────────
// Step sub-widgets
// ─────────────────────────────────────────────────────────────────

class _EmailStep extends StatefulWidget {
  /// Called with (BuildContext, email) once form is valid.
  final void Function(BuildContext ctx, String email) onSubmit;

  const _EmailStep({super.key, required this.onSubmit});

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(ctx, _emailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              "Enter the email\nassociated with\nyour account.",
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(context),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                final rx = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!rx.hasMatch(v.trim())) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 32),
            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (prev, curr) =>
                  curr.status == AuthStatus.loading ||
                  prev.status == AuthStatus.loading,
              builder: (context, state) {
                return CustomButton(
                  label: 'Send Reset Code',
                  isLoading: state.status == AuthStatus.loading,
                  onPressed: () => _submit(context),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  final TextEditingController pinCtrl;
  final String timerLabel;
  final int secondsLeft;
  final String email;
  final void Function(String otp) onOtpComplete;
  final void Function(BuildContext ctx) onResend;

  const _OtpStep({
    super.key,
    required this.pinCtrl,
    required this.timerLabel,
    required this.secondsLeft,
    required this.email,
    required this.onOtpComplete,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.pureWhite),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Enter the 6-digit\ncode.',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.pureWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sent to $email',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 36),
          Center(
            child: Pinput(
              length: 6,
              controller: pinCtrl,
              defaultPinTheme: defaultTheme,
              focusedPinTheme: defaultTheme.copyWith(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neonMint, width: 1.5),
                ),
              ),
              onCompleted: onOtpComplete,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: secondsLeft > 0
                ? Text(
                    'Resend code in $timerLabel',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                : TextButton(
                    onPressed: () => onResend(context),
                    child: const Text('Resend code'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NewPasswordStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController newPasswordCtrl;
  final TextEditingController confirmPasswordCtrl;
  final FocusNode confirmFocus;
  final void Function(BuildContext) onSubmit;

  const _NewPasswordStep({
    super.key,
    required this.formKey,
    required this.newPasswordCtrl,
    required this.confirmPasswordCtrl,
    required this.confirmFocus,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Set a new\npassword.',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: newPasswordCtrl,
              label: 'New Password',
              obscureText: true,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => confirmFocus.requestFocus(),
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
            const SizedBox(height: 16),
            CustomTextField(
              controller: confirmPasswordCtrl,
              label: 'Confirm Password',
              obscureText: true,
              focusNode: confirmFocus,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onSubmit(context),
              validator: (v) {
                if (v != newPasswordCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 32),
            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (prev, curr) =>
                  curr.status == AuthStatus.loading ||
                  prev.status == AuthStatus.loading,
              builder: (context, state) {
                return CustomButton(
                  label: 'Reset Password',
                  isLoading: state.status == AuthStatus.loading,
                  onPressed: () => onSubmit(context),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
