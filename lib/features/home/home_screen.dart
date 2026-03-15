import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';

/// Placeholder — will be replaced in the scan/home module phase.
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
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Home — coming soon',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
