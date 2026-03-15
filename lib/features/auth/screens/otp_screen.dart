import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/custom_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  late Timer _timer;
  int _secondsLeft = 300; // 5 minutes

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
      }
    });
  }

  void _resend(BuildContext ctx) {
    setState(() => _secondsLeft = 300);
    _pinController.clear();
    ctx.read<AuthBloc>().add(OtpResendRequested(email: widget.email));
  }

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer.cancel();
    _pinController.dispose();
    super.dispose();
  }

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

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, curr) =>
          curr.status == AuthStatus.authenticated ||
          curr.status == AuthStatus.failure,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(RouteNames.home);
        } else if (state.status == AuthStatus.failure) {
          _pinController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Invalid code. Try again.'),
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
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                Text(
                  'Check your\nemail.',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.pureWhite,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'We sent a 6-digit code to',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neonMint,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 40),

                // ── PIN input ────────────────────────────────
                Center(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (prev, curr) =>
                        curr.status == AuthStatus.loading ||
                        prev.status == AuthStatus.loading,
                    builder: (context, state) {
                      return Pinput(
                        length: 6,
                        controller: _pinController,
                        enabled: state.status != AuthStatus.loading,
                        defaultPinTheme: defaultTheme,
                        focusedPinTheme: defaultTheme.copyWith(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.neonMint,
                              width: 1.5,
                            ),
                          ),
                        ),
                        errorPinTheme: defaultTheme.copyWith(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error),
                          ),
                        ),
                        onCompleted: (otp) {
                          context.read<AuthBloc>().add(
                                OtpVerified(email: widget.email, otp: otp),
                              );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // ── Verify button ────────────────────────────
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (prev, curr) =>
                      curr.status == AuthStatus.loading ||
                      prev.status == AuthStatus.loading,
                  builder: (context, state) {
                    return CustomButton(
                      label: 'Verify',
                      isLoading: state.status == AuthStatus.loading,
                      onPressed: () {
                        final otp = _pinController.text;
                        if (otp.length == 6) {
                          context.read<AuthBloc>().add(
                                OtpVerified(email: widget.email, otp: otp),
                              );
                        }
                      },
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ── Timer / Resend ───────────────────────────
                Center(
                  child: _secondsLeft > 0
                      ? Text(
                          'Resend code in $_timerLabel',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      : TextButton(
                          onPressed: () => _resend(context),
                          child: const Text("Didn't receive it? Resend"),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
