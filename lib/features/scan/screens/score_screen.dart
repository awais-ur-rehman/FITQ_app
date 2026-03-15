import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/share/services/share_card_generator.dart';
import '../../../models/scan_model.dart';
import '../../../shared/widgets/style_tag.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import '../widgets/analysis_section.dart';
import '../widgets/score_ring.dart';
import '../widgets/stat_bar.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScanBloc, ScanState>(
      buildWhen: (prev, curr) => curr.currentScan != prev.currentScan,
      builder: (context, state) {
        final scan = state.currentScan;
        if (scan == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'No scan found',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        return _ScoreView(scan: scan);
      },
    );
  }
}

class _ScoreView extends StatelessWidget {
  final ScanModel scan;

  const _ScoreView({required this.scan});

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
          onPressed: () => context.go(RouteNames.home),
        ),
        actions: [
          IconButton(
            icon: BlocBuilder<ScanBloc, ScanState>(
              buildWhen: (prev, curr) =>
                  curr.currentScan?.isFavorite !=
                  prev.currentScan?.isFavorite,
              builder: (context, state) {
                final fav = state.currentScan?.isFavorite ?? false;
                return Icon(
                  fav ? Icons.bookmark : Icons.bookmark_border,
                  color: fav ? AppColors.neonMint : AppColors.pureWhite,
                );
              },
            ),
            onPressed: () =>
                context.read<ScanBloc>().add(ScanFavoriteToggled(scan.id)),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────
          SingleChildScrollView(
            child: Column(
              children: [
                // ── Hero image + ring ─────────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Outfit photo
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

                    // Gradient fade to background
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

                    // Score ring — overlapping at bottom center
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

                // Spacer for ring overlap
                const SizedBox(height: 100),

                // ── Body content ──────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Style + Season pills
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
                          .fadeIn(delay: 400.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 28),

                      // ── Stat bars ─────────────────────
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
                          .fadeIn(delay: 600.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 32),

                      // ── Analysis section ─────────────────
                      AnalysisSection(
                        highlights: scan.analysis.highlights,
                        improvements: scan.analysis.improvements,
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 32),

                      // ── Quote card ───────────────────────
                      _QuoteCard(quote: scan.analysis.oneLiner)
                          .animate()
                          .fadeIn(delay: 1000.ms, duration: 400.ms),

                      // Spacer for bottom action bar
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed bottom action bar ─────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomActions(scan: scan, bottomPad: bottomPad),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────

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

class _BottomActions extends StatelessWidget {
  final ScanModel scan;
  final double bottomPad;

  const _BottomActions({required this.scan, required this.bottomPad});

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
          // Share
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

          // Save to Closet (toggle favorite)
          BlocBuilder<ScanBloc, ScanState>(
            buildWhen: (prev, curr) =>
                curr.currentScan?.isFavorite != prev.currentScan?.isFavorite,
            builder: (context, state) {
              final isFav = state.currentScan?.isFavorite ?? false;
              return _ActionBtn(
                icon: isFav ? Icons.bookmark : Icons.bookmark_border,
                label: isFav ? 'Saved' : 'Save',
                accent: isFav,
                onTap: () => context
                    .read<ScanBloc>()
                    .add(ScanFavoriteToggled(scan.id)),
              );
            },
          ),

          const SizedBox(width: 10),

          // Scan Again
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.scanCamera),
              icon: const Icon(Icons.camera_alt_outlined, size: 16),
              label: const Text('Scan Again'),
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
    final border = accent ? AppColors.neonMint.withValues(alpha: 0.3) : AppColors.border;

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
