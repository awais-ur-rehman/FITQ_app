import 'package:equatable/equatable.dart';

class UserStreak extends Equatable {
  final int current;
  final int longest;
  final DateTime? lastScanDate;

  const UserStreak({
    this.current = 0,
    this.longest = 0,
    this.lastScanDate,
  });

  factory UserStreak.fromJson(Map<String, dynamic> json) => UserStreak(
        current: json['current'] as int? ?? 0,
        longest: json['longest'] as int? ?? 0,
        lastScanDate: json['lastScanDate'] != null
            ? DateTime.parse(json['lastScanDate'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'current': current,
        'longest': longest,
        'lastScanDate': lastScanDate?.toIso8601String(),
      };

  @override
  List<Object?> get props => [current, longest, lastScanDate];
}

class UserStats extends Equatable {
  final int totalScans;
  final double averageScore;
  final double highestScore;
  final String? favoriteStyle;

  const UserStats({
    this.totalScans = 0,
    this.averageScore = 0,
    this.highestScore = 0,
    this.favoriteStyle,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        totalScans: json['totalScans'] as int? ?? 0,
        averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0,
        highestScore: (json['highestScore'] as num?)?.toDouble() ?? 0,
        favoriteStyle: json['favoriteStyle'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'totalScans': totalScans,
        'averageScore': averageScore,
        'highestScore': highestScore,
        'favoriteStyle': favoriteStyle,
      };

  @override
  List<Object?> get props =>
      [totalScans, averageScore, highestScore, favoriteStyle];
}

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String username;
  final String? avatarUrl;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? stylePreference;
  final String? bio;
  final bool isVerified;
  final bool isPro;
  final UserStreak streak;
  final UserStats stats;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.stylePreference,
    this.bio,
    this.isVerified = false,
    this.isPro = false,
    this.streak = const UserStreak(),
    this.stats = const UserStats(),
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        username: json['username'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        gender: json['gender'] as String?,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.parse(json['dateOfBirth'] as String)
            : null,
        stylePreference: json['stylePreference'] as String?,
        bio: json['bio'] as String?,
        isVerified: json['isVerified'] as bool? ?? false,
        isPro: json['isPro'] as bool? ?? false,
        streak: json['streak'] != null
            ? UserStreak.fromJson(json['streak'] as Map<String, dynamic>)
            : const UserStreak(),
        stats: json['stats'] != null
            ? UserStats.fromJson(json['stats'] as Map<String, dynamic>)
            : const UserStats(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'username': username,
        'avatarUrl': avatarUrl,
        'gender': gender,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'stylePreference': stylePreference,
        'bio': bio,
        'isVerified': isVerified,
        'isPro': isPro,
        'streak': streak.toJson(),
        'stats': stats.toJson(),
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? username,
    String? avatarUrl,
    String? gender,
    DateTime? dateOfBirth,
    String? stylePreference,
    String? bio,
    bool? isVerified,
    bool? isPro,
    UserStreak? streak,
    UserStats? stats,
  }) =>
      UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        username: username ?? this.username,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        stylePreference: stylePreference ?? this.stylePreference,
        bio: bio ?? this.bio,
        isVerified: isVerified ?? this.isVerified,
        isPro: isPro ?? this.isPro,
        streak: streak ?? this.streak,
        stats: stats ?? this.stats,
      );

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        username,
        avatarUrl,
        gender,
        dateOfBirth,
        stylePreference,
        bio,
        isVerified,
        isPro,
        streak,
        stats,
      ];
}
