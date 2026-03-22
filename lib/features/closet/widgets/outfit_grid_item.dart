import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/scan_model.dart';
import '../../../shared/widgets/score_badge.dart';

class OutfitGridItem extends StatelessWidget {
  final ScanModel scan;
  final VoidCallback onTap;

  const OutfitGridItem({
    super.key,
    required this.scan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: scan.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surface),
              errorWidget: (_, _, _) => CachedNetworkImage(
                imageUrl: scan.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: AppColors.surface),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),

            // Bottom gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),

            // Score badge
            Positioned(
              bottom: 8,
              right: 8,
              child: ScoreBadge(score: scan.score),
            ),

            // Bookmark indicator
            if (scan.isFavorite)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    size: 14,
                    color: AppColors.neonMint,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
