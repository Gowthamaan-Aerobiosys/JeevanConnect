import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';

class UserActivityChart extends StatefulWidget {
  final int activeUsers;
  final int inactiveUsers;

  const UserActivityChart({
    super.key,
    required this.activeUsers,
    required this.inactiveUsers,
  });

  @override
  State<UserActivityChart> createState() => _UserActivityChartState();
}

class _UserActivityChartState extends State<UserActivityChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final totalUsers = widget.activeUsers + widget.inactiveUsers;
    final activePercentage =
        (widget.activeUsers / totalUsers * 100).toStringAsFixed(1);

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              pieTouchData: PieTouchData(
                touchCallback: (totalUsers == 0)
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
                  value: widget.activeUsers.toDouble(),
                  title: 'ON-${widget.activeUsers}',
                  radius: touchedIndex == 0
                      ? LayoutConfig().setWidth(40)
                      : LayoutConfig().setWidth(30),
                  titleStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                PieChartSectionData(
                  color: AppPalette.redS8,
                  value: widget.inactiveUsers.toDouble(),
                  title: 'OF-${widget.inactiveUsers}',
                  radius: touchedIndex == 1
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
                  'streak',
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
}
