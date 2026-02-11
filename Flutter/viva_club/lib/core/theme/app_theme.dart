import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFA8D8EA);
  static const Color secondary = Color(0xFFB4E4D6);
  static const Color accent = Color(0xFFFFF5BA);

  // Custom Pastel Colors
  static const Color skyBlue = Color(0xFFA8D8EA);
  static const Color mintGreen = Color(0xFFB4E4D6);
  static const Color butteryYellow = Color(0xFFFFF5BA);
  static const Color cottonPink = Color(
    0xFFFFD6E0,
  ); // Added for 'Anonymous Support' icon

  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF4A5568);
  static const Color textDark = Color(0xFF2D3748); // Darker text for titles
  static const Color textGrey = Color(0xFF718096); // Muted text

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
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: text),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(
            0xFF2D3748,
          ), // Darker text on light buttons
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFFF7F9FB),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
