import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Provides a unified way to retrieve the Google API key across platforms.
///
/// Priority order:
/// 1) --dart-define=GOOGLE_API_KEY at build/run time (all platforms)
/// 2) env.json file in project directory with { "GOOGLE_API_KEY": "..." }
///
/// Notes:
/// - `String.fromEnvironment` only reads values passed via --dart-define.
/// - For security, avoid committing env.json with a real key.
class ApiKeyLoader {
  static const String keyName = 'GOOGLE_API_KEY';

  /// Load the Google API key. Returns empty string if not found.
  static Future<String> loadGoogleApiKey() async {
    // 1) Prefer build-time define
    const fromDefine = String.fromEnvironment(keyName);
    if (fromDefine.isNotEmpty) {
      return fromDefine.trim();
    }

    // 2) Try reading env.json for desktop/mobile debug convenience
    if (!kIsWeb) {
      try {
        // Look for env.json in current working directory
        final file = File('env.json');
        if (await file.exists()) {
          final raw = await file.readAsString();
          final Map<String, dynamic> jsonMap = json.decode(raw) as Map<String, dynamic>;
          final val = (jsonMap[keyName] ?? '').toString().trim();
          return val;
        }
      } catch (_) {
        // Ignore and return empty below
      }
    }

    return '';
  }
}


