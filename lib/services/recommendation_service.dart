import '../models/recommendation_anime.dart';
import 'app_database.dart';

class RecommendationService {
  static Future<List<RecommendationAnime>> getRecommendations(
    int userId,
    List<String> selectedCategories, {
    int limit = 3,
  }) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(AppDatabase.animeTable);
    final interactionWeights =
        await AppDatabase.instance.getUserCategoryWeights(userId);

    final normalizedSelections = selectedCategories
        .map((category) => category.trim().toLowerCase())
        .toSet();

    final recommendations = rows
        .map((row) => RecommendationAnime.fromMap(row))
        .map((anime) {
          final weightedMatchCount = anime.categories.fold<int>(0, (
            int total,
            String category,
          ) {
            final normalizedCategory = category.toLowerCase();
            final selectionBoost =
                normalizedSelections.contains(normalizedCategory) ? 3 : 0;
            final interactionBoost = interactionWeights[normalizedCategory] ?? 0;
            return total + selectionBoost + interactionBoost;
          });

          return anime.copyWith(matchCount: weightedMatchCount);
        })
        .where((anime) => anime.matchCount > 0)
        .toList()
      ..sort((left, right) {
        final matchCompare = right.matchCount.compareTo(left.matchCount);
        if (matchCompare != 0) {
          return matchCompare;
        }

        return right.score.compareTo(left.score);
      });

    return recommendations.take(limit).toList();
  }
}
