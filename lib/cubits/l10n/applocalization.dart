import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'MapsApp',
      'welcome': 'Welcome',
      'changeLanguage': 'Change Language',
      'devices': 'Devices',
      'map': 'Map',
      'settings': 'Settings',
      'logout': 'Logout',
      'speed': 'Speed',
      'status': 'Status',
      'lastUpdated': 'Last Updated',
    },
    'ar': {
      'appTitle': 'تطبيق الخرائط',
      'welcome': 'مرحبا',
      'changeLanguage': 'تغيير اللغة',
      'devices': 'الأجهزة',
      'map': 'الخريطة',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'speed': 'السرعة',
      'status': 'الحالة',
      'lastUpdated': 'آخر تحديث',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get changeLanguage =>
      _localizedValues[locale.languageCode]!['changeLanguage']!;
  String get devices => _localizedValues[locale.languageCode]!['devices']!;
  String get map => _localizedValues[locale.languageCode]!['map']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get speed => _localizedValues[locale.languageCode]!['speed']!;
  String get status => _localizedValues[locale.languageCode]!['status']!;
  String get lastUpdated =>
      _localizedValues[locale.languageCode]!['lastUpdated']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
