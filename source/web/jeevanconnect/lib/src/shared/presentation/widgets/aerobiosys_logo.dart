import 'package:flutter/material.dart';

import '../../../config/data/assets.dart';
import '../../../config/presentation/layout_config.dart';

class AerobiosysLogo extends StatelessWidget {
  final double height;

  const AerobiosysLogo({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: LayoutConfig().setHeight(height),
      child: Hero(
        tag: "AerobiosysLogo",
        child: Image.asset(
          AppAssets.logo,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}
