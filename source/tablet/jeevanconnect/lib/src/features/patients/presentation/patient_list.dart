import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../packages/pagenated_table/paged_datatable.dart';
import '../../../routing/routes.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../data/patient_repository.dart';
import '../domain/patient.dart';

class PatientsList extends StatefulWidget {
  const PatientsList({super.key});

  @override
  State<PatientsList> createState() => _PatientsListState();
}

class _PatientsListState extends State<PatientsList> {
  final tableController = PagedDataTableController<String, Patient>();

  @override
  void dispose() {
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
      child: PagedDataTable<String, Patient>(
        controller: tableController,
        initialPageSize: 100,
        configuration: const PagedDataTableConfiguration(),
        pageSizes: const [10, 20, 50, 100],
        fetcher: (pageSize, sortModel, filterModel, pageToken) async {
          final patients = await PatientRepository().getPatients();
          return (patients.items, patients.nextPageToken);
        },
        filters: const [],
        fixedColumnCount: 2,
        filterBarChild: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PopupMenuButton(
                icon: const Icon(Icons.more_vert_outlined),
                itemBuilder: (context) => <PopupMenuEntry>[]),
            WhiteSpace.w6,
          ],
        ),
        columns: [
          RowSelectorColumn(),
          TableColumn(
            title: const Text("Patient ID"),
            cellBuilder: (context, item, index) => TextButton(
                onPressed: () {
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
            size: const FractionalColumnSize(.2),
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
            size: const FractionalColumnSize(.35),
          ),
          TableColumn(
            title: const Text("Status"),
            cellBuilder: (context, item, index) => BinaryStatusIndicator(
                isActive: item.isActive, labels: ("Active", "Inactive")),
            size: const FractionalColumnSize(.3),
          ),
          TableColumn(
            title: const Text("Workspace"),
            cellBuilder: (context, item, index) => Text(
              item.workspace.name,
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
}
