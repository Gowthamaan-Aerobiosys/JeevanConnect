import 'package:flutter/material.dart';

import '../components/white_space.dart';

class GeneralStatusIndicator extends StatelessWidget {
  final String currentValue;
  final List<String> labels;
  final List<String> hints;
  final List<Color> backGroudColor;
  final List<Color> foreGroudColor;
  final bool isInTable;

  const GeneralStatusIndicator(
      {super.key,
      required this.currentValue,
      required this.labels,
      required this.hints,
      this.isInTable = false,
      required this.foreGroudColor,
      required this.backGroudColor});

  @override
  Widget build(BuildContext context) {
    final index = hints.indexOf(currentValue);

    return Container(
      padding: WhiteSpace.all5,
      decoration: BoxDecoration(
        color: backGroudColor[index],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          labels[index],
          style: isInTable
              ? Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: foreGroudColor[index],
                    fontWeight: FontWeight.w900,
                  )
              : Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: foreGroudColor[index],
                    fontWeight: FontWeight.w900,
                  ),
        ),
      ),
    );
  }
}
