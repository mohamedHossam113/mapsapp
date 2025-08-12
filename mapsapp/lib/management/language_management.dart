import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageManager extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Locale _currentLocale = const Locale('en', 'US'); // Default to English

  Locale get currentLocale => _currentLocale;

  // ✅ Added missing getters that SettingsPage uses
  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isArabic => _currentLocale.languageCode == 'ar';

  // List of supported locales
  final List<Locale> supportedLocales = const [
    Locale('en', 'US'), // English
    Locale('ar', 'SA'), // Arabic
  ];

  LanguageManager() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final savedLanguage = await _storage.read(key: _languageKey);
      if (savedLanguage != null) {
        final parts = savedLanguage.split('_');
        if (parts.length == 2) {
          _currentLocale = Locale(parts[0], parts[1]);
          notifyListeners();
        }
      }
    } catch (e) {
      // Handle error, keep default locale
      print('Error loading saved language: $e');
    }
  }

  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();

      // Save the selected language
      try {
        await _storage.write(
          key: _languageKey,
          value: '${locale.languageCode}_${locale.countryCode}',
        );
      } catch (e) {
        print('Error saving language: $e');
      }
    }
  }

  // ✅ Added toggleLanguage method that SettingsPage uses
  Future<void> toggleLanguage() async {
    final newLocale =
        isArabic ? const Locale('en', 'US') : const Locale('ar', 'SA');
    await changeLanguage(newLocale);
  }

  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return locale.languageCode.toUpperCase();
    }
  }
}
