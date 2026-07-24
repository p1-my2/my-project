import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Set this for a real phone using `--dart-define=API_BASE_URL=http://PC-IP:5000/api`.
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    // Flutter Web (Chrome)
    if (kIsWeb) {
      return "http://localhost:5000/api";
    }

    // Android Emulator. A real phone must provide API_BASE_URL when launched.
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5000/api";
    }

    // Windows Desktop
    if (Platform.isWindows) {
      return "http://localhost:5000/api";
    }

    // macOS
    if (Platform.isMacOS) {
      return "http://localhost:5000/api";
    }

    // Linux
    if (Platform.isLinux) {
      return "http://localhost:5000/api";
    }

    return "http://localhost:5000/api";
  }
}
