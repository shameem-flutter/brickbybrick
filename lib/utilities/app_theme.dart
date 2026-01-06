import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Dark Palette
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color primary = Color(0xFFBB86FC);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFCF6679);
  static const Color onBackground = Color(0xFFE0E0E0);
  static const Color onSurface = Color(0xFFE0E0E0);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFBB86FC),
    Color(0xFF7F39FB),
  ];

  static const List<Color> surfaceGradient = [
    Color(0xFF2C2C2C),
    Color(0xFF1E1E1E),
  ];

  // Glassmorphism
  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white.withValues(
      alpha: 0.05,
    ), // Using withValues for newer Flutter versions
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: onSurface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: onBackground, displayColor: onBackground),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
