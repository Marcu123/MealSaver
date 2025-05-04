import 'package:flutter/material.dart';
import 'package:meal_saver_phone/models/recipe_dto.dart';

class RecipeSlider extends StatelessWidget {
  final List<RecipeDTO> recipes;
  final Future<void> Function() onLoadMore;
  final bool showCategories;
  final bool isLoadingMore;

  const RecipeSlider({
    super.key,
    required this.recipes,
    required this.onLoadMore,
    this.showCategories = true,
    this.isLoadingMore = false,
  });

  void _showRecipeDetails(BuildContext context, RecipeDTO recipe) {
    final String imageUrl =
        (recipe.imageName.startsWith('http'))
            ? "http://10.0.2.2:8082/proxy/image?url=${Uri.encodeComponent(recipe.imageName)}"
            : "http://10.0.2.2:8082/images/${recipe.imageName}";

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 34, 34, 34),
            title: Text(
              recipe.title,
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.broken_image,
                            color: Colors.white70,
                            size: 100,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Ingredients:",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...recipe.cleanedIngredients.map(
                    (i) => Text(
                      "- $i",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Instructions:",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    recipe.instructions.isNotEmpty
                        ? recipe.instructions
                        : "No instructions provided.",
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (showCategories && recipe.categories.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Categories:",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      children:
                          recipe.categories
                              .map(
                                (cat) => Chip(
                                  label: Text(cat),
                                  backgroundColor: Colors.deepPurple.shade200,
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCards = recipes.length + 1;

    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 400,
          child: PageView.builder(
            itemCount: totalCards,
            controller: PageController(viewportFraction: 0.85),
            itemBuilder: (context, index) {
              if (index == recipes.length) {
                return GestureDetector(
                  onTap: onLoadMore,
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    color: Colors.white10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child:
                          isLoadingMore
                              ? const SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.deepPurple,
                                ),
                              )
                              : Icon(
                                Icons.add_circle_outline,
                                color: Colors.deepPurple.shade200,
                                size: 60,
                              ),
                    ),
                  ),
                );
              }

              final recipe = recipes[index];
              final String imageUrl =
                  (recipe.imageName.startsWith('http'))
                      ? "http://10.0.2.2:8082/proxy/image?url=${Uri.encodeComponent(recipe.imageName)}"
                      : "http://10.0.2.2:8082/images/${recipe.imageName}";

              return GestureDetector(
                onTap: () => _showRecipeDetails(context, recipe),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  color: Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.white70,
                                ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          recipe.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
