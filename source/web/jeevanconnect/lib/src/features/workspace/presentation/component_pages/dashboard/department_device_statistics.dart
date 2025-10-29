import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/components/widget_decoration.dart';

class DepartmentDeviceStatistics extends StatefulWidget {
  final dynamic analytics;
  const DepartmentDeviceStatistics({super.key, required this.analytics});

  @override
  State<DepartmentDeviceStatistics> createState() =>
      _DepartmentDeviceStatisticsState();
}

class _DepartmentDeviceStatisticsState
    extends State<DepartmentDeviceStatistics> {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: const FlGridData(show: true),
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: true,
        allowTouchBarBackDraw: true,
        handleBuiltInTouches: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => AppPalette.transparent,
          tooltipPadding: WhiteSpace.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
                rod.toY.round().toString(),
                Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: AppPalette.white, fontWeight: FontWeight.w700));
          },
        ),
      );

  Widget getBottomTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: AxisSide.right,
      space: 4,
      child: Text(widget.analytics.departments[value.toInt()],
          textAlign: TextAlign.center,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: AppPalette.blueC1,
              )),
    );
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: AxisSide.right,
      space: 4,
      child: Text(value.toStringAsFixed(0),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: AppPalette.white,
              )),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          drawBelowEverything: true,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: LayoutConfig().setHeight(30),
            getTitlesWidget: getBottomTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: LayoutConfig().setWidth(20),
            getTitlesWidget: getLeftTitles,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => const LinearGradient(
        colors: [
          AppPalette.blueC2,
          AppPalette.cyanC1,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.bottomCenter,
      );

  List<BarChartGroupData> get barGroups => widget.analytics.departments
      .map((element) {
        return BarChartGroupData(
          x: widget.analytics.departments.indexOf(element),
          barRods: [
            BarChartRodData(
                toY: widget.analytics.departmentWiseDevices[element]
                        ?.toDouble() ??
                    0.0,
                gradient: _barsGradient,
                width: 20,
                borderRadius: WidgetDecoration.borderRadius5)
          ],
          showingTooltipIndicators: [0],
        );
      })
      .toList()
      .cast<BarChartGroupData>();
}
