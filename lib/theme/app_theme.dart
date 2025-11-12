// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Gradiente de fundo global
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF141E30), Color(0xFF243B55)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Estilo base de card translúcido
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Tema de botões principais
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    backgroundColor: Colors.blueAccent,
    foregroundColor: Colors.white,
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  );

  // Tema de botões de texto
  static TextStyle linkTextStyle = const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  );

  // Input decoration padrão
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  static ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueAccent,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
    useMaterial3: true,
  );
}
