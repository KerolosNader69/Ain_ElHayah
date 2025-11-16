import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

enum UserRole { patient, doctor }

class AuthProvider extends ChangeNotifier {
  static const String _keyIsLoggedIn = 'auth.isLoggedIn';
  static const String _keyEmail = 'auth.email';
  static const String _keyRole = 'auth.role';
  static const String _keyOnboardingCompleted = 'auth.onboardingCompleted';

  bool _isLoggedIn = false;
  String? _email;
  UserRole? _role;
  bool _isLoading = false;
  bool _onboardingCompleted = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get email => _email;
  UserRole? get role => _role;
  bool get isLoading => _isLoading;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get needsOnboarding => _role == UserRole.doctor && !_onboardingCompleted;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    _email = prefs.getString(_keyEmail);
    _onboardingCompleted = prefs.getBool(_keyOnboardingCompleted) ?? false;
    final roleStr = prefs.getString(_keyRole);
    if (roleStr == 'doctor') {
      _role = UserRole.doctor;
    } else if (roleStr == 'patient') {
      _role = UserRole.patient;
    } else {
      _role = null;
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login({required String email, required String password, required UserRole role}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await AuthService.login(email, password);
      // ignore: avoid_print
      print('[AuthProvider.login] response=$response');
      _isLoggedIn = true;
      _email = email.trim();
      _role = role;
      // For existing users, assume onboarding is completed
      _onboardingCompleted = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyEmail, _email!);
      await prefs.setString(_keyRole, role == UserRole.doctor ? 'doctor' : 'patient');
      await prefs.setBool(_keyOnboardingCompleted, true);
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> signUp({required String username, required String email, required String password, required UserRole role}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await AuthService.signup(username, email, password, role);
      // ignore: avoid_print
      print('[AuthProvider.signUp] response=$response');
      _isLoggedIn = true;
      _email = email.trim();
      _role = role;
      // For new signups, doctors need onboarding, patients don't
      _onboardingCompleted = role == UserRole.patient;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyEmail, _email!);
      await prefs.setString(_keyRole, role == UserRole.doctor ? 'doctor' : 'patient');
      await prefs.setBool(_keyOnboardingCompleted, _onboardingCompleted);
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeDoctorOnboarding() async {
    _onboardingCompleted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    _isLoggedIn = false;
    _email = null;
    _role = null;
    _onboardingCompleted = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyOnboardingCompleted);
    _isLoading = false;
    notifyListeners();
  }
}


