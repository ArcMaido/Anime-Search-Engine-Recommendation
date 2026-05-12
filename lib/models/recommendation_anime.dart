import 'anime_model.dart';

class RecommendationAnime {
  final int id;
  final String title;
  final String synopsis;
  final String? imageUrl;
  final List<String> categories;
  final double score;
  final int matchCount;
  final int? episodes;
  final String? status;
  final int? rank;
  final int? popularity;

  const RecommendationAnime({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.categories,
    required this.score,
    this.imageUrl,
    this.matchCount = 0,
    this.episodes,
    this.status,
    this.rank,
    this.popularity,
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

  RecommendationAnime copyWith({
    int? matchCount,
    String? synopsis,
    String? imageUrl,
    int? episodes,
    String? status,
    int? rank,
    int? popularity,
  }) {
    return RecommendationAnime(
      id: id,
      title: title,
      synopsis: synopsis ?? this.synopsis,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories,
      score: score,
      matchCount: matchCount ?? this.matchCount,
      episodes: episodes ?? this.episodes,
      status: status ?? this.status,
      rank: rank ?? this.rank,
      popularity: popularity ?? this.popularity,
    );
  }

  Anime toAnime() {
    return Anime(
      malId: id,
      title: title,
      image: imageUrl,
      score: score,
      episodes: episodes,
      status: status,
      synopsis: synopsis,
      genres: categories
          .map(
            (category) => Genre(
              malId: category.hashCode,
              name: category,
            ),
          )
          .toList(),
      rank: rank,
      popularity: popularity,
    );
  }
}
