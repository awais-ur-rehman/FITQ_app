import 'package:dio/dio.dart';

import '../../../features/scan/data/scan_api.dart';
import '../../../features/scan/data/scan_repository.dart';
import '../../../models/scan_model.dart';

class ClosetRepository {
  final ScanApi _api;

  const ClosetRepository({required ScanApi api}) : _api = api;

  Future<ScanListResult> getScans({
    int page = 1,
    bool favoritesOnly = false,
  }) async {
    try {
      final json = await _api.getScans(
        page: page,
        favoritesOnly: favoritesOnly,
      );
      final data = json['data'] as Map<String, dynamic>;
      final scansJson = data['scans'] as List<dynamic>;
      final pagination = data['pagination'] as Map<String, dynamic>;
      return ScanListResult(
        scans: scansJson
            .map((s) => ScanModel.fromJson(s as Map<String, dynamic>))
            .toList(),
        hasMore: pagination['hasNext'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw ScanException(_parseError(e));
    }
  }

  Future<ScanModel> toggleFavorite(String id) async {
    try {
      final json = await _api.toggleFavorite(id);
      return ScanModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ScanException(_parseError(e));
    }
  }

  Future<void> deleteScan(String id) async {
    try {
      await _api.deleteScan(id);
    } on DioException catch (e) {
      throw ScanException(_parseError(e));
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
