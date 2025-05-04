import 'package:flutter/material.dart';
import 'package:meal_saver_phone/views/profile_page.dart';
import 'package:meal_saver_phone/views/my_foods_page.dart';
import 'package:meal_saver_phone/widgets/custom_bottom_bar.dart';
import 'package:meal_saver_phone/widgets/custom_button1.dart';
import 'package:meal_saver_phone/widgets/notification_drawer.dart';
import 'package:meal_saver_phone/widgets/recipe_filter_modal.dart'
    show showRecipeFilterModal, fetchFilteredRecipes;
import 'package:meal_saver_phone/widgets/recipe_slider.dart';
import 'package:meal_saver_phone/models/recipe_dto.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/services/stomp_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _unreadCount = 0;
  bool showCategories = true;
  bool isLoading = false;

  int aiRecipePage = 0;
  final int aiRecipeSize = 5;

  List<RecipeDTO> generatedRecipes = [];

  String? lastCategory;
  List<String>? lastIngredients;
  int currentPage = 0;
  int size = 5;

  String? profileImageUrl;
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchUnreadNotifications();
    _loadProfileImage();
    final stomp = StompService();
    stomp.onNotificationReceived = _fetchUnreadNotifications;
    stomp.connect();
  }

  Future<void> _loadProfileImage() async {
    final data = await ApiService().getCurrentUser();
    if (mounted && data != null) {
      setState(() {
        profileImageUrl = data['profileImageUrl'];
        isLoadingProfile = false;
      });
    } else {
      setState(() {
        isLoadingProfile = false;
      });
    }
  }

  @override
  void dispose() {
    StompService().disconnect();
    super.dispose();
  }

  Future<void> _fetchUnreadNotifications() async {
    final notifications = await ApiService().getNotifications();
    final unread = notifications.where((n) => !n.read).length;
    if (!mounted) return;
    setState(() {
      _unreadCount = unread;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyFoodsPage()),
      );
    }
  }

  void _openNotificationsDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  Future<void> _handleFilterResult(
    List<RecipeDTO> recipes, {
    required String category,
    required List<String> ingredients,
  }) async {
    if (!mounted) return;
    setState(() {
      lastCategory = category;
      lastIngredients = ingredients;
      currentPage = 0;
      generatedRecipes = recipes;
      showCategories = true;
    });
  }

  Future<void> _loadMoreRecipes() async {
    if (lastCategory == null || lastIngredients == null) return;
    if (!mounted) return;
    setState(() {
      currentPage++;
    });

    final more = await fetchFilteredRecipes(
      lastCategory!,
      lastIngredients!,
      currentPage,
      size,
    );

    if (!mounted) return;
    setState(() {
      generatedRecipes.addAll(more);
    });
  }

  Future<void> _generateAiRecipes() async {
    if (isLoading) return;

    if (!mounted) return;
    setState(() {
      isLoading = true;
      aiRecipePage = 0;
    });

    try {
      final response = await ApiService().getAiGeneratedRecipes(
        page: aiRecipePage,
        size: aiRecipeSize,
      );
      if (!mounted) return;
      setState(() {
        generatedRecipes =
            response.map((aiRecipe) => aiRecipe.toRecipeDTO()).toList();
        showCategories = false;
      });
    } catch (e) {
      print('Error generating AI recipes: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMoreAiRecipes() async {
    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
      aiRecipePage++;
    });

    try {
      final response = await ApiService().getAiGeneratedRecipes(
        page: aiRecipePage,
        size: aiRecipeSize,
      );
      if (!mounted) return;
      setState(() {
        generatedRecipes.addAll(
          response.map((aiRecipe) => aiRecipe.toRecipeDTO()),
        );
      });
    } catch (e) {
      print('Error loading more AI recipes: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder:
                (context) => Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                      onPressed: () => _openNotificationsDrawer(context),
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: CircleAvatar(
                radius: 18,
                backgroundImage:
                    isLoadingProfile
                        ? const AssetImage("assets/images/logo.png")
                        : profileImageUrl != null && profileImageUrl!.isNotEmpty
                        ? NetworkImage(profileImageUrl!)
                        : const AssetImage("assets/images/logo.png")
                            as ImageProvider,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                ).then((_) {
                  _loadProfileImage(); // reîncarcă poza la întoarcere
                });
              },
            ),
          ),
        ],
      ),
      endDrawer: NotificationsDrawer(onClose: _fetchUnreadNotifications),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                      const SizedBox(height: 20),
                      CustomButton1(
                        text: "Do you want to try something new?",
                        onPressed:
                            () => showRecipeFilterModal(context, (
                              recipes, {
                              required category,
                              required ingredients,
                            }) {
                              _handleFilterResult(
                                recipes,
                                category: category,
                                ingredients: ingredients,
                              );
                            }),
                      ),
                      const SizedBox(height: 20),
                      CustomButton1(
                        text: 'Let\'s save your food!',
                        onPressed: isLoading ? null : _generateAiRecipes,
                        child:
                            isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                      const SizedBox(height: 20),
                      if (generatedRecipes.isEmpty)
                        const Text(
                          "No recipes found. Try adjusting your filters.",
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        )
                      else
                        RecipeSlider(
                          recipes: generatedRecipes,
                          onLoadMore:
                              showCategories
                                  ? _loadMoreRecipes
                                  : _loadMoreAiRecipes,
                          showCategories: showCategories,
                          isLoadingMore: isLoading,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(selectedIndex: 0),
    );
  }
}
