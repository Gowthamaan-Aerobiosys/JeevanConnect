import 'package:flutter/material.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../data/socket_data_handler.dart';
import '../../../domain/monitoring_ui_controllers.dart';
import 'vital_parameter_display_card.dart';

class VitalParameterDisplay extends StatelessWidget {
  const VitalParameterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Card(
        elevation: 0,
        color: AppPalette.bgColorDark,
        margin: WhiteSpace.h5,
        child: SizedBox(
          height: double.infinity,
          child: StreamBuilder(
              stream: SocketDataHandler().modeData,
              builder: (context, snapshot) {
                return Column(
                  children: [
                    VitalParameterCard(
                      index: 0,
                      parameter: MonitoringUIControllers
                          .currentMode.displayCardParameters[0].$1,
                    ),
                    WhiteSpace.b3,
                    VitalParameterCard(
                      index: 1,
                      parameter: MonitoringUIControllers
                          .currentMode.displayCardParameters[1].$1,
                    ),
                    WhiteSpace.b3,
                    VitalParameterCard(
                      index: 2,
                      parameter: MonitoringUIControllers
                          .currentMode.displayCardParameters[2].$1,
                    ),
                    WhiteSpace.b3,
                    VitalParameterCard(
                      index: 3,
                      parameter: MonitoringUIControllers
                          .currentMode.displayCardParameters[3].$1,
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
