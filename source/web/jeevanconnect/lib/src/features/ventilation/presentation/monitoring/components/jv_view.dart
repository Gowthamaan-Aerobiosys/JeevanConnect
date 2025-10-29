import 'package:flutter/material.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/components/widget_decoration.dart';
import '../../../domain/monitoring_ui_controllers.dart';

class JvView extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const JvView({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: WhiteSpace.zero,
      color: AppPalette.blueC4,
      shape: WidgetDecoration.roundedEdge5,
      child: GestureDetector(
        onDoubleTap: () {
          navigatorKey.currentState?.pushNamed("default");
        },
        child: ListView(
          padding: WhiteSpace.all10,
          children: [
            StreamBuilder(
                stream: MonitoringUIControllers().derivedParameters,
                initialData: null,
                builder: (context, snapshot) {
                  final parameter = snapshot.data;
                  return Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      _parameterTableRow("PIP", parameter?.pip ?? "...",
                          "cmH\u2082O", context),
                      _parameterTableRow("PEEP", parameter?.peep ?? "...",
                          "cmH\u2082O", context),
                      _parameterTableRow("Pplat", parameter?.pplat ?? "...",
                          "cmH\u2082O", context),
                      _parameterTableRow("MAP", parameter?.map ?? "...",
                          "cmH\u2082O", context),
                      _parameterTableRow(
                          "VTI", parameter?.vti ?? "...", "ml", context),
                      _parameterTableRow(
                          "VTE", parameter?.vte ?? "...", "ml", context),
                      _parameterTableRow("Rinsp", parameter?.rInsp ?? "...",
                          "cmH2O/l/s", context),
                      _parameterTableRow("CStat", parameter?.cstat ?? "...",
                          "ml/cmH2O", context),
                      _parameterTableRow("Cplat", parameter?.cplat ?? "...",
                          "ml/cmH\u2082O", context),
                      _parameterTableRow(
                          "RR", parameter?.rr ?? "...", "breathe/min", context),
                      _parameterTableRow("I:E",
                          _getIE(parameter?.i, parameter?.e), "", context),
                      _parameterTableRow(
                          "Ti", parameter?.ti ?? "...", "ms", context),
                      _parameterTableRow(
                          "Te", parameter?.te ?? "...", "ms", context),
                      _parameterTableRow(
                          "minVol", parameter?.minVol ?? "...", "l", context),
                      _parameterTableRow(
                          "PIF", parameter?.pif ?? "...", "lpm", context),
                      _parameterTableRow(
                          "PEF", parameter?.pef ?? "...", "lpm", context),
                      _parameterTableRow("SpO\u2082", "...", "%", context),
                      _parameterTableRow("Pulse", "...", "bpm", context),
                      _parameterTableRow("PI", "...", "%", context),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  _getIE(i, e) {
    if (i != null && e != null) {
      return "$i:$e";
    }
    return "...";
  }

  TableRow _parameterTableRow(
      String title, String value, String unit, BuildContext context) {
    return TableRow(children: [
      Container(
        height: 45,
        alignment: Alignment.center,
        padding: WhiteSpace.v1,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: AppPalette.amber),
        ),
      ),
      Text(
        value,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headlineMedium!
            .copyWith(fontWeight: FontWeight.bold),
      ),
      Text(unit,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: AppPalette.grey))
    ]);
  }
}
