import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AnalysisSection extends StatelessWidget {
  final List<String> highlights;
  final List<String> improvements;

  const AnalysisSection({
    super.key,
    required this.highlights,
    required this.improvements,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (highlights.isNotEmpty) ...[
          _SectionHeader(title: 'HIGHLIGHTS', color: AppColors.scoreHigh),
          const SizedBox(height: 12),
          ...highlights.map(
            (h) => _AnalysisItem(
              text: h,
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.scoreHigh,
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (improvements.isNotEmpty) ...[
          _SectionHeader(title: 'LEVEL UP', color: AppColors.scoreMid),
          const SizedBox(height: 12),
          ...improvements.map(
            (i) => _AnalysisItem(
              text: i,
              icon: Icons.lightbulb_outline_rounded,
              color: AppColors.scoreMid,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _AnalysisItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _AnalysisItem({
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
