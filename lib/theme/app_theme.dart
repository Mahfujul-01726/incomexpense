import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF429690); // Teal
  static const Color secondaryColor = Color(0xFF2F7E79); // Dark Teal
  static const Color incomeColor = Color(0xFF25A969); // Emerald Green
  static const Color expenseColor = Color(0xFFF95B5A); // Crimson Red
  static const Color warningColor = Color(0xFFF59E0B); // Amber

  // Light Theme colors
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark Theme colors
  static const Color darkBg = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBg,
      cardColor: lightSurface,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: expenseColor,
        surface: lightSurface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme.copyWith(
              headlineLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 32),
              titleLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 20),
              bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 16),
              bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 14),
            ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkSurface,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: expenseColor,
        surface: darkSurface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
              headlineLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 32),
              titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 20),
              bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 16),
              bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 14),
            ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkBg,
        selectedItemColor: secondaryColor,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      useMaterial3: true,
    );
  }

  // Gradients for cards
  static const List<List<Color>> cardGradients = [
    [Color(0xFF6366F1), Color(0xFF3B82F6)], // Blue Indigo
    [Color(0xFFEC4899), Color(0xFFF43F5E)], // Pink Crimson
    [Color(0xFF10B981), Color(0xFF059669)], // Emerald Green
    [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber Orange
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)], // Purple Violet
  ];
}
