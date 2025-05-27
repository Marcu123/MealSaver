import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:http/http.dart' as http;
import 'package:meal_saver_phone/views/reset_password.dart';
import 'package:meal_saver_phone/widgets/login_page_with_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinkHandler extends StatefulWidget {
  const LinkHandler({super.key});

  @override
  State<LinkHandler> createState() => _LinkHandlerState();
}

class _LinkHandlerState extends State<LinkHandler> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _listenToLinks();
  }

  void _listenToLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri == null) return;

      final token = uri.queryParameters['token'];

      if (uri.path == "/api/auth/verify" && token != null) {
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
                    (newContext) => LoginPageWithSnackBar(
                      message: "Account activated! You can now log in.",
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

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
