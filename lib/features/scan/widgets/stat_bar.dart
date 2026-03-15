import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StatBar extends StatelessWidget {
  final String label;
  final double value; // 0–10
  final Duration delay;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    this.delay = Duration.zero,
  });

  Color get _barColor {
    if (value < 4) return AppColors.scoreLow;
    if (value < 7) return AppColors.scoreMid;
    return AppColors.scoreHigh;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: AppTextStyles.labelSmall.copyWith(
                color: _barColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Track
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Bar
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / 10),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, progress, _) => FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _barColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
