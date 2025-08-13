import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/cubits/auth_cubit.dart';
import 'package:mapsapp/cubits/auth_state.dart';
import 'package:mapsapp/generated/l10n.dart';
import 'package:mapsapp/pages/login_page.dart';
import 'package:mapsapp/widgets/custom_googlemaps.dart';
import 'package:mapsapp/widgets/custom_widget.dart';
import 'package:mapsapp/widgets/my_button.dart';

class RegisterationPage extends StatefulWidget {
  const RegisterationPage({super.key});

  @override
  State<RegisterationPage> createState() => _RegisterationPageState();
}

class _RegisterationPageState extends State<RegisterationPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Image.asset(
                'assets/images/car.png',
                width: 200,
                height: 200,
              ),
              const Text(
                'BAWQ Maps Task',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'pacifico',
                ),
              ),
              const SizedBox(height: 50),
              Row(
                children: [
                  Text(
                    S.of(context).register,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Username
              CustomWidget(
                hintText: S.of(context).username,
                controller: usernameController,
              ),
              const SizedBox(height: 20),

              // Email
              CustomWidget(
                hintText: S.of(context).email,
                controller: emailController,
              ),
              const SizedBox(height: 20),

              // Password
              CustomWidget(
                hintText: S.of(context).password,
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Confirm Password
              CustomWidget(
                hintText: S.of(context).confirm_password,
                controller: confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),

              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomGooglemaps(),
                      ),
                    );
                  } else if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }
                  return MyButton(
                    text: S.of(context).sign_up,
                    onTap: () {
                      final username = usernameController.text.trim();
                      final email = emailController.text.trim();
                      final password = passwordController.text;
                      final confirmPassword = confirmPasswordController.text;

                      if (username.isEmpty ||
                          email.isEmpty ||
                          password.isEmpty ||
                          confirmPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text(S.of(context).please_fill_all_fields)),
                        );
                        return;
                      }

                      if (password != confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text(S.of(context).passwords_dont_match)),
                        );
                        return;
                      }

                      context.read<AuthCubit>().registerUser(
                          username, email, password, confirmPassword);
                      print('$username, $email, $password, $confirmPassword');
                    },
                  );
                },
              ),

              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).already_have_an_account,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: Text(
                      S.of(context).login,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
