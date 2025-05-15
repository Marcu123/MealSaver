import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:meal_saver_phone/views/login_page.dart';
import 'package:meal_saver_phone/views/register_page.dart';
import '../widgets/custom_button1.dart';
import '../widgets/custom_button2.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  late VideoPlayerController _controller;
  double _opacity = 1.0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/background.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleNavigation(Widget page) {
    if (_isNavigating) return;
    setState(() {
      _opacity = 0.0;
      _isNavigating = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      ).then((_) {
        setState(() {
          _opacity = 1.0;
          _isNavigating = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _opacity,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            ),
          Container(color: Colors.black.withOpacity(0.4)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 250,
                    height: 250,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'MealSaver',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Your partner in reducing food waste',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 35),
                  CustomButton1(
                    text: 'Get started',
                    onPressed: () => handleNavigation(const LoginPage()),
                  ),
                  const SizedBox(height: 15),
                  CustomButton2(
                    text: 'Create an account',
                    onPressed: () => handleNavigation(const RegisterPage()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
