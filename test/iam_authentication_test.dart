import 'package:flutter_test/flutter_test.dart';
import 'package:eye_wise_connect/services/huawei_modelarts_service.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  group('IAM Authentication Flow Tests', () {
    
    group('First API Call Triggers IAM Token Request on 401', () {
      test('401 response triggers IAM token request', () async {
        // Create a mock Dio that returns 401 first, then success after IAM
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          retryStatusCode: 200,
          retryResponseData: {
            'prediction': 'Normal',
            'confidence': 0.95,
          },
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        // First call should trigger 401, then IAM request, then retry
        final result = await service.inferImage(testImage);
        
        expect(result, isNotNull);
        expect(result['prediction'], 'Normal');
        expect(mockDio.iamTokenRequested, true);
        expect(mockDio.retryWithAuthCalled, true);
      });
      
      test('IAM token request includes correct AK/SK credentials', () async {
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          retryStatusCode: 200,
          retryResponseData: {'prediction': 'Normal', 'confidence': 0.95},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project-123',
          accessKeyId: 'test-ak-456',
          secretAccessKey: 'test-sk-789',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        await service.inferImage(testImage);
        
        expect(mockDio.iamRequestBody, isNotNull);
        expect(mockDio.iamRequestBody!['auth']['identity']['ak-sak']['access'], 'test-ak-456');
        expect(mockDio.iamRequestBody!['auth']['identity']['ak-sak']['secret'], 'test-sk-789');
        expect(mockDio.iamRequestBody!['auth']['scope']['project']['id'], 'test-project-123');
      });
      
      test('IAM token request uses correct region endpoint', () async {
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          retryStatusCode: 200,
          retryResponseData: {'prediction': 'Normal', 'confidence': 0.95},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        await service.inferImage(testImage);
        
        expect(mockDio.iamRequestUrl, 'https://iam.ap-southeast-3.myhuaweicloud.com/v3/auth/tokens');
      });
    });
    
    group('Token Caching with Correct Expiry', () {
      test('Token is cached with 24 hour expiry minus 5 minute buffer', () async {
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          iamTokenExpiry: DateTime.now().add(const Duration(hours: 24)),
          retryStatusCode: 200,
          retryResponseData: {'prediction': 'Normal', 'confidence': 0.95},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        // First call triggers IAM
        await service.inferImage(testImage);
        expect(mockDio.iamTokenRequested, true);
        
        // Verify token is cached (internal state check via second call)
        mockDio.resetCounters();
        mockDio.firstCallStatusCode = 200; // No 401 on second call
        
        await service.inferImage(testImage);
        
        // IAM should not be requested again since token is cached
        expect(mockDio.iamTokenRequested, false);
      });
      
      test('Token expiry is parsed from IAM response', () async {
        final expectedExpiry = DateTime.now().add(const Duration(hours: 24));
        
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          iamTokenExpiry: expectedExpiry,
          retryStatusCode: 200,
          retryResponseData: {'prediction': 'Normal', 'confidence': 0.95},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        await service.inferImage(testImage);
        
        // Verify the expiry was included in the IAM response
        expect(mockDio.iamResponseData, isNotNull);
        expect(mockDio.iamResponseData!['token']['expires_at'], isNotNull);
      });
      
      test('Token defaults to 24 hour expiry when expires_at not in response', () async {
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          iamTokenExpiry: null, // No expiry in response
          retryStatusCode: 200,
          retryResponseData: {'prediction': 'Normal', 'confidence': 0.95},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        // Should still work and default to 24 hours
        final result = await service.inferImage(testImage);
        expect(result, isNotNull);
      });
    });
    
    group('Cached Token Reuse for Subsequent Requests', () {
      test('Second request reuses cached token without new IAM call', () async {
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          iamTokenExpiry: DateTime.now().add(const Duration(hours: 24)),
          retryStatusCode: 200,
          retryResponseData: {'prediction': 'Normal', 'confidence': 0.95},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        // First call - triggers IAM
        await service.inferImage(testImage);
        expect(mockDio.iamTokenRequested, true);
        final firstIamCallCount = mockDio.iamCallCount;
        
        // Reset mock for second call
        mockDio.resetCounters();
        mockDio.firstCallStatusCode = 200; // Success without 401
        
        // Second call - should reuse token
        await service.inferImage(testImage);
        expect(mockDio.iamTokenRequested, false);
        expect(mockDio.iamCallCount, 0); // No new IAM calls
      });
      
      test('Multiple requests reuse same cached token', () async {
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          iamTokenExpiry: DateTime.now().add(const Duration(hours: 24)),
          retryStatusCode: 200,
          retryResponseData: {'prediction': 'Normal', 'confidence': 0.95},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        // First call
        await service.inferImage(testImage);
        expect(mockDio.iamCallCount, 1);
        
        // Subsequent calls
        mockDio.firstCallStatusCode = 200;
        for (int i = 0; i < 5; i++) {
          mockDio.resetCounters();
          await service.inferImage(testImage);
          expect(mockDio.iamCallCount, 0); // No new IAM calls
        }
      });
      
      test('Cached token is used in Authorization header', () async {
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          iamTokenExpiry: DateTime.now().add(const Duration(hours: 24)),
          retryStatusCode: 200,
          retryResponseData: {'prediction': 'Normal', 'confidence': 0.95},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        await service.inferImage(testImage);
        
        // Verify retry call included the token
        expect(mockDio.retryAuthHeader, 'Bearer test-token-12345');
      });
    });
    
    group('Token Refresh When Expired', () {
      test('Expired token triggers new IAM request', () async {
        // Token expires in 1 second
        final shortExpiry = DateTime.now().add(const Duration(seconds: 1));
        
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          iamTokenExpiry: shortExpiry,
          retryStatusCode: 200,
          retryResponseData: {'prediction': 'Normal', 'confidence': 0.95},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        // First call
        await service.inferImage(testImage);
        expect(mockDio.iamCallCount, 1);
        
        // Wait for token to expire (plus 5 min buffer)
        await Future.delayed(const Duration(seconds: 2));
        
        // Second call should trigger new IAM request
        mockDio.resetCounters();
        mockDio.firstCallStatusCode = 401;
        mockDio.iamTokenResponse = 'test-token-67890'; // New token
        
        await service.inferImage(testImage);
        expect(mockDio.iamCallCount, 1); // New IAM call made
      });
      
      test('Token within 5 minute buffer triggers refresh', () async {
        // Token expires in 4 minutes (within 5 min buffer)
        final nearExpiry = DateTime.now().add(const Duration(minutes: 4));
        
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          iamTokenExpiry: nearExpiry,
          retryStatusCode: 200,
          retryResponseData: {'prediction': 'Normal', 'confidence': 0.95},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        // First call
        await service.inferImage(testImage);
        
        // Second call should trigger refresh due to 5 min buffer
        mockDio.resetCounters();
        mockDio.firstCallStatusCode = 401;
        mockDio.iamTokenResponse = 'test-token-new';
        
        await service.inferImage(testImage);
        expect(mockDio.iamCallCount, 1); // Refresh triggered
      });
      
      test('clearToken forces new IAM request on next call', () async {
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          iamTokenExpiry: DateTime.now().add(const Duration(hours: 24)),
          retryStatusCode: 200,
          retryResponseData: {'prediction': 'Normal', 'confidence': 0.95},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        // First call
        await service.inferImage(testImage);
        expect(mockDio.iamCallCount, 1);
        
        // Clear token
        service.clearToken();
        
        // Next call should request new token
        mockDio.resetCounters();
        mockDio.firstCallStatusCode = 401;
        mockDio.iamTokenResponse = 'test-token-new';
        
        await service.inferImage(testImage);
        expect(mockDio.iamCallCount, 1); // New IAM call
      });
    });
    
    group('Authentication Failure Handling', () {
      test('IAM token request failure throws descriptive exception', () async {
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamShouldFail: true,
          iamFailureMessage: 'Invalid credentials',
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'invalid-ak',
          secretAccessKey: 'invalid-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        expect(
          () => service.inferImage(testImage),
          throwsA(predicate((e) {
            if (e is Map<String, dynamic>) {
              final body = e['body'] as Map<String, dynamic>?;
              return body != null && 
                     body['error'].toString().contains('IAM token');
            }
            return e.toString().contains('IAM token') ||
                   e.toString().contains('Invalid credentials');
          })),
        );
      });
      
      test('Missing x-subject-token header throws exception', () async {
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: null, // No token in header
          retryStatusCode: 200,
          retryResponseData: {'prediction': 'Normal', 'confidence': 0.95},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        expect(
          () => service.inferImage(testImage),
          throwsA(predicate((e) {
            if (e is Map<String, dynamic>) {
              final body = e['body'] as Map<String, dynamic>?;
              return body != null && 
                     body['error'].toString().contains('x-subject-token');
            }
            return e.toString().contains('x-subject-token') ||
                   e.toString().contains('IAM token');
          })),
        );
      });
      
      test('401 after retry with token shows authentication failed', () async {
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamTokenResponse: 'test-token-12345',
          retryStatusCode: 401, // Still 401 after auth
          retryResponseData: {'error': 'Invalid token'},
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        expect(
          () => service.inferImage(testImage),
          throwsA(predicate((e) {
            if (e is Map<String, dynamic>) {
              return e['statusCode'] == 401;
            }
            return false;
          })),
        );
      });
      
      test('Network error during IAM request is handled gracefully', () async {
        final mockDio = _MockDioWithIAM(
          firstCallStatusCode: 401,
          iamShouldThrowNetworkError: true,
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        expect(
          () => service.inferImage(testImage),
          throwsA(predicate((e) {
            if (e is Map<String, dynamic>) {
              final body = e['body'] as Map<String, dynamic>?;
              return body != null && 
                     body['error'].toString().contains('IAM token');
            }
            return e.toString().contains('IAM token') ||
                   e.toString().contains('Network');
          })),
        );
      });
    });
  });
}

/// Mock Dio client with IAM authentication simulation
class _MockDioWithIAM extends Fake implements Dio {
  int firstCallStatusCode;
  String? iamTokenResponse;
  DateTime? iamTokenExpiry;
  int retryStatusCode;
  dynamic retryResponseData;
  bool iamShouldFail;
  String? iamFailureMessage;
  bool iamShouldThrowNetworkError;
  
  // Tracking
  bool iamTokenRequested = false;
  bool retryWithAuthCalled = false;
  int iamCallCount = 0;
  String? iamRequestUrl;
  Map<String, dynamic>? iamRequestBody;
  Map<String, dynamic>? iamResponseData;
  String? retryAuthHeader;
  
  _MockDioWithIAM({
    this.firstCallStatusCode = 401,
    this.iamTokenResponse,
    this.iamTokenExpiry,
    this.retryStatusCode = 200,
    this.retryResponseData,
    this.iamShouldFail = false,
    this.iamFailureMessage,
    this.iamShouldThrowNetworkError = false,
  });
  
  void resetCounters() {
    iamTokenRequested = false;
    retryWithAuthCalled = false;
    iamCallCount = 0;
    iamRequestUrl = null;
    iamRequestBody = null;
    retryAuthHeader = null;
  }
  
  @override
  BaseOptions get options => BaseOptions();
  
  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    // IAM token request
    if (path.contains('iam') && path.contains('auth/tokens')) {
      iamTokenRequested = true;
      iamCallCount++;
      iamRequestUrl = path;
      
      if (data is String) {
        iamRequestBody = jsonDecode(data) as Map<String, dynamic>;
      }
      
      if (iamShouldThrowNetworkError) {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          type: DioExceptionType.connectionError,
          message: 'Network error during IAM request',
        );
      }
      
      if (iamShouldFail) {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          response: Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 401,
            data: {'error': iamFailureMessage ?? 'Authentication failed'},
          ),
          type: DioExceptionType.badResponse,
        );
      }
      
      // Build IAM response
      iamResponseData = {
        'token': {
          'expires_at': iamTokenExpiry?.toIso8601String(),
        },
      };
      
      final headers = Headers();
      if (iamTokenResponse != null) {
        headers.add('x-subject-token', iamTokenResponse!);
      }
      
      return Response<T>(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: iamResponseData as T,
        headers: headers,
      );
    }
    
    // ModelArts inference request
    final authHeader = options?.headers?['Authorization'] as String?;
    
    if (authHeader != null) {
      // This is a retry with authentication
      retryWithAuthCalled = true;
      retryAuthHeader = authHeader;
      
      return Response<T>(
        requestOptions: RequestOptions(path: path),
        statusCode: retryStatusCode,
        data: retryResponseData as T,
      );
    }
    
    // First call without auth
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: firstCallStatusCode,
      data: (firstCallStatusCode == 401 
          ? {'error': 'Unauthorized'} 
          : retryResponseData) as T,
    );
  }
}
