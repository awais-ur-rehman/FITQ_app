import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class ProfileApi {
  final ApiClient _client;

  const ProfileApi({required ApiClient client}) : _client = client;

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    final res = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.profile,
      data: data,
    );
    return res.data!;
  }

  Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'avatar.jpg',
      ),
    });
    final res = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.profileAvatar,
      data: formData,
    );
    return res.data!;
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.profileChangePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    return res.data!;
  }

  Future<Map<String, dynamic>> getStats() async {
    final res = await _client
        .get<Map<String, dynamic>>(ApiEndpoints.profileStats);
    return res.data!;
  }

  Future<void> deleteAccount() async {
    await _client.delete<Map<String, dynamic>>(ApiEndpoints.profile);
  }
}
