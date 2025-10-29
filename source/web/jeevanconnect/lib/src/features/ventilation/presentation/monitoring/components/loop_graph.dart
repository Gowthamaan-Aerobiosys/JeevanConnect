import 'package:flutter/material.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../shared/presentation/widgets/simple_two_dimensional_graph.dart';

class LoopGraph extends StatelessWidget {
  final List<double> pressure, flow, volume;

  const LoopGraph(
      {super.key,
      required this.pressure,
      required this.flow,
      required this.volume});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: SimpleTwoDimensionalGraph(
          yAxisMax: 2000,
          yAxisMin: -200,
          xAxisMax: 70,
          xAxisMin: -10,
          xTickScaling: (1, 18),
          yTickScaling: (1, 1),
          traceColor: AppPalette.pink,
          dataSetXValues: pressure,
          dataSetYValues: volume,
          title: 'Pressure vs Volume',
        ),
      ),
      Expanded(
        child: SimpleTwoDimensionalGraph(
          yAxisMax: 200,
          yAxisMin: -200,
          xAxisMax: 2000,
          xAxisMin: -200,
          xTickScaling: (70, 1),
          yTickScaling: (22, 1),
          traceColor: AppPalette.yellow,
          dataSetXValues: volume,
          dataSetYValues: flow,
          title: 'Volume vs Flow',
        ),
      ),
    ]);
  }
}
