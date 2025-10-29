import 'package:flutter/material.dart';
import 'package:jeevanconnect/src/shared/presentation/components/white_space.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../shared/presentation/components/widget_decoration.dart';
import '../../../domain/monitoring_ui_controllers.dart';
import '../../../domain/parameter.dart';

class VitalParameterCard extends StatefulWidget {
  final Parameter parameter;
  final int index;

  const VitalParameterCard(
      {super.key, required this.index, required this.parameter});

  @override
  State<VitalParameterCard> createState() => _VitalParameterCardState();
}

class _VitalParameterCardState extends State<VitalParameterCard> {
  static const _units = ["cmH2O", "cmH2O", "ml", "%", "breathe/min"];
  static const _sampleId = ["pip", "peep", "vti", "fio", "rr"];

  static const Gradient _gradientOne = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment(1.8, 0.0),
    colors: [
      Color(0xFF1F2F98),
      Color(0xFF1CA7EC),
    ],
    tileMode: TileMode.repeated,
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: WhiteSpace.all5,
        decoration: const BoxDecoration(
            gradient: _gradientOne,
            borderRadius: WidgetDecoration.borderRadius5),
        child: Stack(
          children: <Widget>[
            Text(widget.parameter.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: AppPalette.amber)),
            Align(
              alignment: Alignment.centerRight,
              child: StreamBuilder(
                  stream: MonitoringUIControllers().derivedParameters,
                  builder: (context, snapshot) {
                    final parameter = snapshot.data;
                    return Text(
                        parameter?.vitalParameters?[_sampleId[widget.index]] ??
                            "...",
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                fontSize: 90.0));
                  }),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: <Widget>[
                  const Spacer(),
                  Text(
                    _units[widget.index],
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: AppPalette.greyS4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
