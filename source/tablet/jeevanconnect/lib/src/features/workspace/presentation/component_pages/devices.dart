import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../packages/pagenated_table/paged_datatable.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/presentation/components/button.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/dialogs/dialogs.dart'
    show DialogType, simpleDialog, generalDialog;
import '../../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../../../../shared/presentation/widgets/progress_loader.dart';
import '../../../products/products.dart' show Product, ProductRepository;
import '../../workspace.dart' show WorkspaceRepository;
import 'display_statisctics_widget.dart';

class WorkspaceDevices extends StatefulWidget {
  const WorkspaceDevices({super.key});

  @override
  State<WorkspaceDevices> createState() => _WorkspaceDevicesState();
}

class _WorkspaceDevicesState extends State<WorkspaceDevices> {
  final tableController = PagedDataTableController<String, Product>();

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
        child: PagedDataTable<String, Product>(
          controller: tableController,
          initialPageSize: 100,
          configuration: const PagedDataTableConfiguration(),
          pageSizes: const [10, 20, 50, 100],
          fetcher: (pageSize, sortModel, filterModel, pageToken) async {
            final products = await ProductRepository().getWorkspaceProducts(
                WorkspaceRepository().currentWorkspace.workspaceId);
            return (products.items, products.nextPageToken);
          },
          filters: const [],
          fixedColumnCount: 0,
          filterBarChild: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                hoverColor: null,
                backgroundColor: AppPalette.greyC3,
                onPressed: () {
                  // context
                  //     .push(Routes.registerProduct, rootNavigator: true)
                  //     .then((value) => tableController.refresh());
                },
                minWidth: 150,
                child: Text(
                  "Register Product",
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
            TableColumn(
              title: const Text("Serial Number"),
              cellBuilder: (context, item, index) => TextButton(
                  onPressed: () {
                    context
                        .push(Routes.product,
                            arguments: {'product': item}, rootNavigator: true)
                        .then((value) => tableController.refresh());
                  },
                  child: Text(
                    item.serialNumber,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: AppPalette.pink, fontWeight: FontWeight.w800),
                  )),
              size: const FractionalColumnSize(.15),
            ),
            TableColumn(
              title: const Text("Lot Number"),
              cellBuilder: (context, item, index) => Text(
                item.lotNumber,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppPalette.black),
              ),
              size: const FractionalColumnSize(.15),
            ),
            TableColumn(
              title: const Text("Status"),
              cellBuilder: (context, item, index) => BinaryStatusIndicator(
                  isActive: item.isActive, labels: ("Active", "Inactive")),
              size: const FractionalColumnSize(.12),
            ),
            TableColumn(
              title: const Text("Product"),
              cellBuilder: (context, item, index) => Text(
                item.productName,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppPalette.black),
              ),
              size: const FractionalColumnSize(.2),
            ),
            TableColumn(
              title: const Text("Model"),
              cellBuilder: (context, item, index) => Text(
                item.modelName,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppPalette.black),
              ),
              size: const FractionalColumnSize(.25),
            ),
            TableColumn(
              title: const Text("Activity Status"),
              cellBuilder: (context, item, index) => BinaryStatusIndicator(
                  isActive: item.onlineStatus, labels: ("Online", "Offline")),
              size: const FractionalColumnSize(0.3),
            ),
            TableColumn(
              title: const Text("Department"),
              cellBuilder: (context, item, index) => Text(
                item.department ?? "",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppPalette.black),
              ),
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
              await WorkspaceRepository().getStatistics("device");
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
        title: 'Device',
      ),
    );
  }
}
