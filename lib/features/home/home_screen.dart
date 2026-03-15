import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/offline_banner.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';

/// Bottom navigation shell — wraps Closet, Scan tab, and Profile.
class HomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: OfflineBanner(child: navigationShell),
      bottomNavigationBar: Container(
        height: 64 + bottomPad,
        padding: EdgeInsets.only(bottom: bottomPad),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            // Closet tab (branch 0)
            Expanded(
              child: _NavItem(
                icon: Icons.checkroom_outlined,
                label: 'Closet',
                selected: navigationShell.currentIndex == 0,
                onTap: () => navigationShell.goBranch(0),
              ),
            ),

            // Scan tab (branch 1 — center, prominent)
            Expanded(
              child: GestureDetector(
                onTap: () => navigationShell.goBranch(
                  1,
                  initialLocation: navigationShell.currentIndex == 1,
                ),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: navigationShell.currentIndex == 1
                            ? AppColors.neonMint
                            : AppColors.neonMint.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.neonMint.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 20,
                        color: navigationShell.currentIndex == 1
                            ? AppColors.deepCarbon
                            : AppColors.neonMint,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile tab (branch 2)
            Expanded(
              child: _NavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: navigationShell.currentIndex == 2,
                onTap: () => navigationShell.goBranch(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.neonMint : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Content shown in the Scan tab (branch 1).
class ScanTabScreen extends StatelessWidget {
  const ScanTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'FITQ',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.pureWhite,
            letterSpacing: 3,
          ),
        ),
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
                const SizedBox(height: 52),
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
