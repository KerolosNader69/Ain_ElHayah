import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show File;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_key_loader.dart';

/// Production-ready Huawei ModelArts inference service.
/// 
/// SECURITY NOTE: This service uses AK/SK credentials to obtain IAM tokens.
/// For mobile apps, consider using a backend proxy that handles authentication
/// to avoid exposing credentials in the client. If used directly in mobile,
/// ensure proper obfuscation and use secure storage for credentials.
class HuaweiModelArtsService {
  final HuaweiModelArtsConfig config;
  final Dio _dio;
  String? _cachedToken;
  DateTime? _tokenExpiry;

  HuaweiModelArtsService({required this.config, Dio? dio})
      : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  /// Main inference function: sends image bytes and returns parsed JSON response.
  /// 
  /// Throws exception if image exceeds 8MB limit or if inference fails.
  /// Returns structured error object: { "statusCode": int, "body": Map<String,dynamic> }
  Future<Map<String, dynamic>> inferImage(Uint8List imageBytes) async {
    // Enforce 8MB limit
    const maxSizeBytes = 8 * 1024 * 1024; // 8MB
    if (imageBytes.length > maxSizeBytes) {
      throw Exception(
          'Image size (${imageBytes.length} bytes) exceeds 8MB limit. Please compress or resize the image.');
    }

    final base64Image = base64Encode(imageBytes);
    final invokeUrl = config.invokeUrl.replaceAll('<SERVICE_ID>', config.serviceId);

    // Try format A: {"image":"<base64>"}
    Map<String, dynamic>? formatAError;
    try {
      final result = await _tryInference(
        invokeUrl,
        {'image': base64Image},
      );
      return result;
    } catch (e) {
      formatAError = e is Map<String, dynamic> ? e : null;
      // If format A fails, try format B
      try {
        final result = await _tryInference(
          invokeUrl,
          {'instances': [{'image': base64Image}]},
        );
        return result;
      } catch (e2) {
        // Both formats failed, throw the original error from format A
        throw formatAError ?? e;
      }
    }
  }

  Future<Map<String, dynamic>> _tryInference(
    String url,
    Map<String, dynamic> payload,
  ) async {
    try {
      print('[HuaweiModelArtsService] Calling: $url');
      print('[HuaweiModelArtsService] Payload keys: ${payload.keys.toList()}');
      
      // On web, use backend proxy to avoid CORS issues
      if (kIsWeb) {
        print('[HuaweiModelArtsService] Using backend proxy for web');
        final proxyUrl = 'http://localhost:3001/api/modelarts/infer';
        
        // Load credentials from env.json via backend or use provided config
        // The backend will read from its own env.json file
        final proxyPayload = {
          'imageBase64': payload['image'] ?? (payload['instances'] != null ? payload['instances'][0]['image'] : ''),
          // Only send these if they're not placeholder values
          if (config.serviceId != 'proxy') 'serviceId': config.serviceId,
          if (config.region != 'proxy') 'region': config.region,
          if (config.accessKeyId != 'proxy') 'accessKey': config.accessKeyId,
          if (config.secretAccessKey != 'proxy') 'secretKey': config.secretAccessKey,
          if (config.projectId != 'proxy') 'projectId': config.projectId,
        };
        
        final response = await _dio.post(
          proxyUrl,
          data: jsonEncode(proxyPayload),
          options: Options(
            headers: {'Content-Type': 'application/json'},
            validateStatus: (status) => status != null && status < 500,
          ),
        );
        
        print('[HuaweiModelArtsService] Proxy response status: ${response.statusCode}');
        print('[HuaweiModelArtsService] Proxy response data: ${response.data}');
        
        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          if (response.data is Map) {
            return response.data as Map<String, dynamic>;
          } else if (response.data is String) {
            return jsonDecode(response.data) as Map<String, dynamic>;
          }
          return {'result': response.data};
        }
        
        final errorBody = response.data is Map
            ? response.data as Map<String, dynamic>
            : {'error': response.data.toString()};
        throw {
          'statusCode': response.statusCode ?? 500,
          'body': errorBody,
        };
      }
      
      // Mobile/Desktop: Direct call
      final response = await _dio.post(
        url,
        data: jsonEncode(payload),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('[HuaweiModelArtsService] Response status: ${response.statusCode}');
      print('[HuaweiModelArtsService] Response data type: ${response.data.runtimeType}');
      print('[HuaweiModelArtsService] Response data: ${response.data}');

      // Success (2xx)
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        if (response.data is Map) {
          final result = response.data as Map<String, dynamic>;
          print('[HuaweiModelArtsService] Parsed response keys: ${result.keys.toList()}');
          return result;
        } else if (response.data is String) {
          final decoded = jsonDecode(response.data) as Map<String, dynamic>;
          print('[HuaweiModelArtsService] Decoded response keys: ${decoded.keys.toList()}');
          return decoded;
        }
        print('[HuaweiModelArtsService] WARNING: Unexpected response type, wrapping in result');
        return {'result': response.data};
      }

      // 401 Unauthorized - need to get IAM token
      if (response.statusCode == 401) {
        print('[HuaweiModelArtsService] Got 401, obtaining IAM token...');
        await _ensureToken();
        print('[HuaweiModelArtsService] IAM token obtained, retrying with auth...');
        // Retry with authentication
        final authResponse = await _dio.post(
          url,
          data: jsonEncode(payload),
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_cachedToken',
              'X-Project-Id': config.projectId,
            },
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        print('[HuaweiModelArtsService] Auth retry status: ${authResponse.statusCode}');
        print('[HuaweiModelArtsService] Auth retry data: ${authResponse.data}');
        
        if (authResponse.statusCode != null &&
            authResponse.statusCode! >= 200 &&
            authResponse.statusCode! < 300) {
          if (authResponse.data is Map) {
            final result = authResponse.data as Map<String, dynamic>;
            print('[HuaweiModelArtsService] Auth success - response keys: ${result.keys.toList()}');
            return result;
          } else if (authResponse.data is String) {
            final decoded = jsonDecode(authResponse.data) as Map<String, dynamic>;
            print('[HuaweiModelArtsService] Auth success - decoded keys: ${decoded.keys.toList()}');
            return decoded;
          }
          print('[HuaweiModelArtsService] Auth success - wrapping in result');
          return {'result': authResponse.data};
        }

        // Auth retry failed
        final errorBody = authResponse.data is Map
            ? authResponse.data as Map<String, dynamic>
            : (authResponse.data is String
                ? jsonDecode(authResponse.data) as Map<String, dynamic>
                : {'error': authResponse.data.toString()});
        throw {
          'statusCode': authResponse.statusCode ?? 500,
          'body': errorBody,
        };
      }

      // Other errors (non-401)
      final errorBody = response.data is Map
          ? response.data as Map<String, dynamic>
          : (response.data is String
              ? jsonDecode(response.data) as Map<String, dynamic>
              : {'error': response.data.toString()});
      throw {
        'statusCode': response.statusCode ?? 500,
        'body': errorBody,
      };
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode ?? 500;
        final errorBody = e.response!.data is Map
            ? e.response!.data as Map<String, dynamic>
            : (e.response!.data is String
                ? jsonDecode(e.response!.data) as Map<String, dynamic>
                : {'error': e.response!.data?.toString() ?? e.message});
        throw {
          'statusCode': statusCode,
          'body': errorBody,
        };
      }
      throw {
        'statusCode': 0,
        'body': {'error': 'Network error: ${e.message}'},
      };
    } catch (e) {
      if (e is Map<String, dynamic>) {
        rethrow;
      }
      throw {
        'statusCode': 0,
        'body': {'error': e.toString()},
      };
    }
  }

  /// Obtain IAM token using AK/SK credentials.
  /// Token is cached until expiry (typically 24 hours).
  Future<void> _ensureToken() async {
    // Check if cached token is still valid (with 5 minute buffer)
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(minutes: 5)))) {
      return;
    }

    final region = config.region;
    final iamUrl = 'https://iam.$region.myhuaweicloud.com/v3/auth/tokens';

    final requestBody = {
      'auth': {
        'identity': {
          'methods': ['ak-sak'],
          'ak-sak': {
            'access': config.accessKeyId,
            'secret': config.secretAccessKey,
          },
        },
        'scope': {
          'project': {'id': config.projectId},
        },
      },
    };

    try {
      final response = await _dio.post(
        iamUrl,
        data: jsonEncode(requestBody),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // Extract token from response header
      final token = response.headers.value('x-subject-token');
      if (token == null || token.isEmpty) {
        throw Exception('Failed to obtain IAM token: x-subject-token header missing');
      }

      _cachedToken = token;

      // Parse token expiry from response body (if available)
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final tokenData = data['token'] as Map<String, dynamic>?;
        if (tokenData != null && tokenData['expires_at'] != null) {
          try {
            _tokenExpiry = DateTime.parse(tokenData['expires_at'] as String);
          } catch (_) {
            // Default to 24 hours if parsing fails
            _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
          }
        } else {
          _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
        }
      } else {
        _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map
          ? (e.response!.data as Map)['error']?.toString() ?? e.message
          : e.message;
      throw Exception('Failed to obtain IAM token: $errorMsg');
    } catch (e) {
      throw Exception('Failed to obtain IAM token: $e');
    }
  }

  /// Clear cached token (useful for testing or credential rotation).
  void clearToken() {
    _cachedToken = null;
    _tokenExpiry = null;
  }
}

/// Configuration for Huawei ModelArts inference endpoint.
class HuaweiModelArtsConfig {
  final String projectId;
  final String accessKeyId;
  final String secretAccessKey;
  final String serviceId; // SERVICE_ID to replace in invoke URL
  final String region; // e.g., 'ap-southeast-3'
  final String invokeUrl; // Full URL template with <SERVICE_ID> placeholder

  const HuaweiModelArtsConfig({
    required this.projectId,
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.serviceId,
    required this.region,
    required this.invokeUrl,
  });

  bool get isComplete =>
      projectId.isNotEmpty &&
      accessKeyId.isNotEmpty &&
      secretAccessKey.isNotEmpty &&
      serviceId.isNotEmpty &&
      region.isNotEmpty &&
      invokeUrl.isNotEmpty;
}

/// Extension to load ModelArts configuration from env.json or compile-time variables.
extension ApiKeyLoaderModelArts on ApiKeyLoader {
  // ModelArts configuration keys
  static const String modelArtsProjectIdKey = 'MODELARTS_PROJECT_ID';
  static const String modelArtsAccessKey = 'MODELARTS_ACCESS_KEY';
  static const String modelArtsSecretKey = 'MODELARTS_SECRET_KEY';
  static const String modelArtsServiceIdKey = 'MODELARTS_SERVICE_ID';
  static const String modelArtsRegionKey = 'MODELARTS_REGION';
  static const String modelArtsInvokeUrlKey = 'MODELARTS_INVOKE_URL';

  /// Load Huawei ModelArts configuration from --dart-define values or env.json.
  /// Returns null if required fields are missing.
  static Future<HuaweiModelArtsConfig?> loadHuaweiModelArtsConfig() async {
    // 1) Prefer build-time defines
    const proj = String.fromEnvironment(modelArtsProjectIdKey);
    const ak = String.fromEnvironment(modelArtsAccessKey);
    const sk = String.fromEnvironment(modelArtsSecretKey);
    const serviceId = String.fromEnvironment(modelArtsServiceIdKey);
    const region = String.fromEnvironment(modelArtsRegionKey);
    const invokeUrl = String.fromEnvironment(modelArtsInvokeUrlKey);

    if (proj.isNotEmpty &&
        ak.isNotEmpty &&
        sk.isNotEmpty &&
        serviceId.isNotEmpty &&
        region.isNotEmpty &&
        invokeUrl.isNotEmpty) {
      return HuaweiModelArtsConfig(
        projectId: proj.trim(),
        accessKeyId: ak.trim(),
        secretAccessKey: sk.trim(),
        serviceId: serviceId.trim(),
        region: region.trim(),
        invokeUrl: invokeUrl.trim(),
      );
    }

    // 2) Fallback to env.json for desktop/mobile
    // Note: On web, use compile-time variables (--dart-define) as env.json is not accessible
    if (!kIsWeb) {
      // Desktop/mobile: try env.json
      try {
        final file = File('env.json');
        if (await file.exists()) {
          final raw = await file.readAsString();
          final Map<String, dynamic> jsonMap = json.decode(raw) as Map<String, dynamic>;

          String getStr(String k) => (jsonMap[k] ?? '').toString().trim();

          final cfg = HuaweiModelArtsConfig(
            projectId: getStr(modelArtsProjectIdKey),
            accessKeyId: getStr(modelArtsAccessKey),
            secretAccessKey: getStr(modelArtsSecretKey),
            serviceId: getStr(modelArtsServiceIdKey),
            region: getStr(modelArtsRegionKey),
            invokeUrl: getStr(modelArtsInvokeUrlKey),
          );

          if (cfg.isComplete) {
            print('[ApiKeyLoaderModelArts] Loaded from env.json');
            return cfg;
          }
        }
      } catch (e) {
        print('[ApiKeyLoaderModelArts] Failed to load from env.json: $e');
      }
    }

    return null;
  }
}

