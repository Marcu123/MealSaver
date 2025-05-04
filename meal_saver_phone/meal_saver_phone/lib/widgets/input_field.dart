import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final String? Function(String?)? validator;

  const InputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.isPassword = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: const Color.fromARGB(255, 46, 46, 46),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 130, 24, 230),
            width: 2.5,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
}
