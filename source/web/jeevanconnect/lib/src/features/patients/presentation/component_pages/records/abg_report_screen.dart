import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../packages/pagenated_table/paged_datatable.dart';
import '../../../../../shared/domain/date_time_formatter.dart';
import '../../../../../shared/presentation/components/button.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/dialogs/dialogs.dart'
    show simpleDialog, DialogType, generalDialog;
import '../../../../../shared/presentation/form_elements/text_field.dart';
import '../../../../../shared/presentation/widgets/progress_loader.dart';
import '../../../data/patient_repository.dart';
import '../../../domain/abg.dart';
import '../../../domain/abg_form_bloc.dart';

class ABGReportScreen extends StatefulWidget {
  final dynamic recordId;
  const ABGReportScreen({super.key, required this.recordId});

  @override
  State<StatefulWidget> createState() => _ABGReportScreenState();
}

class _ABGReportScreenState extends State<ABGReportScreen> {
  final tableController = PagedDataTableController<String, ABGReport>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    tableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedDataTableTheme(
      data: PagedDataTableThemeData(
        backgroundColor: AppPalette.greyS2,
        footerTextStyle: Theme.of(context)
            .textTheme
            .labelSmall!
            .copyWith(color: AppPalette.black),
        rowColor: (index) =>
            index.isEven ? const Color.fromARGB(255, 235, 231, 231) : null,
      ),
      child: PagedDataTable<String, ABGReport>(
        controller: tableController,
        initialPageSize: 100,
        configuration: const PagedDataTableConfiguration(),
        pageSizes: const [10, 20, 50, 100],
        fetcher: (pageSize, sortModel, filterModel, pageToken) async {
          final abgRecords =
              await PatientRepository().getABGRecords(widget.recordId);
          return (abgRecords.items, abgRecords.nextPageToken);
        },
        filters: const [],
        fixedColumnCount: 1,
        filterBarChild: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PopupMenuButton(
                icon: const Icon(Icons.more_vert_outlined),
                position: PopupMenuPosition.under,
                color: Theme.of(context).scaffoldBackgroundColor,
                onSelected: (option) {
                  _pagePopActionCallback(option);
                },
                itemBuilder: (context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        value: 'add-new',
                        child: Text(
                          'Add',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'remove-selected',
                        child: Text(
                          'Remove',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ]),
            WhiteSpace.w6,
          ],
        ),
        columns: [
          RowSelectorColumn(),
          TableColumn(
            title: const Text("Time"),
            cellBuilder: (context, item, index) => Text(
              DateTimeFormat.getTimeStamp(item.createdAt),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.15),
          ),
          TableColumn(
            title: const Text("pH"),
            cellBuilder: (context, item, index) => Text(
              item.pH.toStringAsFixed(2),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.1),
          ),
          TableColumn(
            title: const Text("pO2"),
            cellBuilder: (context, item, index) => Text(
              item.pO2.toStringAsFixed(2),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.12),
          ),
          TableColumn(
            title: const Text("pCO2"),
            cellBuilder: (context, item, index) => Text(
              item.pCO2.toStringAsFixed(2),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.15),
          ),
          TableColumn(
            title: const Text("hCO3"),
            cellBuilder: (context, item, index) => Text(
              item.hCO3.toStringAsFixed(2),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.18),
          ),
          TableColumn(
            title: const Text("BEecf"),
            cellBuilder: (context, item, index) => Text(
              item.baseExcess.toStringAsFixed(2),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.18),
          ),
          TableColumn(
            title: const Text("SO2"),
            cellBuilder: (context, item, index) => Text(
              item.sO2.toStringAsFixed(2),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.25),
          ),
          TableColumn(
            title: const Text("Lac"),
            cellBuilder: (context, item, index) => Text(
              item.lactate.toStringAsFixed(2),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.3),
          ),
          TableColumn(
            title: const Text("Comments"),
            cellBuilder: (context, item, index) => Text(
              item.comments ?? "",
              maxLines: 10,
              textAlign: TextAlign.justify,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const RemainingColumnSize(),
          ),
        ],
      ),
    );
  }

  _pagePopActionCallback(option) async {
    try {
      switch (option) {
        case 'remove-selected':
          ProgressLoader.show(context);
          final items = tableController.selectedItems;
          if (items.isNotEmpty) {
            List index = [];
            for (var element in items) {
              index.add(element.id);
            }
            String indices = index.toString();
            indices = indices.substring(1, indices.length - 1);
            await PatientRepository()
                .removeABGRecord(indices, widget.recordId.toString());
          }
          if (mounted) {
            ProgressLoader.hide(context);
          }
          break;
        case 'add-new':
          await _addABGLog(context);
          break;
      }
      if (mounted) {
        tableController.refresh();
      }
    } catch (exception) {
      debugPrint("Pagepopaction: $exception");
      if (mounted) {
        simpleDialog(context,
                type: DialogType.error,
                title: (exception as dynamic).title ?? "Unexpected Error",
                content: (exception as dynamic).displayMessage ?? "",
                buttonName: "Close")
            .then((value) => ProgressLoader.hide(context));
      }
    }
  }

  _addABGLog(BuildContext context) {
    return generalDialog(
      context,
      barrierDismissible: true,
      alignment: Alignment.topCenter,
      child: Card(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          height: LayoutConfig().setFractionHeight(70),
          width: LayoutConfig().setFractionWidth(40),
          child: Padding(
            padding: WhiteSpace.h20,
            child: BlocProvider(
              create: (BuildContext context) => ABGReportFormBloc(),
              child: Builder(
                builder: (BuildContext context) {
                  final addABGLog = BlocProvider.of<ABGReportFormBloc>(context);
                  addABGLog.recordId = widget.recordId.toString();

                  return FormBlocListener<ABGReportFormBloc, String, String>(
                    onSubmitting: (context, state) {
                      ProgressLoader.show(context);
                    },
                    onSuccess: (context, state) {
                      ProgressLoader.hide(context);
                      ProgressLoader.hide(context);
                    },
                    onFailure: (context, state) {
                      ProgressLoader.hide(context);
                      ProgressLoader.hide(context);
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
                        Text("Add ABG Log",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(fontWeight: FontWeight.w700)),
                        WhiteSpace.b12,
                        Row(
                          children: [
                            Expanded(
                              child: FormTextField(
                                textFieldBloc: addABGLog.pH,
                                label: "pH",
                                icon: Icons.numbers_outlined,
                              ),
                            ),
                            WhiteSpace.w6,
                            Expanded(
                              child: FormTextField(
                                textFieldBloc: addABGLog.baseExcess,
                                label: "Base excess",
                                icon: Icons.numbers_outlined,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: FormTextField(
                                textFieldBloc: addABGLog.pCO2,
                                label: "pCO2",
                                icon: Icons.numbers_outlined,
                              ),
                            ),
                            WhiteSpace.w6,
                            Expanded(
                              child: FormTextField(
                                textFieldBloc: addABGLog.pO2,
                                label: "pO2",
                                icon: Icons.numbers_outlined,
                              ),
                            ),
                            WhiteSpace.w6,
                            Expanded(
                              child: FormTextField(
                                textFieldBloc: addABGLog.hCO3,
                                label: "hCO3",
                                icon: Icons.numbers_outlined,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: FormTextField(
                                textFieldBloc: addABGLog.sO2,
                                label: "SO2",
                                icon: Icons.numbers_outlined,
                              ),
                            ),
                            WhiteSpace.w6,
                            Expanded(
                              child: FormTextField(
                                textFieldBloc: addABGLog.lactate,
                                label: "Lactate",
                                icon: Icons.numbers_outlined,
                              ),
                            ),
                          ],
                        ),
                        WhiteSpace.b12,
                        FormTextField(
                          maxLines: 5,
                          textFieldBloc: addABGLog.comments,
                          label: "Comments",
                          icon: Icons.notes,
                        ),
                        WhiteSpace.spacer,
                        const Divider(thickness: 0.2, color: AppPalette.greyS8),
                        WhiteSpace.b6,
                        Button(
                          onPressed: () {
                            addABGLog.pH.validate();
                            addABGLog.pCO2.validate();
                            addABGLog.pO2.validate();
                            addABGLog.hCO3.validate();
                            addABGLog.baseExcess.validate();
                            addABGLog.sO2.validate();
                            addABGLog.lactate.validate();
                            if (addABGLog.state.isValid()) {
                              addABGLog.submit();
                            }
                          },
                          buttonPadding: WhiteSpace.all8,
                          hoverColor: null,
                          backgroundColor: AppPalette.greenS8,
                          child: Text(
                            "Add log",
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
      ),
    );
  }
}
