import 'package:flutter/material.dart';
import 'package:mapsapp/cubits/l10n/applocalization.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn(Locale locale) : super(locale);

  @override
  String get appTitle => 'MapsApp';

  @override
  String get welcome => 'Welcome';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get devices => 'Devices';

  @override
  String get map => 'Map';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get speed => 'Speed';

  @override
  String get status => 'Status';

  @override
  String get lastUpdated => 'Last Updated';
}
