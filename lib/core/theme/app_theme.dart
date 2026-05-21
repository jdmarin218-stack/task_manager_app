import 'package:flutter/material.dart';

/// Tema global de la aplicación Task Manager
class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFF1E1E2E);
  static const Color surfaceColor = Color(0xFF2A2A3E);
  static const Color errorColor = Color(0xFFCF6679);

  // Colores de prioridad
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityHigh = Color(0xFFF44336);

  // Colores de estado
  static const Color statusPending = Color(0xFF9E9E9E);
  static const Color statusInProgress = Color(0xFF2196F3);
  static const Color statusCompleted = Color(0xFF4CAF50);

  /// Tema oscuro principal
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: surfaceColor,
          error: errorColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: surfaceColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      );

  /// Color según prioridad
  static Color priorityColor(TaskPriorityDisplay priority) {
    switch (priority) {
      case TaskPriorityDisplay.low:
        return priorityLow;
      case TaskPriorityDisplay.medium:
        return priorityMedium;
      case TaskPriorityDisplay.high:
        return priorityHigh;
    }
  }

  /// Color según estado
  static Color statusColor(TaskStatusDisplay status) {
    switch (status) {
      case TaskStatusDisplay.pending:
        return statusPending;
      case TaskStatusDisplay.inProgress:
        return statusInProgress;
      case TaskStatusDisplay.completed:
        return statusCompleted;
    }
  }
}

/// Enums de display para el tema
enum TaskPriorityDisplay { low, medium, high }
enum TaskStatusDisplay { pending, inProgress, completed }
