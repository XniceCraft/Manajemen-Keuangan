import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color backgroundColor = Color(0xFF0F0F23);
  static const Color surfaceColor = Color(0xFF1A1A2E);
  static const Color cardColor = Color(0xFF16213E);
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFB0B3B8);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)],
  );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.indigo,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Outfit',
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppTheme.textColor),
        displayMedium: TextStyle(color: AppTheme.textColor),
        displaySmall: TextStyle(color: AppTheme.textColor),
        headlineLarge: TextStyle(color: AppTheme.textColor),
        headlineMedium: TextStyle(color: AppTheme.textColor),
        headlineSmall: TextStyle(color: AppTheme.textColor),
        titleLarge: TextStyle(color: AppTheme.textColor),
        titleMedium: TextStyle(color: AppTheme.textColor),
        titleSmall: TextStyle(color: AppTheme.textColor),
        bodyLarge: TextStyle(color: AppTheme.textColor),
        bodyMedium: TextStyle(color: AppTheme.textColor),
        bodySmall: TextStyle(color: AppTheme.textSecondaryColor),
        labelLarge: TextStyle(color: AppTheme.textColor),
        labelMedium: TextStyle(color: AppTheme.textColor),
        labelSmall: TextStyle(color: AppTheme.textSecondaryColor),
      ).apply(fontFamily: 'Outfit'),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: TextStyle(
            color: AppTheme.textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Outfit'
          )
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: TextStyle(
            color: AppTheme.textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Outfit'
          )
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static BoxDecoration get glassmorphismDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white.withAlpha(26), Colors.white.withAlpha(13)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withAlpha(15), width: 1),
    );
  }

  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(26),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
