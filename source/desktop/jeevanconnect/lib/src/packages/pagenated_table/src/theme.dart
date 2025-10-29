import 'package:flutter/material.dart';

final class PagedDataTableThemeData {
  final EdgeInsetsGeometry cellPadding;

  final EdgeInsetsGeometry padding;

  final BorderRadius borderRadius;

  final double elevation;

  final Color backgroundColor;

  final double headerHeight;

  final double footerHeight;

  final double rowHeight;

  final double filterBarHeight;

  final BoxBorder cellBorderSide;

  final TextStyle cellTextStyle;

  final TextStyle headerTextStyle;

  final TextStyle footerTextStyle;

  final Color? Function(int index)? rowColor;

  final Color? selectedRow;

  final bool verticalScrollbarVisibility;

  final bool horizontalScrollbarVisibility;

  final double filterDialogBreakpoint;

  final ChipThemeData? chipTheme;

  const PagedDataTableThemeData({
    this.cellPadding =
        const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.elevation = 0.0,
    this.cellBorderSide = const Border(),
    this.headerHeight = 56.0,
    this.footerHeight = 56.0,
    this.filterBarHeight = 50.0,
    this.rowHeight = 52.0,
    this.selectedRow,
    this.cellTextStyle =
        const TextStyle(color: Colors.black, overflow: TextOverflow.ellipsis),
    this.headerTextStyle = const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        overflow: TextOverflow.ellipsis),
    this.footerTextStyle = const TextStyle(fontSize: 14, color: Colors.black),
    this.rowColor,
    this.verticalScrollbarVisibility = true,
    this.horizontalScrollbarVisibility = true,
    this.filterDialogBreakpoint = 1000.0,
    this.chipTheme,
    this.backgroundColor = Colors.white,
  });

  @override
  int get hashCode => Object.hash(
      cellPadding,
      padding,
      borderRadius,
      elevation,
      headerHeight,
      footerHeight,
      rowHeight,
      cellBorderSide,
      cellTextStyle,
      headerTextStyle,
      rowColor,
      verticalScrollbarVisibility,
      horizontalScrollbarVisibility,
      chipTheme,
      backgroundColor);

  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      (other is PagedDataTableThemeData &&
          other.cellPadding == cellPadding &&
          other.padding == padding &&
          other.borderRadius == borderRadius &&
          other.elevation == elevation &&
          other.headerHeight == headerHeight &&
          other.footerHeight == footerHeight &&
          other.rowHeight == rowHeight &&
          other.cellTextStyle == cellTextStyle &&
          other.headerTextStyle == headerTextStyle &&
          other.rowColor == rowColor &&
          other.cellBorderSide == cellBorderSide &&
          other.selectedRow == selectedRow &&
          other.verticalScrollbarVisibility == verticalScrollbarVisibility &&
          other.horizontalScrollbarVisibility ==
              horizontalScrollbarVisibility &&
          other.chipTheme == chipTheme &&
          other.backgroundColor == backgroundColor);
}

final class PagedDataTableTheme extends InheritedWidget {
  final PagedDataTableThemeData data;

  const PagedDataTableTheme(
      {required this.data, required super.child, super.key});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      data != (oldWidget as PagedDataTableTheme).data;

  static PagedDataTableThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PagedDataTableTheme>()?.data;

  static PagedDataTableThemeData of(BuildContext context) =>
      maybeOf(context) ?? const PagedDataTableThemeData();
}
