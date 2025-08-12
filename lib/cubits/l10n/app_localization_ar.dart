import 'package:flutter/material.dart';
import 'package:mapsapp/cubits/l10n/applocalization.dart';

class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr(Locale locale) : super(locale);

  @override
  String get appTitle => 'تطبيق الخرائط';

  @override
  String get welcome => 'مرحبا';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get devices => 'الأجهزة';

  @override
  String get map => 'الخريطة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get speed => 'السرعة';

  @override
  String get status => 'الحالة';

  @override
  String get lastUpdated => 'آخر تحديث';
}
