import 'package:flutter/material.dart';
import 'package:meal_saver_phone/models/recipe_dto.dart';
import 'package:html_unescape/html_unescape.dart';

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
    final unescape = HtmlUnescape();
    final String? rawImage = recipe.imageName;
    final bool hasValidImage = rawImage != null && rawImage.trim().isNotEmpty;

    final String imageUrl =
        hasValidImage
            ? (rawImage.startsWith('http')
                ? "http://10.0.2.2:8082/proxy/image?url=${Uri.encodeComponent(rawImage)}"
                : "http://10.0.2.2:8082/images/$rawImage")
            : "";

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 34, 34, 34),
            title: Text(
              unescape.convert(recipe.title),
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child:
                        hasValidImage
                            ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Image.asset(
                                    'assets/images/no_food.png',
                                    fit: BoxFit.contain,
                                  ),
                            )
                            : Image.asset(
                              'assets/images/no_food.png',
                              fit: BoxFit.contain,
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
                  ...recipe.cleanedIngredients
                      .where((i) => i.trim().isNotEmpty)
                      .map(
                        (i) => Text(
                          "- ${unescape.convert(i)}",
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
                        ? unescape.convert(recipe.instructions)
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
                                  label: Text(unescape.convert(cat)),
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    103,
                                    55,
                                    192,
                                  ),
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                  if (recipe.sources.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Sources:",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...recipe.sources.map(
                      (s) => Text(
                        s,
                        style: const TextStyle(color: Colors.white70),
                      ),
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
    final unescape = HtmlUnescape();
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
              final String? rawImage = recipe.imageName;
              final bool hasValidImage =
                  rawImage != null && rawImage.trim().isNotEmpty;

              final String imageUrl =
                  hasValidImage
                      ? (rawImage.startsWith('http')
                          ? "http://10.0.2.2:8082/proxy/image?url=${Uri.encodeComponent(rawImage)}"
                          : "http://10.0.2.2:8082/images/$rawImage")
                      : "";

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
                          child:
                              hasValidImage
                                  ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                              'assets/images/no_food.png',
                                              fit: BoxFit.contain,
                                            ),
                                  )
                                  : Image.asset(
                                    'assets/images/no_food.png',
                                    fit: BoxFit.contain,
                                  ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          unescape.convert(recipe.title),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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
