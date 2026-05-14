import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color deepOcean = Color(0xFF07131F);
  static const Color midnightCard = Color(0xFF112338);
  static const Color horizonBlue = Color(0xFF3B82F6);
  static const Color coral = Color(0xFFFB7185);
  static const Color mint = Color(0xFF34D399);
  static const Color moon = Color(0xFFE6EEF8);
  static const Color mist = Color(0xFF95A8BF);

  static const Color paper = Color(0xFFF6F4EF);
  static const Color ivoryCard = Color(0xFFFFFFFF);
  static const Color cobalt = Color(0xFF1D4ED8);
  static const Color sunset = Color(0xFFE85D75);
  static const Color sea = Color(0xFF0EA5A3);
  static const Color ink = Color(0xFF102236);
  static const Color slate = Color(0xFF5A6F86);

  // Compatibility aliases for existing widgets.
  static const Color background = deepOcean;
  static const Color cardBackground = midnightCard;
  static const Color primaryPurple = cobalt;
  static const Color accentCyan = sea;
  static const Color whiteText = moon;
  static const Color greyText = mist;

  static ThemeData darkTheme() {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark(useMaterial3: true).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: horizonBlue,
        brightness: Brightness.dark,
      ).copyWith(
        primary: horizonBlue,
        secondary: coral,
        tertiary: mint,
        background: deepOcean,
        surface: midnightCard,
        onSurface: moon,
        onBackground: moon,
        outline: const Color(0xFF29405C),
        surfaceContainerHighest: const Color(0xFF1A334B),
      ),
      scaffoldBackgroundColor: deepOcean,
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: mist,
          height: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: deepOcean,
        foregroundColor: moon,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sora(
          color: moon,
          fontWeight: FontWeight.w700,
          fontSize: 21,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: midnightCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: horizonBlue,
          foregroundColor: moon,
          textStyle: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: moon,
          side: const BorderSide(color: Color(0xFF29405C)),
          textStyle: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: midnightCard,
        hintStyle: GoogleFonts.plusJakartaSans(color: mist, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF29405C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF29405C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: horizonBlue, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF17314A),
        side: const BorderSide(color: Color(0xFF2A4A67)),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: moon,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: midnightCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentTextStyle: GoogleFonts.plusJakartaSans(color: moon),
      ),
    );
  }

  static ThemeData lightTheme() {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.light(useMaterial3: true).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cobalt,
        brightness: Brightness.light,
      ).copyWith(
        primary: cobalt,
        secondary: sunset,
        tertiary: sea,
        background: paper,
        surface: ivoryCard,
        onSurface: ink,
        onBackground: ink,
        outline: const Color(0xFFD4DEE9),
        surfaceContainerHighest: const Color(0xFFE9EEF5),
      ),
      scaffoldBackgroundColor: paper,
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: slate,
          height: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sora(
          color: ink,
          fontWeight: FontWeight.w700,
          fontSize: 21,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: ivoryCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cobalt,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: Color(0xFFD4DEE9)),
          textStyle: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ivoryCard,
        hintStyle: GoogleFonts.plusJakartaSans(color: slate, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD4DEE9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD4DEE9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cobalt, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEAF2FF),
        side: const BorderSide(color: Color(0xFFC9D9F4)),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: ink,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ivoryCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentTextStyle: GoogleFonts.plusJakartaSans(color: ink),
      ),
    );
  }
}
