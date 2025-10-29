import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../components/white_space.dart';

class BinaryStatusIndicator extends StatelessWidget {
  final bool isActive;
  final (String, String) labels;
  final Color? activeBackground,
      inactiveBackground,
      activeForeground,
      inactiveForeground;
  const BinaryStatusIndicator(
      {super.key,
      required this.isActive,
      required this.labels,
      this.activeBackground = AppPalette.greenS1,
      this.inactiveBackground = AppPalette.redS1,
      this.activeForeground = AppPalette.greenS8,
      this.inactiveForeground = AppPalette.redS8});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: WhiteSpace.all8,
      decoration: BoxDecoration(
        color: isActive ? activeBackground : inactiveBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          isActive ? labels.$1 : labels.$2,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: isActive ? activeForeground : inactiveForeground,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}
