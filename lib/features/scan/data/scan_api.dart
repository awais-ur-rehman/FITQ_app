import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class ScanApi {
  final ApiClient _client;

  const ScanApi({required ApiClient client}) : _client = client;

  Future<Map<String, dynamic>> uploadScan(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'outfit.jpg',
      ),
    });
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.scans,
      data: formData,
    );
    return res.data!;
  }

  Future<Map<String, dynamic>> getScans({
    int page = 1,
    int limit = 20,
    bool favoritesOnly = false,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (favoritesOnly) params['favorites'] = 'true';
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.scans,
      queryParameters: params,
    );
    return res.data!;
  }

  Future<Map<String, dynamic>> getScanById(String id) async {
    final res =
        await _client.get<Map<String, dynamic>>(ApiEndpoints.scanById(id));
    return res.data!;
  }

  Future<Map<String, dynamic>> toggleFavorite(String id) async {
    final res = await _client
        .patch<Map<String, dynamic>>(ApiEndpoints.scanFavorite(id));
    return res.data!;
  }

  Future<void> deleteScan(String id) async {
    await _client.delete<Map<String, dynamic>>(ApiEndpoints.scanById(id));
  }
}
