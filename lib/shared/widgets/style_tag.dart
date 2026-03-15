import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class StyleTag extends StatelessWidget {
  final String label;
  final Color? color;
  final bool filled;

  const StyleTag({
    super.key,
    required this.label,
    this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final tagColor = color ?? AppColors.neonMint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: filled
            ? tagColor.withValues(alpha: 0.15)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: filled ? tagColor.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: filled ? tagColor : AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
