import 'package:flutter/material.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../shared/presentation/widgets/time_series_graph.dart';

class LiveGraph extends StatelessWidget {
  final List<double> pressure, flow, volume, timeStamp;
  final List<bool> pointType;

  const LiveGraph(
      {super.key,
      required this.pressure,
      required this.flow,
      required this.timeStamp,
      required this.pointType,
      required this.volume});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: TimeSeriesGraph(
            title: "Pressure",
            yAxisMin: -10,
            yAxisMax: 75,
            positiveTraceColor: AppPalette.pink,
            isAutoScaled: false,
            negativeTraceColor: AppPalette.blue,
            dataSetXValues: timeStamp,
            dataSetYValues: pressure,
            pointType: pointType,
          ),
        ),
        Expanded(
          child: TimeSeriesGraph(
            title: "Flow",
            yAxisMin: -120,
            yAxisMax: 120,
            isAutoScaled: false,
            positiveTraceColor: AppPalette.orange,
            negativeTraceColor: AppPalette.green,
            dataSetXValues: timeStamp,
            dataSetYValues: flow,
            pointType: pointType,
          ),
        ),
        Expanded(
          child: TimeSeriesGraph(
            title: "Volume",
            yAxisMin: -200,
            isAutoScaled: false,
            yAxisMax: 1700,
            positiveTraceColor: Colors.yellowAccent,
            negativeTraceColor: AppPalette.brown,
            dataSetXValues: timeStamp,
            dataSetYValues: volume,
            pointType: pointType,
          ),
        ),
      ],
    );
  }
}
