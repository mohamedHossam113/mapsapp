import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/cubits/auth_state.dart';
import 'package:mapsapp/models/auth_response.dart';
import 'package:mapsapp/services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;

  AuthCubit(this.authService) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());

    try {
      final AuthResponse response = await authService.login(username, password);
      emit(AuthSuccess(token: response.token));
    } catch (e) {
      emit(AuthFailure(error: 'Login failed: ${e.toString()}'));
    }
  }

  Future<void> registerUser(String username, String email, String password,
      String confirmPassword) async {
    emit(AuthLoading());

    try {
      final AuthResponse response = await authService.registerUser(
          username, email, password, confirmPassword);
      print(' sfsf');
      emit(AuthSuccess(token: response.token));
    } catch (e) {
      emit(AuthFailure(error: 'Registration failed: ${e.toString()}'));
    }
  }
}
