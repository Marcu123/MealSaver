import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/services/stomp_service.dart';
import 'package:meal_saver_phone/views/forgot_password.dart';
import 'package:meal_saver_phone/views/home_page.dart';
import 'package:meal_saver_phone/views/register_page.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button1.dart';

final StompService stompService = StompService();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final ApiService apiService = ApiService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final responseMessage = await apiService.loginUser(
        username: usernameController.text,
        password: passwordController.text,
      );

      debugPrint("🔐 Login response: $responseMessage");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(responseMessage)));

      if (responseMessage == "Login successful!") {
        try {
          await stompService.connect();
          debugPrint("✅ STOMP connected.");
        } catch (stompError, stack) {
          debugPrint("❌ STOMP connection error: $stompError");
          debugPrint("📍 Stacktrace: $stack");
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Login exception: $e");
      debugPrint("📍 Stacktrace: $stackTrace");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: ${e.toString().replaceAll("Exception:", "").trim()}",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
              const Text(
                'Hi there! Welcome back to MealSaver',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 35),
              InputField(
                controller: usernameController,
                labelText: 'Enter your username',
                isPassword: false,
              ),
              const SizedBox(height: 15),
              InputField(
                controller: passwordController,
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
                    if (states.contains(WidgetState.pressed) ||
                        states.contains(WidgetState.hovered)) {
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
                onPressed: isLoading ? null : login,
                child:
                    isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : null,
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
                        if (states.contains(WidgetState.pressed) ||
                            states.contains(WidgetState.hovered)) {
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
