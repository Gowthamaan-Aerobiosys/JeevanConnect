import 'package:flutter/material.dart';

import '../../../../config/presentation/layout_config.dart';
import '../../../../shared/presentation/components/white_space.dart';
import 'components/alert_banner.dart';

class MonitoringAppBar extends StatelessWidget {
  final dynamic session;
  const MonitoringAppBar({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final displayName = session.patient?.patientId ?? session.sessionId;

    return SizedBox(
      height: LayoutConfig().setFractionHeight(8),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: WhiteSpace.h30,
              child: Text(
                displayName,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Center(child: AlertBanner()),
        ],
      ),
    );
  }
}
