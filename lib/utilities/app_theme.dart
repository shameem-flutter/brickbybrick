import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Light Palette
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF6A4DFF); // Vibrant Electric Purple
  static const Color secondary = Color(0xFF00CFE8); // Vibrant Cyan
  static const Color accent = Color(0xFFFF8D36); // Vibrant Orange
  static const Color error = Color(0xFFFF4C5E);
  static const Color textBody = Color(0xFF2D3142);
  static const Color textGrey = Color(0xFF9EA3AE);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6A4DFF),
    Color(0xFF8B75FF),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFF8D36),
    Color(0xFFFFB37B),
  ];

  static const List<Color> cardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF0F2F8),
  ];

  // Modern Decorations
  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.8),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF6A4DFF).withValues(alpha: 0.08),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration premiumCard = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textBody,
        outline: textGrey.withValues(alpha: 0.2),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textBody,
        displayColor: textBody,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: textBody,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: textBody),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
