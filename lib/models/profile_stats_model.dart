import 'package:equatable/equatable.dart';

class MonthlyData extends Equatable {
  final String month;
  final int count;
  final double avgScore;

  const MonthlyData({
    required this.month,
    required this.count,
    required this.avgScore,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) => MonthlyData(
        month: json['month'] as String? ?? '',
        count: json['count'] as int? ?? 0,
        avgScore: (json['avgScore'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [month, count, avgScore];
}

class StyleData extends Equatable {
  final String style;
  final int count;

  const StyleData({required this.style, required this.count});

  factory StyleData.fromJson(Map<String, dynamic> json) => StyleData(
        style: json['style'] as String? ?? '',
        count: json['count'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [style, count];
}

class ScoreRangeData extends Equatable {
  final String range;
  final int count;

  const ScoreRangeData({required this.range, required this.count});

  factory ScoreRangeData.fromJson(Map<String, dynamic> json) => ScoreRangeData(
        range: json['range'] as String? ?? '',
        count: json['count'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [range, count];
}

class ProfileStats extends Equatable {
  final int totalScans;
  final double averageScore;
  final double highestScore;
  final int currentStreak;
  final int longestStreak;
  final String? favoriteStyle;
  final List<MonthlyData> monthlyData;
  final List<StyleData> styleDistribution;
  final List<ScoreRangeData> scoreDistribution;

  const ProfileStats({
    this.totalScans = 0,
    this.averageScore = 0,
    this.highestScore = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.favoriteStyle,
    this.monthlyData = const [],
    this.styleDistribution = const [],
    this.scoreDistribution = const [],
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) => ProfileStats(
        totalScans: json['totalScans'] as int? ?? 0,
        averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0,
        highestScore: (json['highestScore'] as num?)?.toDouble() ?? 0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        favoriteStyle: json['favoriteStyle'] as String?,
        monthlyData: (json['monthlyData'] as List<dynamic>? ?? [])
            .map((e) => MonthlyData.fromJson(e as Map<String, dynamic>))
            .toList(),
        styleDistribution:
            (json['styleDistribution'] as List<dynamic>? ?? [])
                .map((e) => StyleData.fromJson(e as Map<String, dynamic>))
                .toList(),
        scoreDistribution:
            (json['scoreDistribution'] as List<dynamic>? ?? [])
                .map((e) =>
                    ScoreRangeData.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  @override
  List<Object?> get props => [
        totalScans,
        averageScore,
        highestScore,
        currentStreak,
        longestStreak,
        favoriteStyle,
        monthlyData,
        styleDistribution,
        scoreDistribution,
      ];
}
