import 'package:flutter/material.dart';
import 'package:meal_saver_phone/views/forgot_password.dart';
import 'package:meal_saver_phone/views/register_page.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button1.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 150, height: 150),
              const SizedBox(height: 10),
              const Text(
                'MealSaver',
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Hi there! Welcome back to MealSaver',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 35),

              InputField(
                controller: _usernameController,
                labelText: 'Enter your username',
                isPassword: false,
              ),

              const SizedBox(height: 15),

              InputField(
                controller: _passwordController,
                labelText: 'Enter your password',
                isPassword: true,
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage(),
                    ),
                  );
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white;
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.white;
                    }
                    return const Color.fromARGB(255, 130, 24, 230);
                  }),
                ),
                child: const Text(
                  'Forgot password!',
                  style: TextStyle(fontSize: 14.0),
                ),
              ),

              const SizedBox(height: 20),

              CustomButton1(
                text: 'Login',
                onPressed: () {
                  final username = _usernameController.text;
                  final password = _passwordController.text;
                },
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.white;
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.white;
                        }
                        return const Color.fromARGB(255, 130, 24, 230);
                      }),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
