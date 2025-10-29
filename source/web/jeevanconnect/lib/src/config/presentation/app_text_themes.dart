import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'layout_config.dart';

class AppTextTheme {
  static TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: LayoutConfig().setFontSize(70),
      color: AppPalette.black,
    ),
    displayMedium: TextStyle(
      fontSize: LayoutConfig().setFontSize(50),
      color: AppPalette.black,
    ),
    displaySmall: TextStyle(
      fontSize: LayoutConfig().setFontSize(40),
      color: AppPalette.black,
    ),
    headlineLarge: TextStyle(
      fontSize: LayoutConfig().setFontSize(30),
      color: AppPalette.black,
    ),
    headlineMedium: TextStyle(
      fontSize: LayoutConfig().setFontSize(25),
      color: AppPalette.black,
    ),
    headlineSmall: TextStyle(
      fontSize: LayoutConfig().setFontSize(20),
      color: AppPalette.black,
    ),
    labelLarge: TextStyle(
      fontSize: LayoutConfig().setFontSize(18),
      color: AppPalette.black,
    ),
    labelMedium: TextStyle(
      fontSize: LayoutConfig().setFontSize(16),
      color: AppPalette.black,
    ),
    labelSmall: TextStyle(
      fontSize: LayoutConfig().setFontSize(14),
      color: AppPalette.black,
    ),
    bodyLarge: TextStyle(
      fontSize: LayoutConfig().setFontSize(12),
      color: AppPalette.black,
    ),
    bodyMedium: TextStyle(
      fontSize: LayoutConfig().setFontSize(8),
      color: AppPalette.black,
    ),
    bodySmall: TextStyle(
      fontSize: LayoutConfig().setFontSize(6),
      color: AppPalette.black,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: LayoutConfig().setFontSize(70),
      color: AppPalette.white,
    ),
    displayMedium: TextStyle(
      fontSize: LayoutConfig().setFontSize(50),
      color: AppPalette.white,
    ),
    displaySmall: TextStyle(
      fontSize: LayoutConfig().setFontSize(40),
      color: AppPalette.white,
    ),
    headlineLarge: TextStyle(
      fontSize: LayoutConfig().setFontSize(30),
      color: AppPalette.white,
    ),
    headlineMedium: TextStyle(
      fontSize: LayoutConfig().setFontSize(25),
      color: AppPalette.white,
    ),
    headlineSmall: TextStyle(
      fontSize: LayoutConfig().setFontSize(20),
      color: AppPalette.white,
    ),
    labelLarge: TextStyle(
      fontSize: LayoutConfig().setFontSize(18),
      color: AppPalette.white,
    ),
    labelMedium: TextStyle(
      fontSize: LayoutConfig().setFontSize(16),
      color: AppPalette.white,
    ),
    labelSmall: TextStyle(
      fontSize: LayoutConfig().setFontSize(14),
      color: AppPalette.white,
    ),
    bodyLarge: TextStyle(
      fontSize: LayoutConfig().setFontSize(12),
      color: AppPalette.white,
    ),
    bodyMedium: TextStyle(
      fontSize: LayoutConfig().setFontSize(8),
      color: AppPalette.white,
    ),
    bodySmall: TextStyle(
      fontSize: LayoutConfig().setFontSize(6),
      color: AppPalette.white,
    ),
  );
}
