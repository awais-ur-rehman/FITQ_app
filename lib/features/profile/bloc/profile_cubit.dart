import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../data/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;
  final AuthBloc _authBloc;

  ProfileCubit({
    required ProfileRepository repo,
    required AuthBloc authBloc,
  })  : _repo = repo,
        _authBloc = authBloc,
        super(const ProfileState());

  void loadUser() {
    final user = _authBloc.state.user;
    if (user != null) {
      emit(state.copyWith(user: user, status: ProfileStatus.success));
    }
  }

  Future<void> loadStats() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final stats = await _repo.getStats();
      emit(state.copyWith(status: ProfileStatus.success, stats: stats));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? gender,
    String? stylePreference,
  }) async {
    emit(state.copyWith(isSaving: true));
    try {
      final updated = await _repo.updateProfile(
        name: name,
        username: username,
        bio: bio,
        gender: gender,
        stylePreference: stylePreference,
      );
      _authBloc.add(ProfileUpdated(updated));
      emit(state.copyWith(isSaving: false, user: updated));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<void> uploadAvatar(File imageFile) async {
    emit(state.copyWith(isSaving: true));
    try {
      final updated = await _repo.uploadAvatar(imageFile);
      _authBloc.add(ProfileUpdated(updated));
      emit(state.copyWith(isSaving: false, user: updated));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(state.copyWith(isSaving: true));
    try {
      await _repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(state.copyWith(isSaving: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
      return false;
    }
  }

  Future<void> deleteAccount() async {
    emit(state.copyWith(isSaving: true));
    try {
      await _repo.deleteAccount();
      emit(state.copyWith(isSaving: false));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }
}
