import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../config/presentation/layout_config.dart';
import '../../../../packages/pagenated_table/paged_datatable.dart';
import '../../../../shared/domain/date_time_formatter.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import '../../authentication.dart' show Session, AuthenticationRepository;

class SessionsTab extends StatelessWidget {
  const SessionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        color: AppPalette.white,
        shape: WidgetDecoration.roundedEdge5,
        margin: WhiteSpace.all10,
        child: Padding(
          padding: WhiteSpace.all20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  "Active Sessions",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: AppPalette.black),
                ),
                subtitle: Text(
                  "View and manage all of your active sessions.",
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: AppPalette.greyS8),
                ),
              ),
              WhiteSpace.b16,
              SizedBox(
                height: LayoutConfig().setFractionHeight(50),
                width: LayoutConfig().setFractionWidth(75),
                child: const SessionList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SessionList extends StatefulWidget {
  const SessionList({super.key});

  @override
  State<SessionList> createState() => _SessionListState();
}

class _SessionListState extends State<SessionList> {
  final tableController = PagedDataTableController<String, Session>();

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
      child: PagedDataTable<String, Session>(
        controller: tableController,
        initialPageSize: 100,
        configuration: const PagedDataTableConfiguration(),
        pageSizes: const [10, 20, 50, 100],
        fetcher: (pageSize, sortModel, filterModel, pageToken) async {
          final sessions = await AuthenticationRepository().getSessions();
          return (sessions.items, sessions.nextPageToken);
        },
        filters: const [],
        fixedColumnCount: 2,
        filterBarChild: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            WhiteSpace.w6,
            PopupMenuButton(
                icon: const Icon(Icons.more_vert_outlined),
                itemBuilder: (context) => <PopupMenuEntry>[]),
            WhiteSpace.w6,
          ],
        ),
        columns: [
          RowSelectorColumn(),
          TableColumn(
            title: const Text("Device"),
            size: const FractionalColumnSize(0.175),
            cellBuilder: (context, item, index) => Text(
              item.deviceType,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
          ),
          TableColumn(
            title: const Text("OS"),
            size: const FractionalColumnSize(0.175),
            cellBuilder: (context, item, index) => Text(
              item.os,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
          ),
          TableColumn(
            title: const Text("Browser"),
            size: const FractionalColumnSize(0.175),
            cellBuilder: (context, item, index) => Text(
              item.browser,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
          ),
          TableColumn(
            title: const Text("Login Time"),
            size: const FractionalColumnSize(0.5),
            cellBuilder: (context, item, index) => Text(
              DateTimeFormat.getTimeStamp(item.loginTime),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
          ),
          TableColumn(
            title: const Text("Place"),
            size: const RemainingColumnSize(),
            cellBuilder: (context, item, index) => Text(
              "${item.city}, ${item.country}",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
          ),
        ],
      ),
    );
  }
}
