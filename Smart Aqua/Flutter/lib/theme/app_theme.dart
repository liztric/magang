import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AquascapeTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF2E3E5C),
    scaffoldBackgroundColor: Colors.white,
    textTheme: GoogleFonts.poppinsTextTheme(),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2E3E5C),
      secondary: Color(0xFF4A6491),
      surface: Colors.white,
      error: Color(0xFFE74C3C),
    ),
  );

  static const gradientBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E3E5C),
      Color(0xFF4A6089),
    ],
  );
} 