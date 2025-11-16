import 'api_service.dart';
import '../providers/auth_provider.dart';

/// AuthService - Wrapper around ApiService for authentication
/// 
/// This service now uses ApiService which connects to the backend proxy server.
/// The proxy handles authentication with Huawei Cloud and resolves CORS issues.
class AuthService {

  static Future<Map<String, dynamic>> signup(String username, String email, String password, UserRole role) async {
    // Use ApiService which handles the proxy connection
    final result = await ApiService.signup(
      username: username,
      email: email,
      password: password,
      role: role,
    );
    
    // Debug prints
    // ignore: avoid_print
    print('[AuthService.signup] result=$result');
    
    // Convert ApiService format to AuthService format
    if (result['success'] == true) {
      return result['data'] ?? result;
    } else {
      throw Exception(result['error'] ?? 'Signup failed');
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    // Use ApiService which handles the proxy connection
    final result = await ApiService.login(
      email: email,
      password: password,
    );
    
    // Debug prints
    // ignore: avoid_print
    print('[AuthService.login] result=$result');
    
    // Convert ApiService format to AuthService format
    if (result['success'] == true) {
      return result['data'] ?? result;
    } else {
      throw Exception(result['error'] ?? 'Login failed');
    }
  }
}


