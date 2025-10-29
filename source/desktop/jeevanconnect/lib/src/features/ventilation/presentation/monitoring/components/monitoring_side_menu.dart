import 'package:flutter/material.dart';

import '../../../../../config/data/assets.dart';
import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../shared/presentation/components/button.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/components/widget_decoration.dart';
import '../../../../../shared/presentation/dialogs/dialogs.dart';
import '../../../data/socket_data_handler.dart';
import '../../../domain/monitoring_ui_controllers.dart';
import 'jv_view.dart';
import 'set_parameters_display.dart';

class MonitoringSideMenu extends StatelessWidget {
  const MonitoringSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> sideMenuKey =
        GlobalKey<NavigatorState>(debugLabel: "Side Menu");

    return Expanded(
      flex: 4,
      child: Navigator(
          key: sideMenuKey,
          initialRoute: 'default',
          onGenerateRoute: (RouteSettings settings) {
            WidgetBuilder builder;
            switch (settings.name) {
              case 'default':
                builder =
                    (BuildContext _) => DefaultMenu(navigatorKey: sideMenuKey);
                break;
              case 'jvView':
                builder = (BuildContext _) => JvView(navigatorKey: sideMenuKey);
                break;
              default:
                throw Exception('Invalid route: ${settings.name}');
            }
            return MaterialPageRoute(
                builder: builder, settings: settings, fullscreenDialog: true);
          }),
    );
  }
}

class DefaultMenu extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const DefaultMenu({super.key, required this.navigatorKey});

  static String modeName = "...";

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.transparent,
      elevation: 0,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.h5,
      child: SizedBox(
        child: Column(
          children: [
            WhiteSpace.b16,
            Button(
              onPressed: () {
                if (MonitoringUIControllers.settings.isNotEmpty) {
                  _viewSetData(context);
                } else {
                  simpleDialog(context,
                      title: "Gathering data",
                      type: DialogType.info,
                      content:
                          "JeevanConnect is gathering data, this may take a while. Try again later",
                      buttonName: "Close");
                }
              },
              backgroundColor: AppPalette.transparent,
              child: StreamBuilder(
                  stream: SocketDataHandler().modeData,
                  initialData: null,
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    if (data != null) {
                      if (data.isNotEmpty) {
                        MonitoringUIControllers().rebuildSettings(data);
                        modeName = MonitoringUIControllers.currentMode.modeName;
                      }
                    }
                    return Text.rich(
                      TextSpan(
                          text: modeName,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 50),
                          children: <InlineSpan>[
                            TextSpan(
                              text: '\nAdult/Ped.',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(
                                      fontWeight: FontWeight.normal,
                                      color: AppPalette.deepOrangeS9),
                            )
                          ]),
                      textAlign: TextAlign.center,
                    );
                  }),
            ),
            WhiteSpace.b16,
            SizedBox(
              height: LayoutConfig().setFractionHeight(35),
              child: Button(
                onPressed: () {
                  navigatorKey.currentState?.pushNamed("jvView");
                },
                backgroundColor: AppPalette.transparent,
                child: Image.asset(
                  AppAssets.lungs,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            StreamBuilder(
                stream: MonitoringUIControllers().derivedParameters,
                builder: (context, snapshot) {
                  final parameter = snapshot.data;
                  return Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      _parameterTableRow(
                          "RR", parameter?.rr ?? "...", "breathe/min", context),
                      _parameterTableRow(
                          "minVol", parameter?.minVol ?? "...", "l", context),
                      _parameterTableRow("CStat", parameter?.cstat ?? "...",
                          "ml/cmH2O", context),
                      _parameterTableRow("Rinsp", parameter?.rInsp ?? "...",
                          "cmH2O/l/s", context),
                      _parameterTableRow("Cplat", parameter?.cplat ?? "...",
                          "ml/cmH\u2082O", context),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  TableRow _parameterTableRow(
      String title, String value, String unit, BuildContext context) {
    return TableRow(children: [
      Container(
        height: 45,
        alignment: Alignment.center,
        padding: WhiteSpace.v5,
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

  _viewSetData(context) {
    Map setValues = {};
    for (var parameter in MonitoringUIControllers.currentMode.parameters) {
      if (parameter.parameterId == "pressureTriggerLimit") {
        if (MonitoringUIControllers.settings["flowTrigger"]) {
          setValues["Flow Trigger Limit"] =
              "${MonitoringUIControllers.settings["flowTriggerLimit"]} ${parameter.unit}";
        } else {
          setValues[parameter.title] =
              "${MonitoringUIControllers.settings[parameter.parameterId]} ${parameter.unit}";
        }
      } else {
        setValues[parameter.title] =
            "${MonitoringUIControllers.settings[parameter.parameterId]} ${parameter.unit}";
      }
    }

    generalDialog(
      context,
      barrierDismissible: true,
      alignment: Alignment.centerRight,
      child: SetParameterTable(
        setValues: setValues,
        title: modeName,
      ),
    );
  }
}
