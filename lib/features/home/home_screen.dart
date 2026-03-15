import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';

/// Minimal home placeholder — full home with bottom nav built in next phase.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'FITQ',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.pureWhite,
            letterSpacing: 3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20),
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (prev, curr) => curr.user != prev.user,
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hey ${state.user?.name.split(' ').first ?? ''} 👋',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.pureWhite,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to rate your fit?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: () => context.push(RouteNames.scanCamera),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonMint,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonMint.withValues(alpha: 0.25),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 40,
                      color: AppColors.deepCarbon,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'TAP TO SCAN',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
