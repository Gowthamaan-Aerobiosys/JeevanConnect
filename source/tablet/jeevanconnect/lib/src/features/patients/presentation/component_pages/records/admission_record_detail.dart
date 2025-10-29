import 'package:flutter/material.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../shared/domain/date_time_formatter.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/components/widget_decoration.dart';
import '../patient_summary.dart';
import 'abg_report_screen.dart';
import 'clinical_logs.dart';

class AdmissionRecordDetail extends StatelessWidget {
  final int id;
  final dynamic record;
  const AdmissionRecordDetail(
      {super.key, required this.record, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.greyC2,
      body: Padding(
        padding: WhiteSpace.all30,
        child: SingleChildScrollView(
          padding: WhiteSpace.h15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "AMR - $id",
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              WhiteSpace.b32,
              Row(
                children: [
                  WhiteSpace.w56,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Admission date",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppPalette.greyC3),
                      ),
                      WhiteSpace.b32,
                      Text(
                        "Height",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppPalette.greyC3),
                      ),
                      WhiteSpace.b32,
                      Text(
                        "Weight",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppPalette.greyC3),
                      ),
                      WhiteSpace.b32,
                      Text(
                        "IBW",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppPalette.greyC3),
                      ),
                      WhiteSpace.b32,
                      Text(
                        "BMI",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppPalette.greyC3),
                      ),
                      WhiteSpace.b32,
                      Text(
                        "Reason for admission",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppPalette.greyC3),
                      ),
                      WhiteSpace.b32,
                      Text(
                        "History of BP/Coronary heart disease",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppPalette.greyC3),
                      ),
                      WhiteSpace.b32,
                      Text(
                        "Tags",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppPalette.greyC3),
                      ),
                    ],
                  ),
                  WhiteSpace.w56,
                  Column(
                    children: [
                      Text(
                        DateTimeFormat.getTimeStamp(record.admissionDate),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      WhiteSpace.b32,
                      Text(
                        "${record.height.toString()} cm",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      WhiteSpace.b32,
                      Text(
                        "${record.weight.toString()} kg",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      WhiteSpace.b32,
                      Text(
                        "${record.ibw} kg",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      WhiteSpace.b32,
                      Text(
                        record.bmi,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      WhiteSpace.b32,
                      Text(
                        record.historyOfDiabetes ? "Yes" : "No",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      WhiteSpace.b32,
                      Text(
                        record.historyOfBp ? "Yes" : "No",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      WhiteSpace.b32,
                      Wrap(
                        spacing: 5.0,
                        runSpacing: 5.0,
                        runAlignment: WrapAlignment.center,
                        children: record.tags.map<Widget>((chipLabel) {
                          return FilterChip(
                            padding: WhiteSpace.zero,
                            avatarBorder: WidgetDecoration.sharpEdge,
                            backgroundColor: AppPalette.white,
                            selectedColor: AppPalette.blueC1,
                            showCheckmark: false,
                            label: Text(chipLabel.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(color: AppPalette.black)),
                            selected: true,
                            onSelected: (bool selected) {},
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
              WhiteSpace.b32,
              const Divider(),
              WhiteSpace.b32,
              SizedBox(
                height: LayoutConfig().setFractionHeight(50),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: AppPalette.white,
                            shape: WidgetDecoration.roundedEdge5,
                            margin: WhiteSpace.zero,
                            child: InfoTile(
                              isCentered: false,
                              isBold: false,
                              isParagraph: true,
                              titleColor: AppPalette.blueS9,
                              title: "Reason for Admission",
                              subTitle: record.reasonForAdmission,
                            ),
                          ),
                        ),
                        WhiteSpace.w6,
                        Expanded(
                          child: Card(
                            color: AppPalette.white,
                            shape: WidgetDecoration.roundedEdge5,
                            margin: WhiteSpace.zero,
                            child: InfoTile(
                              isCentered: false,
                              isBold: false,
                              isParagraph: true,
                              titleColor: AppPalette.blueS9,
                              title: "Reason for Ventilation",
                              subTitle: record.reasonForVentilation,
                            ),
                          ),
                        ),
                      ],
                    ),
                    WhiteSpace.b6,
                    Expanded(
                      child: Card(
                        color: AppPalette.white,
                        shape: WidgetDecoration.roundedEdge5,
                        margin: WhiteSpace.zero,
                        child: InfoTile(
                          isCentered: false,
                          isBold: false,
                          maxLines: 5,
                          isParagraph: true,
                          titleColor: AppPalette.blueS9,
                          title: "Summary",
                          subTitle: record.currentStatus,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              WhiteSpace.b32,
              const Divider(),
              WhiteSpace.b32,
              Text(
                "ABG Reports",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              WhiteSpace.b32,
              SizedBox(
                height: LayoutConfig().setFractionHeight(70),
                child: ABGReportScreen(recordId: record.id),
              ),
              WhiteSpace.b32,
              const Divider(),
              WhiteSpace.b32,
              ClinicalLogs(recordId: record.id)
            ],
          ),
        ),
      ),
    );
  }
}
