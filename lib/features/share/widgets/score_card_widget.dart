import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/scan_model.dart';
import '../../../shared/widgets/style_tag.dart';

/// Rendered offscreen via screenshot package to produce a shareable PNG.
/// Fixed 400px wide — do not use MediaQuery inside.
class ScoreCardWidget extends StatelessWidget {
  final ScanModel scan;
  final String username;

  const ScoreCardWidget({
    super.key,
    required this.scan,
    required this.username,
  });

  Color get _scoreColor {
    if (scan.score < 4) return AppColors.scoreLow;
    if (scan.score < 7) return AppColors.scoreMid;
    return AppColors.scoreHigh;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Outfit photo ─────────────────────────────
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: scan.imageUrl,
                width: 400,
                height: 460,
                fit: BoxFit.cover,
              ),
              // Bottom gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 120,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.background.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),
              // Score badge overlaid on image bottom-right
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _scoreColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    scan.score.toStringAsFixed(1),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.deepCarbon,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Content ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FITQ brand row
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.neonMint,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'FQ',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepCarbon,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'FITQ',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.pureWhite,
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'fitq.app',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Quote
                Text(
                  '"${scan.analysis.oneLiner}"',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.pureWhite,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 14),

                // Tags + username
                Row(
                  children: [
                    StyleTag(label: scan.analysis.styleCategory, filled: true),
                    const SizedBox(width: 8),
                    StyleTag(label: scan.analysis.seasonMatch),
                    const Spacer(),
                    Text(
                      '@$username',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
