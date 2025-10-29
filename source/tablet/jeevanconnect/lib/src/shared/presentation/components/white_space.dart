import 'package:flutter/material.dart';

import '../../../config/presentation/layout_config.dart';

class WhiteSpace {
  static final SizedBox b1 = SizedBox(height: LayoutConfig().setHeight(1));
  static final SizedBox b3 = SizedBox(height: LayoutConfig().setHeight(3));
  static final SizedBox b6 = SizedBox(height: LayoutConfig().setHeight(6));
  static final SizedBox b12 = SizedBox(height: LayoutConfig().setHeight(12));
  static final SizedBox b16 = SizedBox(height: LayoutConfig().setHeight(16));
  static final SizedBox b32 = SizedBox(height: LayoutConfig().setHeight(32));
  static final SizedBox b56 = SizedBox(height: LayoutConfig().setHeight(56));
  static final SizedBox b96 = SizedBox(height: LayoutConfig().setHeight(96));

  static final SizedBox w1 = SizedBox(width: LayoutConfig().setWidth(1));
  static final SizedBox w3 = SizedBox(width: LayoutConfig().setWidth(3));
  static final SizedBox w6 = SizedBox(width: LayoutConfig().setWidth(6));
  static final SizedBox w12 = SizedBox(width: LayoutConfig().setWidth(12));
  static final SizedBox w16 = SizedBox(width: LayoutConfig().setWidth(16));
  static final SizedBox w32 = SizedBox(width: LayoutConfig().setWidth(32));
  static final SizedBox w56 = SizedBox(width: LayoutConfig().setWidth(56));
  static final SizedBox w96 = SizedBox(width: LayoutConfig().setWidth(96));

  static const Spacer spacer = Spacer();

  static const EdgeInsets zero = EdgeInsets.zero;
  static final EdgeInsets all1 = EdgeInsets.symmetric(
      vertical: LayoutConfig().setHeight(1),
      horizontal: LayoutConfig().setWidth(1));
  static final EdgeInsets all5 = EdgeInsets.symmetric(
      vertical: LayoutConfig().setHeight(5),
      horizontal: LayoutConfig().setWidth(5));
  static final EdgeInsets all8 = EdgeInsets.symmetric(
      vertical: LayoutConfig().setHeight(8),
      horizontal: LayoutConfig().setWidth(8));
  static final EdgeInsets all10 = EdgeInsets.symmetric(
      vertical: LayoutConfig().setHeight(10),
      horizontal: LayoutConfig().setWidth(10));
  static final EdgeInsets all15 = EdgeInsets.symmetric(
      vertical: LayoutConfig().setHeight(15),
      horizontal: LayoutConfig().setWidth(15));
  static final EdgeInsets all20 = EdgeInsets.symmetric(
      vertical: LayoutConfig().setHeight(20),
      horizontal: LayoutConfig().setWidth(20));
  static final EdgeInsets all30 = EdgeInsets.symmetric(
      vertical: LayoutConfig().setHeight(30),
      horizontal: LayoutConfig().setWidth(30));
  static final EdgeInsets all70 = EdgeInsets.symmetric(
      vertical: LayoutConfig().setHeight(70),
      horizontal: LayoutConfig().setWidth(70));

  static final EdgeInsets h1 =
      EdgeInsets.symmetric(horizontal: LayoutConfig().setWidth(1));
  static final EdgeInsets h5 =
      EdgeInsets.symmetric(horizontal: LayoutConfig().setWidth(5));
  static final EdgeInsets h8 =
      EdgeInsets.symmetric(horizontal: LayoutConfig().setWidth(8));
  static final EdgeInsets h10 =
      EdgeInsets.symmetric(horizontal: LayoutConfig().setWidth(10));
  static final EdgeInsets h15 =
      EdgeInsets.symmetric(horizontal: LayoutConfig().setWidth(15));
  static final EdgeInsets h20 =
      EdgeInsets.symmetric(horizontal: LayoutConfig().setWidth(20));
  static final EdgeInsets h30 =
      EdgeInsets.symmetric(horizontal: LayoutConfig().setWidth(30));
  static final EdgeInsets h50 =
      EdgeInsets.symmetric(horizontal: LayoutConfig().setWidth(50));

  static final EdgeInsets onlyRight15 =
      EdgeInsets.only(right: LayoutConfig().setWidth(15));

  static final EdgeInsets v1 =
      EdgeInsets.symmetric(vertical: LayoutConfig().setHeight(1));
  static final EdgeInsets v5 =
      EdgeInsets.symmetric(vertical: LayoutConfig().setHeight(5));
  static final EdgeInsets v8 =
      EdgeInsets.symmetric(vertical: LayoutConfig().setHeight(8));
  static final EdgeInsets v10 =
      EdgeInsets.symmetric(vertical: LayoutConfig().setHeight(10));
  static final EdgeInsets v15 =
      EdgeInsets.symmetric(vertical: LayoutConfig().setHeight(15));
  static final EdgeInsets v20 =
      EdgeInsets.symmetric(vertical: LayoutConfig().setHeight(20));
  static final EdgeInsets v30 =
      EdgeInsets.symmetric(vertical: LayoutConfig().setHeight(30));
}
