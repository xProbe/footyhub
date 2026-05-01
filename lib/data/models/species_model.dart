class SpeciesModel {
  final String id;
  final String name;
  final String family;
  final String difficulty;
  final String description;
  final String imageUrl;
  bool isBookmarked;

  SpeciesModel({
    required this.id,
    required this.name,
    required this.family,
    required this.difficulty,
    required this.description,
    required this.imageUrl,
    this.isBookmarked = false,
  });

  // Fungsi untuk memetakan data dari JSON API
  factory SpeciesModel.fromJson(Map<String, dynamic> json) {
    return SpeciesModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      family: json['family'] ?? '',
      difficulty: json['difficulty'] ?? 'Beginner',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
