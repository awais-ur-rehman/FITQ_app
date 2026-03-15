import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/profile_stats_model.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    if (context.read<ProfileCubit>().state.stats == null) {
      context.read<ProfileCubit>().loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.pureWhite,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Stats',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.pureWhite),
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (prev, curr) =>
            prev.status != curr.status || prev.stats != curr.stats,
        builder: (context, state) {
          if (state.status == ProfileStatus.loading && state.stats == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.neonMint,
                strokeWidth: 2,
              ),
            );
          }

          if (state.status == ProfileStatus.failure && state.stats == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load stats',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () =>
                        context.read<ProfileCubit>().loadStats(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = state.stats;
          if (stats == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.paddingOf(context).bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview cards
                _OverviewRow(stats: stats),
                const SizedBox(height: 32),

                // Score distribution bar chart
                if (stats.scoreDistribution.isNotEmpty) ...[
                  _ChartHeader(label: 'SCORE DISTRIBUTION'),
                  const SizedBox(height: 16),
                  _ScoreDistributionChart(data: stats.scoreDistribution),
                  const SizedBox(height: 32),
                ],

                // Monthly activity line chart
                if (stats.monthlyData.isNotEmpty) ...[
                  _ChartHeader(label: 'MONTHLY ACTIVITY'),
                  const SizedBox(height: 16),
                  _MonthlyLineChart(data: stats.monthlyData),
                  const SizedBox(height: 32),
                ],

                // Style breakdown pie chart
                if (stats.styleDistribution.isNotEmpty) ...[
                  _ChartHeader(label: 'STYLE BREAKDOWN'),
                  const SizedBox(height: 16),
                  _StylePieChart(data: stats.styleDistribution),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  final String label;

  const _ChartHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 2,
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final ProfileStats stats;

  const _OverviewRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniStat(
          label: 'Total Scans',
          value: stats.totalScans.toString(),
          color: AppColors.neonMint,
        ),
        const SizedBox(width: 10),
        _MiniStat(
          label: 'Avg Score',
          value: stats.averageScore.toStringAsFixed(1),
          color: _scoreColor(stats.averageScore),
        ),
        const SizedBox(width: 10),
        _MiniStat(
          label: 'Best',
          value: stats.highestScore.toStringAsFixed(1),
          color: AppColors.scoreHigh,
        ),
      ],
    );
  }

  Color _scoreColor(double s) {
    if (s < 4) return AppColors.scoreLow;
    if (s < 7) return AppColors.scoreMid;
    return AppColors.scoreHigh;
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style:
                  AppTextStyles.titleLarge.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreDistributionChart extends StatelessWidget {
  final List<ScoreRangeData> data;

  const _ScoreDistributionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.scoreLow, AppColors.scoreMid, AppColors.scoreHigh];

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data
                  .map((d) => d.count.toDouble())
                  .fold(0.0, (a, b) => a > b ? a : b) *
              1.3,
          barGroups: List.generate(data.length, (i) {
            final color = i < colors.length
                ? colors[i]
                : AppColors.neonMint;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].count.toDouble(),
                  color: color,
                  width: 28,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[idx].range,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _MonthlyLineChart extends StatelessWidget {
  final List<MonthlyData> data;

  const _MonthlyLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.count.toDouble()))
        .toList();

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.neonMint,
              barWidth: 2.5,
              dotData: FlDotData(
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.neonMint,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.neonMint.withValues(alpha: 0.08),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (data.length / 4).ceilToDouble(),
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[idx].month,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _StylePieChart extends StatelessWidget {
  final List<StyleData> data;

  const _StylePieChart({required this.data});

  static const _pieColors = [
    AppColors.neonMint,
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
  ];

  @override
  Widget build(BuildContext context) {
    final total = data.fold(0, (sum, d) => sum + d.count);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: List.generate(data.length, (i) {
                  final color = _pieColors[i % _pieColors.length];
                  final pct = total > 0
                      ? (data[i].count / total * 100).round()
                      : 0;
                  return PieChartSectionData(
                    value: data[i].count.toDouble(),
                    color: color,
                    radius: 28,
                    title: '$pct%',
                    titleStyle: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.deepCarbon,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(data.length, (i) {
                final color = _pieColors[i % _pieColors.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data[i].style,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${data[i].count}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
