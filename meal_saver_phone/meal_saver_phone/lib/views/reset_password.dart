import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/views/login_page.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button1.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;
  const ResetPasswordPage({required this.token, super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final ApiService _apiService = ApiService();

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final result = await _apiService.resetPassword(
      widget.token,
      passwordController.text,
    );

    if (!mounted) return;

    if (result.contains("successfully")) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Reset Your Password",
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
              const SizedBox(height: 20),
              InputField(
                controller: passwordController,
                labelText: 'New Password',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Password is required';
                  if (!RegExp(
                    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
                  ).hasMatch(value)) {
                    return 'Min 8 chars, 1 letter, 1 number, 1 special char';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomButton1(
                text: "Reset Password",
                onPressed: isLoading ? null : _resetPassword,
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
