import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../config/presentation/layout_config.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import '../../data/monitoring_repository.dart';

class MonitoringEvents extends StatelessWidget {
  final dynamic session;
  const MonitoringEvents({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.white,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.all10,
      child: SizedBox(
        height: LayoutConfig().setFractionHeight(60),
        width: double.infinity,
        child: Padding(
          padding: WhiteSpace.all10,
          child: FutureBuilder(
              future: MonitoringRepository()
                  .getMonitoringLog(session.sessionId, "events"),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  if (snapshot.data.isEmpty) {
                    return Center(
                        child: Text(
                      "No events recorded",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(color: AppPalette.black),
                    ));
                  } else {
                    final events = snapshot.data;
                    return ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        padding: WhiteSpace.all10,
                        itemCount: events.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (events[index] != null) {
                            return Padding(
                              padding: WhiteSpace.v8,
                              child: Text(events[index]!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(color: AppPalette.black)),
                            );
                          }
                          return null;
                        });
                  }
                }

                return const Center(
                  child: CupertinoActivityIndicator(
                    radius: 20,
                    color: AppPalette.greyS8,
                  ),
                );
              }),
        ),
      ),
    );
  }
}
