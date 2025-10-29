import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../packages/pagenated_table/paged_datatable.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/domain/date_time_formatter.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../../../../shared/presentation/widgets/sliding_page_parent.dart';
import '../../../patients/patients.dart' show PatientRepository;
import '../../../ventilation/ventilation.dart' show VentilationSessionDetails;
import '../../data/product_repository.dart';
import '../../domain/ventilator_session.dart';

class MonitoringSessionsTab extends StatefulWidget {
  const MonitoringSessionsTab({super.key});

  @override
  State<MonitoringSessionsTab> createState() => _MonitoringSessionsTabState();
}

class _MonitoringSessionsTabState extends State<MonitoringSessionsTab> {
  final tableController = PagedDataTableController<String, VentilatorSession>();

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
        child: PagedDataTable<String, VentilatorSession>(
          controller: tableController,
          initialPageSize: 100,
          configuration: const PagedDataTableConfiguration(),
          pageSizes: const [10, 20, 50, 100],
          fetcher: (pageSize, sortModel, filterModel, pageToken) async {
            final sessions = await ProductRepository().getVentilatorSession();
            return (sessions.items.reversed.toList(), sessions.nextPageToken);
          },
          filters: const [],
          fixedColumnCount: 0,
          filterBarChild: null,
          columns: [
            RowSelectorColumn(),
            TableColumn(
              title: const Text("Session ID"),
              cellBuilder: (context, item, index) => TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) {
                              return SlidingPage(
                                  child: VentilationSessionDetails(
                                session: item,
                              ));
                            },
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return child;
                            },
                          ),
                        )
                        .then((_) => tableController.refresh());
                  },
                  child: Text(
                    item.sessionId,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: AppPalette.pink, fontWeight: FontWeight.w800),
                  )),
              size: const FractionalColumnSize(.15),
            ),
            TableColumn(
              title: const Text("Patient"),
              cellBuilder: (context, item, index) => TextButton(
                  onPressed: () {
                    if (item.patient != null) {
                      PatientRepository().currentPatient = item.patient;
                      context.push(Routes.patient,
                          arguments: {'patient': item.patient},
                          rootNavigator: true);
                    }
                  },
                  child: Text(
                    item.patient?.patientId ?? "Not Assigned",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: AppPalette.black, fontWeight: FontWeight.w800),
                  )),
              size: const FractionalColumnSize(.25),
            ),
            TableColumn(
              title: const Text("Status"),
              cellBuilder: (context, item, index) => BinaryStatusIndicator(
                  isActive: item.isActive, labels: ("Active", "Inactive")),
              size: const FractionalColumnSize(.2),
            ),
            TableColumn(
              title: const Text("Added On"),
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
                title: const Text("Last Updated"),
                cellBuilder: (context, item, index) => Text(
                      DateTimeFormat.getTimeStamp(item.updatedAt),
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: AppPalette.black),
                    ),
                size: const RemainingColumnSize()),
          ],
        ),
      ),
    );
  }
}
