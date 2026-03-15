import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class PrefsService {
  final SharedPreferences _prefs;

  const PrefsService({required SharedPreferences prefs}) : _prefs = prefs;

  // ─── Tokens ──────────────────────────────────────────────────

  String? getAccessToken() => _prefs.getString(AppConstants.keyAccessToken);

  String? getRefreshToken() => _prefs.getString(AppConstants.keyRefreshToken);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) =>
      Future.wait([
        _prefs.setString(AppConstants.keyAccessToken, accessToken),
        _prefs.setString(AppConstants.keyRefreshToken, refreshToken),
      ]);

  // ─── User ─────────────────────────────────────────────────────

  String? getUser() => _prefs.getString(AppConstants.keyUser);

  Future<void> saveUser(String userJson) =>
      _prefs.setString(AppConstants.keyUser, userJson);

  // ─── Onboarding ───────────────────────────────────────────────

  bool isOnboardingSeen() =>
      _prefs.getBool(AppConstants.keyOnboardingSeen) ?? false;

  Future<void> setOnboardingSeen() =>
      _prefs.setBool(AppConstants.keyOnboardingSeen, true);

  // ─── Clear ────────────────────────────────────────────────────

  Future<void> clearAll() => _prefs.clear();
}
