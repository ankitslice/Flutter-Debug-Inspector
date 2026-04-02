import 'package:flutter/material.dart';

/// Dark palette aligned with the Android Compose reference.
abstract final class InspectorColors {
  static const Color bgPage = Color(0xFF0E1117);
  static const Color bgCard = Color(0xFF1A1E2A);
  static const Color bgCardAlt = Color(0xFF1F2435);
  static const Color accentGreen = Color(0xFF4ADE80);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentOrange = Color(0xFFFB923C);
  static const Color accentRed = Color(0xFFF87171);
  static const Color accentYellow = Color(0xFFFBBF24);
  static const Color accentPurple = Color(0xFFA78BFA);
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecond = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color divider = Color(0xFF2D3748);
}

ThemeData inspectorDarkTheme() {
  const scheme = ColorScheme.dark(
    surface: InspectorColors.bgPage,
    primary: InspectorColors.accentBlue,
    secondary: InspectorColors.accentGreen,
    onSurface: InspectorColors.textPrimary,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: InspectorColors.bgPage,
    appBarTheme: const AppBarTheme(
      backgroundColor: InspectorColors.bgCard,
      foregroundColor: InspectorColors.textPrimary,
      elevation: 0,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: InspectorColors.accentBlue,
      unselectedLabelColor: InspectorColors.textMuted,
      dividerColor: InspectorColors.divider,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: InspectorColors.bgCardAlt,
      selectedColor: InspectorColors.bgCardAlt,
      labelStyle: const TextStyle(color: InspectorColors.textPrimary, fontSize: 12),
      side: const BorderSide(color: InspectorColors.divider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    cardTheme: const CardThemeData(color: InspectorColors.bgCard, elevation: 0),
    dividerColor: InspectorColors.divider,
  );
}
