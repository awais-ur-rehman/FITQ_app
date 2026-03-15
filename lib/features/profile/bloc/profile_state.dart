import 'package:equatable/equatable.dart';

import '../../../models/profile_stats_model.dart';
import '../../../models/user_model.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserModel? user;
  final ProfileStats? stats;
  final bool isSaving;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.stats,
    this.isSaving = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    ProfileStats? stats,
    bool? isSaving,
    String? errorMessage,
  }) =>
      ProfileState(
        status: status ?? this.status,
        user: user ?? this.user,
        stats: stats ?? this.stats,
        isSaving: isSaving ?? this.isSaving,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, user, stats, isSaving, errorMessage];
}
