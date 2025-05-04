class FoodDTO {
  final int id;
  final String name;
  final int size;
  final String expirationDate;

  FoodDTO({
    required this.id,
    required this.name,
    required this.size,
    required this.expirationDate,
  });

  factory FoodDTO.fromJson(Map<String, dynamic> json) {
    return FoodDTO(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      size: json['size'] ?? 0,
      expirationDate: json['expirationDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'expirationDate': expirationDate,
    };
  }
}
