import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import 'white_space.dart';
import 'widget_decoration.dart';

class Button extends StatelessWidget {
  const Button(
      {super.key,
      this.shape = WidgetDecoration.roundedEdge5,
      this.hoverColor,
      this.buttonPadding,
      this.backgroundColor = AppPalette.blueS9,
      this.padding,
      this.toolTip = "",
      this.waitDuration = const Duration(seconds: 1),
      this.minWidth,
      this.onPressed,
      required this.child,
      this.onLongPress});

  final ShapeBorder? shape;
  final Color? hoverColor;
  final Color? backgroundColor;
  final EdgeInsets? buttonPadding;
  final EdgeInsets? padding;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double? minWidth;
  final String toolTip;
  final Duration waitDuration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: toolTip,
      waitDuration: waitDuration,
      child: MaterialButton(
        onPressed: onPressed,
        minWidth: minWidth,
        shape: shape,
        padding: padding,
        color: backgroundColor,
        hoverColor: hoverColor,
        elevation: 0.0,
        onLongPress: onLongPress,
        child: Padding(
          padding: buttonPadding ?? WhiteSpace.v5,
          child: child,
        ),
      ),
    );
  }
}
