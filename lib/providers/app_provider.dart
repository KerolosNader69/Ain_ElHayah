import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = _locale.languageCode == 'en' 
        ? const Locale('ar') 
        : const Locale('en');
    notifyListeners();
  }
}
