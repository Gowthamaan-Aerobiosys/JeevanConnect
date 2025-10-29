import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jeevanconnect/src/shared/presentation/components/white_space.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../shared/presentation/components/widget_decoration.dart';
import '../../../data/product_repository.dart';

class DeviceUsageStatistics extends StatefulWidget {
  const DeviceUsageStatistics({
    super.key,
    required this.year,
    Color? line1Color,
    Color? line2Color,
    Color? betweenColor,
  })  : line1Color = line1Color ?? AppPalette.cyanC1,
        line2Color = line2Color ?? AppPalette.redS8,
        betweenColor = betweenColor ?? AppPalette.redS1;

  final Color line1Color;
  final Color line2Color;
  final Color betweenColor;
  final int year;

  @override
  State<DeviceUsageStatistics> createState() => _DeviceUsageStatisticsState();
}

class _DeviceUsageStatisticsState extends State<DeviceUsageStatistics> {
  Map sessionCount = {};

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 12:
        text = 'Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      case 4:
        text = 'May';
        break;
      case 5:
        text = 'Jun';
        break;
      case 6:
        text = 'Jul';
        break;
      case 7:
        text = 'Aug';
        break;
      case 8:
        text = 'Sep';
        break;
      case 9:
        text = 'Oct';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dec';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: AxisSide.left,
      space: 4,
      child: Text(text,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: AppPalette.blueC1,
              )),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    String text = value < 0 ? "" : value.toStringAsFixed(0);
    return SideTitleWidget(
      axisSide: AxisSide.right,
      space: 4,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: AppPalette.white,
            ),
      ),
    );
  }

  bool isLoading = false;

  _getSessionData() async {
    sessionCount =
        await ProductRepository().getProductSessionAnalytics(widget.year);
    isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void initState() {
    super.initState();
    _getSessionData();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.greyC5,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.zero,
      child: Padding(
        padding: WhiteSpace.all20,
        child: isLoading
            ? Center(
                child: CupertinoActivityIndicator(
                  radius: 20,
                  color: Theme.of(context).primaryColorLight,
                ),
              )
            : LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) =>
                            AppPalette.bgColorLight,
                      )),
                  lineBarsData: [
                    LineChartBarData(
                      spots: getSpots(),
                      isCurved: false,
                      barWidth: 3,
                      color: widget.line1Color,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  minY: -1,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: LayoutConfig().setHeight(20),
                        getTitlesWidget: bottomTitleWidgets,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        getTitlesWidget: leftTitleWidgets,
                        reservedSize: LayoutConfig().setWidth(40),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData:
                      const FlGridData(show: true, drawVerticalLine: false),
                ),
              ),
      ),
    );
  }

  List<FlSpot> getSpots() {
    int maxMonth = -1;
    List<FlSpot> spots = [];
    for (int i = 0; i < 12; i++) {
      final month = "${i + 1}".padLeft(2, "0");
      final count = sessionCount[month];
      if (count != null) {
        maxMonth = i + 1;
        spots.add(FlSpot(i.toDouble(), count.toDouble()));
      } else {
        spots.add(FlSpot(i.toDouble(), 0.0));
      }
    }

    return maxMonth == -1 ? [] : spots.sublist(0, maxMonth);
  }
}
