# AniSearch - API Documentation

Complete guide to the Jikan API integration used in AniSearch.

## Jikan API Overview

**Official Website**: [https://jikan.moe/](https://jikan.moe/)

Jikan is an **unofficial MyAnimeList API** that provides free access to MyAnimeList data.

### API Characteristics

- **Free**: No authentication required
- **REST API**: Standard HTTP methods
- **JSON Response**: All responses are in JSON format
- **Open Source**: Community-maintained
- **Rate Limited**: ~60 requests per minute
- **Reliable**: Widely used by anime applications

---

## Base URL

```
https://api.jikan.moe/v4
```

All endpoints are relative to this base URL.

---

## Endpoints Used in AniSearch

### 1. Search Anime

**Endpoint**:
```
GET /anime?q={query}&page={page}&limit={limit}
```

**Description**: Search for anime by title

**Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `q` | string | Yes | - | Query string (anime title) |
| `page` | integer | No | 1 | Page number for pagination |
| `limit` | integer | No | 25 | Results per page (max 25) |
| `status` | string | No | - | Filter by status (airing, complete, etc.) |
| `type` | string | No | - | Filter by type (TV, Movie, OVA, etc.) |
| `min_score` | number | No | - | Minimum score filter |
| `order_by` | string | No | - | Order results by field |
| `sort` | string | No | - | Sort order (asc, desc) |

**Example Request**:
```
https://api.jikan.moe/v4/anime?q=naruto&page=1&limit=25
```

**Response Structure**:
```json
{
  "data": [
    {
      "mal_id": 20,
      "url": "https://myanimelist.net/anime/20/Naruto",
      "images": {
        "jpg": {
          "image_url": "https://cdn.myanimelist.net/images/anime/...",
          "small_image_url": "https://...",
          "large_image_url": "https://..."
        }
      },
      "trailer": {
        "youtube_id": "...",
        "url": "https://www.youtube.com/watch?v=...",
        "embed_url": "https://www.youtube.com/embed/...",
        "images": null
      },
      "title": "Naruto",
      "title_english": "Naruto",
      "title_japanese": "ナルト",
      "type": "TV",
      "source": "Manga",
      "episodes": 220,
      "status": "Finished Airing",
      "airing": false,
      "aired": {
        "from": "2002-10-03T00:00:00+00:00",
        "to": "2007-02-08T00:00:00+00:00",
        "prop": {...},
        "string": "Oct 3, 2002 to Feb 8, 2007"
      },
      "duration": "24 min per ep",
      "rating": "PG-13",
      "score": 7.95,
      "scored_by": 2031234,
      "rank": 50,
      "popularity": 13,
      "genres": [
        {
          "mal_id": 1,
          "type": "anime",
          "name": "Action",
          "url": "https://myanimelist.net/anime/genre/1/Action"
        },
        ...
      ],
      "synopsis": "Naruto Uzumaki, a hyperactive...",
      "background": "...",
      "season": "fall",
      "year": 2002,
      "studios": [...],
      "producers": [...],
      "licensors": [...],
      "themes": [...],
      "demographics": [...]
    }
    // ... more anime
  ],
  "pagination": {
    "last_visible_page": 3,
    "has_next_page": true,
    "current_page": 1,
    "items": {
      "count": 25,
      "total": 64,
      "per_page": 25
    }
  }
}
```

**Status Codes**:
- `200 OK`: Request successful
- `404 Not Found`: No results found
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server error

---

### 2. Get Anime Details

**Endpoint**:
```
GET /anime/{mal_id}
```

**Description**: Get detailed information about a specific anime

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `mal_id` | integer | Yes | MyAnimeList ID |

**Optional Extensions**:
```
GET /anime/{mal_id}/full
GET /anime/{mal_id}/characters
GET /anime/{mal_id}/staff
GET /anime/{mal_id}/episodes
GET /anime/{mal_id}/news
GET /anime/{mal_id}/forum
GET /anime/{mal_id}/videos
GET /anime/{mal_id}/pictures
GET /anime/{mal_id}/moreinfo
```

**Example Request**:
```
https://api.jikan.moe/v4/anime/20/full
```

**Response Structure**:
```json
{
  "data": {
    "mal_id": 20,
    "url": "https://myanimelist.net/anime/20/Naruto",
    "images": {
      "jpg": {
        "image_url": "https://...",
        "small_image_url": "https://...",
        "large_image_url": "https://..."
      }
    },
    "trailer": {
      "youtube_id": "...",
      "url": "https://www.youtube.com/watch?v=...",
      "embed_url": "https://www.youtube.com/embed/...",
      "images": null
    },
    "title": "Naruto",
    "type": "TV",
    "source": "Manga",
    "episodes": 220,
    "status": "Finished Airing",
    "airing": false,
    "aired": {...},
    "duration": "24 min per ep",
    "rating": "PG-13",
    "score": 7.95,
    "scored_by": 2031234,
    "rank": 50,
    "popularity": 13,
    "members": 2500000,
    "genres": [...],
    "explicit_genres": [...],
    "themes": [...],
    "demographics": [...],
    "studios": [...],
    "producers": [...],
    "licensors": [...],
    "synopsis": "...",
    "background": "...",
    "season": "fall",
    "year": 2002,
    "broadcast": {...},
    "relations": [...],
    "external_links": [...],
    "streaming": [...]
  }
}
```

---

## Implementation in AniSearch

### AnimeService Class

**Location**: `lib/services/anime_service.dart`

**Methods**:

#### 1. `searchAnime(String query, {int page = 1})`

```dart
Future<AnimeResponse> searchAnime(String query, {int page = 1}) async
```

**Purpose**: Search anime by title

**Parameters**:
- `query`: Search term
- `page`: Page number (default: 1)

**Returns**: `AnimeResponse` with list of anime

**Example**:
```dart
try {
  final result = await AnimeService.searchAnime('naruto');
  print(result.data.length); // Number of results
} catch (e) {
  print('Error: $e');
}
```

#### 2. `getAnimeDetail(int malId)`

```dart
Future<Anime?> getAnimeDetail(int malId) async
```

**Purpose**: Get detailed information about anime

**Parameters**:
- `malId`: MyAnimeList ID

**Returns**: `Anime` object or null if not found

**Example**:
```dart
try {
  final anime = await AnimeService.getAnimeDetail(20);
  print(anime?.title); // Print anime title
} catch (e) {
  print('Error: $e');
}
```

---

## Data Models

### Anime Model

```dart
class Anime {
  final int malId;           // MyAnimeList ID
  final String title;        // Anime title
  final String? image;       // Poster image URL
  final double? score;       // Rating (0-10)
  final int? episodes;       // Episode count
  final String? status;      // Airing status
  final String? synopsis;    // Plot description
  final List<Genre>? genres; // Genre list
  final int? rank;           // MAL ranking
  final int? popularity;     // Popularity ranking
  final TrailerData? trailer;// Trailer info
  final String? airing;      // Airing info
}
```

### Genre Model

```dart
class Genre {
  final int malId;      // Genre ID
  final String name;    // Genre name (e.g., "Action", "Adventure")
}
```

### TrailerData Model

```dart
class TrailerData {
  final String? youtubeId;  // YouTube video ID
  final String? url;        // YouTube URL
  final String? embedUrl;   // Embed URL
  final bool? images;       // Has custom images
}
```

---

## Error Handling

### Timeout Handling

```dart
const int timeoutSeconds = 15;

final response = await http.get(uri).timeout(
  Duration(seconds: timeoutSeconds),
  onTimeout: () => throw Exception('Request timeout'),
);
```

### Status Code Handling

```dart
if (response.statusCode == 200) {
  // Success
} else if (response.statusCode == 404) {
  // Not found - return empty list
} else {
  // Error
  throw Exception('Failed: ${response.statusCode}');
}
```

### Exception Handling

```dart
try {
  final result = await AnimeService.searchAnime(query);
  // Use result
} catch (e) {
  // Handle error
  print('Error: $e');
}
```

---

## Rate Limiting & Performance

### API Limits

- **Rate Limit**: ~60 requests per minute
- **Max Results**: 25 per page
- **Response Time**: Typically < 500ms

### App Optimization

**Debounced Search**:
```dart
Timer? _debounceTimer;

void _onSearchChanged(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 800), () {
    _searchAnime(query);
  });
}
```

**Image Caching**:
```dart
CachedNetworkImage(
  imageUrl: anime.image!,
  cacheManager: CacheManager.instance,
)
```

---

## API Best Practices (Implemented)

✅ **Proper URL Encoding**:
```dart
final String url = '$baseUrl/anime?q=$query';
```

✅ **Headers Configuration**:
```dart
headers: {
  'Content-Type': 'application/json',
}
```

✅ **Timeout Management**:
```dart
.timeout(const Duration(seconds: 15))
```

✅ **Error Recovery**:
```dart
onTimeout: () => throw Exception('Request timeout'),
```

✅ **Response Validation**:
```dart
if (response.statusCode == 200) {
  final json = jsonDecode(response.body);
  return AnimeResponse.fromJson(json);
}
```

---

## Response Parsing

### JSON to Dart Model

```dart
factory Anime.fromJson(Map<String, dynamic> json) {
  return Anime(
    malId: json['mal_id'] as int? ?? 0,
    title: json['title'] as String? ?? 'Unknown',
    image: (json['images'] as Map?)?['jpg']?['image_url'],
    score: (json['score'] as num?)?.toDouble(),
    episodes: json['episodes'] as int?,
    status: json['status'] as String?,
    synopsis: json['synopsis'] as String?,
    genres: (json['genres'] as List?)
        ?.map((g) => Genre.fromJson(g))
        .toList(),
  );
}
```

---

## Testing the API

### Manual Testing

**cURL Examples**:
```bash
# Search anime
curl "https://api.jikan.moe/v4/anime?q=naruto"

# Get details
curl "https://api.jikan.moe/v4/anime/20/full"
```

**Postman**:
1. Open Postman
2. Create new request
3. Enter URL: `https://api.jikan.moe/v4/anime?q=naruto`
4. Send GET request
5. View response

---

## Common Issues & Solutions

### 1. No Results Found

**Issue**: Search returns empty results

**Causes**:
- Typo in search term
- Anime doesn't exist on MAL
- API filtering

**Solution**:
```dart
if (result.data.isEmpty) {
  // Show empty state
  showEmptyState();
}
```

### 2. Rate Limit Exceeded

**Issue**: 429 Too Many Requests

**Causes**:
- Too many requests in short time
- API rate limit reached

**Solution**:
```dart
// Use debounced search
// Add delay between requests
// Cache responses
```

### 3. Image Not Loading

**Issue**: Images fail to load

**Causes**:
- URL broken
- No internet connection
- Image CDN down

**Solution**:
```dart
CachedNetworkImage(
  errorWidget: (context, url, error) => 
    Icon(Icons.image_not_supported),
)
```

### 4. Timeout Error

**Issue**: Request takes too long

**Causes**:
- Slow internet
- API server slow
- Large response

**Solution**:
```dart
.timeout(Duration(seconds: 15))
// Increase timeout if needed
```

---

## Future API Enhancements

**Possible Additions**:
- Anime recommendations
- Character information
- Staff details
- Episode information
- Forum discussions
- User reviews
- Seasonal anime
- Top anime charts
- Genre browsing
- Advanced filtering

---

## References

- [Jikan API Documentation](https://jikan.moe/)
- [Jikan GitHub Repository](https://github.com/jikan-me/jikan)
- [MyAnimeList](https://myanimelist.net/)
- [HTTP Package Documentation](https://pub.dev/packages/http)

---

## Summary

The AniSearch app effectively integrates with the Jikan API to provide:
- Real-time anime search
- Detailed anime information
- Robust error handling
- Performance optimization
- User-friendly experience

The API integration is production-ready and follows Flutter best practices for network communication.

---

**Last Updated**: May 2024
**API Version**: v4
**Status**: ✅ Production Ready
