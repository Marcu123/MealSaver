import 'recipe_dto.dart';

class AiRecipeDTO {
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> optionalIngredientsToBuy;
  final String imageUrl;
  final List<String> sources;

  AiRecipeDTO({
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.optionalIngredientsToBuy,
    required this.imageUrl,
    required this.sources,
  });

  factory AiRecipeDTO.fromJson(Map<String, dynamic> json) {
    return AiRecipeDTO(
      title: json['title'] ?? '',
      ingredients:
          (json['ingredients'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      steps:
          (json['steps'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      optionalIngredientsToBuy:
          (json['optionalIngredientsToBuy'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      imageUrl: json['imageUrl'] ?? '',
      sources:
          (json['sources'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }

  RecipeDTO toRecipeDTO() {
    return RecipeDTO(
      title: title,
      cleanedIngredients: ingredients,
      instructions: steps.join('\n'),
      categories: optionalIngredientsToBuy,
      imageName: imageUrl,
      sources: sources,
    );
  }
}
