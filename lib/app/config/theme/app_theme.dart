import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- PALETA DE COLORES DEFINIDA ---
  static const Color primaryColor = Color(0xFF007AFF);
  static const Color scaffoldBackgroundColor = Color(0xFFF5F6F8);
  static const Color cardColor = Colors.white;
  static const Color unselectedBackgroundColor = Colors.grey;

  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // The fontFamily property is not a constant
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      cardColor: cardColor,
      unselectedWidgetColor: unselectedBackgroundColor,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        error: Colors.red,
        secondary: Colors.grey.shade600,
        brightness: Brightness.light,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600),
      ),

      // Estilo del Botón Principal
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),

      // Estilo de los Botones de Texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // Estilo de los Cards
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
