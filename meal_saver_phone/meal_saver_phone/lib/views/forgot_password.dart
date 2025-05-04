import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/views/login_page.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button1.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService();

  void navigateWithFade(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    final message = await _apiService.sendForgotPasswordEmail(email);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
              const SizedBox(height: 5),
              const Text(
                'Forgot your password?',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 30),
              InputField(
                controller: _emailController,
                labelText: 'Enter your email',
                isPassword: false,
              ),
              const SizedBox(height: 20),
              CustomButton1(
                text: 'Send email verification',
                onPressed: _handleForgotPassword,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Want to login again?',
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      navigateWithFade(context, const LoginPage());
                    },
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.pressed) ||
                            states.contains(WidgetState.hovered)) {
                          return Colors.white;
                        }
                        return const Color.fromARGB(255, 130, 24, 230);
                      }),
                    ),
                    child: const Text(
                      'Login',
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
