import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF1A1714); // Deep warm off-black
  static const Color surface = Color(0xFF242018); // Warm dark brown

  // Accents & Semantic
  static const Color primary = Color(
    0xFFE8A135,
  ); // Amber/gold (Money, attention)
  static const Color impulse = Color(
    0xFFD4614A,
  ); // Muted coral (Visible, not alarming)
  static const Color planned = Color(
    0xFF7A9E7E,
  ); // Muted sage green (Healthy, safe)

  // Typography
  static const Color textPrimary = Color(0xFFF5EFE6); // Warm white
  static const Color textSecondary = Color(0xFF9A9088); // Warm grey
}

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark();

    // 1. Define the Typography
    final textTheme = base.textTheme.copyWith(
      // Display/Headers use Sora for a warm, geometric feel
      displayLarge: GoogleFonts.sora(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.sora(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.sora(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.sora(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.sora(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.sora(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.sora(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.sora(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: GoogleFonts.sora(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),

      // Body/Numbers use DM Mono for precise, tabular alignment
      bodyLarge: GoogleFonts.dmMono(color: AppColors.textPrimary, fontSize: 16),
      bodyMedium: GoogleFonts.dmMono(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.dmMono(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.dmMono(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );

    // 2. Build the Theme
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.impulse, // Using coral for errors/warnings
        onPrimary: AppColors.background,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: textTheme,

      // 3. Component Styling (Enforcing minimal chrome and rounded, friendly edges)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.sora(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: GoogleFonts.dmMono(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.sora(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: GoogleFonts.dmMono(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
      ),
    );
  }
}
