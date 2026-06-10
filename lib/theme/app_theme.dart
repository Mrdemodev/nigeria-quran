import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary – deep navy blue (was green)
  static const Color primaryGreen = Color(0xFF1565C0); // kept name for compatibility
  static const Color lightGreen  = Color(0xFF1976D2);
  static const Color mediumGreen = Color(0xFF1E88E5);

  // Gold accents
  static const Color gold      = Color(0xFFFFB300);
  static const Color lightGold = Color(0xFFFFD54F);
  static const Color darkGold  = Color(0xFFFF8F00);

  // Dark - AMOLED (blue-tinted)
  static const Color darkBg      = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF07090F);
  static const Color darkCard    = Color(0xFF0D1420);
  static const Color darkCard2   = Color(0xFF141E30);

  // Light (neutral / very slight blue)
  static const Color cream        = Color(0xFFF2F5FA);
  static const Color lightCard    = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFEBF0F8);

  // Primary blue gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // App-wide header gradient
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0A1E44), Color(0xFF1565C0), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Quran screens (same blue family, explicit)
  static const Color quranBlue    = Color(0xFF1565C0);
  static const Color quranBlueDark = Color(0xFF0D47A1);
  static const Color quranBlueMid = Color(0xFF1976D2);
  static const LinearGradient quranGradient = LinearGradient(
    colors: [Color(0xFF0A1E44), Color(0xFF1565C0), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Duas – warm teal
  static const Color duasTeal = Color(0xFF00695C);
  static const LinearGradient duasGradient = LinearGradient(
    colors: [Color(0xFF00251A), Color(0xFF00695C), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gold gradient
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFF8F00), Color(0xFFFFB300), Color(0xFFFFD54F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Arabic / Qur'anic text ─────────────────────────────
  // Parchment backgrounds for the Arabic text block
  static const Color arabicBgLight = Color(0xFFFBF6E9);
  static const Color arabicBgDark  = Color(0xFF0C1826);
  // Warm text colours
  static const Color arabicTextLight = Color(0xFF1A0A00);
  static const Color arabicTextDark  = Color(0xFFEAD9A8);

  /// Font-family name registered by google_fonts for Scheherazade New.
  /// Use as a drop-in for `fontFamily:` inside existing TextStyle objects.
  // ignore: constant_identifier_names
  static const String arabicFontFamily = 'Scheherazade New';

  /// Scheherazade New — purpose-built for Qur'anic manuscripts; matches the
  /// traditional Madinah Mushaf typographic style with full harakat support.
  static TextStyle arabicStyle({
    double fontSize = 26,
    Color? color,
    double height = 2.0,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0.3,
  }) =>
      GoogleFonts.scheherazadeNew(
        fontSize: fontSize,
        color: color,
        height: height,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: gold,
        surface: lightCard,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: cream,
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: lightCard,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryGreen.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? const IconThemeData(color: primaryGreen, size: 24)
            : const IconThemeData(color: Color(0xFFAFAFAF), size: 24)),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? GoogleFonts.poppins(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.w600)
            : GoogleFonts.poppins(color: const Color(0xFFAFAFAF), fontSize: 10)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryGreen,
        inactiveTrackColor: primaryGreen.withValues(alpha: 0.2),
        thumbColor: primaryGreen,
        overlayColor: primaryGreen.withValues(alpha: 0.15),
        trackHeight: 3,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightGreen,
        primary: lightGreen,
        secondary: gold,
        surface: darkCard,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: darkCard,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: lightGreen.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? const IconThemeData(color: lightGold, size: 24)
            : IconThemeData(color: Colors.grey[600], size: 24)),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? GoogleFonts.poppins(color: lightGold, fontSize: 10, fontWeight: FontWeight.w600)
            : GoogleFonts.poppins(color: Colors.grey[600], fontSize: 10)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightGold, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightGreen,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: lightGold,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
        thumbColor: lightGold,
        overlayColor: lightGold.withValues(alpha: 0.15),
        trackHeight: 3,
      ),
    );
  }
}
