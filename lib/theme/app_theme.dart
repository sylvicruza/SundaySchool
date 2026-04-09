import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E0048); // Deep Premium Purple
  static const Color accentColor = Color(0xFFC29910);  // Royal Gold
  static const Color scaffoldBg = Color(0xFFFBFBFD);   // Soft Sanctuary White

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF4A148C),
        onPrimaryContainer: Color(0xFFF3E5F5),
        secondary: accentColor,
        onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFFFFE57F),
        onSecondaryContainer: Color(0xFF423C00),
        surface: scaffoldBg,
        onSurface: Color(0xFF1C1B1F),
        surfaceContainerHighest: Color(0xFFF1F0F4),
        onSurfaceVariant: Color(0xFF49454E),
        error: Color(0xFFB3261E),
        onError: Color(0xFFFFFFFF),
        outline: Color(0xFF79747E),
        outlineVariant: Color(0xFFCAC4D0),
      ),
      textTheme: TextTheme(
        // High-end Headlines: Noto Serif
        displayLarge: GoogleFonts.notoSerif(
          fontSize: 56, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.notoSerif(
          fontSize: 45, fontWeight: FontWeight.bold, color: primaryColor,
        ),
        displaySmall: GoogleFonts.notoSerif(
          fontSize: 36, fontWeight: FontWeight.bold, color: primaryColor, height: 1.1,
        ),
        headlineLarge: GoogleFonts.notoSerif(
          fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1C1B1F),
        ),
        headlineMedium: GoogleFonts.notoSerif(
          fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1C1B1F),
        ),
        headlineSmall: GoogleFonts.notoSerif(
          fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1C1B1F),
        ),
        
        // Navigation & Titles: Noto Serif or Inter
        titleLarge: GoogleFonts.notoSerif(
          fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1C1B1F),
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF49454E),
        ),
        
        // Body: Plus Jakarta Sans for modern readability
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16, color: const Color(0xFF1C1B1F), height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: const Color(0xFF49454E), height: 1.5,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12, color: const Color(0xFF49454E),
        ),
        
        // Accent Labels: Inter
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.4, color: accentColor,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: accentColor,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: accentColor,
        ),
      ),
      useMaterial3: true,
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryColor),
        titleTextStyle: GoogleFonts.notoSerif(
          fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor,
        ),
      ),
    );
  }
}

