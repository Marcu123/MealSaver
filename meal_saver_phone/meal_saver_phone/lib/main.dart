import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/notification_service.dart';
import 'package:meal_saver_phone/services/permission_service.dart';
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
  }
}
