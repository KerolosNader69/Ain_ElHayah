import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors - Modern Dark Theme
  static const Color primaryColor = Color(0xFF3B82F6); // Bright blue
  static const Color primaryVariant = Color(0xFF1D4ED8); // Darker blue
  static const Color accentColor = Color(0xFF10B981); // Emerald green
  static const Color secondaryColor = Color(0xFF6366F1); // Indigo
  
  // Success, Warning, Error Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);
  
  // Dark Theme Colors - Comprehensive System
  static const Color darkBackground = Color(0xFF0A0A0A); // Deep black background
  static const Color darkSurface = Color(0xFF111111); // Slightly lighter surface
  static const Color darkSurfaceVariant = Color(0xFF1A1A1A); // Card backgrounds
  static const Color darkSurfaceElevated = Color(0xFF222222); // Elevated surfaces
  static const Color darkMuted = Color(0xFF2A2A2A); // Muted backgrounds
  static const Color darkBorder = Color(0xFF333333); // Subtle borders
  static const Color darkBorderStrong = Color(0xFF444444); // Stronger borders
  
  // Text Colors - High Contrast Dark Theme
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color darkTextSecondary = Color(0xFFE5E7EB); // Light gray
  static const Color darkTextMuted = Color(0xFF9CA3AF); // Muted gray
  static const Color darkTextDescription = Color(0xFF6B7280); // Description text
  static const Color darkTextPlaceholder = Color(0xFF4B5563); // Placeholder text
  
  // Enhanced Gradients - Modern Dark Theme
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
      Color(0xFF020617),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A1A), Color(0xFF111111)],
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF222222), Color(0xFF1A1A1A)],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  // Enhanced Typography - Modern Dark Theme
  static TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.02,
  );

  static TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.01,
  );

  static TextStyle get heading3 => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.01,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.6,
    letterSpacing: 0.01,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.01,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
    letterSpacing: 0.01,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
    letterSpacing: 0.02,
  );

  // Comprehensive Dark Theme - Single Theme System
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        primaryContainer: Color(0xFF1E3A8A),
        secondary: accentColor,
        secondaryContainer: Color(0xFF065F46),
        surface: darkSurface,
        background: darkBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        error: errorColor,
        onError: Colors.white,
        outline: darkBorder,
        outlineVariant: darkBorderStrong,
        surfaceVariant: darkSurfaceVariant,
        onSurfaceVariant: darkTextSecondary,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          height: 1.2,
          letterSpacing: -0.02,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          height: 1.2,
          letterSpacing: -0.01,
        ),
        displaySmall: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          height: 1.2,
          letterSpacing: -0.01,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          height: 1.2,
          letterSpacing: -0.01,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          height: 1.2,
          letterSpacing: -0.01,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          height: 1.2,
          letterSpacing: -0.01,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: 1.2,
          letterSpacing: -0.01,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: 1.2,
          letterSpacing: -0.01,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: 1.2,
          letterSpacing: -0.01,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkTextPrimary,
          height: 1.5,
          letterSpacing: 0.01,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkTextPrimary,
          height: 1.5,
          letterSpacing: 0.01,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkTextMuted,
          height: 1.5,
          letterSpacing: 0.02,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: 1.2,
          letterSpacing: 0.01,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkTextMuted,
          height: 1.2,
          letterSpacing: 0.02,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: darkTextMuted,
          height: 1.2,
          letterSpacing: 0.02,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.01,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.01,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.01,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: darkTextPlaceholder,
          fontSize: 16,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkMuted,
        selectedColor: primaryColor.withOpacity(0.2),
        labelStyle: const TextStyle(
          color: darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Comprehensive Helper Methods for Dark Theme
  static Color getTextColor(BuildContext context, {bool isPrimary = false, bool isSecondary = false, bool isMuted = false, bool isDescription = false}) {
    if (isPrimary) return darkTextPrimary;
    if (isSecondary) return darkTextSecondary;
    if (isMuted) return darkTextMuted;
    if (isDescription) return darkTextDescription;
    return darkTextPrimary;
  }

  static Color getMutedBackgroundColor(BuildContext context) {
    return darkMuted;
  }

  static Color getBorderColor(BuildContext context) {
    return darkBorder;
  }

  static Color getSurfaceColor(BuildContext context) {
    return darkSurface;
  }

  static Color getSurfaceVariantColor(BuildContext context) {
    return darkSurfaceVariant;
  }

  static Color getSurfaceElevatedColor(BuildContext context) {
    return darkSurfaceElevated;
  }

  // Enhanced Glassmorphism Effect for Dark Theme
  static BoxDecoration getGlassmorphismDecoration(BuildContext context, {double opacity = 0.1}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity * 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Enhanced Gradient Decoration for Dark Theme
  static BoxDecoration getGradientDecoration(BuildContext context, {bool isDark = true}) {
    return BoxDecoration(
      gradient: cardGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Enhanced Surface Decoration for Dark Theme
  static BoxDecoration getSurfaceDecoration(BuildContext context) {
    return BoxDecoration(
      color: darkSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: darkBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Enhanced Elevated Surface Decoration
  static BoxDecoration getElevatedSurfaceDecoration(BuildContext context) {
    return BoxDecoration(
      color: darkSurfaceElevated,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: darkBorderStrong,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Enhanced Button Styles for Dark Theme
  static ButtonStyle getPrimaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 8,
      shadowColor: primaryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01,
      ),
    );
  }

  static ButtonStyle getSecondaryButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: darkTextPrimary,
      side: const BorderSide(color: darkBorder, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01,
      ),
    );
  }

  static ButtonStyle getAccentButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      elevation: 8,
      shadowColor: accentColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01,
      ),
    );
  }

  // Enhanced Card Decoration for Dark Theme
  static BoxDecoration getCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: darkSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: darkBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Enhanced Input Decoration for Dark Theme
  static InputDecoration getInputDecoration(BuildContext context, {
    required String hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: darkTextPlaceholder),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: darkTextMuted) : null,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: darkTextMuted) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: darkMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // Enhanced Chip Decoration for Dark Theme
  static BoxDecoration getChipDecoration(BuildContext context, {bool isSelected = false}) {
    return BoxDecoration(
      color: isSelected ? primaryColor.withOpacity(0.2) : darkMuted,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isSelected ? primaryColor : darkBorder,
        width: 1,
      ),
    );
  }
}