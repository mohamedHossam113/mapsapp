import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/cubits/auth_cubit.dart';
import 'package:mapsapp/cubits/device_cubit.dart';
import 'package:mapsapp/cubits/geofence_cubit.dart';
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
    return ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: const _AppInitializer(),
    );
  }
}

class _AppInitializer extends StatelessWidget {
  const _AppInitializer({super.key});

  Future<String?> _getSavedToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'token');
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

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

        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => DeviceCubit(DeviceService())),
            BlocProvider(create: (_) => AuthCubit(AuthService())),
            BlocProvider(create: (_) => GeofenceCubit(GeofenceService())),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              cardColor: Colors.grey.shade100,
              colorScheme: const ColorScheme.light(
                background: Colors.white,
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
              colorScheme: ColorScheme.dark(
                background: Colors.black,
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
          ),
        );
      },
    );
  }
}
