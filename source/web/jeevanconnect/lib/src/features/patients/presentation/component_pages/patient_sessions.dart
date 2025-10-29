import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../packages/pagenated_table/paged_datatable.dart';
import '../../../../shared/domain/date_time_formatter.dart';
import '../../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../../../products/products.dart' show VentilatorSession;
import '../../data/patient_repository.dart';

class PatientSessions extends StatefulWidget {
  const PatientSessions({super.key});

  @override
  State<PatientSessions> createState() => _PatientSessionsState();
}

class _PatientSessionsState extends State<PatientSessions> {
  final tableController = PagedDataTableController<String, VentilatorSession>();

  @override
  void dispose() {
    super.dispose();
    tableController.dispose();
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
      child: PagedDataTable<String, VentilatorSession>(
        controller: tableController,
        initialPageSize: 100,
        configuration: const PagedDataTableConfiguration(),
        pageSizes: const [10, 20, 50, 100],
        fetcher: (pageSize, sortModel, filterModel, pageToken) async {
          final sessions = await PatientRepository().getPatientSession();
          return (sessions.items, sessions.nextPageToken);
        },
        filters: const [],
        fixedColumnCount: 2,
        columns: [
          TableColumn(
            title: const Text("Session ID"),
            cellBuilder: (context, item, index) => TextButton(
                onPressed: () {},
                child: Text(
                  item.sessionId,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: AppPalette.pink, fontWeight: FontWeight.w800),
                )),
            size: const FractionalColumnSize(.25),
          ),
          TableColumn(
            title: const Text("Status"),
            cellBuilder: (context, item, index) => BinaryStatusIndicator(
                isActive: item.isActive, labels: ("Active", "Inactive")),
            size: const FractionalColumnSize(.25),
          ),
          TableColumn(
            title: const Text("Added On"),
            cellBuilder: (context, item, index) => Text(
              DateTimeFormat.getTimeStamp(item.createdAt),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.5),
          ),
          TableColumn(
              title: const Text("Last Updated"),
              cellBuilder: (context, item, index) => Text(
                    DateTimeFormat.getTimeStamp(item.updatedAt),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: AppPalette.black),
                  ),
              size: const RemainingColumnSize()),
        ],
      ),
    );
  }
}
