import 'package:flutter/material.dart';

import '../../shared/presentation/components/widget_decoration.dart';
import 'app_palette.dart';
import 'app_text_themes.dart';

class AppThemeData {
  final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Mukta',
    scaffoldBackgroundColor: AppPalette.bgColorLight,
    textTheme: AppTextTheme.lightTextTheme,
    primaryColorLight: AppPalette.black,
    primaryColorDark: AppPalette.white,
    inputDecorationTheme: InputDecorationTheme(
      errorStyle: AppTextTheme.darkTextTheme.labelLarge!
          .copyWith(color: AppPalette.red),
      enabledBorder: const OutlineInputBorder(
          borderSide: WidgetDecoration.borderSideBlack,
          borderRadius: WidgetDecoration.borderRadius5),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 18,
      activeTrackColor: AppPalette.blueS9,
      thumbColor: AppPalette.grey,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
    ),
    scrollbarTheme: ScrollbarThemeData(
      radius: WidgetDecoration.radius10,
      interactive: true,
      crossAxisMargin: 0.0,
      thickness: WidgetStateProperty.resolveWith((states) => 5.0),
      thumbVisibility: WidgetStateProperty.resolveWith((states) => true),
    ),
  );

  final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Mukta',
    scaffoldBackgroundColor: AppPalette.bgColorDark,
    textTheme: AppTextTheme.darkTextTheme,
    primaryColorLight: AppPalette.white,
    primaryColorDark: AppPalette.greyC1,
    inputDecorationTheme: InputDecorationTheme(
      errorStyle: AppTextTheme.darkTextTheme.labelSmall!
          .copyWith(color: AppPalette.red),
      enabledBorder: const OutlineInputBorder(
          borderSide: WidgetDecoration.borderSideWhite,
          borderRadius: WidgetDecoration.borderRadius5),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 18,
      activeTrackColor: AppPalette.blueS9,
      thumbColor: AppPalette.grey,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
    ),
    scrollbarTheme: ScrollbarThemeData(
      radius: WidgetDecoration.radius10,
      interactive: true,
      crossAxisMargin: 0.0,
      thumbColor: WidgetStateProperty.resolveWith((states) => AppPalette.white),
      thickness: WidgetStateProperty.resolveWith((states) => 5.0),
      thumbVisibility: WidgetStateProperty.resolveWith((states) => true),
    ),
  );
}
