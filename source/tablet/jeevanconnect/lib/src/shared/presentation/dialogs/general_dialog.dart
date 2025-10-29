import 'package:flutter/material.dart';

import '../components/white_space.dart';

Future generalDialog(context,
    {required Widget child,
    EdgeInsets? padding,
    Alignment alignment = Alignment.center,
    bool barrierDismissible = false}) {
  return showGeneralDialog(
      context: context,
      barrierLabel: "",
      barrierDismissible: barrierDismissible,
      pageBuilder: (context, _, __) {
        return PopScope(
          canPop: barrierDismissible,
          child: Padding(
            padding: padding ?? WhiteSpace.all30,
            child: Align(alignment: alignment, child: child),
          ),
        );
      });
}
