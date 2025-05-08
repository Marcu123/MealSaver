class RecipeVideoDTO {
  final int id;
  final String videoUrl;
  final List<String> tags;
  final String description;
  final String thumbnailUrl;
  final int likes;
  final String username;
  final bool likedByUser;

  RecipeVideoDTO({
    required this.id,
    required this.videoUrl,
    required this.tags,
    required this.description,
    required this.thumbnailUrl,
    required this.likes,
    required this.username,
    this.likedByUser = false, // <- esențial
  });

  factory RecipeVideoDTO.fromJson(Map<String, dynamic> json) {
    return RecipeVideoDTO(
      id: json['id'],
      videoUrl: json['videoUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      likes: json['likes'],
      username: json['username'],
      likedByUser: json['likedByUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'videoUrl': videoUrl,
    'tags': tags,
    'description': description,
    'thumbnailUrl': thumbnailUrl,
    'likes': likes,
    'username': username,
  };
}
