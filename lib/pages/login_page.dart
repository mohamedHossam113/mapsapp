import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/cubits/auth_cubit.dart';
import 'package:mapsapp/cubits/auth_state.dart';
import 'package:mapsapp/generated/l10n.dart';
import 'package:mapsapp/pages/registeration_page.dart';
import 'package:mapsapp/widgets/custom_widget.dart';
import 'package:mapsapp/widgets/main_page.dart';
import 'package:mapsapp/widgets/my_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
            });
          } else if (state is AuthFailure) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            });
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                Text(
                  S.of(context).login,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                CustomWidget(
                  hintText: S.of(context).username,
                  onChanged: (value) {},
                  controller: emailController,
                ),
                const SizedBox(height: 20),
                CustomWidget(
                  hintText: S.of(context).password,
                  onChanged: (value) {},
                  controller: passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: state is AuthLoading
                      ? '${S.of(context).loading}...'
                      : S.of(context).sign_in,
                  onTap: () {
                    final username = emailController.text.trim();
                    final password = passwordController.text.trim();

                    if (username.isNotEmpty && password.isNotEmpty) {
                      context.read<AuthCubit>().login(username, password);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              S.of(context).please_enter_username_and_password),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).dont_have_account,
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
                            builder: (context) => const RegisterationPage(),
                          ),
                        );
                      },
                      child: Text(
                        ' ${S.of(context).register}',
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
          );
        },
      ),
    );
  }
}
