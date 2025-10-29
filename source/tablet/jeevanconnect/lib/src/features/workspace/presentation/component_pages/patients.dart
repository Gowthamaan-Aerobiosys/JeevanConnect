import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../packages/pagenated_table/paged_datatable.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/domain/date_time_formatter.dart';
import '../../../../shared/presentation/components/button.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../../../../shared/presentation/dialogs/dialogs.dart'
    show DialogType, simpleDialog, generalDialog;
import '../../../../shared/presentation/widgets/progress_loader.dart';
import '../../../patients/patients.dart' show Patient, PatientRepository;
import '../../data/workspace_repository.dart';
import 'display_statisctics_widget.dart';

class WorkspacePatients extends StatefulWidget {
  const WorkspacePatients({super.key});

  @override
  State<WorkspacePatients> createState() => _WorkspacePatientsState();
}

class _WorkspacePatientsState extends State<WorkspacePatients> {
  final tableController = PagedDataTableController<String, Patient>();

  @override
  void dispose() {
    super.dispose();
    tableController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WhiteSpace.all20,
      child: PagedDataTableTheme(
        data: PagedDataTableThemeData(
          backgroundColor: AppPalette.greyS2,
          footerTextStyle: Theme.of(context)
              .textTheme
              .labelSmall!
              .copyWith(color: AppPalette.black),
          rowColor: (index) =>
              index.isEven ? const Color.fromARGB(255, 235, 231, 231) : null,
        ),
        child: PagedDataTable<String, Patient>(
          controller: tableController,
          initialPageSize: 100,
          configuration: const PagedDataTableConfiguration(),
          pageSizes: const [10, 20, 50, 100],
          fetcher: (pageSize, sortModel, filterModel, pageToken) async {
            final patients = await PatientRepository().getWorkspacePatients();
            return (patients.items.reversed.toList(), patients.nextPageToken);
          },
          filters: const [],
          fixedColumnCount: 2,
          filterBarChild: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (WorkspaceRepository().currentWorkspace.isAdmin)
                Button(
                  hoverColor: null,
                  onPressed: () {
                    context.push(Routes.registerPatient,
                        rootNavigator: true,
                        arguments: {
                          'workspaceName':
                              WorkspaceRepository().currentWorkspace.name
                        }).then((value) => tableController.refresh());
                  },
                  minWidth: 150,
                  child: Text(
                    "Register Patient",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              WhiteSpace.w6,
              PopupMenuButton(
                icon: const Icon(Icons.more_vert_outlined),
                color: Theme.of(context).scaffoldBackgroundColor,
                onSelected: (option) {
                  _pagePopActionCallback(option);
                },
                itemBuilder: (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 'view-statistics',
                    child: Text(
                      'View Statistics',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  )
                ],
              ),
              WhiteSpace.w6,
            ],
          ),
          columns: [
            RowSelectorColumn(),
            TableColumn(
              title: const Text("Patient ID"),
              cellBuilder: (context, item, index) => TextButton(
                  onPressed: () {
                    PatientRepository().currentPatient = item;
                    context.push(Routes.patient,
                        arguments: {'patient': item}, rootNavigator: true);
                  },
                  child: Text(
                    item.patientId,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: AppPalette.pink, fontWeight: FontWeight.w800),
                  )),
              size: const FractionalColumnSize(.2),
            ),
            TableColumn(
              title: const Text("Age"),
              cellBuilder: (context, item, index) => Text(
                item.age.toString(),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppPalette.black),
              ),
              size: const FractionalColumnSize(.15),
            ),
            TableColumn(
              title: const Text("Gender"),
              cellBuilder: (context, item, index) => Text(
                item.gender,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppPalette.black),
              ),
              size: const FractionalColumnSize(.17),
            ),
            TableColumn(
              title: const Text("Name"),
              cellBuilder: (context, item, index) => Text(
                item.name ?? "",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppPalette.black),
              ),
              size: const FractionalColumnSize(.4),
            ),
            TableColumn(
              title: const Text("Admitted On"),
              cellBuilder: (context, item, index) => Text(
                DateTimeFormat.getTimeStamp(item.createdAt),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppPalette.black),
              ),
              size: const FractionalColumnSize(.5),
            ),
            TableColumn(
              title: const Text("Status"),
              cellBuilder: (context, item, index) => BinaryStatusIndicator(
                  isActive: item.isActive, labels: ("Active", "Inactive")),
              size: const RemainingColumnSize(),
            ),
          ],
        ),
      ),
    );
  }

  _pagePopActionCallback(option) async {
    try {
      switch (option) {
        case 'view-statistics':
          ProgressLoader.show(context);
          final sampleStats =
              await WorkspaceRepository().getStatistics("patient");
          if (mounted) {
            ProgressLoader.hide(context);
            _showStatisticsDialog(context, sampleStats);
          }
          break;
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

  _showStatisticsDialog(BuildContext context, statistics) {
    generalDialog(
      context,
      barrierDismissible: true,
      alignment: Alignment.center,
      child: StatisticsTable(
        statistics: statistics,
        title: 'Patient',
      ),
    );
  }
}
