import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meal_saver_phone/models/recipe_dto.dart';
import 'package:meal_saver_phone/widgets/custom_button2.dart';

void showRecipeFilterModal(
  BuildContext context,
  Function(
    List<RecipeDTO> recipes, {
    required String category,
    required List<String> ingredients,
  })
  onGenerate,
) {
  String selectedCategory = 'meat';
  List<String> selectedIngredients = [];
  int currentPage = 0;
  int size = 5;
  TextEditingController ingredientController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color.fromARGB(255, 34, 34, 34),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: StatefulBuilder(
          builder:
              (context, setStateModal) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Try something new",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedCategory,
                      dropdownColor: Colors.black,
                      iconEnabledColor: Colors.white,
                      items:
                          [
                                'meat',
                                'seafood',
                                'vegetarian',
                                'vegan',
                                'dessert',
                                'salad',
                                'baked',
                                'pasta',
                                'rice & grains',
                                'soup & stew',
                                'snack',
                                'spicy',
                                'breakfast',
                                'other',
                              ]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (val) => setStateModal(() {
                            selectedCategory = val!;
                          }),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ingredientController,
                            decoration: const InputDecoration(
                              hintText: "Add ingredient",
                              hintStyle: TextStyle(color: Colors.white70),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            setStateModal(() {
                              if (ingredientController.text.isNotEmpty) {
                                selectedIngredients.add(
                                  ingredientController.text.toLowerCase(),
                                );
                                ingredientController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 6,
                      children:
                          selectedIngredients
                              .map(
                                (ing) => Chip(
                                  label: Text(ing),
                                  backgroundColor: Colors.deepPurple.shade200,
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  deleteIconColor: Colors.white,
                                  onDeleted:
                                      () => setStateModal(
                                        () => selectedIngredients.remove(ing),
                                      ),
                                ),
                              )
                              .toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (currentPage > 0) {
                              setStateModal(() => currentPage--);
                            }
                          },
                          child: const Text("Prev"),
                        ),
                        Text(
                          "Page: ${currentPage + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            setStateModal(() => currentPage++);
                          },
                          child: const Text("Next"),
                        ),
                      ],
                    ),
                    CustomButton2(
                      text: "Generate",
                      onPressed: () async {
                        Navigator.pop(context);
                        final recipes = await fetchFilteredRecipes(
                          selectedCategory,
                          selectedIngredients,
                          currentPage,
                          size,
                        );
                        onGenerate(
                          recipes,
                          category: selectedCategory,
                          ingredients: selectedIngredients,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
        ),
      );
    },
  );
}

Future<List<RecipeDTO>> fetchFilteredRecipes(
  String category,
  List<String> ingredients,
  int page,
  int size,
) async {
  final uri = Uri.parse("http://10.0.2.2:8082/api/recipes/filter").replace(
    queryParameters: {
      'category': category,
      'ingredients': ingredients,
      'page': '$page',
      'size': '$size',
    },
  );
  print("📡 Sending request to: $uri");

  final response = await http.get(uri);
  print("📥 Response status: ${response.statusCode}");
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("📦 Data received: ${data.length} items");
    return List<RecipeDTO>.from(data.map((item) => RecipeDTO.fromJson(item)));
  } else {
    print("❌ Failed to fetch recipes: ${response.body}");
    return [];
  }
}
