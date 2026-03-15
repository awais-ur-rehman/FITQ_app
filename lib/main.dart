import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'core/storage/prefs_service.dart';
import 'core/utils/connectivity_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final sharedPrefs = await SharedPreferences.getInstance();
  final prefsService = PrefsService(prefs: sharedPrefs);
  final connectivity = ConnectivityService();
  final apiClient = ApiClient(prefs: prefsService, connectivity: connectivity);
  runApp(FITQApp(
    prefsService: prefsService,
    apiClient: apiClient,
    connectivity: connectivity,
  ));
}
