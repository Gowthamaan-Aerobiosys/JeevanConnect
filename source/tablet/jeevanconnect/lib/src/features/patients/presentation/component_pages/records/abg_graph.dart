import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jeevanconnect/src/shared/presentation/components/white_space.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../shared/domain/date_time_formatter.dart';
import '../../../../../shared/presentation/components/widget_decoration.dart';
import '../../../data/patient_repository.dart';

class ABGGraph extends StatefulWidget {
  final dynamic recordId;
  const ABGGraph({super.key, required this.recordId});

  @override
  State<ABGGraph> createState() => _ABGGraphState();
}

class _ABGGraphState extends State<ABGGraph> {
  Map? graphData;
  bool isLoading = false;
  List lables = [], timeStamps = [];
  String id = "pH";

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String label = "";
    if (lables.isNotEmpty && label.length > value.toInt()) {
      label = lables[value.toInt()];
    }
    return SideTitleWidget(
      axisSide: AxisSide.top,
      space: 0,
      child: Text(label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: AppPalette.blueC1,
              )),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    String text = value < 0 ? "" : value.toStringAsFixed(0);
    return SideTitleWidget(
      axisSide: AxisSide.right,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: AppPalette.white,
            ),
      ),
    );
  }

  _getGraphData() async {
    isLoading = true;
    if (widget.recordId != null) {
      graphData = await PatientRepository().getABGGraph(widget.recordId);
      _prepareTimeStamps();
    }
    isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  _prepareTimeStamps() {
    if (graphData != null) {
      final instances = graphData!['graph_data']['timestamps'];
      if (instances == null) {
        timeStamps = [];
        return;
      }
      timeStamps = instances
          .map((element) => DateTime.parse(element))
          .map((dateTime) =>
              dateTime.difference(DateTime.parse(instances.first)).inHours)
          .toList();
      lables = instances
          .map((element) =>
              DateTimeFormat.getGraphStamp(DateTime.parse(element)))
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _getGraphData();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.greyC5,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.zero,
      child: Padding(
        padding: WhiteSpace.all10,
        child: Column(
          children: [
            WhiteSpace.b12,
            Text(
              "ABG Report Trend",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(),
            ),
            WhiteSpace.b12,
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(
                    value: "pH", label: Text('pH', style: _getTextStyle("pH"))),
                ButtonSegment<String>(
                    value: "pCO2",
                    label: Text('pCO2', style: _getTextStyle("pCO2"))),
                ButtonSegment<String>(
                    value: "pO2",
                    label: Text('pO2', style: _getTextStyle("pO2"))),
                ButtonSegment<String>(
                    value: "hCO3",
                    label: Text('hCO3', style: _getTextStyle("hCO3"))),
                ButtonSegment<String>(
                    value: "base_excess",
                    label: Text('BEecf', style: _getTextStyle("BEecf"))),
                ButtonSegment<String>(
                    value: "sO2",
                    label: Text('sO2', style: _getTextStyle("sO2"))),
                ButtonSegment<String>(
                    value: "lactate",
                    label: Text('Lactate', style: _getTextStyle("lactate"))),
              ],
              selected: {id},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  id = newSelection.first;
                });
              },
            ),
            WhiteSpace.b32,
            if (lables.isNotEmpty)
              isLoading
                  ? Center(
                      child: CupertinoActivityIndicator(
                        radius: 20,
                        color: Theme.of(context).primaryColorLight,
                      ),
                    )
                  : Expanded(
                      child: Padding(
                        padding: WhiteSpace.h30,
                        child: LineChart(
                          LineChartData(
                            lineTouchData: const LineTouchData(enabled: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: getSpots(id),
                                isCurved: false,
                                barWidth: 2,
                                color: AppPalette.pink,
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                            minY: -1,
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 6,
                                  reservedSize: LayoutConfig().setHeight(35),
                                  getTitlesWidget: bottomTitleWidgets,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: leftTitleWidgets,
                                  reservedSize: LayoutConfig().setWidth(40),
                                ),
                              ),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(
                                show: true, drawVerticalLine: false),
                          ),
                        ),
                      ),
                    ),
            if (lables.isEmpty) WhiteSpace.spacer,
            if (lables.isEmpty)
              Text(
                "No recorded data",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            if (lables.isEmpty) WhiteSpace.spacer,
          ],
        ),
      ),
    );
  }

  _getTextStyle(name) {
    return Theme.of(context)
        .textTheme
        .headlineSmall!
        .copyWith(color: name == id ? AppPalette.black : AppPalette.white);
  }

  List<FlSpot> getSpots(id) {
    if (graphData == null) {
      return [];
    }
    List<FlSpot> spots = [];
    final values = graphData!['graph_data'][id];
    if (values == null) {
      return [];
    }
    if (values.length != timeStamps.length) {
      return [];
    }
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(timeStamps[i].toDouble(), values[i]));
    }
    return spots;
  }
}
