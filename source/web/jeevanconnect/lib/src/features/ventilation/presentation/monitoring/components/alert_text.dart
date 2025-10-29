import 'package:flutter/material.dart';

import '../../../../../config/presentation/app_palette.dart';

class AlertBannerText extends StatelessWidget {
  final String message;
  const AlertBannerText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                letterSpacing: 3.0,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2.3
                  ..color = AppPalette.black,
              ),
        ),
        Text(
          message,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
              letterSpacing: 3.0,
              fontWeight: FontWeight.bold,
              color: AppPalette.white),
        ),
      ],
    );
  }
}
