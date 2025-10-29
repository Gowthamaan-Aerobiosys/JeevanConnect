import 'package:flutter/material.dart';
import 'package:jeevanconnect/src/routing/routes.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../packages/pagenated_table/paged_datatable.dart';
import '../../../../../shared/domain/date_time_formatter.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/dialogs/dialogs.dart'
    show simpleDialog, DialogType;
import '../../../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../../../../../shared/presentation/widgets/progress_loader.dart';
import '../../../../../shared/presentation/widgets/sliding_page_parent.dart';
import '../../../data/patient_repository.dart';
import '../../../domain/admission_record.dart';
import 'admission_record_detail.dart';

class AdmissionRecords extends StatefulWidget {
  const AdmissionRecords({super.key});

  @override
  State<StatefulWidget> createState() => _AdmissionRecordsState();
}

class _AdmissionRecordsState extends State<AdmissionRecords> {
  final tableController = PagedDataTableController<String, AdmissionRecord>();

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
      child: PagedDataTable<String, AdmissionRecord>(
        controller: tableController,
        initialPageSize: 100,
        configuration: const PagedDataTableConfiguration(),
        pageSizes: const [10, 20, 50, 100],
        fetcher: (pageSize, sortModel, filterModel, pageToken) async {
          final records = await PatientRepository().getAdmissionRecords();
          return (records.items.reversed.toList(), records.nextPageToken);
        },
        filters: const [],
        fixedColumnCount: 2,
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
                        value: 'discharge',
                        child: Text(
                          'Discharge',
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
            title: const Text("Admission Record"),
            cellBuilder: (context, item, index) => TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) {
                        return SlidingPage(
                            child: AdmissionRecordDetail(
                          record: item,
                          id: index + 1,
                        ));
                      },
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return child;
                      },
                    ),
                  );
                },
                child: Text(
                  "AMR-${index + 1}",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: AppPalette.pink, fontWeight: FontWeight.w800),
                )),
            size: const FractionalColumnSize(.25),
          ),
          TableColumn(
            title: const Text("Status"),
            cellBuilder: (context, item, index) => BinaryStatusIndicator(
                isActive: !item.isDischarged, labels: ("Active", "Archived")),
            size: const FractionalColumnSize(.35),
          ),
          TableColumn(
            title: const Text("Admitted On"),
            cellBuilder: (context, item, index) => Text(
              DateTimeFormat.getTimeStamp(item.admissionDate),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.5),
          ),
          TableColumn(
            title: const Text("Last updated On"),
            cellBuilder: (context, item, index) => Text(
              item.modifiedAt,
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
          if (items.isNotEmpty) {}
          if (mounted) {
            ProgressLoader.hide(context);
          }
          break;
        case 'add-new':
          context
              .push(Routes.addAdmissionRecord, rootNavigator: true)
              .then((value) => tableController.refresh());
          break;
        case 'discharge':
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
            buttonName: "Close");
      }
    }
  }
}
