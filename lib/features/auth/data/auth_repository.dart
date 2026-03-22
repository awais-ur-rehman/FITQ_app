import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/storage/prefs_service.dart';
import '../../../models/user_model.dart';
import 'auth_api.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthRepository {
  final AuthApi _api;
  final PrefsService _prefs;

  const AuthRepository({
    required AuthApi api,
    required PrefsService prefs,
  })  : _api = api,
        _prefs = prefs;

  /// Returns null if no local token, throws [AuthException] on API error.
  Future<UserModel?> restoreSession() async {
    if (_prefs.getAccessToken() == null) return null;
    try {
      return await getMe();
    } catch (_) {
      await _prefs.clearAll();
      return null;
    }
  }

  Future<void> signup({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _api.signup(
        name: name,
        username: username,
        email: email,
        password: password,
      );
    } on DioException catch (e) {
      throw AuthException(_parseError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<UserModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final json = await _api.verifyOtp(email: email, otp: otp);
      final data = json['data'] as Map<String, dynamic>;
      await _prefs.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _prefs.saveUser(jsonEncode(user.toJson()));
      return user;
    } on DioException catch (e) {
      throw AuthException(_parseError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> resendOtp({required String email}) async {
    try {
      await _api.resendOtp(email: email);
    } on DioException catch (e) {
      throw AuthException(_parseError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final json = await _api.login(email: email, password: password);
      final data = json['data'] as Map<String, dynamic>;
      await _prefs.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _prefs.saveUser(jsonEncode(user.toJson()));
      return user;
    } on DioException catch (e) {
      throw AuthException(_parseError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _api.forgotPassword(email: email);
    } on DioException catch (e) {
      throw AuthException(_parseError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _api.resetPassword(email: email, otp: otp, newPassword: newPassword);
      await _prefs.clearAll();
    } on DioException catch (e) {
      throw AuthException(_parseError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final json = await _api.getMe();
      final data = json['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _prefs.saveUser(jsonEncode(user.toJson()));
      return user;
    } on DioException catch (e) {
      throw AuthException(_parseError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Best-effort logout; always clear local data
    } finally {
      await _prefs.clearAll();
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
