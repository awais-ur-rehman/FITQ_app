import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../bloc/closet_cubit.dart';
import '../bloc/closet_state.dart';
import '../widgets/outfit_grid_item.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ClosetCubit>();
    if (cubit.state.status == ClosetStatus.initial) {
      cubit.loadScans();
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (_scrollController.offset >= max - 200) {
      context.read<ClosetCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'CLOSET',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.pureWhite,
            letterSpacing: 2,
          ),
        ),
        actions: [
          BlocBuilder<ClosetCubit, ClosetState>(
            buildWhen: (prev, curr) => prev.filter != curr.filter,
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _FilterToggle(
                  current: state.filter,
                  onChanged: (f) => context.read<ClosetCubit>().setFilter(f),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ClosetCubit, ClosetState>(
        builder: (context, state) {
          if (state.status == ClosetStatus.loading && state.scans.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.neonMint,
                strokeWidth: 2,
              ),
            );
          }

          if (state.status == ClosetStatus.failure && state.scans.isEmpty) {
            return _ErrorView(
              onRetry: () => context.read<ClosetCubit>().loadScans(),
            );
          }

          if (state.scans.isEmpty) {
            return _EmptyView(filter: state.filter);
          }

          return RefreshIndicator(
            color: AppColors.neonMint,
            backgroundColor: AppColors.surface,
            onRefresh: () =>
                context.read<ClosetCubit>().loadScans(refresh: true),
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount:
                  state.scans.length + (state.isLoadingMore ? 2 : 0),
              itemBuilder: (context, index) {
                if (index >= state.scans.length) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.neonMint,
                      strokeWidth: 2,
                    ),
                  );
                }
                final scan = state.scans[index];
                return OutfitGridItem(
                  scan: scan,
                  onTap: () => context.push(
                    '/closet/${scan.id}',
                    extra: scan,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  final ClosetFilter current;
  final ValueChanged<ClosetFilter> onChanged;

  const _FilterToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(
            label: 'All',
            active: current == ClosetFilter.all,
            onTap: () => onChanged(ClosetFilter.all),
          ),
          _Pill(
            label: 'Saved',
            active: current == ClosetFilter.favorites,
            onTap: () => onChanged(ClosetFilter.favorites),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.neonMint : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: active ? AppColors.deepCarbon : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final ClosetFilter filter;

  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) {
    final isFavs = filter == ClosetFilter.favorites;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFavs ? Icons.bookmark_border : Icons.checkroom_outlined,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              isFavs ? 'No saved outfits yet' : 'No outfits scanned yet',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isFavs
                  ? 'Bookmark your favorites from the score screen'
                  : 'Snap a photo to see how your outfit rates.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (!isFavs) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => context.push(RouteNames.scanCamera),
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('Take your first scan'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Could not load outfits',
            style:
                AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          TextButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}
