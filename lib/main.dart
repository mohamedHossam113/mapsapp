import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mapsapp/cubits/auth_cubit.dart';
import 'package:mapsapp/cubits/device_cubit.dart';
import 'package:mapsapp/cubits/geofence_cubit.dart';
import 'package:mapsapp/generated/l10n.dart';
import 'package:mapsapp/management/language_management.dart';
import 'package:mapsapp/pages/login_page.dart';
import 'package:mapsapp/pages/settings_page.dart';
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
    final languageManager = Provider.of<LanguageManager>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: languageManager.currentLocale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: languageManager.supportedLocales,
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
      builder: (context, child) {
        return FutureBuilder<String?>(
          future: _getSavedToken(),
          builder: (context, snapshot) {
            // Show loader while waiting
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // When future completes (even with null)
            final token = snapshot.data;
            return Navigator(
              initialRoute:
                  (token != null && token.isNotEmpty) ? '/main' : '/login',
              onGenerateRoute: (settings) {
                switch (settings.name) {
                  case '/main':
                    return MaterialPageRoute(builder: (_) => const MainPage());
                  case '/settings':
                    return MaterialPageRoute(
                        builder: (_) => const SettingsPage());
                  case '/login':
                  default:
                    return MaterialPageRoute(builder: (_) => const LoginPage());
                }
              },
            );
          },
        );
      },
    );
  }
}
