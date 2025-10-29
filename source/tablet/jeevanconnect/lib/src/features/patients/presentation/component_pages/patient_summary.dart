import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jeevanconnect/src/features/patients/patients.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../config/presentation/layout_config.dart';
import '../../../../shared/domain/date_time_formatter.dart';
import '../../../../shared/presentation/components/button.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import '../../../../shared/presentation/dialogs/dialogs.dart';
import '../../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../../data/patient_repository.dart';
import 'patient_sessions.dart';
import 'records/abg_graph.dart';
import 'records/clinical_logs.dart';

class PatientSummary extends StatefulWidget {
  const PatientSummary({super.key});

  @override
  State<PatientSummary> createState() => _PatientSummaryState();
}

class _PatientSummaryState extends State<PatientSummary> {
  bool isLoading = true;

  late final dynamic patientSummary;

  _getPatientSummary() async {
    isLoading = true;
    final records = await PatientRepository().getAdmissionRecords();
    if (records.items.isEmpty) {
      patientSummary = null;
    } else {
      patientSummary = records.items.last;
    }

    isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void initState() {
    isLoading = true;
    _getPatientSummary();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CupertinoActivityIndicator(
              radius: 20,
              color: Theme.of(context).primaryColorLight,
            ),
          )
        : SingleChildScrollView(
            padding: WhiteSpace.h10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: LayoutConfig().setFractionHeight(50),
                  child: Row(
                    children: [
                      WhiteSpace.w6,
                      SizedBox(
                        width: LayoutConfig().setFractionWidth(20),
                        child: Column(
                          children: [
                            Card(
                              color: AppPalette.white,
                              shape: WidgetDecoration.roundedEdge5,
                              margin: WhiteSpace.zero,
                              child: Column(
                                children: [
                                  WhiteSpace.b12,
                                  Text(
                                    PatientRepository().currentPatient.name ??
                                        PatientRepository()
                                            .currentPatient
                                            .patientId,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                            color: AppPalette.black,
                                            fontWeight: FontWeight.w700),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: InfoTile(
                                          title: "Age",
                                          padding: WhiteSpace.all1,
                                          subTitle: PatientRepository()
                                              .currentPatient
                                              .age
                                              .toString(),
                                        ),
                                      ),
                                      Expanded(
                                        child: InfoTile(
                                            title: "Gender",
                                            padding: WhiteSpace.all1,
                                            subTitle: PatientRepository()
                                                .currentPatient
                                                .gender),
                                      ),
                                      Expanded(
                                        child: InfoTile(
                                            title: "Blood",
                                            padding: WhiteSpace.all1,
                                            subTitle: PatientRepository()
                                                    .currentPatient
                                                    .bloodGroup ??
                                                "---"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            WhiteSpace.b6,
                            Card(
                              color: AppPalette.white,
                              shape: WidgetDecoration.roundedEdge5,
                              margin: WhiteSpace.zero,
                              child: InfoTile(
                                isCentered: false,
                                isParagraph: true,
                                title: "UUID (ABHA)",
                                subTitle:
                                    PatientRepository().currentPatient.abha ??
                                        "---",
                              ),
                            ),
                            WhiteSpace.b6,
                            SizedBox(
                              width: double.infinity,
                              height: LayoutConfig().setFractionHeight(15),
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 5.0,
                                  runSpacing: 5.0,
                                  runAlignment: WrapAlignment.center,
                                  children: (patientSummary?.tags ?? [])
                                      .map<Widget>((chipLabel) {
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
                                              .copyWith(
                                                  color: AppPalette.black)),
                                      selected: true,
                                      onSelected: (bool selected) {},
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: QuickLinkButton(
                                      icon: Icons.download_outlined,
                                      label: "Download",
                                      onPressed: () {
                                        simpleDialog(context,
                                            type: DialogType.info,
                                            title: "Permission required",
                                            content:
                                                "You are not authorised to download patient data. Contact the workspace admin.",
                                            buttonName: "Close");
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: QuickLinkButton(
                                      icon: Icons.share_outlined,
                                      label: "Share",
                                      onPressed: () {
                                        simpleDialog(context,
                                            type: DialogType.info,
                                            title: "Permission required",
                                            content:
                                                "You are not authorised to share patient data. Contact the workspace admin.",
                                            buttonName: "Close");
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: QuickLinkButton(
                                      icon: Icons.receipt_long_outlined,
                                      label: "Logs",
                                      onPressed: () {
                                        _viewLogs(context);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      WhiteSpace.w12,
                      if (patientSummary != null)
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Recent admission record",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  WhiteSpace.spacer,
                                  Text(
                                    "Updated on: ${patientSummary?.modifiedAt ?? "---"}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                        .copyWith(
                                            color: AppPalette.greyC3,
                                            fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              WhiteSpace.b6,
                              Card(
                                color: AppPalette.white,
                                shape: WidgetDecoration.roundedEdge5,
                                margin: WhiteSpace.zero,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InfoTile(
                                        title: "Height",
                                        padding: WhiteSpace.all1,
                                        subTitle:
                                            "${patientSummary?.height ?? "-"} cm",
                                      ),
                                    ),
                                    Expanded(
                                      child: InfoTile(
                                        title: "Weight",
                                        padding: WhiteSpace.all1,
                                        subTitle:
                                            "${patientSummary?.weight ?? "-"} kg",
                                      ),
                                    ),
                                    Expanded(
                                      child: InfoTile(
                                        title: "BMI",
                                        padding: WhiteSpace.all1,
                                        subTitle: patientSummary?.bmi ?? "-",
                                      ),
                                    ),
                                    Expanded(
                                      child: InfoTile(
                                        title: "IBW",
                                        padding: WhiteSpace.all1,
                                        subTitle:
                                            "${patientSummary?.ibw ?? "-"} kg",
                                      ),
                                    ),
                                    Expanded(
                                      child: InfoTile(
                                        title: "ITV",
                                        padding: WhiteSpace.all1,
                                        subTitle:
                                            "${patientSummary?.getITV() ?? "-"} ml",
                                      ),
                                    ),
                                    Expanded(
                                      child: InfoTile(
                                        title: "Admission date",
                                        padding: WhiteSpace.all1,
                                        subTitle: DateTimeFormat.getDate(
                                            patientSummary?.admissionDate),
                                      ),
                                    ),
                                    Expanded(
                                      child: InfoTile(
                                        title: "Status",
                                        subTitle: "",
                                        subTitleWidget: BinaryStatusIndicator(
                                            isActive: !(patientSummary
                                                    ?.isDischarged ??
                                                false),
                                            inactiveBackground:
                                                AppPalette.greyC3,
                                            inactiveForeground:
                                                AppPalette.white,
                                            labels: (
                                              "In Treatment",
                                              "Offline"
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              WhiteSpace.b12,
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
                                        subTitle: patientSummary
                                                ?.reasonForAdmission ??
                                            "No records found",
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
                                        subTitle: patientSummary
                                                ?.reasonForVentilation ??
                                            "No records found",
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
                                    subTitle: patientSummary?.currentStatus ??
                                        "No records found",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      if (patientSummary == null)
                        Expanded(
                            child: Center(
                          child: Center(
                            child: Text(
                              "No Records found",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        )),
                      WhiteSpace.w6,
                    ],
                  ),
                ),
                WhiteSpace.b6,
                const Divider(),
                WhiteSpace.b6,
                Row(
                  children: [
                    SizedBox(
                      height: LayoutConfig().setFractionHeight(60),
                      width: LayoutConfig().setFractionWidth(49),
                      child: const PatientSessions(),
                    ),
                    WhiteSpace.w6,
                    SizedBox(
                      height: LayoutConfig().setFractionHeight(60),
                      width: LayoutConfig().setFractionWidth(49),
                      child: ABGGraph(recordId: patientSummary?.id),
                    )
                  ],
                ),
                WhiteSpace.b16,
              ],
            ),
          );
  }

  _viewLogs(BuildContext context) {
    if (patientSummary != null) {
      generalDialog(
        context,
        barrierDismissible: true,
        alignment: Alignment.topCenter,
        child: Card(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: WhiteSpace.all30,
            child: SizedBox(
              height: LayoutConfig().setFractionHeight(60),
              width: LayoutConfig().setFractionWidth(40),
              child: ClinicalLogs(recordId: patientSummary.id),
            ),
          ),
        ),
      );
    }
  }
}

class InfoTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget? subTitleWidget;
  final bool isCentered;
  final bool isBold;
  final Color titleColor;
  final bool isParagraph;
  final int maxLines;
  final EdgeInsets? padding;

  const InfoTile(
      {super.key,
      required this.title,
      required this.subTitle,
      this.subTitleWidget,
      this.isCentered = true,
      this.isParagraph = false,
      this.maxLines = 2,
      this.padding,
      this.titleColor = AppPalette.greyC3,
      this.isBold = true});

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(
      title,
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: titleColor,
          fontWeight: isBold ? FontWeight.normal : FontWeight.w800),
    );

    Widget subtitleWidget = subTitleWidget ??
        Text(
          subTitle,
          textAlign: TextAlign.justify,
          overflow: TextOverflow.ellipsis,
          maxLines: maxLines,
          style: isParagraph
              ? Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: AppPalette.black,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w400)
              : Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: AppPalette.black,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w400),
        );

    if (isCentered) {
      titleWidget = Center(child: titleWidget);
      subtitleWidget = Center(child: subtitleWidget);
    }

    return ListTile(
      contentPadding: padding,
      title: titleWidget,
      subtitle: subtitleWidget,
    );
  }
}

class QuickLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const QuickLinkButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Button(
      padding: WhiteSpace.zero,
      backgroundColor: null,
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppPalette.greyC3,
            size: LayoutConfig().setFontSize(30),
          ),
          WhiteSpace.b6,
          Flexible(
            child: Text(
              label,
              //overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
