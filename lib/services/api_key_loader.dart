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
  // Huawei DLI keys
  static const String dliProjectIdKey = 'DLI_PROJECT_ID';
  static const String dliAccessKey = 'DLI_ACCESS_KEY';
  static const String dliSecretKey = 'DLI_SECRET_KEY';
  static const String dliUsernameKey = 'DLI_USERNAME';
  static const String dliRegionKey = 'DLI_REGION';
  static const String dliEndpointKey = 'DLI_ENDPOINT';

  // Huawei AI models (DeepSeek/Qwen via competition endpoint)
  static const String huaweiAiKey = 'HUAWEI_AI_API_KEY';
  static const String huaweiAiBaseUrl = 'HUAWEI_AI_BASE_URL'; // optional override
  static const String huaweiAiModel = 'HUAWEI_AI_MODEL'; // e.g., 'deepseek-v3.1' or 'qwen-3'

  // Huawei SIS (Speech Interaction Service) keys
  static const String sisProjectIdKey = 'SIS_PROJECT_ID';
  static const String sisAccessKey = 'SIS_ACCESS_KEY';
  static const String sisSecretKey = 'SIS_SECRET_KEY';
  static const String sisEndpointKey = 'SIS_ENDPOINT';
  static const String sisLanguageKey = 'SIS_LANGUAGE'; // e.g., 'en_US' or 'ar_AE'

  // Huawei ModelArts keys
  static const String modelArtsProjectIdKey = 'MODELARTS_PROJECT_ID';
  static const String modelArtsAccessKey = 'MODELARTS_ACCESS_KEY';
  static const String modelArtsSecretKey = 'MODELARTS_SECRET_KEY';
  static const String modelArtsServiceIdKey = 'MODELARTS_SERVICE_ID';
  static const String modelArtsRegionKey = 'MODELARTS_REGION';
  static const String modelArtsInvokeUrlKey = 'MODELARTS_INVOKE_URL';

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


/// Strongly-typed configuration for Huawei Cloud SIS (ASR over WebSocket)
class HuaweiSisConfig {
  final String projectId;
  final String accessKeyId;
  final String secretAccessKey;
  final String endpoint; // e.g., 'sis.ap-southeast-3.myhuaweicloud.com'
  final String language; // 'en_US' or 'ar_AE'

  const HuaweiSisConfig({
    required this.projectId,
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.endpoint,
    this.language = 'en_US',
  });

  bool get isComplete =>
      projectId.isNotEmpty && accessKeyId.isNotEmpty && secretAccessKey.isNotEmpty && endpoint.isNotEmpty;
}

extension ApiKeyLoaderSis on ApiKeyLoader {
  /// Load Huawei SIS configuration from --dart-define values or env.json.
  /// Returns null if required fields are missing.
  static Future<HuaweiSisConfig?> loadHuaweiSisConfig() async {
    // 1) Prefer build-time defines
    const proj = String.fromEnvironment(ApiKeyLoader.sisProjectIdKey);
    const ak = String.fromEnvironment(ApiKeyLoader.sisAccessKey);
    const sk = String.fromEnvironment(ApiKeyLoader.sisSecretKey);
    const endpoint = String.fromEnvironment(ApiKeyLoader.sisEndpointKey);
    const lang = String.fromEnvironment(ApiKeyLoader.sisLanguageKey);

    if (proj.isNotEmpty && ak.isNotEmpty && sk.isNotEmpty && endpoint.isNotEmpty) {
      return HuaweiSisConfig(
        projectId: proj.trim(),
        accessKeyId: ak.trim(),
        secretAccessKey: sk.trim(),
        endpoint: endpoint.trim(),
        language: lang.trim().isEmpty ? 'en_US' : lang.trim(),
      );
    }

    // 2) Fallback to env.json for desktop/mobile debug convenience
    if (!kIsWeb) {
      try {
        final file = File('env.json');
        if (await file.exists()) {
          final raw = await file.readAsString();
          final Map<String, dynamic> jsonMap = json.decode(raw) as Map<String, dynamic>;

          String getStr(String k) => (jsonMap[k] ?? '').toString().trim();

          final cfg = HuaweiSisConfig(
            projectId: getStr(ApiKeyLoader.sisProjectIdKey),
            accessKeyId: getStr(ApiKeyLoader.sisAccessKey),
            secretAccessKey: getStr(ApiKeyLoader.sisSecretKey),
            endpoint: getStr(ApiKeyLoader.sisEndpointKey),
            language: () { final v = getStr(ApiKeyLoader.sisLanguageKey); return v.isEmpty ? 'en_US' : v; }(),
          );

          if (cfg.isComplete) return cfg;
        }
      } catch (_) {
        // Ignore and return null below
      }
    }

    return null;
  }
}

/// Strongly-typed configuration for Huawei Cloud Data Lake Insight (DLI)
class HuaweiDliConfig {
  final String projectId;
  final String accessKeyId;
  final String secretAccessKey;
  final String username;
  final String? region;      // e.g., 'af-south-1'
  final String? endpoint;    // Optional full endpoint override

  const HuaweiDliConfig({
    required this.projectId,
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.username,
    this.region,
    this.endpoint,
  });

  bool get isComplete =>
      projectId.isNotEmpty && accessKeyId.isNotEmpty && secretAccessKey.isNotEmpty;
}

extension ApiKeyLoaderDli on ApiKeyLoader {
  /// Load Huawei DLI configuration from --dart-define values or env.json.
  /// Returns null if required fields are missing.
  static Future<HuaweiDliConfig?> loadHuaweiDliConfig() async {
    // 1) Prefer build-time defines
    const proj = String.fromEnvironment(ApiKeyLoader.dliProjectIdKey);
    const ak = String.fromEnvironment(ApiKeyLoader.dliAccessKey);
    const sk = String.fromEnvironment(ApiKeyLoader.dliSecretKey);
    const user = String.fromEnvironment(ApiKeyLoader.dliUsernameKey);
    const region = String.fromEnvironment(ApiKeyLoader.dliRegionKey);
    const endpoint = String.fromEnvironment(ApiKeyLoader.dliEndpointKey);

    if (proj.isNotEmpty && ak.isNotEmpty && sk.isNotEmpty) {
      return HuaweiDliConfig(
        projectId: proj.trim(),
        accessKeyId: ak.trim(),
        secretAccessKey: sk.trim(),
        username: user.trim(),
        region: region.trim().isEmpty ? null : region.trim(),
        endpoint: endpoint.trim().isEmpty ? null : endpoint.trim(),
      );
    }

    // 2) Fallback to env.json for desktop/mobile debug convenience
    if (!kIsWeb) {
      try {
        final file = File('env.json');
        if (await file.exists()) {
          final raw = await file.readAsString();
          final Map<String, dynamic> jsonMap = json.decode(raw) as Map<String, dynamic>;

          String getStr(String k) => (jsonMap[k] ?? '').toString().trim();

          final cfg = HuaweiDliConfig(
            projectId: getStr(ApiKeyLoader.dliProjectIdKey),
            accessKeyId: getStr(ApiKeyLoader.dliAccessKey),
            secretAccessKey: getStr(ApiKeyLoader.dliSecretKey),
            username: getStr(ApiKeyLoader.dliUsernameKey),
            region: () { final v = getStr(ApiKeyLoader.dliRegionKey); return v.isEmpty ? null : v; }(),
            endpoint: () { final v = getStr(ApiKeyLoader.dliEndpointKey); return v.isEmpty ? null : v; }(),
          );

          if (cfg.isComplete) return cfg;
        }
      } catch (_) {
        // Ignore and return null below
      }
    }

    return null;
  }
}

class HuaweiAiConfig {
  final String apiKey;
  final String? baseUrl;
  final String? model;
  const HuaweiAiConfig({required this.apiKey, this.baseUrl, this.model});
}

extension ApiKeyLoaderHuaweiAi on ApiKeyLoader {
  static Future<HuaweiAiConfig?> loadHuaweiAiConfig() async {
    const key = String.fromEnvironment(ApiKeyLoader.huaweiAiKey);
    final base = String.fromEnvironment(ApiKeyLoader.huaweiAiBaseUrl);
    final model = String.fromEnvironment(ApiKeyLoader.huaweiAiModel);
    if (key.isNotEmpty) {
      return HuaweiAiConfig(
        apiKey: key.trim(),
        baseUrl: base.trim().isEmpty ? null : base.trim(),
        model: model.trim().isEmpty ? null : model.trim(),
      );
    }

    if (!kIsWeb) {
      try {
        final file = File('env.json');
        if (await file.exists()) {
          final raw = await file.readAsString();
          final Map<String, dynamic> jsonMap = json.decode(raw) as Map<String, dynamic>;
          String getStr(String k) => (jsonMap[k] ?? '').toString().trim();
          final k = getStr(ApiKeyLoader.huaweiAiKey);
          if (k.isEmpty) return null;
          return HuaweiAiConfig(
            apiKey: k,
            baseUrl: () { final v = getStr(ApiKeyLoader.huaweiAiBaseUrl); return v.isEmpty ? null : v; }(),
            model: () { final v = getStr(ApiKeyLoader.huaweiAiModel); return v.isEmpty ? null : v; }(),
          );
        }
      } catch (_) {}
    }
    return null;
  }
}


