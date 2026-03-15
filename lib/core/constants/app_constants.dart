class AppConstants {
  AppConstants._();

  // App
  static const String appName = 'FITQ';
  static const String appVersion = '1.0.0';

  // Scan limits
  static const int dailyScanLimitFree = 3;
  static const int dailyScanLimitPro = 100;

  // OTP
  static const int otpLength = 6;
  static const int otpExpirySeconds = 300;
  static const int otpResendCooldownSeconds = 60;
  static const int otpMaxAttempts = 3;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Upload constraints
  static const int maxImageSizeMb = 5;
  static const int maxAvatarSizeMb = 2;
  static const int imageMaxDimension = 1024;
  static const int imageJpegQuality = 85;

  // Hive box names
  static const String scansCacheBox = 'scans_cache';
  static const String userCacheBox = 'user_cache';

  // SharedPreferences keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user';
  static const String keyOnboardingSeen = 'onboarding_seen';
}
