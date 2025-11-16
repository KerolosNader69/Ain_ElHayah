import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Backend configuration service for managing API endpoints
/// across different platforms and environments
class BackendConfig {
  /// Get the appropriate backend URL based on the current platform
  /// 
  /// Returns:
  /// - Web: Uses environment variable or localhost
  /// - Android Emulator: Uses 10.0.2.2 (emulator host)
  /// - iOS Simulator: Uses localhost
  /// - Physical devices: Should use actual IP address
  static String getBackendUrl() {
    // Check for environment variable first (useful for production builds)
    const envBackendUrl = String.fromEnvironment('BACKEND_URL');
    if (envBackendUrl.isNotEmpty) {
      return envBackendUrl;
    }

    // Platform-specific defaults for development
    if (kIsWeb) {
      // For web, use localhost or relative URL
      return 'http://localhost:3001';
    } else if (Platform.isAndroid) {
      // Android emulator uses special IP to reach host machine
      return 'http://10.0.2.2:3001';
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return 'http://localhost:3001';
    } else {
      // Default fallback
      return 'http://localhost:3001';
    }
  }

  /// Check if backend is likely reachable (basic validation)
  /// This doesn't make an actual network call, just validates the URL format
  static bool isValidBackendUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
