import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import 'components/graph.dart';
import 'components/monitoring_side_menu.dart';
import 'components/vital_parameter_display.dart';

class MontitoringContent extends StatelessWidget {
  const MontitoringContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        VitalParameterDisplay(),
        Card(
          color: AppPalette.black,
          elevation: 0,
          shape: WidgetDecoration.roundedEdge5,
          margin: WhiteSpace.zero,
          child: MonitoringGraph(),
        ),
        MonitoringSideMenu(),
      ],
    );
  }
}
