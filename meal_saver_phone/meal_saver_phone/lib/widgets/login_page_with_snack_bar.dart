import 'package:flutter/material.dart';
import 'package:meal_saver_phone/views/login_page.dart';

class LoginPageWithSnackBar extends StatelessWidget {
  final String message;

  const LoginPageWithSnackBar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });

    return const LoginPage();
  }
}
