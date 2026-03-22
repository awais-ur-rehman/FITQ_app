import 'dart:io';

import 'package:dio/dio.dart';

import '../../../models/scan_model.dart';
import 'scan_api.dart';

class ScanException implements Exception {
  final String message;
  final int? statusCode;

  const ScanException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ScanListResult {
  final List<ScanModel> scans;
  final bool hasMore;

  const ScanListResult({required this.scans, required this.hasMore});
}

class ScanRepository {
  final ScanApi _api;

  const ScanRepository({required ScanApi api}) : _api = api;

  Future<ScanModel> uploadScan(File imageFile) async {
    try {
      final json = await _api.uploadScan(imageFile);
      final data = json['data'] as Map<String, dynamic>;
      return ScanModel.fromJson(data['scan'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ScanException(_parseError(e), statusCode: e.response?.statusCode);
    } catch (e) {
      throw ScanException(e.toString());
    }
  }

  Future<ScanListResult> getScans({int page = 1}) async {
    try {
      final json = await _api.getScans(page: page);
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
      throw ScanException(_parseError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<ScanModel> getScanById(String id) async {
    try {
      final json = await _api.getScanById(id);
      return ScanModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ScanException(_parseError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<ScanModel> toggleFavorite(String id) async {
    try {
      final json = await _api.toggleFavorite(id);
      return ScanModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ScanException(_parseError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> deleteScan(String id) async {
    try {
      await _api.deleteScan(id);
    } on DioException catch (e) {
      throw ScanException(_parseError(e), statusCode: e.response?.statusCode);
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? 'An error occurred';
    }
    if (e.response?.statusCode == 429) {
      return 'Daily scan limit reached. Upgrade to Pro for unlimited scans.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    return 'Network error. Please check your connection.';
  }
}
