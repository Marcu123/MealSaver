import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/link_handler.dart';
import 'package:meal_saver_phone/services/notification_service.dart';
import 'package:meal_saver_phone/services/permission_service.dart';
import 'package:meal_saver_phone/views/profile_page.dart';
import 'views/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await requestNotificationPermission();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {'/profile': (context) => const ProfilePage()},
      home: Stack(children: [const LandingPage(), const LinkHandler()]),
    );
  }
}
