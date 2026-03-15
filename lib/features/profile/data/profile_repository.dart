import 'dart:io';

import 'package:dio/dio.dart';

import '../../../models/profile_stats_model.dart';
import '../../../models/user_model.dart';
import 'profile_api.dart';

class ProfileException implements Exception {
  final String message;
  final int? statusCode;

  const ProfileException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ProfileRepository {
  final ProfileApi _api;

  const ProfileRepository({required ProfileApi api}) : _api = api;

  Future<UserModel> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? gender,
    String? stylePreference,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (username != null) data['username'] = username;
      if (bio != null) data['bio'] = bio;
      if (gender != null) data['gender'] = gender;
      if (stylePreference != null) data['stylePreference'] = stylePreference;
      final json = await _api.updateProfile(data);
      return UserModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ProfileException(_parseError(e),
          statusCode: e.response?.statusCode);
    }
  }

  Future<UserModel> uploadAvatar(File imageFile) async {
    try {
      final json = await _api.uploadAvatar(imageFile);
      return UserModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ProfileException(_parseError(e),
          statusCode: e.response?.statusCode);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on DioException catch (e) {
      throw ProfileException(_parseError(e),
          statusCode: e.response?.statusCode);
    }
  }

  Future<ProfileStats> getStats() async {
    try {
      final json = await _api.getStats();
      return ProfileStats.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ProfileException(_parseError(e),
          statusCode: e.response?.statusCode);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _api.deleteAccount();
    } on DioException catch (e) {
      throw ProfileException(_parseError(e),
          statusCode: e.response?.statusCode);
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? 'An error occurred';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    return 'Network error. Please check your connection.';
  }
}
