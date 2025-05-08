import 'package:flutter/material.dart';
import 'package:meal_saver_phone/views/add_food_page.dart';
import 'package:meal_saver_phone/views/home_page.dart';
import 'package:meal_saver_phone/views/my_foods_page.dart';
import 'package:meal_saver_phone/views/chef_battle_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNav({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddFoodPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyFoodsPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChefBattlePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(255, 46, 46, 46),
      selectedItemColor: const Color.fromARGB(255, 130, 24, 230),
      unselectedItemColor: Colors.white,
      currentIndex: selectedIndex >= 0 && selectedIndex < 4 ? selectedIndex : 0,
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Add',
        ),
        BottomNavigationBarItem(icon: Icon(MdiIcons.fridge), label: 'My Foods'),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.fromString('food-hot-dog')),
          label: 'Chef Battle',
        ),
      ],
    );
  }
}
