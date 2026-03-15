import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>();
    cubit.loadUser();
    if (cubit.state.stats == null) cubit.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final user =
              state.user ?? context.read<AuthBloc>().state.user;
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.neonMint,
                strokeWidth: 2,
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.background,
                expandedHeight: 200,
                pinned: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    color: AppColors.pureWhite,
                    onPressed: () => context.push(RouteNames.settings),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProfileHeader(
                    avatarUrl: user.avatarUrl,
                    name: user.name,
                    username: user.username,
                    bio: user.bio,
                    isPro: user.isPro,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Edit profile button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.push(RouteNames.editProfile),
                          child: const Text('Edit Profile'),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Stats row
                      _StatsRow(
                        totalScans: user.stats.totalScans,
                        avgScore: user.stats.averageScore,
                        streak: user.streak.current,
                        highest: user.stats.highestScore,
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideY(begin: 0.15, end: 0),

                      const SizedBox(height: 28),

                      // Streak card
                      _StreakCard(
                        current: user.streak.current,
                        longest: user.streak.longest,
                      )
                          .animate()
                          .fadeIn(delay: 350.ms, duration: 400.ms),

                      const SizedBox(height: 28),

                      // Detailed stats link
                      _SectionHeader(
                        label: 'STYLE INSIGHTS',
                        actionLabel: user.stats.totalScans > 0
                            ? 'See all stats'
                            : null,
                        onAction: () => context.push(RouteNames.stats),
                      ),
                      const SizedBox(height: 12),

                      if (user.stats.totalScans == 0)
                        _NoStatsView()
                      else if (state.stats != null) ...[
                        if (state.stats!.favoriteStyle != null)
                          _InsightTile(
                            icon: Icons.style_outlined,
                            label: 'Favorite Style',
                            value: state.stats!.favoriteStyle!,
                          ),
                        const SizedBox(height: 8),
                        _InsightTile(
                          icon: Icons.emoji_events_outlined,
                          label: 'Highest Score',
                          value: state.stats!.highestScore.toStringAsFixed(1),
                        ),
                      ] else if (state.status == ProfileStatus.loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              color: AppColors.neonMint,
                              strokeWidth: 2,
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final String username;
  final String? bio;
  final bool isPro;

  const _ProfileHeader({
    required this.avatarUrl,
    required this.name,
    required this.username,
    this.bio,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 56,
        20,
        16,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
              color: AppColors.surface,
            ),
            child: ClipOval(
              child: avatarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: AppColors.surfaceVariant),
                      errorWidget: (_, _, _) => const Icon(
                        Icons.person_outline,
                        color: AppColors.textMuted,
                        size: 32,
                      ),
                    )
                  : const Icon(
                      Icons.person_outline,
                      color: AppColors.textMuted,
                      size: 32,
                    ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: AppColors.pureWhite),
                    ),
                    if (isPro) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.neonMint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PRO',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.deepCarbon,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '@$username',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                if (bio != null && bio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      bio!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalScans;
  final double avgScore;
  final int streak;
  final double highest;

  const _StatsRow({
    required this.totalScans,
    required this.avgScore,
    required this.streak,
    required this.highest,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Scans', value: totalScans.toString()),
        const SizedBox(width: 10),
        _StatCard(
            label: 'Avg Score', value: avgScore.toStringAsFixed(1)),
        const SizedBox(width: 10),
        _StatCard(label: 'Streak', value: '${streak}d'),
        const SizedBox(width: 10),
        _StatCard(label: 'Best', value: highest.toStringAsFixed(1)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.neonMint,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int current;
  final int longest;

  const _StreakCard({required this.current, required this.longest});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neonMint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$current day streak',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.pureWhite),
                ),
                Text(
                  'Longest: ${longest}d',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (current >= longest && current > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.neonMint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.neonMint.withValues(alpha: 0.3)),
              ),
              child: Text(
                'PB',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.neonMint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.label,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.neonMint,
              ),
            ),
          ),
      ],
    );
  }
}

class _NoStatsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.bar_chart_outlined,
            size: 36,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          Text(
            'No stats yet',
            style: AppTextStyles.titleSmall
                .copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Scan your first outfit to see insights here.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InsightTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.titleSmall
                .copyWith(color: AppColors.pureWhite),
          ),
        ],
      ),
    );
  }
}
