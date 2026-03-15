import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const ColoredBox(
            color: Color(0x88000000),
            child: Center(
              child: _Spinner(),
            ),
          ),
      ],
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const CircularProgressIndicator(
        color: AppColors.neonMint,
        strokeWidth: 2.5,
      ),
    );
  }
}
