class AnimeResponse {
  final List<Anime> data;
  final Pagination pagination;

  AnimeResponse({
    required this.data,
    required this.pagination,
  });

  factory AnimeResponse.fromJson(Map<String, dynamic> json) {
    return AnimeResponse(
      data: (json['data'] as List?)
              ?.map((item) => Anime.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: Pagination.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class Anime {
  final int malId;
  final String title;
  final String? image;
  final double? score;
  final int? episodes;
  final String? status;
  final String? synopsis;
  final List<Genre>? genres;
  final int? rank;
  final int? popularity;
  final TrailerData? trailer;
  final bool? airing;

  Anime({
    required this.malId,
    required this.title,
    this.image,
    this.score,
    this.episodes,
    this.status,
    this.synopsis,
    this.genres,
    this.rank,
    this.popularity,
    this.trailer,
    this.airing,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      malId: json['mal_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Unknown',
      image: (json['images'] as Map<String, dynamic>?)?['jpg']?['image_url']
          as String?,
      score: (json['score'] as num?)?.toDouble(),
      episodes: json['episodes'] as int?,
      status: json['status'] as String?,
      synopsis: json['synopsis'] as String?,
      genres: (json['genres'] as List?)
          ?.map((genre) => Genre.fromJson(genre as Map<String, dynamic>))
          .toList(),
      rank: json['rank'] as int?,
      popularity: json['popularity'] as int?,
      trailer: json['trailer'] != null
          ? TrailerData.fromJson(json['trailer'] as Map<String, dynamic>)
          : null,
      airing: json['airing'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'title': title,
      'images': image == null
          ? null
          : {
              'jpg': {
                'image_url': image,
              },
            },
      'score': score,
      'episodes': episodes,
      'status': status,
      'synopsis': synopsis,
      'genres': genres
          ?.map(
            (genre) => {
              'mal_id': genre.malId,
              'name': genre.name,
            },
          )
          .toList(),
      'rank': rank,
      'popularity': popularity,
      'trailer': trailer?.toJson(),
      'airing': airing,
    };
  }
}

class Genre {
  final int malId;
  final String name;

  Genre({
    required this.malId,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      malId: json['mal_id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
    );
  }
}

class TrailerData {
  final String? youtubeId;
  final String? url;
  final String? embedUrl;
  final Map<String, dynamic>? images;

  TrailerData({
    this.youtubeId,
    this.url,
    this.embedUrl,
    this.images,
  });

  factory TrailerData.fromJson(Map<String, dynamic> json) {
    return TrailerData(
      youtubeId: json['youtube_id'] as String?,
      url: json['url'] as String?,
      embedUrl: json['embed_url'] as String?,
      images: json['images'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'youtube_id': youtubeId,
      'url': url,
      'embed_url': embedUrl,
      'images': images,
    };
  }
}

class Pagination {
  final int lastVisiblePage;
  final bool hasNextPage;

  Pagination({
    required this.lastVisiblePage,
    required this.hasNextPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      lastVisiblePage: json['last_visible_page'] as int? ?? 1,
      hasNextPage: json['has_next_page'] as bool? ?? false,
    );
  }
}
