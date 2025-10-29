import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';

class DeviceActivityChart extends StatefulWidget {
  final int activeDevices;
  final int offlineDevices;
  final int idleDevices;
  final int repairDevices;

  const DeviceActivityChart({
    super.key,
    required this.activeDevices,
    required this.offlineDevices,
    required this.idleDevices,
    required this.repairDevices,
  });

  @override
  State<DeviceActivityChart> createState() => _DeviceActivityChartState();
}

class _DeviceActivityChartState extends State<DeviceActivityChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final totalDevices = widget.activeDevices +
        widget.offlineDevices +
        widget.idleDevices +
        widget.repairDevices;
    final activePercentage =
        (widget.activeDevices / (totalDevices != 0 ? totalDevices : 1) * 100)
            .toStringAsFixed(1);

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              pieTouchData: PieTouchData(
                touchCallback: (totalDevices == 0)
                    ? null
                    : (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              centerSpaceRadius: LayoutConfig().setWidth(45),
              sections: [
                PieChartSectionData(
                  color: AppPalette.greenS8,
                  value: widget.activeDevices.toDouble(),
                  title: 'IU-${widget.activeDevices}',
                  radius: isTouched(0)
                      ? LayoutConfig().setWidth(40)
                      : LayoutConfig().setWidth(30),
                  titleStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                PieChartSectionData(
                  color: AppPalette.blueS9,
                  value: widget.idleDevices.toDouble(),
                  title: 'ID-${widget.idleDevices}',
                  radius: isTouched(1)
                      ? LayoutConfig().setWidth(40)
                      : LayoutConfig().setWidth(30),
                  titleStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                PieChartSectionData(
                  color: AppPalette.greyC3,
                  value: widget.repairDevices.toDouble(),
                  title: 'RP-${widget.repairDevices}',
                  radius: isTouched(2)
                      ? LayoutConfig().setWidth(40)
                      : LayoutConfig().setWidth(30),
                  titleStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                PieChartSectionData(
                  color: AppPalette.redS8,
                  value: widget.offlineDevices.toDouble(),
                  title: 'OF-${widget.offlineDevices}',
                  radius: isTouched(3)
                      ? LayoutConfig().setWidth(40)
                      : LayoutConfig().setWidth(30),
                  titleStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$activePercentage%',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'load',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: AppPalette.greyC3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  isTouched(index) {
    int currentIndex = index;

    final deviceCount = [
      widget.activeDevices,
      widget.idleDevices,
      widget.repairDevices,
      widget.offlineDevices,
    ];

    for (int i = index; i >= 0; i--) {
      if (deviceCount[i] <= 0) {
        currentIndex--;
      }
    }
    return currentIndex == touchedIndex;
  }
}
