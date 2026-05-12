import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/anime_model.dart';
import '../models/recommendation_anime.dart';
import '../services/app_database.dart';
import '../services/anime_service.dart';
import '../services/recommendation_service.dart';
import '../widgets/anime_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/search_bar.dart';
import '../widgets/theme_toggle_button.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;
  final List<String> selectedCategories;

  const HomeScreen({
    Key? key,
    required this.user,
    this.selectedCategories = const [],
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _availableCategories = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Supernatural',
    'Mystery',
    'Sports',
    'Horror',
  ];

  static const int _recommendationsPerPage = 10;

  List<Anime> _animeList = [];
  List<RecommendationAnime> _categoryRecommendations = [];
  List<String> _activeCategories = [];
  bool _isLoading = false;
  bool _isRecommendationLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _searchQuery = '';
  int _recommendationPage = 0;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeHome();
  }

  Future<void> _initializeHome() async {
    final savedCategories = await AppDatabase.instance.getActiveCategories();

    if (!mounted) {
      return;
    }

    setState(() {
      _activeCategories = savedCategories.isNotEmpty
          ? savedCategories
          : List<String>.from(widget.selectedCategories);
    });

    await _loadCategoryRecommendations();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCategoryRecommendations() async {
    setState(() {
      _isRecommendationLoading = true;
    });

    final hasSavedHistory =
        (await AppDatabase.instance.getUserCategoryWeights(widget.user.id))
            .isNotEmpty;

    if (_activeCategories.isEmpty && !hasSavedHistory) {
      if (!mounted) {
        return;
      }

      setState(() {
        _categoryRecommendations = [];
        _recommendationPage = 0;
        _isRecommendationLoading = false;
      });

      return;
    }

    try {
      final recommendations = await RecommendationService.getRecommendations(
        widget.user.id,
        _activeCategories,
        limit: 30,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _categoryRecommendations = recommendations;
        _recommendationPage = 0;
        _isRecommendationLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _categoryRecommendations = [];
        _isRecommendationLoading = false;
      });
    }
  }

  Future<List<String>> _resolveAnimeCategories(Anime anime) async {
    final detail = await AnimeService.getAnimeDetail(anime.malId);
    final source = detail ?? anime;
    final categories = source.genres?.map((genre) => genre.name).toList() ?? [];

    if (categories.isNotEmpty) {
      return categories;
    }

    return anime.genres?.map((genre) => genre.name).toList() ?? [];
  }

  Future<void> _openAnimeDetailAndRecord(Anime anime) async {
    final detail = await AnimeService.getAnimeDetail(anime.malId);
    final detailAnime = detail ?? anime;
    final categories = detailAnime.genres?.map((genre) => genre.name).toList() ?? [];

    // Save the interaction to the database
    if (categories.isNotEmpty) {
      await AppDatabase.instance.saveAnimeInteraction(
        userId: widget.user.id,
        animeId: detailAnime.malId,
        animeTitle: detailAnime.title,
        categories: categories,
      );

      // Update recommendations to show anime from the same categories (sorted A-Z)
      final categoryRecommendations =
          await RecommendationService.getRecommendationsByCategories(
        categories,
        limit: 30,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _categoryRecommendations = categoryRecommendations;
        _recommendationPage = 0;
      });
    }

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(anime: detailAnime),
      ),
    );
  }

  Future<void> _openRecommendationDetailAndRecord(RecommendationAnime anime) async {
    if (anime.categories.isNotEmpty) {
      await AppDatabase.instance.saveAnimeInteraction(
        userId: widget.user.id,
        animeId: anime.id,
        animeTitle: anime.title,
        categories: anime.categories,
      );
    }

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          anime: anime.toAnime(),
          loadFromApi: true,
        ),
      ),
    );
  }

  Future<void> _showCategorySelectionPrompt({
    required String title,
    required List<String> categories,
    String? imageUrl,
    Anime? detailAnime,
    int? animeId,
    String? animeTitle,
    bool persistSelection = false,
  }) async {
    if (categories.isEmpty || !mounted) {
      return;
    }

    final selectedCategories = <String>{};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;

        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final canConfirm = selectedCategories.length >= 3;

              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.outline,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: colorScheme.surfaceContainerHighest,
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: colorScheme.surfaceContainerHighest,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.category_outlined,
                                      color: colorScheme.onSurfaceVariant,
                                      size: 34,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Select at least 3 categories, then confirm to refresh recommendations.',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected = selectedCategories.contains(category);
                        return FilterChip(
                          selected: isSelected,
                          label: Text(category),
                          onSelected: (_) {
                            setSheetState(() {
                              if (isSelected) {
                                selectedCategories.remove(category);
                              } else {
                                selectedCategories.add(category);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Selected: ${selectedCategories.length}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (detailAnime != null)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(anime: detailAnime),
                                  ),
                                );
                              },
                              child: const Text('View details'),
                            ),
                          ),
                        if (detailAnime != null) const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: canConfirm
                                ? () async {
                                    if (persistSelection && animeId != null && animeTitle != null) {
                                      await AppDatabase.instance.saveAnimeInteraction(
                                        userId: widget.user.id,
                                        animeId: animeId,
                                        animeTitle: animeTitle,
                                        categories: selectedCategories.toList(),
                                      );
                                    }

                                    if (!mounted) {
                                      return;
                                    }

                                    setState(() {
                                      _activeCategories = selectedCategories.toList();
                                    });

                                    await AppDatabase.instance.saveActiveCategories(
                                      selectedCategories.toList(),
                                    );

                                    Navigator.of(sheetContext).pop();
                                    await _loadCategoryRecommendations();
                                  }
                                : null,
                            child: const Text('Confirm'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _recordAnimeInteraction(Anime anime) async {
    final categories = anime.genres?.map((genre) => genre.name).toList() ?? [];

    if (categories.isEmpty) {
      return;
    }

    await AppDatabase.instance.saveAnimeInteraction(
      userId: widget.user.id,
      animeId: anime.malId,
      animeTitle: anime.title,
      categories: categories,
    );
  }

  Future<void> _searchAnime(String query) async {
    if (query.isEmpty) {
      setState(() {
        _animeList = [];
        _hasError = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await AnimeService.searchAnime(query);
      if (mounted) {
        setState(() {
          _animeList = result.data;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _animeList = [];
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _searchQuery = query;

    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _searchAnime(query);
    });
  }

  void _onSearchSubmitted(String query) {
    _debounceTimer?.cancel();
    _searchQuery = query;
    _searchAnime(query);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('SearchNime'),
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        centerTitle: true,
        actions: [
          const ThemeToggleButton(),
          IconButton(
            tooltip: 'Open favorites',
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              final clearedData = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );

              if (clearedData == true) {
                _activeCategories = [];
                await _showCategorySelectionPrompt(
                  title: 'Choose categories to restart recommendations',
                  categories: _availableCategories,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          AnimeSearchBar(
            onSearch: _onSearchSubmitted,
            onChanged: _onSearchChanged,
            isLoading: _isLoading,
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_searchQuery.isEmpty) {
      if (_isRecommendationLoading) {
        return const LoadingState(message: 'Preparing your recommendations...');
      }

      if (_categoryRecommendations.isNotEmpty) {
        final totalPages =
            (_categoryRecommendations.length / _recommendationsPerPage).ceil();
        final startIndex = _recommendationPage * _recommendationsPerPage;
        final endIndex = (startIndex + _recommendationsPerPage)
            .clamp(0, _categoryRecommendations.length);
        final visibleRecommendations = _categoryRecommendations.sublist(
          startIndex,
          endIndex,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Previous page',
                    onPressed: _recommendationPage > 0
                        ? () {
                            setState(() {
                              _recommendationPage--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      'Recommendations page ${_recommendationPage + 1} of $totalPages',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next page',
                    onPressed: _recommendationPage < totalPages - 1
                        ? () {
                            setState(() {
                              _recommendationPage++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: visibleRecommendations.length,
                padding: const EdgeInsets.only(bottom: 16),
                itemBuilder: (context, index) {
                  return _RecommendationCard(
                    anime: visibleRecommendations[index],
                    onTap: () => _openRecommendationDetailAndRecord(
                      visibleRecommendations[index],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
    }

    if (_isLoading && _animeList.isEmpty) {
      return const LoadingState(message: 'Searching for anime...');
    }

    if (_hasError) {
      return ErrorState(
        message: _errorMessage,
        onRetry: () => _searchAnime(_searchQuery),
      );
    }

    if (_animeList.isEmpty) {
      if (_searchQuery.isEmpty) {
        return const EmptyState(
          message: 'Search your favorite anime',
          subtitle: 'Enter an anime title to get started',
          icon: Icons.search,
        );
      } else {
        return const EmptyState(
          message: 'No Results Found',
          subtitle: 'Try searching with a different keyword',
          icon: Icons.sentiment_dissatisfied,
        );
      }
    }

    return ListView.builder(
      itemCount: _animeList.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        return AnimeCard(
          anime: _animeList[index],
          onTap: () => _openAnimeDetailAndRecord(_animeList[index]),
        );
      },
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final RecommendationAnime anime;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.anime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: colorScheme.outline),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: anime.imageUrl != null && anime.imageUrl!.isNotEmpty
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 140,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(22),
                          bottomLeft: Radius.circular(22),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: anime.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_not_supported,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              anime.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _miniStatChip(
                                  context,
                                  Icons.play_circle_outline,
                                  anime.episodes != null
                                      ? '${anime.episodes} eps'
                                      : 'Episodes TBA',
                                ),
                                _miniStatChip(
                                  context,
                                  Icons.auto_awesome,
                                  anime.status ?? 'Status TBA',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              anime.synopsis,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.78),
                                fontSize: 12,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Matched ${anime.matchCount} categories',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_not_supported,
                              color: colorScheme.onSurfaceVariant,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              anime.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _miniStatChip(
                                  context,
                                  Icons.play_circle_outline,
                                  anime.episodes != null
                                      ? '${anime.episodes} eps'
                                      : 'Episodes TBA',
                                ),
                                _miniStatChip(
                                  context,
                                  Icons.auto_awesome,
                                  anime.status ?? 'Status TBA',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              anime.synopsis,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.78),
                                fontSize: 12,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Matched ${anime.matchCount} categories',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _miniStatChip(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
