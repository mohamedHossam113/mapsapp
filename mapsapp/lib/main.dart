import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/cubits/auth_cubit.dart';
import 'package:mapsapp/pages/login_page.dart';
import 'package:mapsapp/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mapsapp/widgets/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TestGoogleMapsWithFlutter());
}

class TestGoogleMapsWithFlutter extends StatelessWidget {
  const TestGoogleMapsWithFlutter({super.key});

  @override
  Widget build(BuildContext context) {
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

        return BlocProvider(
          create: (context) => AuthCubit(AuthService()),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: token != null && token.isNotEmpty
                ? const MainPage() // ✅ Logged in
                : const LoginPage(), // ❌ No token, go to login
          ),
        );
      },
    );
  }

  Future<String?> _getSavedToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'token');
  }
}
