import 'package:equatable/equatable.dart';

class ScanAnalysis extends Equatable {
  final double colorHarmony;
  final double fitScore;
  final String styleCategory;
  final String seasonMatch;
  final List<String> highlights;
  final List<String> improvements;
  final String oneLiner;
  final String detailedBreakdown;

  const ScanAnalysis({
    required this.colorHarmony,
    required this.fitScore,
    required this.styleCategory,
    required this.seasonMatch,
    required this.highlights,
    required this.improvements,
    required this.oneLiner,
    required this.detailedBreakdown,
  });

  factory ScanAnalysis.fromJson(Map<String, dynamic> json) => ScanAnalysis(
        colorHarmony: (json['colorHarmony'] as num).toDouble(),
        fitScore: (json['fitScore'] as num).toDouble(),
        styleCategory: json['styleCategory'] as String,
        seasonMatch: json['seasonMatch'] as String,
        highlights:
            (json['highlights'] as List<dynamic>).cast<String>(),
        improvements:
            (json['improvements'] as List<dynamic>).cast<String>(),
        oneLiner: json['oneLiner'] as String,
        detailedBreakdown: json['detailedBreakdown'] as String,
      );

  Map<String, dynamic> toJson() => {
        'colorHarmony': colorHarmony,
        'fitScore': fitScore,
        'styleCategory': styleCategory,
        'seasonMatch': seasonMatch,
        'highlights': highlights,
        'improvements': improvements,
        'oneLiner': oneLiner,
        'detailedBreakdown': detailedBreakdown,
      };

  @override
  List<Object?> get props => [
        colorHarmony,
        fitScore,
        styleCategory,
        seasonMatch,
        highlights,
        improvements,
        oneLiner,
        detailedBreakdown,
      ];
}

class ScanModel extends Equatable {
  final String id;
  final String imageUrl;
  final String thumbnailUrl;
  final double score;
  final ScanAnalysis analysis;
  final bool isPublic;
  final bool isFavorite;
  final DateTime createdAt;

  const ScanModel({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.score,
    required this.analysis,
    this.isPublic = false,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) => ScanModel(
        id: json['id'] as String,
        imageUrl: json['imageUrl'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String,
        score: (json['score'] as num).toDouble(),
        analysis:
            ScanAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
        isPublic: json['isPublic'] as bool? ?? false,
        isFavorite: json['isFavorite'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
        'score': score,
        'analysis': analysis.toJson(),
        'isPublic': isPublic,
        'isFavorite': isFavorite,
        'createdAt': createdAt.toIso8601String(),
      };

  ScanModel copyWith({
    String? id,
    String? imageUrl,
    String? thumbnailUrl,
    double? score,
    ScanAnalysis? analysis,
    bool? isPublic,
    bool? isFavorite,
    DateTime? createdAt,
  }) =>
      ScanModel(
        id: id ?? this.id,
        imageUrl: imageUrl ?? this.imageUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        score: score ?? this.score,
        analysis: analysis ?? this.analysis,
        isPublic: isPublic ?? this.isPublic,
        isFavorite: isFavorite ?? this.isFavorite,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        imageUrl,
        thumbnailUrl,
        score,
        analysis,
        isPublic,
        isFavorite,
        createdAt,
      ];
}
