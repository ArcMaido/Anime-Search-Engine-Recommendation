# AniSearch - Modern Anime Search Engine

A modern, beautiful Flutter mobile application for searching and discovering anime using the Jikan API (MyAnimeList unofficial API).

## 📱 Features

### ✨ Main Features
- **Anime Search**: Search anime titles in real-time with debounced input
- **Anime Results List**: Browse anime with card-based UI showing:
  - Anime cover image
  - Title and rating score
  - Episode count and status
  - Short synopsis preview

- **Anime Detail Screen**: View comprehensive anime information:
  - Large anime poster
  - Full synopsis
  - Genres, score, rank, popularity
  - Episode count and airing status
  - Trailer information

- **Loading & Error States**: 
  - Smooth loading spinner during API calls
  - Clear error messages with retry option
  - Empty state UI for no results

### 🎨 UI/UX Features
- Modern dark anime-themed design
- Smooth animations and transitions
- Rounded corners with clean shadows
- Responsive layout for all devices
- Color-coded information (Purple for primary, Cyan for accents)
- Minimalist and clean design

## 🛠 Project Structure

```
lib/
├── models/
│   └── anime_model.dart          # Data models for API responses
├── services/
│   └── anime_service.dart        # API integration with Jikan API
├── screens/
│   ├── home_screen.dart          # Main search screen
│   └── detail_screen.dart        # Anime detail page
├── widgets/
│   ├── search_bar.dart           # Custom search bar widget
│   ├── anime_card.dart           # Individual anime card widget
│   ├── genre_chip.dart           # Genre display chip
│   ├── empty_state.dart          # Empty state UI
│   ├── error_state.dart          # Error state UI
│   └── loading_state.dart        # Loading spinner UI
├── utils/
│   └── app_theme.dart            # Theme configuration and colors
└── main.dart                      # App entry point
```

## 🎨 Color Palette

- **Background**: #121212
- **Card Background**: #1E1E1E
- **Primary Purple**: #BB86FC
- **Accent Cyan**: #03DAC6
- **White Text**: #FFFFFF
- **Grey Text**: #9E9E9E

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0                    # HTTP client for API calls
  cached_network_image: ^3.3.1    # Image caching
  google_fonts: ^6.2.1            # Google fonts support
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode / VS Code

### Installation

1. **Clone or navigate to the project directory**
   ```bash
   cd anisearch
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 💡 How to Use

1. **Search Anime**: Type an anime title in the search bar
2. **Real-time Results**: Results appear as you type (debounced for performance)
3. **View Details**: Tap any anime card to see full details
4. **Retry on Error**: If an error occurs, use the retry button

## 🔌 API Integration

The app uses the **Jikan API** (MyAnimeList Unofficial API) for anime data.

**Base URL**: `https://api.jikan.moe/v4`

**Endpoints Used**:
- Search: `/anime?q={query}&page={page}&limit=25`
- Detail: `/anime/{mal_id}/full`

## 📋 Code Quality

- ✅ Null safety enabled
- ✅ Clean code practices
- ✅ Proper async/await handling
- ✅ Separated concerns (widgets, services, models)
- ✅ Responsive and optimized UI
- ✅ Efficient image loading with caching

## 🎯 Key Implementation Details

### API Service (`anime_service.dart`)
- Handles all HTTP requests to Jikan API
- Proper error handling with user-friendly messages
- Request timeout management
- Response parsing with null safety

### Models (`anime_model.dart`)
- `Anime`: Main anime data model
- `AnimeResponse`: API response wrapper
- `Genre`: Genre information
- `TrailerData`: Trailer details
- All models use null-safe Dart

### Screens

**Home Screen**:
- Search bar with debounced input
- ListView.builder for efficient list rendering
- Loading, error, and empty states
- Smooth navigation with slide animation

**Detail Screen**:
- CustomScrollView with SliverAppBar
- Parallax effect with image
- Comprehensive anime information
- Smooth scrolling experience

### Widgets
- **AnimeCard**: Displays anime with image, title, rating, episodes
- **SearchBar**: Custom search input with loading indicator
- **GenreChip**: Genre tags display
- **LoadingState**: Loading spinner UI
- **ErrorState**: Error display with retry button
- **EmptyState**: No results or initial state UI

## 🌟 Features Implemented

- ✅ Modern dark anime-themed UI
- ✅ Real-time search with debouncing
- ✅ API integration with Jikan
- ✅ Anime cards with thumbnail, title, rating, episodes
- ✅ Detail screen with full information
- ✅ Loading and error states
- ✅ Image caching for performance
- ✅ Smooth animations and transitions
- ✅ Responsive layout
- ✅ Clean code structure
- ✅ Null safety
- ✅ Proper state management
- ✅ User-friendly error handling

## 🔮 Optional Features (Can be added)

- Search history
- Favorites system
- Advanced filtering
- Infinite scrolling pagination
- Shimmer loading effect
- Dark mode toggle (already dark)
- Share anime details
- Bookmarking
- Reviews and ratings

## 🐛 Troubleshooting

**No internet connection**: Error state will display with retry button

**API Rate Limiting**: Jikan API has rate limits. Wait a moment and retry.

**Images not loading**: Check internet connection. Cached images will be stored locally.

**Performance on old devices**: App is optimized with:
- Image caching
- Efficient list rendering with ListView.builder
- Debounced search

## 📝 Notes

- The app uses Material Design 3
- All UI components are responsive
- Network calls are properly handled with error states
- Images are cached for faster loading
- Search input is debounced to reduce API calls

## 🤝 Contributing

Feel free to extend this project with additional features like:
- Seasonal anime lists
- Top anime rankings
- User ratings
- Discussion forum
- Notifications

## 📄 License

This project is open source and available under the MIT License.

---

**Enjoy discovering anime with AniSearch! 🎌**
