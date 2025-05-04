class RecipeDTO {
  final String title;
  final List<String> cleanedIngredients;
  final String instructions;
  final List<String> categories;
  final String imageName;

  RecipeDTO({
    required this.title,
    required this.cleanedIngredients,
    required this.instructions,
    required this.categories,
    required this.imageName,
  });

  factory RecipeDTO.fromJson(Map<String, dynamic> json) {
    return RecipeDTO(
      title: json['title'],
      cleanedIngredients: List<String>.from(json['cleanedIngredients']),
      instructions: json['instructions'],
      categories: List<String>.from(json['categories']),
      imageName: json['imageName'],
    );
  }
}
