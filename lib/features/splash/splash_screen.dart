import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/storage/prefs_service.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthCheckRequested());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr.status == AuthStatus.authenticated ||
          curr.status == AuthStatus.unauthenticated,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(RouteNames.home);
        } else if (state.status == AuthStatus.unauthenticated) {
          final prefs = context.read<PrefsService>();
          if (prefs.isOnboardingSeen()) {
            context.go(RouteNames.login);
          } else {
            context.go(RouteNames.onboarding);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo mark — replace inner content with SvgPicture once
                  // assets/icons/fitq_logo.svg is provided
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.neonMint,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'FQ',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepCarbon,
                        letterSpacing: -1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'FITQ',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.pureWhite,
                      letterSpacing: 6,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'YOUR OUTFIT. RATED.',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 64),

                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.neonMint.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
