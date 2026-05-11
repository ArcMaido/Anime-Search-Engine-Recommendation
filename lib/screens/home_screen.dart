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
  List<Anime> _animeList = [];
  List<RecommendationAnime> _categoryRecommendations = [];
  bool _isLoading = false;
  bool _isRecommendationLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadCategoryRecommendations();
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

    try {
      final recommendations = await RecommendationService.getRecommendations(
        widget.user.id,
        widget.selectedCategories,
        limit: 10,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _categoryRecommendations = recommendations;
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

  Future<void> _navigateToDetail(Anime anime) async {
    await _recordAnimeInteraction(anime);

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return DetailScreen(anime: anime);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );

    await _loadCategoryRecommendations();
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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
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
    if (_searchQuery.isEmpty) {
      if (_isRecommendationLoading) {
        return const LoadingState(message: 'Preparing your recommendations...');
      }

      if (_categoryRecommendations.isNotEmpty) {
        return ListView.builder(
          itemCount: _categoryRecommendations.length,
          padding: const EdgeInsets.only(bottom: 16),
          itemBuilder: (context, index) {
            return _RecommendationCard(
              anime: _categoryRecommendations[index],
            );
          },
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
          onTap: () => _navigateToDetail(_animeList[index]),
        );
      },
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final RecommendationAnime anime;

  const _RecommendationCard({required this.anime});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        margin: EdgeInsets.zero,
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: colorScheme.outline),
        ),
        child: Row(
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
                child: anime.imageUrl != null && anime.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
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
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.auto_awesome,
                          color: colorScheme.primary,
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
                    Text(
                      anime.synopsis,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.72),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Matched ${anime.matchCount} categories',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
