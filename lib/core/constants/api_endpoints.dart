class ApiEndpoints {
  ApiEndpoints._();

  // Switch to http://10.0.2.2:5000/api/v1 for Android emulator local dev
  static const String baseUrl = 'https://fitq-api.onrender.com/api/v1';

  // Auth
  static const String signup = '/auth/signup';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Scans
  static const String scans = '/scans';
  static String scanById(String id) => '/scans/$id';
  static String scanFavorite(String id) => '/scans/$id/favorite';

  // Profile
  static const String profile = '/profile';
  static const String profileAvatar = '/profile/avatar';
  static const String profileChangePassword = '/profile/change-password';
  static const String profileStats = '/profile/stats';
}
