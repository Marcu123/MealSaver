import 'package:flutter/material.dart';
import 'package:meal_saver_phone/views/login_page.dart';
import 'package:meal_saver_phone/views/register_page.dart';
import '../widgets/custom_button1.dart';
import '../widgets/custom_button2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 350, height: 350),

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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 15),

                CustomButton2(
                  text: 'Create an account',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
