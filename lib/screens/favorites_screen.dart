import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/anime_model.dart';
import '../services/favorites_service.dart';
import '../utils/app_theme.dart';
import '../widgets/theme_toggle_button.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Anime> _favorites = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final favorites = await FavoritesService.getFavorites();
      if (!mounted) {
        return;
      }

      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _removeFavorite(Anime anime) async {
    await FavoritesService.removeFavorite(anime.malId);
    if (!mounted) {
      return;
    }

    setState(() {
      _favorites.removeWhere((item) => item.malId == anime.malId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${anime.title} removed from favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openDetail(Anime anime) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => DetailScreen(anime: anime),
          ),
        )
        .then((_) => _loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Favorites',
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    if (_favorites.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 84,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'No favorites yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Open an anime and tap the heart icon to save it here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryPurple,
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final anime = _favorites[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Dismissible(
              key: ValueKey(anime.malId),
              direction: DismissDirection.endToStart,
              background: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => _removeFavorite(anime),
              child: GestureDetector(
                onTap: () => _openDetail(anime),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
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
                            child: anime.image != null &&
                                    anime.image!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: anime.image!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppTheme.primaryPurple,
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: AppTheme.greyText,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: AppTheme.greyText,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        anime.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppTheme.whiteText,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _removeFavorite(anime),
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: AppTheme.primaryPurple,
                                      ),
                                      tooltip: 'Remove from favorites',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (anime.score != null && anime.score! > 0)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: AppTheme.accentCyan,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        anime.score!.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: AppTheme.accentCyan,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  anime.status ?? 'N/A',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.greyText,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (anime.synopsis != null &&
                                    anime.synopsis!.isNotEmpty)
                                  Text(
                                    anime.synopsis!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppTheme.greyText,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
