import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

class AppRouter {
  AppRouter._();

  // Routes are added here progressively as screens are built.
  // Auth redirect logic is added once AuthBloc is wired in Phase 4.
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    ],
  );
}
