import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/prefs_service.dart';

class ApiClient {
  late final Dio _dio;
  final PrefsService _prefs;

  ApiClient({required PrefsService prefs}) : _prefs = prefs {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final retryOptions = error.requestOptions
                ..headers['Authorization'] =
                    'Bearer ${_prefs.getAccessToken()}';
              try {
                final retryResponse = await _dio.fetch<dynamic>(retryOptions);
                return handler.resolve(retryResponse);
              } on DioException catch (e) {
                return handler.reject(e);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = _prefs.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.refresh}',
        data: {'refreshToken': refreshToken},
      );

      final data = (response.data?['data'] as Map<String, dynamic>?) ?? {};
      await _prefs.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      await _prefs.clearAll();
      return false;
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {Object? data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> patch<T>(String path, {Object? data}) =>
      _dio.patch<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}
