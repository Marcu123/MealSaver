import 'package:flutter/material.dart';

class CustomButton1 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton1({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        minimumSize: const Size(330, 50),
        backgroundColor: const Color.fromARGB(255, 130, 24, 230),
        foregroundColor: Colors.white,
      ),
      child: Text(text),
    );
  }
}
