import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/views/login_page.dart';
import 'package:meal_saver_phone/views/update_profile_page.dart';
import 'package:meal_saver_phone/widgets/custom_app_bar.dart';
import 'package:meal_saver_phone/widgets/custom_button1.dart';
import 'package:meal_saver_phone/widgets/custom_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "";
  String email = "";
  String fullName = "";
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await ApiService().getCurrentUser();
    if (data != null && mounted) {
      setState(() {
        username = data['username'] ?? "";
        email = data['email'] ?? "";
        fullName =
            "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
        profileImageUrl = data['profileImageUrl'];
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 30, 30, 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Change Password',
            style: TextStyle(color: Colors.white),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Old Password',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (!RegExp(
                      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
                    ).hasMatch(value)) {
                      return '8+ chars, 1 letter, 1 number, 1 symbol';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final result = await ApiService().changePassword(
                          oldPasswordController.text,
                          newPasswordController.text,
                        );

                        if (!context.mounted) return;
                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(result)));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      backgroundColor: const Color.fromARGB(255, 130, 24, 230),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: const CustomAppBar(title: "Profile", showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child:
                  profileImageUrl != null && profileImageUrl!.isNotEmpty
                      ? CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(profileImageUrl!),
                      )
                      : const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage("assets/images/logo.png"),
                      ),
            ),
            const SizedBox(height: 20),
            Text(
              fullName,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              "@$username",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              email,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 30, 30, 30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CustomButton2(
                    text: "Update Information",
                    onPressed: () async {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UpdateProfilePage(),
                        ),
                      );

                      if (updated == true) {
                        _logout();
                      } else {
                        await _loadUserData();
                      }
                    },
                  ),

                  const SizedBox(height: 15),
                  CustomButton1(
                    text: "Change Password",
                    onPressed: _showChangePasswordDialog,
                  ),
                  const SizedBox(height: 15),
                  CustomButton1(
                    text: "Log Out",
                    onPressed: () {
                      _logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
