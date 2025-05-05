import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/link_handler.dart';
import 'package:meal_saver_phone/services/notification_service.dart';
import 'package:meal_saver_phone/services/permission_service.dart';
import 'package:meal_saver_phone/views/profile_page.dart';
import 'package:meal_saver_phone/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await requestNotificationPermission();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color.fromARGB(255, 22, 22, 22),
      ),
      debugShowCheckedModeBanner: false,
      routes: {'/profile': (context) => const ProfilePage()},
      home: Stack(children: [const SplashScreen(), const LinkHandler()]),
    );
  }
}
