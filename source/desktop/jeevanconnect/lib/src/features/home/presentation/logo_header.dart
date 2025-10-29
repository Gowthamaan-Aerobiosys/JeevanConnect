import 'package:flutter/material.dart';

import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/widgets/aerobiosys_logo.dart';

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: LayoutConfig().setFractionHeight(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AerobiosysLogo(height: 30),
          WhiteSpace.w16,
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              "JeevanConnect",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    );
  }
}
