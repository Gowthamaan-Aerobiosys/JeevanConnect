import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../config/presentation/layout_config.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import 'about/device_usage_statistics.dart';

class GraphCard extends StatefulWidget {
  const GraphCard({super.key});

  @override
  State<GraphCard> createState() => _GraphCardState();
}

class _GraphCardState extends State<GraphCard> {
  static const _graphs = ['Battery', 'Monitoring Usage', 'Up time'];
  List<bool> _selected = [];
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _selected = List.generate(_graphs.length, (index) => false);
    _selected[1] = true;
    _selectedIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.white,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.zero,
      child: SizedBox(
        height: LayoutConfig().setHeight(350),
        width: LayoutConfig().setFractionWidth(67.9),
        child: IntrinsicHeight(
          child: Padding(
            padding: WhiteSpace.all10,
            child: Row(
              children: [
                SizedBox(
                  width: LayoutConfig().setFractionWidth(15),
                  child: ListView.builder(
                    itemCount: _graphs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        shape: WidgetDecoration.roundedEdge5,
                        selectedTileColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        selected: _selected[index],
                        title: Text(
                          _graphs[index],
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                  color: _selected[index]
                                      ? AppPalette.white
                                      : AppPalette.greyC3),
                        ),
                        onTap: () {
                          _selected =
                              List.generate(_graphs.length, (index) => false);
                          _selected[index] = true;
                          _selectedIndex = index;
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
                const VerticalDivider(),
                SizedBox(
                  width: LayoutConfig().setFractionWidth(50),
                  child: Center(
                    child: _selectedIndex == 1
                        ? const DeviceUsageStatistics(
                            year: 2024,
                          )
                        : Text(
                            "No data found",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(color: AppPalette.black),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
