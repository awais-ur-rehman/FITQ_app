import 'package:flutter/foundation.dart';

class ConnectivityService {
  final isOnline = ValueNotifier<bool>(true);

  void reportOffline() {
    if (isOnline.value) isOnline.value = false;
  }

  void reportOnline() {
    if (!isOnline.value) isOnline.value = true;
  }

  void dispose() => isOnline.dispose();
}
