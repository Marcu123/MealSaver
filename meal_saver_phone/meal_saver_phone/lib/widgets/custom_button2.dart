import 'package:flutter/material.dart';

class CustomButton2 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton2({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        minimumSize: const Size(330, 50),
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 22, 22, 22),
      ),
      child: Text(text),
    );
  }
}
