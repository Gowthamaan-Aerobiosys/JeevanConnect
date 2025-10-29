import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';

class WidgetDecoration {
  static const radius2 = Radius.circular(2.0);
  static const radius5 = Radius.circular(5.0);
  static const radius10 = Radius.circular(10.0);
  static const radius20 = Radius.circular(20.0);
  static const radius40 = Radius.circular(40.0);

  static const borderRadius5 = BorderRadius.all(radius5);
  static const borderRadiusT5 =
      BorderRadius.only(topLeft: radius5, topRight: radius5);
  static const borderRadius10 = BorderRadius.all(radius10);
  static const borderRadius20 = BorderRadius.all(radius20);
  static const borderRadius40 = BorderRadius.all(radius40);

  static const sharpEdge = RoundedRectangleBorder();

  static const roundedEdge5 =
      RoundedRectangleBorder(borderRadius: borderRadius5);
  static const roundedEdgeT5 =
      RoundedRectangleBorder(borderRadius: borderRadiusT5);
  static const roundedEdge10 =
      RoundedRectangleBorder(borderRadius: borderRadius10);

  static const roundedLeftEdge5 = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: radius5, bottomLeft: radius5));
  static const roundedRightEdge5 = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(bottomRight: radius5, topRight: radius5));

  static const borderSideWhite = BorderSide(color: AppPalette.white);
  static const borderSideBlack = BorderSide(color: AppPalette.black);
}
