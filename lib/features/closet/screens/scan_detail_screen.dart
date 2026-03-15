import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/share/services/share_card_generator.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../models/scan_model.dart';
import '../../../shared/widgets/style_tag.dart';
import '../../scan/widgets/analysis_section.dart';
import '../../scan/widgets/score_ring.dart';
import '../../scan/widgets/stat_bar.dart';
import '../bloc/closet_cubit.dart';
import '../bloc/closet_state.dart';

class ScanDetailScreen extends StatelessWidget {
  final String scanId;
  final ScanModel? initialScan;

  const ScanDetailScreen({
    super.key,
    required this.scanId,
    this.initialScan,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClosetCubit, ClosetState>(
      buildWhen: (prev, curr) =>
          prev.scans != curr.scans,
      builder: (context, state) {
        final scan = state.scans.where((s) => s.id == scanId).firstOrNull ??
            initialScan;
        if (scan == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.neonMint,
                strokeWidth: 2,
              ),
            ),
          );
        }
        return _DetailView(scan: scan);
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  final ScanModel scan;

  const _DetailView({required this.scan});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final imgHeight = size.height * 0.48;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.pureWhite,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          BlocBuilder<ClosetCubit, ClosetState>(
            buildWhen: (prev, curr) => prev.scans != curr.scans,
            builder: (context, state) {
              final fav =
                  state.scans.where((s) => s.id == scan.id).firstOrNull?.isFavorite ??
                      scan.isFavorite;
              return IconButton(
                icon: Icon(
                  fav ? Icons.bookmark : Icons.bookmark_border,
                  color: fav ? AppColors.neonMint : AppColors.pureWhite,
                ),
                onPressed: () =>
                    context.read<ClosetCubit>().toggleFavorite(scan.id),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Hero image + ring
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: imgHeight,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: scan.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: AppColors.surface,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.neonMint,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: imgHeight * 0.55,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.6),
                              AppColors.background,
                            ],
                            stops: const [0.0, 0.65, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ScoreRing(score: scan.score, size: 160),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 100),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StyleTag(
                            label: scan.analysis.styleCategory,
                            filled: true,
                          ),
                          const SizedBox(width: 8),
                          StyleTag(label: scan.analysis.seasonMatch),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 28),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BREAKDOWN',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 14),
                          StatBar(
                            label: 'Color Harmony',
                            value: scan.analysis.colorHarmony,
                          ),
                          const SizedBox(height: 14),
                          StatBar(
                            label: 'Fit Score',
                            value: scan.analysis.fitScore,
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 32),

                      AnalysisSection(
                        highlights: scan.analysis.highlights,
                        improvements: scan.analysis.improvements,
                      )
                          .animate()
                          .fadeIn(delay: 700.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 32),

                      _QuoteCard(quote: scan.analysis.oneLiner)
                          .animate()
                          .fadeIn(delay: 900.ms, duration: 400.ms),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(scan: scan, bottomPad: bottomPad),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String quote;

  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\u201C',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 48,
              color: AppColors.neonMint,
              height: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            quote,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.pureWhite,
              fontStyle: FontStyle.italic,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final ScanModel scan;
  final double bottomPad;

  const _BottomBar({required this.scan, required this.bottomPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _ActionBtn(
            icon: Icons.ios_share_rounded,
            label: 'Share',
            onTap: () {
              final username =
                  context.read<AuthBloc>().state.user?.username ?? 'fitq_user';
              ShareCardGenerator.shareScore(
                context: context,
                scan: scan,
                username: username,
              );
            },
          ),
          const SizedBox(width: 10),
          BlocBuilder<ClosetCubit, ClosetState>(
            buildWhen: (prev, curr) => prev.scans != curr.scans,
            builder: (context, state) {
              final isFav =
                  state.scans.where((s) => s.id == scan.id).firstOrNull?.isFavorite ??
                      scan.isFavorite;
              return _ActionBtn(
                icon: isFav ? Icons.bookmark : Icons.bookmark_border,
                label: isFav ? 'Saved' : 'Save',
                accent: isFav,
                onTap: () =>
                    context.read<ClosetCubit>().toggleFavorite(scan.id),
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionBtn(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              onTap: () => _confirmDelete(context),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete outfit?',
          style: AppTextStyles.titleMedium
              .copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will permanently remove this scan.',
          style:
              AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ClosetCubit>().deleteScan(scan.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = accent ? AppColors.neonMint : AppColors.textPrimary;
    final bg = accent
        ? AppColors.neonMint.withValues(alpha: 0.1)
        : AppColors.surfaceVariant;
    final border =
        accent ? AppColors.neonMint.withValues(alpha: 0.3) : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
