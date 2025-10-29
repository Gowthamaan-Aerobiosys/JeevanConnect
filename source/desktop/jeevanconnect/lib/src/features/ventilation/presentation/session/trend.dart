import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../config/presentation/layout_config.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import '../../data/monitoring_repository.dart';
import 'shaded_time_series_graph.dart';

class MonitoringTrend extends StatefulWidget {
  final dynamic session;
  const MonitoringTrend({super.key, required this.session});

  @override
  State<MonitoringTrend> createState() => _MonitoringTrendState();
}

class _MonitoringTrendState extends State<MonitoringTrend> {
  late String _duration;
  late int timeDetail;
  static const List<String> _paramLabels = [
    'PIP (cmH\u2082O)',
    'PEEP (cmH\u2082O)',
    'Tidal Volume (ml)',
    'Compliance (ml/cmH\u2082O)',
    'Minute Volume (liter)',
    'FiO\u2082',
    'PIF'
  ];
  bool isReady = false;
  static const List<String> _timeFrames = [
    '5 minutes',
    '15 minutes',
    '30 minutes',
    '1 hour',
    '3 hours',
    '9 hours',
    '12 hours',
    '24 hours',
    '48 hours'
  ];
  static const List<String> _paramNames = [
    "pip",
    "peep",
    "vti",
    "compliance",
    "minuteVolume",
    "fio",
    "pif",
    "time"
  ];

  @override
  void initState() {
    super.initState();
    isReady = false;
    _duration = '3 hours';
    timeDetail = 4;
  }

  @override
  void dispose() {
    super.dispose();
  }

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
                  .getMonitoringLog(widget.session.sessionId, "trend"),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  if (snapshot.data.isEmpty) {
                    return Center(
                        child: Text(
                      "No monitoring data recorded",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(color: AppPalette.black),
                    ));
                  } else {
                    final events = snapshot.data;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        WhiteSpace.b16,
                        DropdownButton<String>(
                          value: _duration,
                          items: _timeFrames
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(color: AppPalette.black)));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _duration = value ?? '48 hours';
                              timeDetail = _timeFrames.indexOf(_duration);
                              isReady = false;
                            });
                            Future.delayed(const Duration(milliseconds: 600),
                                () {
                              isReady = true;
                              setState(() {});
                            });
                          },
                          iconSize: 40,
                          dropdownColor: AppPalette.white,
                        ),
                        Expanded(
                          child: ListView.separated(
                              padding: WhiteSpace.all10,
                              itemCount: 7,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                    height:
                                        LayoutConfig().setFractionHeight(50),
                                    width: double.infinity,
                                    padding: WhiteSpace.all5,
                                    decoration: const BoxDecoration(
                                        color: AppPalette.black,
                                        borderRadius:
                                            WidgetDecoration.borderRadius5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        WhiteSpace.b12,
                                        Padding(
                                          padding: WhiteSpace.h20,
                                          child: Text(_paramLabels[index],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge),
                                        ),
                                        Expanded(
                                          child: ShadedTimeSeriesGraph(
                                            x: events["time"],
                                            y: events[_paramNames[index]],
                                            timeFrame: timeDetail,
                                            parameterLabel: _paramLabels[index],
                                          ),
                                        ),
                                        WhiteSpace.b12,
                                      ],
                                    ));
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      WhiteSpace.b32),
                        )
                      ],
                    );
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
