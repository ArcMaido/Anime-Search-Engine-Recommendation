# SearchNime - Troubleshooting Guide

Common issues and solutions for the SearchNime Flutter application.

---

## Installation & Setup Issues

### 1. "Flutter command not found"

**Problem**: Terminal doesn't recognize `flutter` command

**Solutions**:

**Windows**:
1. Check if Flutter is in PATH:
   ```powershell
   $env:PATH
   ```
2. Add Flutter to PATH manually:
   - System Properties → Environment Variables
   - Add Flutter bin folder path
   - Restart terminal

3. Verify installation:
   ```powershell
   flutter --version
   ```

**macOS/Linux**:
1. Edit shell profile:
   ```bash
   nano ~/.zshrc  # or ~/.bash_profile
   ```

2. Add:
   ```bash
   export PATH="$PATH:$HOME/flutter/bin"
   ```

3. Apply changes:
   ```bash
   source ~/.zshrc
   ```

---

### 2. "Doctor issues" from `flutter doctor`

**Problem**: `flutter doctor` shows errors

**Solutions**:

```bash
# Accept all Android licenses
flutter doctor --android-licenses

# Fix all possible issues
flutter doctor

# Upgrade Flutter
flutter upgrade

# Clear cache and try again
flutter clean
flutter pub get
```

---

### 3. Android SDK not found

**Problem**: "Android SDK not found" error

**Solutions**:

1. **Using Android Studio**:
   - Open Android Studio
   - Tools → SDK Manager
   - Install required Android SDK version (API 21+)
   - Note the SDK path

2. **Set ANDROID_HOME**:
   
   **Windows**:
   - System Properties → Environment Variables
   - Create new variable: `ANDROID_HOME`
   - Value: Path to Android SDK

   **macOS/Linux**:
   ```bash
   export ANDROID_HOME=$HOME/Library/Android/sdk
   ```

3. **Accept licenses**:
   ```bash
   flutter doctor --android-licenses
   ```

---

### 4. "Project not found" or "Invalid project"

**Problem**: Flutter can't find or recognize the project

**Solutions**:

```bash
# Clean everything
flutter clean

# Get dependencies
flutter pub get

# Check project structure
flutter pub upgrade

# Re-create project if needed
flutter create --platforms android,ios anisearch
```

---

## Runtime Issues

### 5. App won't start

**Problem**: App crashes immediately or shows black screen

**Solutions**:

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Run with verbose output
flutter run -v

# Clear app cache (on device)
adb shell pm clear com.example.anisearch
```

---

### 6. "No devices found"

**Problem**: Flutter can't find connected device

**Solutions**:

**Android**:
```bash
# List devices
flutter devices

# Connect via USB:
# 1. Enable USB Debugging on device
# 2. Connect via USB cable
# 3. Allow permission on device

# Restart adb
adb kill-server
adb start-server

# Check connection
adb devices
```

**iOS** (macOS only):
```bash
# List simulators
xcrun simctl list devices

# Launch simulator
open -a Simulator

# List connected devices
flutter devices
```

---

### 7. "Error: Could not find or load main class"

**Problem**: Gradle or build system error

**Solutions**:

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Force rebuild
flutter run --no-build-cache

# Clear gradle cache (Android)
# Navigate to project and run:
cd android
./gradlew clean
cd ..
flutter run
```

---

## API & Network Issues

### 8. "No internet connection"

**Problem**: App shows error when searching

**Check**:
1. Device has internet access
2. Wi-Fi or mobile data is connected
3. Firewall isn't blocking the app

**Solution**:
```bash
# Test API manually
curl "https://api.jikan.moe/v4/anime?q=naruto"
```

If curl fails, the API or your connection is down.

---

### 9. "Request timeout" error

**Problem**: API calls are timing out

**Causes**:
- Slow internet connection
- API server is slow
- Too many requests

**Solutions**:

1. **Check connection speed**:
   - Use faster Wi-Fi
   - Move closer to router
   - Try mobile data

2. **Wait and retry**:
   - Tap retry button
   - Wait a moment
   - Try again

3. **Check API status**:
   - Visit [https://jikan.moe/](https://jikan.moe/)
   - Check if API is down

4. **Increase timeout** (in code):
   - Edit `lib/services/anime_service.dart`
   - Change `timeoutSeconds` from 15 to 30

---

### 10. "Failed to load anime" error

**Problem**: Generic error when searching

**Solutions**:

1. **Check search term**:
   - Make sure anime exists on MAL
   - Try a different title
   - Check spelling

2. **Check API**:
   ```bash
   # Test with curl
   curl "https://api.jikan.moe/v4/anime?q=naruto"
   ```

3. **Check error message**:
   - Read the full error
   - It may indicate specific issue
   - Check API logs if available

---

### 11. "Rate limit exceeded" (429 error)

**Problem**: Too many requests to API

**Causes**:
- Searching too rapidly
- Too many users on API
- API maintenance

**Solution**:
- Wait a few minutes
- Try again later
- The app has built-in debounce (800ms)

---

### 12. Images not loading

**Problem**: Anime images show as broken/error

**Solutions**:

1. **Check internet connection**:
   - Ensure device is online
   - Verify connectivity

2. **Clear cache**:
   ```bash
   # Clear app data
   adb shell pm clear com.example.anisearch
   flutter run
   ```

3. **Check image URL**:
   - May have expired
   - Try another anime
   - Check CDN availability

4. **Increase timeout for images**:
   - Edit `anime_card.dart`
   - Adjust `CachedNetworkImage` settings

---

## UI/UX Issues

### 13. Text is cut off or misaligned

**Problem**: UI elements not displaying correctly

**Solutions**:

1. **Rebuild app**:
   ```bash
   flutter run --release
   ```

2. **Check screen size**:
   - Rotate device
   - Try landscape mode
   - Test on different devices

3. **Check font loading**:
   - Ensure Google Fonts loaded
   - Check pubspec.yaml

---

### 14. App runs very slowly

**Problem**: Performance issues, lag

**Causes**:
- Running in debug mode
- Device too old
- Memory leak

**Solutions**:

1. **Run in release mode**:
   ```bash
   flutter run --release
   ```

2. **Close other apps**:
   - Free up device memory
   - Close background apps

3. **Profile the app**:
   ```bash
   flutter run --profile
   ```

4. **Check device specs**:
   - Minimum: Snapdragon 430 equivalent
   - Minimum RAM: 2GB

---

### 15. Animations are stuttering

**Problem**: Animation frame drops, jank

**Solutions**:

1. **Run in release mode**:
   ```bash
   flutter run --release
   ```

2. **Reduce animation complexity**:
   - Simpler transitions
   - Fewer concurrent animations

3. **Profile animation**:
   ```bash
   flutter run --profile
   # Tap on device for performance overlay
   ```

---

## Build Issues

### 16. Build fails with "SDK version issues"

**Problem**: Gradle or SDK version mismatch

**Solutions**:

1. **Check versions**:
   ```bash
   flutter doctor
   ```

2. **Update SDK**:
   - Android Studio → SDK Manager
   - Install latest SDK tools

3. **Update Flutter**:
   ```bash
   flutter upgrade
   ```

---

### 17. APK/App Bundle build fails

**Problem**: Can't build release APK

**Solutions**:

1. **Clean build**:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build APK**:
   ```bash
   flutter build apk --release
   ```

3. **Check dependencies**:
   ```bash
   flutter pub upgrade
   flutter pub get
   ```

4. **Verbose output**:
   ```bash
   flutter build apk --release -v
   ```

---

## Code Issues

### 18. "null safety" errors

**Problem**: Null safety validation errors

**Solutions**:

1. **Check code**:
   - Look for lines with errors
   - Review null-checking

2. **Run analyzer**:
   ```bash
   flutter analyze
   ```

3. **Fix automatically**:
   ```bash
   dart fix --apply
   ```

---

### 19. Import/Package errors

**Problem**: "Import not found" or "Package not found"

**Solutions**:

```bash
# Get dependencies
flutter pub get

# Upgrade packages
flutter pub upgrade

# Clean and retry
flutter clean
flutter pub get
flutter run
```

---

### 20. "Widgets not updating"

**Problem**: UI doesn't update when state changes

**Solutions**:

1. **Check setState**:
   ```dart
   setState(() {
     // Update variables here
   });
   ```

2. **Check mounted**:
   ```dart
   if (mounted) {
     setState(() { ... });
   }
   ```

3. **Verify listener**:
   - Controller/Provider notifying listeners
   - Stream emitting updates

---

## Database & Storage Issues

### 21. No app data persistence

**Note**: Current version doesn't use local database

**To add persistence**:
- Use `sqflite` or `hive` package
- Implement local caching
- Save search history

---

## Device-Specific Issues

### 22. Issues on older Android (API < 21)

**Problem**: App won't run on older devices

**Solution**:
- Set `minSdkVersion: 21` in `build.gradle`
- Can't support older versions
- Current minimum: Android 5.0

---

### 23. iOS-specific issues

**Problem**: App crashes on iOS

**Solutions**:

1. **Check iOS requirements**:
   - Min iOS 11.0
   - Device with enough storage

2. **Clear build cache**:
   ```bash
   flutter clean
   cd ios
   rm -rf Pods
   cd ..
   flutter run
   ```

3. **Update CocoaPods**:
   ```bash
   sudo gem install cocoapods
   ```

---

## Debugging

### Useful Debug Commands

**Verbose logging**:
```bash
flutter run -v
```

**Log output**:
```bash
flutter logs
```

**Device logs** (Android):
```bash
adb logcat
```

**Performance profiling**:
```bash
flutter run --profile
```

**DevTools**:
```bash
flutter pub global activate devtools
devtools
# Open browser to localhost:9100
```

---

## Getting Help

### Resources

1. **Official Documentation**:
   - [Flutter Docs](https://flutter.dev/docs)
   - [Dart Docs](https://dart.dev/guides)

2. **Community Support**:
   - [Flutter Community](https://flutter.dev/community)
   - [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
   - [Reddit r/Flutter](https://reddit.com/r/flutter)

3. **Package Documentation**:
   - [http package](https://pub.dev/packages/http)
   - [cached_network_image](https://pub.dev/packages/cached_network_image)
   - [google_fonts](https://pub.dev/packages/google_fonts)

4. **API Support**:
   - [Jikan API Docs](https://jikan.moe/)
   - [MyAnimeList](https://myanimelist.net/)

---

## Before Asking for Help

✅ Check this guide first
✅ Run `flutter doctor` to check system
✅ Read error messages carefully
✅ Try the suggested solutions
✅ Search online for the error message
✅ Check official documentation
✅ Verify internet connection
✅ Restart device and app

---

## Reporting Issues

When reporting a bug, include:

1. **Environment Info**:
   ```bash
   flutter doctor
   ```

2. **Error Message**: Full stack trace

3. **Steps to Reproduce**:
   - What you did
   - What happened
   - What you expected

4. **Device Info**:
   - OS and version
   - Device model
   - Flutter version

---

## Performance Checklist

- ✅ Use Release Mode for testing
- ✅ Image caching enabled
- ✅ Debounced search working
- ✅ ListView.builder used
- ✅ No memory leaks
- ✅ Proper null safety
- ✅ Optimized animations

---

## Security Checklist

- ✅ API calls use HTTPS
- ✅ No hardcoded secrets
- ✅ Proper error handling
- ✅ Input validation
- ✅ Null safety enforced

---

## Final Tips

1. **Start Fresh**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Update Everything**:
   ```bash
   flutter upgrade
   ```

3. **Check Logs**:
   ```bash
   flutter logs
   ```

4. **Reload During Development**:
   - Press 'R' for hot reload
   - Press 'Shift+R' for hot restart

---

**If you still can't solve the issue:**

1. Document exactly what you did
2. Include full error message
3. Run `flutter doctor` output
4. Search online forums
5. Contact Flutter support

---

**Last Updated**: May 2024
**Status**: ✅ Comprehensive
