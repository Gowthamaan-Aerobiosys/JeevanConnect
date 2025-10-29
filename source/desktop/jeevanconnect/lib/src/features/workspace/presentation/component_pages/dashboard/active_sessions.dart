import 'package:flutter/material.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../packages/pagenated_table/paged_datatable.dart';
import '../../../../../routing/routes.dart';
import '../../../../../shared/domain/date_time_formatter.dart';
import '../../../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../../../../../shared/presentation/widgets/sliding_page_parent.dart';
import '../../../../patients/patients.dart' show PatientRepository;
import '../../../../products/data/product_repository.dart';
import '../../../../products/products.dart' show VentilatorSession;
import '../../../../ventilation/ventilation.dart'
    show VentilationSessionDetails;
import '../../../data/workspace_repository.dart';

class ActiveWorkspaceSessions extends StatefulWidget {
  const ActiveWorkspaceSessions({super.key});

  @override
  State<ActiveWorkspaceSessions> createState() =>
      _ActiveWorkspaceSessionsState();
}

class _ActiveWorkspaceSessionsState extends State<ActiveWorkspaceSessions> {
  final tableController = PagedDataTableController<String, VentilatorSession>();

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
      child: PagedDataTable<String, VentilatorSession>(
        controller: tableController,
        initialPageSize: 100,
        configuration: const PagedDataTableConfiguration(),
        pageSizes: const [10, 20, 50, 100],
        fetcher: (pageSize, sortModel, filterModel, pageToken) async {
          final sessions =
              await WorkspaceRepository().getActiveWorkspaceSessions();
          return (sessions.items.reversed.toList(), sessions.nextPageToken);
        },
        filters: const [],
        fixedColumnCount: 2,
        filterBarChild: null,
        columns: [
          TableColumn(
            title: const Text("Session ID"),
            cellBuilder: (context, item, index) => TextButton(
                onPressed: () {
                  ProductRepository().currentProduct = item.ventilator;
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
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return child;
                          },
                        ),
                      )
                      .then((_) => tableController.refresh());
                },
                child: Text(
                  item.sessionId,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppPalette.pink, fontWeight: FontWeight.w800),
                )),
            size: const FractionalColumnSize(.3),
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
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppPalette.black, fontWeight: FontWeight.w800),
                )),
            size: const FractionalColumnSize(.35),
          ),
          TableColumn(
            title: const Text("Status"),
            cellBuilder: (context, item, index) => BinaryStatusIndicator(
                isActive: item.isActive, labels: ("Active", "Inactive")),
            size: const FractionalColumnSize(.35),
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
