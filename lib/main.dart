import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ Add this import
import 'package:mapsapp/cubits/auth_cubit.dart';
import 'package:mapsapp/cubits/device_cubit.dart';
import 'package:mapsapp/cubits/geofence_cubit.dart';
import 'package:mapsapp/cubits/l10n/applocalization.dart';
import 'package:mapsapp/management/language_management.dart';
import 'package:mapsapp/pages/login_page.dart';
import 'package:mapsapp/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mapsapp/services/device_service.dart';
import 'package:mapsapp/services/geofence_service.dart';
import 'package:mapsapp/widgets/main_page.dart';
import 'package:provider/provider.dart';
import 'package:mapsapp/management/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const TestGoogleMapsWithFlutter());
}

class TestGoogleMapsWithFlutter extends StatelessWidget {
  const TestGoogleMapsWithFlutter({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => LanguageManager()),
        BlocProvider<DeviceCubit>(
          create: (context) => DeviceCubit(DeviceService()),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(AuthService()),
        ),
        BlocProvider<GeofenceCubit>(
          create: (context) => GeofenceCubit(GeofenceService()),
        ),
      ],
      child: const _AppInitializer(),
    );
  }
}

class _AppInitializer extends StatelessWidget {
  const _AppInitializer();

  Future<String?> _getSavedToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'token');
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final languageManager = Provider.of<LanguageManager>(context); // ✅ Add this

    return FutureBuilder<String?>(
      future: _getSavedToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final token = snapshot.data;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // ✅ Add localization support
          locale: languageManager.currentLocale,
          supportedLocales: languageManager.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            cardColor: Colors.grey.shade100,
            colorScheme: const ColorScheme.light(
              surface: Colors.white,
              primary: Colors.black,
              error: Colors.red,
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.transparent,
            ),
            textTheme: const TextTheme(
              titleLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black87),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            cardColor: Colors.grey.shade900,
            colorScheme: const ColorScheme.dark(
              surface: Colors.black,
              primary: Colors.white,
              error: Colors.redAccent,
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.transparent,
            ),
            textTheme: const TextTheme(
              titleLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
          ),
          themeMode: themeManager.themeMode,
          home: token != null && token.isNotEmpty
              ? const MainPage()
              : const LoginPage(),
        );
      },
    );
  }
}
