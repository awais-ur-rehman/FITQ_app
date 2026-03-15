import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../core/storage/prefs_service.dart';

abstract class RouteNames {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String scanCamera = '/scan/camera';
  static const String scanConfirm = '/scan/confirm';
  static const String scanScore = '/scan/score';
  static const String closet = '/closet';
  static const String scanDetail = '/closet/:id';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String stats = '/profile/stats';
  static const String settings = '/profile/settings';
}

/// Wraps a BLoC stream so GoRouter can listen for state changes via
/// [refreshListenable] and re-evaluate redirect logic.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();

  static final Set<String> _authRoutes = {
    RouteNames.login,
    RouteNames.signup,
    RouteNames.otp,
    RouteNames.forgotPassword,
  };

  static GoRouter createRouter({
    required AuthBloc authBloc,
    required PrefsService prefs,
  }) {
    return GoRouter(
      initialLocation: RouteNames.splash,
      refreshListenable: _GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final status = authBloc.state.status;
        final loc = state.matchedLocation;

        // Still initialising — let splash handle navigation via BlocListener
        if (status == AuthStatus.initial || status == AuthStatus.loading) {
          return null;
        }

        if (status == AuthStatus.authenticated) {
          if (loc == RouteNames.splash ||
              loc == RouteNames.onboarding ||
              _authRoutes.contains(loc)) {
            return RouteNames.home;
          }
          return null;
        }

        // Unauthenticated
        if (loc == RouteNames.splash) {
          return prefs.isOnboardingSeen()
              ? RouteNames.login
              : RouteNames.onboarding;
        }

        if (loc != RouteNames.onboarding && !_authRoutes.contains(loc)) {
          return RouteNames.login;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: RouteNames.splash,
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: RouteNames.onboarding,
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: RouteNames.login,
          builder: (_, _) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteNames.signup,
          builder: (_, _) => const SignupScreen(),
        ),
        GoRoute(
          path: RouteNames.otp,
          builder: (_, state) {
            final email = state.extra as String? ?? '';
            return OtpScreen(email: email);
          },
        ),
        GoRoute(
          path: RouteNames.forgotPassword,
          builder: (_, _) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: RouteNames.home,
          builder: (_, _) => const HomeScreen(),
        ),
      ],
    );
  }
}
