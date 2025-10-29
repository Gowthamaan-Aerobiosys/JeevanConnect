import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:jeevanconnect/src/routing/routes.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../packages/timeline/timeline.dart';
import '../../../../../shared/presentation/components/button.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/dialogs/dialogs.dart';
import '../../../../../shared/presentation/form_elements/text_field.dart';
import '../../../../../shared/presentation/widgets/progress_loader.dart';
import '../../../data/patient_repository.dart';
import '../../../domain/add_log_form_bloc.dart';

class ClinicalLogs extends StatefulWidget {
  final dynamic recordId;
  const ClinicalLogs({super.key, required this.recordId});

  @override
  State<ClinicalLogs> createState() => _ClinicalLogsState();
}

class _ClinicalLogsState extends State<ClinicalLogs> {
  bool isLoading = true;
  List clinicalLog = [];

  _getClinicalLogs() async {
    final logs = await PatientRepository().getClinicalLog(widget.recordId);
    clinicalLog = logs.items;
    isLoading = false;
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => setState(() {}));
  }

  @override
  void initState() {
    isLoading = true;
    _getClinicalLogs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Logs",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            WhiteSpace.spacer,
            IconButton(
              padding: WhiteSpace.zero,
              icon: Icon(
                Icons.add,
                color: AppPalette.greyC3,
                size: Theme.of(context).textTheme.headlineLarge!.fontSize,
              ),
              onPressed: () {
                _addLog(context);
              },
            ),
            WhiteSpace.w32,
            IconButton(
              padding: WhiteSpace.zero,
              icon: Icon(
                Icons.refresh_outlined,
                color: AppPalette.greyC3,
                size: Theme.of(context).textTheme.headlineLarge!.fontSize,
              ),
              onPressed: () {
                isLoading = true;
                setState(() {});
                _getClinicalLogs();
              },
            )
          ],
        ),
        WhiteSpace.b32,
        isLoading
            ? Center(
                child: CupertinoActivityIndicator(
                  radius: 20,
                  color: Theme.of(context).primaryColorLight,
                ),
              )
            : SizedBox(
                height: LayoutConfig().setFractionHeight(50),
                child: Timeline.tileBuilder(
                  theme: TimelineThemeData(
                    nodePosition: 0.15,
                    color: const Color(0xff989898),
                    indicatorTheme: const IndicatorThemeData(position: 0),
                  ),
                  shrinkWrap: true,
                  builder: TimelineTileBuilder.connectedFromStyle(
                    contentsAlign: ContentsAlign.basic,
                    oppositeContentsBuilder: (context, index) => Padding(
                      padding: WhiteSpace.all10,
                      child: Text(
                        "${clinicalLog[index].addedBy}\n${clinicalLog[index].timeStamp}",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppPalette.grey),
                      ),
                    ),
                    contentsBuilder: (context, index) => Padding(
                      padding: WhiteSpace.all10,
                      child: Row(
                        children: [
                          Text(
                            clinicalLog[index].content,
                            textAlign: TextAlign.justify,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          WhiteSpace.spacer,
                          IconButton(
                            padding: WhiteSpace.zero,
                            icon: Icon(
                              Icons.close,
                              color: AppPalette.red,
                              size: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .fontSize,
                            ),
                            onPressed: () async {
                              ProgressLoader.show(context);
                              await PatientRepository().removeClinicalLog(
                                  clinicalLog[index].id.toString(),
                                  widget.recordId.toString());
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                ProgressLoader.hide(context);
                              }
                              isLoading = true;
                              setState(() {});
                              _getClinicalLogs();
                            },
                          )
                        ],
                      ),
                    ),
                    connectorStyleBuilder: (context, index) =>
                        ConnectorStyle.dashedLine,
                    indicatorStyleBuilder: (context, index) =>
                        IndicatorStyle.outlined,
                    itemCount: clinicalLog.length,
                  ),
                ),
              ),
      ],
    );
  }

  _addLog(BuildContext context) {
    return generalDialog(
      context,
      barrierDismissible: true,
      alignment: Alignment.topCenter,
      child: Card(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          height: LayoutConfig().setFractionHeight(55),
          width: LayoutConfig().setFractionWidth(40),
          child: BlocProvider(
            create: (BuildContext context) => AddLogFormBloc(),
            child: Builder(
              builder: (BuildContext context) {
                final addLog = BlocProvider.of<AddLogFormBloc>(context);

                addLog.recordId = widget.recordId.toString();

                return FormBlocListener<AddLogFormBloc, String, String>(
                  onSubmitting: (context, state) {
                    ProgressLoader.show(context);
                  },
                  onSuccess: (context, state) {
                    ProgressLoader.hide(context);
                    context.pop(true);
                  },
                  onFailure: (context, state) {
                    ProgressLoader.hide(context);
                    context.pop(false);
                    final response = jsonDecode(state.failureResponse!);
                    simpleDialog(context,
                        type: DialogType.error,
                        title: response['title'],
                        content: response['content'],
                        buttonName: "Close");
                  },
                  child: Column(
                    children: [
                      WhiteSpace.b16,
                      Text("Add Clinical Log",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontWeight: FontWeight.w700)),
                      WhiteSpace.b12,
                      Padding(
                        padding: WhiteSpace.h30,
                        child: Text(
                          "A maximum of 5 lines is allowed",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      WhiteSpace.b12,
                      Padding(
                        padding: WhiteSpace.h50,
                        child: FormTextField(
                          maxLines: 5,
                          textFieldBloc: addLog.clinicalLog,
                          label: "Content",
                          icon: Icons.announcement_outlined,
                        ),
                      ),
                      Padding(
                        padding: WhiteSpace.h50,
                        child: FormTextField(
                          textFieldBloc: addLog.addedBy,
                          label: "Added by",
                          icon: Icons.person,
                        ),
                      ),
                      const Divider(thickness: 0.2, color: AppPalette.greyS8),
                      WhiteSpace.b6,
                      Button(
                        onPressed: () {
                          addLog.clinicalLog.validate();
                          addLog.addedBy.validate();
                          if (addLog.state.isValid()) {
                            addLog.submit();
                          }
                        },
                        buttonPadding: WhiteSpace.all8,
                        hoverColor: null,
                        backgroundColor: AppPalette.greenS8,
                        child: Text(
                          "Add Log",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      WhiteSpace.spacer,
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ).then((value) {
      if (value ?? false) {
        isLoading = true;
        setState(() {});
        _getClinicalLogs();
      }
    });
  }
}
