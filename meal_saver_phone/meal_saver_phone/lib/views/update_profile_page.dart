import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/widgets/custom_app_bar.dart';
import 'package:meal_saver_phone/widgets/custom_button1.dart';
import 'package:meal_saver_phone/widgets/input_field.dart';
import 'package:meal_saver_phone/widgets/image_picker_widget.dart';
import 'package:meal_saver_phone/services/cloudinary_service.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();

  File? newProfileImage;
  String? profileImageUrl;
  String? existingImageUrl;

  void _setImage(File? image) {
    setState(() => newProfileImage = image);
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final data = await ApiService().getCurrentUser();
    if (!mounted || data == null) return;
    setState(() {
      firstNameController.text = data['firstName'] ?? '';
      lastNameController.text = data['lastName'] ?? '';
      emailController.text = data['email'] ?? '';
      usernameController.text = data['username'] ?? '';
      existingImageUrl = data['profileImageUrl'];
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final username = usernameController.text.trim();

    if (newProfileImage != null) {
      final imageUrl = await uploadToCloudinary(newProfileImage!);
      profileImageUrl = imageUrl;
    }

    final response = await ApiService().updateUserInfo(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      username: username,
      profileImageUrl: profileImageUrl,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(response)));

    if (response.toLowerCase().contains("success")) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: const CustomAppBar(title: "Update Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ImagePickerWidget(
                onImageSelected: _setImage,
                username: usernameController.text,
                existingImageUrl: existingImageUrl,
              ),
              const SizedBox(height: 20),
              InputField(
                controller: firstNameController,
                labelText: 'First Name',
                isPassword: false,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),
              InputField(
                controller: lastNameController,
                labelText: 'Last Name',
                isPassword: false,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),
              InputField(
                controller: emailController,
                labelText: 'Email',
                isPassword: false,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),
              InputField(
                controller: usernameController,
                labelText: 'Username',
                isPassword: false,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 30),
              CustomButton1(text: 'Update', onPressed: _updateProfile),
            ],
          ),
        ),
      ),
    );
  }
}
