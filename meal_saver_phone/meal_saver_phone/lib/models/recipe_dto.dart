class RecipeDTO {
  final String title;
  final List<String> cleanedIngredients;
  final String instructions;
  final List<String> categories;
  final String imageName;
  final List<String> sources;

  RecipeDTO({
    required this.title,
    required this.cleanedIngredients,
    required this.instructions,
    required this.categories,
    required this.imageName,
    required this.sources,
  });

  factory RecipeDTO.fromJson(Map<String, dynamic> json) {
    return RecipeDTO(
      title: json['title'],
      cleanedIngredients: List<String>.from(json['cleanedIngredients']),
      instructions: json['instructions'],
      categories: List<String>.from(json['categories']),
      imageName: json['imageName'],
      sources: List<String>.from(json['sources'] ?? []),
    );
  }
}
