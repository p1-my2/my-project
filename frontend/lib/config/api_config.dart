import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Base URL configured at build time via `--dart-define=API_BASE_URL=https://your-backend.up.railway.app/api`
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      final trimmed = _configuredBaseUrl.trim();
      return trimmed.endsWith('/')
          ? trimmed.substring(0, trimmed.length - 1)
          : trimmed;
    }

    // Flutter Web Development Default
    if (kIsWeb) {
      return "http://localhost:5000/api";
    }

    // Android Emulator Default
    if (!kIsWeb && Platform.isAndroid) {
      return "http://10.0.2.2:5000/api";
    }

    return "http://localhost:5000/api";
  }
}
