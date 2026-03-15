import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ScoreBadge extends StatelessWidget {
  final double score;
  final double fontSize;

  const ScoreBadge({super.key, required this.score, this.fontSize = 13});

  Color get _color {
    if (score < 4) return AppColors.scoreLow;
    if (score < 7) return AppColors.scoreMid;
    return AppColors.scoreHigh;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        score.toStringAsFixed(1),
        style: AppTextStyles.labelMedium.copyWith(
          color: _color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
