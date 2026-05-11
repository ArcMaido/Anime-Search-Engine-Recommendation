class RecommendationAnime {
  final int id;
  final String title;
  final String synopsis;
  final String? imageUrl;
  final List<String> categories;
  final double score;
  final int matchCount;

  const RecommendationAnime({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.categories,
    required this.score,
    this.imageUrl,
    this.matchCount = 0,
  });

  factory RecommendationAnime.fromMap(
    Map<String, dynamic> map, {
    int matchCount = 0,
  }) {
    final rawCategories = (map['categories'] as String? ?? '')
        .split(',')
        .map((category) => category.trim())
        .where((category) => category.isNotEmpty)
        .toList();

    return RecommendationAnime(
      id: map['id'] as int,
      title: map['title'] as String,
      synopsis: map['synopsis'] as String,
      imageUrl: map['image_url'] as String?,
      categories: rawCategories,
      score: (map['score'] as num).toDouble(),
      matchCount: matchCount,
    );
  }

  RecommendationAnime copyWith({int? matchCount}) {
    return RecommendationAnime(
      id: id,
      title: title,
      synopsis: synopsis,
      imageUrl: imageUrl,
      categories: categories,
      score: score,
      matchCount: matchCount ?? this.matchCount,
    );
  }
}
