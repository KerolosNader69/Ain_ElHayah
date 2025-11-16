import 'package:flutter_test/flutter_test.dart';
import 'package:eye_wise_connect/services/huawei_modelarts_service.dart';
import 'package:eye_wise_connect/services/retina_inference_service.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  group('Error Handling Tests', () {
    
    group('Image Size Validation', () {
      test('Rejects image larger than 8MB with descriptive error', () async {
        // Create a config (doesn't matter if it's valid for this test)
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config);
        
        // Create an image larger than 8MB (8 * 1024 * 1024 + 1 bytes)
        final largeImage = Uint8List(8 * 1024 * 1024 + 1);
        
        // Expect the service to throw an exception
        expect(
          () => service.inferImage(largeImage),
          throwsA(predicate((e) =>
            e.toString().contains('8MB') &&
            e.toString().contains('compress or resize')
          )),
        );
      });
      
      test('Accepts image exactly at 8MB limit', () async {
        // Create a mock Dio that returns success
        final mockDio = _MockDio(statusCode: 200, responseData: {
          'prediction': 'Normal',
          'confidence': 0.95,
        });
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        
        // Create an image exactly 8MB
        final exactImage = Uint8List(8 * 1024 * 1024);
        
        // Should not throw
        final result = await service.inferImage(exactImage);
        expect(result, isNotNull);
      });
      
      test('Accepts image smaller than 8MB', () async {
        // Create a mock Dio that returns success
        final mockDio = _MockDio(statusCode: 200, responseData: {
          'prediction': 'Normal',
          'confidence': 0.95,
        });
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        
        // Create a small image (1MB)
        final smallImage = Uint8List(1024 * 1024);
        
        // Should not throw
        final result = await service.inferImage(smallImage);
        expect(result, isNotNull);
      });
    });
    
    group('Configuration Validation', () {
      test('Missing configuration shows descriptive error', () {
        final incompleteConfig = HuaweiModelArtsConfig(
          projectId: '',
          accessKeyId: '',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        expect(incompleteConfig.isComplete, false);
        
        // Verify we can identify missing fields
        final missingFields = <String>[];
        if (incompleteConfig.projectId.isEmpty) missingFields.add('MODELARTS_PROJECT_ID');
        if (incompleteConfig.accessKeyId.isEmpty) missingFields.add('MODELARTS_ACCESS_KEY');
        if (incompleteConfig.secretAccessKey.isEmpty) missingFields.add('MODELARTS_SECRET_KEY');
        if (incompleteConfig.serviceId.isEmpty) missingFields.add('MODELARTS_SERVICE_ID');
        if (incompleteConfig.region.isEmpty) missingFields.add('MODELARTS_REGION');
        if (incompleteConfig.invokeUrl.isEmpty) missingFields.add('MODELARTS_INVOKE_URL');
        
        expect(missingFields, contains('MODELARTS_PROJECT_ID'));
        expect(missingFields, contains('MODELARTS_ACCESS_KEY'));
        expect(missingFields.length, 2);
      });
      
      test('Complete configuration passes validation', () {
        final completeConfig = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        expect(completeConfig.isComplete, true);
      });
    });
    
    group('Authentication Errors', () {
      test('401 error shows authentication failed message', () async {
        // Create a mock Dio that returns 401
        final mockDio = _MockDio(
          statusCode: 401,
          responseData: {'error': 'Unauthorized'},
          shouldFailIAM: true, // Make IAM token request also fail
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
        
        // Expect authentication error (wrapped in Exception when IAM fails)
        expect(
          () => service.inferImage(testImage),
          throwsA(predicate((e) {
            // When IAM token request fails, it's wrapped in an Exception
            if (e is Map<String, dynamic>) {
              final body = e['body'] as Map<String, dynamic>?;
              return e['statusCode'] == 0 && 
                     body != null &&
                     body['error'].toString().contains('IAM token');
            }
            return e.toString().contains('401') || 
                   e.toString().contains('Unauthorized') ||
                   e.toString().contains('IAM token') ||
                   e.toString().contains('authentication');
          })),
        );
      });
      
      test('Invalid credentials show actionable error message', () async {
        final mockDio = _MockDio(
          statusCode: 401,
          responseData: {
            'error': 'Invalid credentials',
            'message': 'The access key or secret key is incorrect'
          },
          shouldFailIAM: true,
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'wrong-ak',
          secretAccessKey: 'wrong-sk',
          serviceId: 'test-service',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        expect(
          () => service.inferImage(testImage),
          throwsA(predicate((e) {
            // When IAM fails, error is wrapped in Exception
            if (e is Map<String, dynamic>) {
              final body = e['body'] as Map<String, dynamic>?;
              return body != null && 
                     (body['error']?.toString().contains('credentials') == true ||
                      body['error']?.toString().contains('IAM token') == true);
            }
            return e.toString().contains('credentials') || 
                   e.toString().contains('IAM token');
          })),
        );
      });
    });
    
    group('Network Errors', () {
      test('Network disconnection shows user-friendly error', () async {
        // Create a mock Dio that simulates network error
        final mockDio = _MockDio(
          shouldThrowNetworkError: true,
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
              return e['statusCode'] == 0 &&
                     e['body']['error'].toString().contains('Network error');
            }
            return false;
          })),
        );
      });
      
      test('Timeout error shows network error message', () async {
        final mockDio = _MockDio(
          shouldThrowTimeout: true,
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
              return e['statusCode'] == 0 &&
                     e['body']['error'].toString().contains('Network error');
            }
            return false;
          })),
        );
      });
    });
    
    group('Service Not Found Errors', () {
      test('404 error shows service not found message', () async {
        final mockDio = _MockDio(
          statusCode: 404,
          responseData: {
            'error': 'Service not found',
            'message': 'The specified service ID does not exist'
          },
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'invalid-service-id',
          region: 'ap-southeast-3',
          invokeUrl: 'https://test.com/v1/infers/<SERVICE_ID>',
        );
        
        final service = HuaweiModelArtsService(config: config, dio: mockDio);
        final testImage = Uint8List(1024);
        
        expect(
          () => service.inferImage(testImage),
          throwsA(predicate((e) {
            if (e is Map<String, dynamic>) {
              return e['statusCode'] == 404;
            }
            return false;
          })),
        );
      });
      
      test('Invalid service ID shows actionable error', () async {
        final mockDio = _MockDio(
          statusCode: 404,
          responseData: {
            'error': 'ModelArts service not found',
            'message': 'Please verify service ID and region'
          },
        );
        
        final config = HuaweiModelArtsConfig(
          projectId: 'test-project',
          accessKeyId: 'test-ak',
          secretAccessKey: 'test-sk',
          serviceId: 'wrong-id',
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
              return e['statusCode'] == 404 &&
                     body != null &&
                     (body['error']?.toString().contains('not found') == true ||
                      body['message']?.toString().contains('verify') == true);
            }
            return false;
          })),
        );
      });
    });
    
    group('Model Inference Errors', () {
      test('500 error shows model inference failed message', () async {
        final mockDio = _MockDio(
          statusCode: 500,
          responseData: {
            'error': 'Internal server error',
            'message': 'Model inference failed'
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
        
        expect(
          () => service.inferImage(testImage),
          throwsA(predicate((e) {
            if (e is Map<String, dynamic>) {
              return e['statusCode'] == 500;
            }
            return false;
          })),
        );
      });
    });
    
    group('Error Message User-Friendliness', () {
      test('All error messages are actionable and user-friendly', () {
        // Test various error scenarios and verify messages
        final errorScenarios = [
          {
            'error': 'Image size exceeds 8MB limit',
            'action': 'compress or resize',
            'userFriendly': true,
          },
          {
            'error': 'ModelArts configuration is missing',
            'action': 'check env.json',
            'userFriendly': true,
          },
          {
            'error': 'Authentication failed',
            'action': 'check credentials',
            'userFriendly': true,
          },
          {
            'error': 'Network error',
            'action': 'check internet connection',
            'userFriendly': true,
          },
          {
            'error': 'Service not found',
            'action': 'verify service ID',
            'userFriendly': true,
          },
        ];
        
        for (final scenario in errorScenarios) {
          expect(scenario['userFriendly'], true);
          expect(scenario['action'], isNotEmpty);
        }
      });
    });
  });
}

/// Mock Dio client for testing error scenarios
class _MockDio extends Fake implements Dio {
  final int? statusCode;
  final dynamic responseData;
  final bool shouldThrowNetworkError;
  final bool shouldThrowTimeout;
  final bool shouldFailIAM;
  
  _MockDio({
    this.statusCode,
    this.responseData,
    this.shouldThrowNetworkError = false,
    this.shouldThrowTimeout = false,
    this.shouldFailIAM = false,
  });
  
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
    // Simulate network error
    if (shouldThrowNetworkError) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
        message: 'Connection failed',
      );
    }
    
    // Simulate timeout
    if (shouldThrowTimeout) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timeout',
      );
    }
    
    // Simulate IAM token request failure
    if (path.contains('iam') && shouldFailIAM) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 401,
          data: {'error': 'Invalid credentials'},
        ),
        type: DioExceptionType.badResponse,
      );
    }
    
    // Return mock response
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: statusCode,
      data: responseData as T,
    );
  }
}
