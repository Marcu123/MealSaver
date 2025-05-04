import 'recipe_dto.dart'; // important să imporți aici

class AiRecipeDTO {
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> optionalIngredientsToBuy;
  final String imageUrl;

  AiRecipeDTO({
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.optionalIngredientsToBuy,
    required this.imageUrl,
  });

  factory AiRecipeDTO.fromJson(Map<String, dynamic> json) {
    return AiRecipeDTO(
      title: json['title'] ?? '',
      ingredients:
          (json['ingredients'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      steps:
          (json['steps'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      optionalIngredientsToBuy:
          (json['optionalIngredientsToBuy'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  // 🔥 Conversie către RecipeDTO
  RecipeDTO toRecipeDTO() {
    return RecipeDTO(
      title: title,
      cleanedIngredients: ingredients,
      instructions: steps.join('\n'), // concatenăm pașii în text
      categories: optionalIngredientsToBuy,
      imageName: imageUrl,
    );
  }
}
