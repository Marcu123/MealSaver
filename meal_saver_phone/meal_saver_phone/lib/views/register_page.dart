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
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final ApiService apiService = ApiService();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Set<String> validatedFields = {};

  File? userImage;

  void _setUserImage(File? image) {
    setState(() {
      userImage = image;
    });
  }

  String sanitizeInput(String input) {
    return input.replaceAll(
      RegExp(r'<[^>]*>|script', caseSensitive: false),
      '',
    );
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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

  Future<void> register() async {
    setState(() {
      final fields = {
        'firstName': firstNameController,
        'lastName': lastNameController,
        'username': usernameController,
        'email': emailController,
        'password': passwordController,
      };
      for (var entry in fields.entries) {
        validatedFields.add(entry.key);
      }
    });

    if (isLoading || !_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final firstName = sanitizeInput(firstNameController.text.trim());
    final lastName = sanitizeInput(lastNameController.text.trim());
    final email = sanitizeInput(emailController.text.trim());
    final username = sanitizeInput(usernameController.text.trim());
    final password = passwordController.text;

    try {
      final responseMessage = await apiService.registerUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        username: username,
        password: password,
      );

      if (!mounted) return;

      showSnackbar(responseMessage);

      if (responseMessage.toLowerCase().contains("check your email")) {
        // ✅ Încarcă imaginea și trimite URL-ul DOAR dacă există
        if (userImage != null) {
          final bytes = await userImage!.readAsBytes();
          final cloudUrl = await apiService.uploadToCloudinary(bytes);
          if (cloudUrl != null) {
            await apiService.sendImageUrlToBackend(username, cloudUrl);
          }
        }

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginPage(),
            transitionsBuilder:
                (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (_) {
      showSnackbar("Something went wrong.");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Widget buildInputField({
    required String fieldKey,
    required TextEditingController controller,
    required String label,
    required bool isPassword,
    required String? Function(String?) validator,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setState(() => validatedFields.add(fieldKey));
        }
      },
      child: Builder(
        builder:
            (context) => InputField(
              controller: controller,
              labelText: label,
              isPassword: isPassword,
              validator: (value) {
                if (!validatedFields.contains(fieldKey)) return null;
                return validator(value);
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 22, 22, 22),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
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
                      child: buildInputField(
                        fieldKey: 'firstName',
                        controller: firstNameController,
                        label: 'First Name',
                        isPassword: false,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'First name is required';
                          }
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value.trim())) {
                            return 'Only letters allowed';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: buildInputField(
                        fieldKey: 'lastName',
                        controller: lastNameController,
                        label: 'Last Name',
                        isPassword: false,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Last name is required';
                          }
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value.trim())) {
                            return 'Only letters allowed';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                buildInputField(
                  fieldKey: 'username',
                  controller: usernameController,
                  label: 'Username',
                  isPassword: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }
                    if (value.trim().length < 4) return 'Minimum 4 characters';
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                      return 'Only letters, numbers and _';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                buildInputField(
                  fieldKey: 'email',
                  controller: emailController,
                  label: 'Email',
                  isPassword: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                    ).hasMatch(value.trim())) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                buildInputField(
                  fieldKey: 'password',
                  controller: passwordController,
                  label: 'Password',
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (!RegExp(
                      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
                    ).hasMatch(value)) {
                      return '8+ chars, 1 letter, 1 number, 1 symbol';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                CustomButton1(
                  text: 'Register',
                  onPressed: isLoading ? null : register,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed:
                          () => navigateWithFade(context, const LoginPage()),
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) =>
                              states.contains(WidgetState.pressed) ||
                                      states.contains(WidgetState.hovered)
                                  ? Colors.white
                                  : const Color.fromARGB(255, 130, 24, 230),
                        ),
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
      ),
    );
  }
}
