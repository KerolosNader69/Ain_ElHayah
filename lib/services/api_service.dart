import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API Service for Eye Wise Connect
/// 
/// This service now connects to our backend proxy server.
/// The proxy handles authentication with Huawei Cloud and resolves CORS issues.
/// Base URL: http://localhost:3001/api
/// 
/// Architecture: Flutter App → Backend Proxy → Huawei Cloud APIG
class ApiService {
  // Base URL for backend proxy server
  // For local development: http://localhost:3001/api
  // For production: Update to your deployed backend URL (e.g., https://your-backend.herokuapp.com/api)
  // For web: Try localhost first, fallback to direct Huawei Cloud (may have CORS issues)
  static String get _baseUrl {
    if (kIsWeb) {
      // On web, try to use the same origin or localhost
      // You can override this with environment variable
      const webBaseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3001/api',
      );
      return webBaseUrl;
    }
    return 'http://localhost:3001/api';
  }

  /// Sign up a new user
  /// 
  /// [username] - User's username
  /// [email] - User's email address
  /// [password] - User's password
  /// [role] - User's role (patient or doctor)
  /// 
  /// Returns a Map with:
  /// - success: bool indicating if the request was successful
  /// - data: Map with response data (if successful)
  /// - error: String with error message (if failed)
  /// 
  /// Throws exceptions for network errors or unexpected responses
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required dynamic role,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/signup');
      
      // Convert UserRole enum to string
      final roleString = role.toString().split('.').last; // 'patient' or 'doctor'
      
      final body = jsonEncode({
        'username': username.trim(),
        'email': email.trim(),
        'password': password.trim(),
        'user_type': roleString,
      });

      // Only Content-Type needed - AppCode is handled by the backend proxy
      final headers = {
        'Content-Type': 'application/json',
      };

      http.Response response;
      try {
        response = await http.post(
          uri,
          headers: headers,
          body: body,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Request timeout. Please check your internet connection.');
          },
        );
      } on http.ClientException catch (e) {
        // Handle connection refused or network errors
        if (e.message.contains('Connection refused') || 
            e.message.contains('Failed host lookup') ||
            e.message.contains('ERR_CONNECTION_REFUSED')) {
          return {
            'success': false,
            'error': 'Backend server is not running. Please start the backend server:\n'
                     '1. Open terminal in the backend folder\n'
                     '2. Run: npm install (if first time)\n'
                     '3. Run: npm start\n'
                     '4. Server should be running on http://localhost:3001',
          };
        }
        rethrow;
      }

      // Parse response
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw FormatException('Invalid JSON response: ${response.body}');
      }

      // Handle success responses (200, 201)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Check if response has success field
        if (responseData.containsKey('success') && responseData['success'] == true) {
          return {
            'success': true,
            'data': responseData['data'] ?? responseData,
          };
        }
        // If no success field, assume success for 2xx status
        return {
          'success': true,
          'data': responseData,
        };
      }

      // Handle error responses (4xx, 5xx)
      return {
        'success': false,
        'error': responseData['error'] ?? 
                 responseData['message'] ?? 
                 'Signup failed with status ${response.statusCode}',
      };
    } on FormatException catch (e) {
      return {
        'success': false,
        'error': 'Invalid response format: ${e.message}',
      };
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.message}. Please check your internet connection.',
      };
    } on Exception catch (e) {
      return {
        'success': false,
        'error': e.toString().replaceFirst('Exception: ', ''),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  /// Login a user
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// 
  /// Returns a Map with:
  /// - success: bool indicating if the request was successful
  /// - data: Map with response data (if successful)
  /// - error: String with error message (if failed)
  /// 
  /// Throws exceptions for network errors or unexpected responses
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/login');
      
      final body = jsonEncode({
        'email': email.trim(),
        'password': password.trim(),
      });

      // Only Content-Type needed - AppCode is handled by the backend proxy
      final headers = {
        'Content-Type': 'application/json',
      };

      http.Response response;
      try {
        response = await http.post(
          uri,
          headers: headers,
          body: body,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Request timeout. Please check your internet connection.');
          },
        );
      } on http.ClientException catch (e) {
        // Handle connection refused or network errors
        if (e.message.contains('Connection refused') || 
            e.message.contains('Failed host lookup') ||
            e.message.contains('ERR_CONNECTION_REFUSED')) {
          return {
            'success': false,
            'error': 'Backend server is not running. Please start the backend server:\n'
                     '1. Open terminal in the backend folder\n'
                     '2. Run: npm install (if first time)\n'
                     '3. Run: npm start\n'
                     '4. Server should be running on http://localhost:3001',
          };
        }
        rethrow;
      }

      // Parse response
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw FormatException('Invalid JSON response: ${response.body}');
      }

      // Handle success responses (200, 201)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Check if response has success field
        if (responseData.containsKey('success') && responseData['success'] == true) {
          return {
            'success': true,
            'data': responseData['data'] ?? responseData,
          };
        }
        // If no success field, assume success for 2xx status
        return {
          'success': true,
          'data': responseData,
        };
      }

      // Handle error responses (4xx, 5xx)
      return {
        'success': false,
        'error': responseData['error'] ?? 
                 responseData['message'] ?? 
                 'Login failed with status ${response.statusCode}',
      };
    } on FormatException catch (e) {
      return {
        'success': false,
        'error': 'Invalid response format: ${e.message}',
      };
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.message}. Please check your internet connection.',
      };
    } on Exception catch (e) {
      return {
        'success': false,
        'error': e.toString().replaceFirst('Exception: ', ''),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }
}

