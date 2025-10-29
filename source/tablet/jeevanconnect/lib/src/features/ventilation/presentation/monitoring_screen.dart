import 'package:flutter/material.dart';

import '../../../routing/routes.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../data/socket_data_handler.dart';
import '../domain/monitoring_ui_controllers.dart';
import 'monitoring/monitoring_app_bar.dart';
import 'monitoring/monitoring_content.dart';

class MonitoringScreen extends StatelessWidget {
  final dynamic session;
  const MonitoringScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF070B34),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Jeevan Connect - Monitoring Screen",
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        leading: WhiteSpace.w6,
        actions: [
          Button(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            hoverColor: null,
            padding: WhiteSpace.zero,
            buttonPadding: WhiteSpace.zero,
            child: Icon(
              Icons.logout_outlined,
              color: Theme.of(context).primaryColorLight,
              size: LayoutConfig().setFontSize(30),
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                MonitoringUIControllers().dispose();
                SocketDataHandler().disconnectSocket();
                context.pop();
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          MonitoringAppBar(session: session),
          WhiteSpace.b3,
          const Expanded(child: MontitoringContent()),
          WhiteSpace.b6
        ],
      ),
    );
  }
}
