# AniSearch Setup Guide

Complete guide to set up and run the AniSearch Flutter application.

## Prerequisites

### Required
- **Flutter SDK**: Version 3.0.0 or higher
- **Dart SDK**: Version 3.0.0 or higher (comes with Flutter)
- **Git**: For version control (optional)
- **Code Editor**: VS Code, Android Studio, or IntelliJ IDEA

### Device/Emulator
- **Android**: Min SDK 21 (Android 5.0) or higher
- **iOS**: Min iOS 11.0 or higher

## Windows Setup

### 1. Install Flutter

1. Download Flutter from [https://flutter.dev/docs/get-started/install/windows](https://flutter.dev/docs/get-started/install/windows)
2. Extract to a folder (e.g., `C:\flutter`)
3. Add Flutter to PATH:
   - Right-click "This PC" → Properties
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "System variables", click "New"
   - Variable name: `PATH`
   - Variable value: `C:\flutter\bin` (add to existing PATH)
4. Open PowerShell and verify:
   ```powershell
   flutter --version
   ```

### 2. Install Android SDK

1. Download Android Studio from [https://developer.android.com/studio](https://developer.android.com/studio)
2. Install Android Studio
3. Run `flutter doctor` to check setup:
   ```powershell
   flutter doctor
   ```

### 3. Clone/Download Project

```powershell
# Navigate to your desired location
cd C:\your-workspace

# Clone (if using git) or download the project
git clone <repository-url> anisearch
cd anisearch
```

### 4. Get Dependencies

```powershell
# Get all Flutter dependencies
flutter pub get
```

### 5. Create/Run on Emulator

#### Using Android Emulator

```powershell
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch emulator-name

# Or create a new one through Android Studio
```

#### Using Physical Device

1. Enable USB Debugging on your Android device
2. Connect via USB
3. Run:
   ```powershell
   flutter devices
   ```

### 6. Run the App

```powershell
# Run on connected device/emulator
flutter run

# Or run with release mode for better performance
flutter run --release
```

---

## macOS Setup

### 1. Install Flutter

```bash
# Download and install
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:$HOME/development/flutter/bin"

# Verify installation
flutter --version
```

### 2. Install Xcode

```bash
# Install via App Store or:
xcode-select --install
```

### 3. Install CocoaPods

```bash
# Install if needed
sudo gem install cocoapods
```

### 4. Clone Project

```bash
cd ~/your-workspace
git clone <repository-url> anisearch
cd anisearch
```

### 5. Get Dependencies

```bash
flutter pub get
```

### 6. Run on Simulator/Device

```bash
# Run on iOS Simulator
flutter run

# Or run on physical device
flutter run --release
```

---

## Linux Setup

### 1. Install Flutter

```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (~/.bashrc or ~/.zshrc)
export PATH="$PATH:$HOME/flutter/bin"
```

### 2. Install Dependencies

```bash
sudo apt-get update
sudo apt-get install clang cmake git ninja-build pkg-config libgtk-3-dev
```

### 3. Clone Project

```bash
cd ~/your-workspace
git clone <repository-url> anisearch
cd anisearch
```

### 4. Get Dependencies

```bash
flutter pub get
```

### 5. Run

```bash
flutter run
```

---

## Verify Installation

Run `flutter doctor` to check all requirements:

```powershell
flutter doctor
```

Expected output should show:
- ✓ Flutter (with version)
- ✓ Android toolchain
- ✓ Android Studio / VS Code
- ✓ Connected devices

## Project Structure

```
anisearch/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── anime_model.dart
│   ├── services/
│   │   └── anime_service.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── detail_screen.dart
│   ├── widgets/
│   │   ├── search_bar.dart
│   │   ├── anime_card.dart
│   │   ├── genre_chip.dart
│   │   ├── empty_state.dart
│   │   ├── error_state.dart
│   │   └── loading_state.dart
│   └── utils/
│       └── app_theme.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## Troubleshooting

### "Flutter command not found"
- Make sure Flutter is in your PATH
- Restart terminal/PowerShell after adding to PATH

### "Android SDK not found"
- Run `flutter doctor --android-licenses`
- Accept all licenses
- Run `flutter doctor` again

### "Device not found"
- Check if device is connected: `flutter devices`
- Enable USB debugging on Android device
- Restart adb: `adb kill-server && adb start-server`

### "App won't start"
```powershell
# Clean build
flutter clean

# Get dependencies again
flutter pub get

# Run again
flutter run
```

### "Network/API issues"
- Check internet connection
- Jikan API might be temporarily down
- Try searching again after a moment

### "Images not loading"
- Check internet connection
- Verify device has storage permission
- Clear app cache and run again

## Development Commands

```powershell
# Get dependencies
flutter pub get

# Check for issues
flutter analyze

# Format code
flutter format lib/

# Run tests (if available)
flutter test

# Build release APK (Android)
flutter build apk --release

# Build App Bundle (Android)
flutter build appbundle --release

# Build iOS (macOS only)
flutter build ios --release
```

## Performance Tips

1. **Use Release Mode for Testing**
   ```powershell
   flutter run --release
   ```

2. **Hot Reload for Development**
   - Press 'R' in terminal during `flutter run`

3. **Hot Restart**
   - Press 'Shift+R' in terminal

4. **Profiling**
   ```powershell
   flutter run --profile
   ```

## Network & API

The app uses:
- **Jikan API**: MyAnimeList Unofficial API
- **Base URL**: `https://api.jikan.moe/v4`

Ensure your device/emulator has internet access.

## Next Steps

1. ✅ Run the app
2. ✅ Search for anime
3. ✅ View anime details
4. ✅ Explore the code
5. ✅ Customize and extend

## Useful Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Jikan API Documentation](https://jikan.moe/)
- [Material Design Guidelines](https://material.io/design)

## Support

For issues or questions:
1. Check [Flutter Troubleshooting](https://flutter.dev/docs/testing/oem-sdks)
2. Check [Jikan API Status](https://jikan.moe/)
3. Review error messages carefully
4. Run `flutter doctor` for system diagnostics

---

**Happy coding! 🚀**
