import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFFA8D8EA); // Sky Blue
  static const Color secondary = Color(0xFFB4E4D6); // Mint Green
  static const Color accent = Color(0xFFFFF5BA); // Buttery Yellow
  static const Color cottonPink = Color(0xFFFFD6E0);

  // Aliases for compatibility with existing code
  static const Color skyBlue = primary;
  static const Color mintGreen = secondary;
  static const Color butteryYellow = accent;

  // Light Mode Colors
  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF4A5568);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textGrey = Color(0xFF718096);

  // Green App: Deep Dark Mode Colors (OLED Friendly #000000)
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkText = Color(0xFFE2E8F0);
  static const Color darkTextGrey = Color(0xFFA0AEC0);

  static const Color error = Color(0xFFFC8181);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
    );
  }

  // Green App: Sustainability-First Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: darkSurface,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFF1A202C),
        filled: true,
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
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF2D3748),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}
