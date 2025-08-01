import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/cubits/auth_cubit.dart';
import 'package:mapsapp/pages/login_page.dart';
import 'package:mapsapp/services/auth_service.dart';

void main() {
  runApp(const TestGoogleMapsWithFlutter());
}

class TestGoogleMapsWithFlutter extends StatelessWidget {
  const TestGoogleMapsWithFlutter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthService()),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
