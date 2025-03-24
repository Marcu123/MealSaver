import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/views/login_page.dart';
import 'package:meal_saver_phone/widgets/image_picker_widget.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button1.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final ApiService apiService = ApiService();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> register() async {
    try {
      final responseMessage = await apiService.registerUser(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        username: usernameController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(responseMessage)));

      if (responseMessage == "Registration successful!") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception:", "").trim()),
        ),
      );
    }
  }

  File? userImage;

  void _setUserImage(File? image) {
    setState(() {
      userImage = image;
    });
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
              ImagePickerWidget(onImageSelected: _setUserImage),
              const SizedBox(height: 20),

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
                'Create your account',
                style: TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: InputField(
                      controller: firstNameController,
                      labelText: 'First Name',
                      isPassword: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InputField(
                      controller: lastNameController,
                      labelText: 'Last Name',
                      isPassword: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              InputField(
                controller: usernameController,
                labelText: 'Username',
                isPassword: false,
              ),

              const SizedBox(height: 15),

              InputField(
                controller: emailController,
                labelText: 'Email',
                isPassword: false,
              ),

              const SizedBox(height: 15),

              InputField(
                controller: passwordController,
                labelText: 'Password',
                isPassword: true,
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 20),

              CustomButton1(
                text: 'Register',
                onPressed: () {
                  register();
                },
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
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
