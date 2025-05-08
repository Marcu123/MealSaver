import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meal_saver_phone/views/home_page.dart';
import 'package:meal_saver_phone/views/landing_page.dart';
import 'package:meal_saver_phone/views/reset_password.dart';
import 'package:meal_saver_phone/widgets/login_page_with_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppLinks _appLinks = AppLinks();
  bool _handledDeepLink = false;

  @override
  void initState() {
    super.initState();
    _listenToLinks();
    _checkLogin();
  }

  void _listenToLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri == null) return;

      print("📨 Received deep link: $uri");
      final token = uri.queryParameters['token'];

      if (uri.path == "/api/auth/verify" && token != null) {
        _handledDeepLink = true;
        try {
          final response = await http.get(
            Uri.parse(
              "https://0075-194-176-167-117.ngrok-free.app/api/auth/verify?token=$token",
            ),
          );

          if (!mounted) return;

          if (response.statusCode == 200) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auth_token');

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder:
                    (_) => LoginPageWithSnackBar(
                      message: "✅ Account activated! You can now log in.",
                    ),
              ),
              (_) => false,
            );
          } else {
            _showDialog("Activation failed", response.body);
          }
        } catch (e) {
          _showDialog("Error", "Something went wrong: $e");
        }
      } else if (uri.path == "/api/auth/reset-password" && token != null) {
        _handledDeepLink = true;

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResetPasswordPage(token: token)),
        );
      }
    });
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    await Future.delayed(const Duration(milliseconds: 1000));

    if (_handledDeepLink) return;

    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LandingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
