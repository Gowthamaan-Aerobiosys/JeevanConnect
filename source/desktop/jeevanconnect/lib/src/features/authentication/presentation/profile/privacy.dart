import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';

class PrivacyTab extends StatelessWidget {
  const PrivacyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.white,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.all10,
      child: Padding(
        padding: WhiteSpace.all20,
      ),
    );
  }
}
