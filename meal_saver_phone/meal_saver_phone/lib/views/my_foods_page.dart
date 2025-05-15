import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/models/food_dto.dart';
import 'package:meal_saver_phone/widgets/animated_fridge.dart';
import 'package:meal_saver_phone/widgets/custom_app_bar.dart';
import 'package:meal_saver_phone/widgets/custom_bottom_bar.dart';
import 'package:meal_saver_phone/views/home_page.dart';

class MyFoodsPage extends StatefulWidget {
  const MyFoodsPage({super.key});

  @override
  State<MyFoodsPage> createState() => _MyFoodsPageState();
}

class _MyFoodsPageState extends State<MyFoodsPage> {
  List<FoodDTO> allFoods = [];
  List<FoodDTO> expiringSoonFoods = [];
  List<FoodDTO> expiredFoods = [];
  bool isLoading = true;
  bool fridgeOpened = false;

  @override
  void initState() {
    super.initState();
    _loadAllSections();
  }

  Future<void> _loadAllSections() async {
    try {
      final all = await ApiService().getMyFoods();
      final expiring = await ApiService().getExpiringSoonFoods();
      final expired = await ApiService().getExpiredFoods();
      if (!mounted) return;
      setState(() {
        allFoods = all;
        expiringSoonFoods = expiring;
        expiredFoods = expired;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: CustomAppBar(title: 'My Fridge', showBack: fridgeOpened),
      bottomNavigationBar: const CustomBottomNav(selectedIndex: 2),
      body: WillPopScope(
        onWillPop: () async {
          if (fridgeOpened) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
            return false;
          }
          return true;
        },
        child: Center(
          child:
              isLoading
                  ? const CircularProgressIndicator()
                  : fridgeOpened
                  ? _buildSections()
                  : AnimatedFridge(
                    onFridgeOpened: () {
                      setState(() => fridgeOpened = true);
                    },
                  ),
        ),
      ),
    );
  }

  Widget _buildSections() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection("Expiring Soon", expiringSoonFoods),
          const SizedBox(height: 20),
          _buildSection("Expired", expiredFoods),
          const SizedBox(height: 20),
          _buildSection("All Foods", allFoods),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<FoodDTO> foods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        foods.isEmpty
            ? const Text(
              "No items in this section.",
              style: TextStyle(color: Colors.white70),
            )
            : Column(children: foods.map(_buildFoodCard).toList()),
      ],
    );
  }

  Widget _buildFoodCard(FoodDTO food) {
    final date = DateTime.tryParse(food.expirationDate);
    final formattedDate =
        date != null
            ? DateFormat('MMM dd, yyyy').format(date)
            : food.expirationDate;

    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(food.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          'Size: ${food.size}g\nExpires on: $formattedDate',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.deepPurpleAccent),
              onPressed: () => _showEditDialog(food),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _deleteFood(food.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(FoodDTO food) {
    final nameController = TextEditingController(text: food.name);
    final sizeController = TextEditingController(text: food.size.toString());
    DateTime selectedDate =
        DateTime.tryParse(food.expirationDate) ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 33, 33, 33),
          title: const Text(
            "Update Food",
            style: TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: sizeController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Size (g)",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                        builder:
                            (context, child) =>
                                Theme(data: ThemeData.dark(), child: child!),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                      style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateFood(
                  food.name,
                  nameController.text,
                  int.tryParse(sizeController.text) ?? food.size,
                  selectedDate.toIso8601String(),
                );
              },
              child: const Text(
                "Update",
                style: TextStyle(color: Colors.deepPurpleAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateFood(
    String oldName,
    String newName,
    int newSize,
    String newDate,
  ) async {
    final user = await ApiService().getCurrentUser();
    final username = user?['username'] ?? '';
    final food = allFoods.firstWhere((f) => f.name == oldName);

    final response = await ApiService().updateFood(oldName, {
      'id': food.id,
      'name': newName,
      'size': newSize,
      'expirationDate': newDate,
      'username': username,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(response)));
    await _loadAllSections();
  }

  Future<void> _deleteFood(int foodId) async {
    await ApiService().deleteFood(foodId);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Food deleted.")));
    await _loadAllSections();
  }
}
