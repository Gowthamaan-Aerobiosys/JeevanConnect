import 'package:flutter/material.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../shared/presentation/components/button.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/components/widget_decoration.dart';

class SetParameterTable extends StatelessWidget {
  final String title;
  final dynamic setValues;

  const SetParameterTable(
      {super.key, required this.setValues, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.white,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.all10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WhiteSpace.b16,
          Text(
            '$title - Ventilation Parameters',
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: AppPalette.black, fontWeight: FontWeight.bold),
          ),
          WhiteSpace.b16,
          SizedBox(
            width: LayoutConfig().setFractionWidth(30),
            height: LayoutConfig().setFractionHeight(40),
            child: SingleChildScrollView(
              child: Padding(
                padding: WhiteSpace.h30,
                child: Table(
                  border: TableBorder.all(color: AppPalette.grey),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: AppPalette.blueS9),
                      children: [
                        TableCell(
                          child: Padding(
                            padding: WhiteSpace.v5,
                            child: Text(
                              'Parameter',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: WhiteSpace.v5,
                            child: Text(
                              'Set',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...setValues.entries.map((entry) => TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: WhiteSpace.v5,
                                child: Text(
                                  entry.key,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: AppPalette.black),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: WhiteSpace.v5,
                                child: Text(
                                  entry.value.toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: AppPalette.black),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
          WhiteSpace.b16,
          Button(
            hoverColor: null,
            backgroundColor: AppPalette.greyC3,
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            minWidth: 150,
            child: Text(
              "Close",
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: AppPalette.black, fontWeight: FontWeight.bold),
            ),
          ),
          WhiteSpace.b16,
        ],
      ),
    );
  }
}
