import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String tag;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.tag,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container — swap for SVG asset later
          Container(
            width: size.width * 0.55,
            height: size.width * 0.55,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 80, color: iconColor),
          ),

          const SizedBox(height: 40),

          // Tag
          Text(
            tag,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.neonMint,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.pureWhite,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
