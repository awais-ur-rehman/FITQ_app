import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class AuthApi {
  final ApiClient _client;

  const AuthApi({required ApiClient client}) : _client = client;

  Future<Map<String, dynamic>> signup({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.signup,
      data: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      },
    );
    return res.data!;
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.verifyOtp,
      data: {'email': email, 'otp': otp},
    );
    return res.data!;
  }

  Future<void> resendOtp({required String email}) async {
    await _client.post<Map<String, dynamic>>(
      ApiEndpoints.resendOtp,
      data: {'email': email},
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return res.data!;
  }

  Future<void> forgotPassword({required String email}) async {
    await _client.post<Map<String, dynamic>>(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _client.post<Map<String, dynamic>>(
      ApiEndpoints.resetPassword,
      data: {'email': email, 'otp': otp, 'newPassword': newPassword},
    );
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _client.get<Map<String, dynamic>>(ApiEndpoints.me);
    return res.data!;
  }

  Future<void> logout() async {
    await _client.post<Map<String, dynamic>>(ApiEndpoints.logout);
  }
}
