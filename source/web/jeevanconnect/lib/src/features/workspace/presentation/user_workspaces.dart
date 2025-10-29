import 'package:flutter/material.dart';

import '../../../routing/routes.dart';
import '../../../config/presentation/app_palette.dart';
import '../../../packages/pagenated_table/paged_datatable.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../../../shared/presentation/widgets/initial_avatar.dart';
import '../data/workspace_repository.dart';
import '../domain/workspace.dart';

class UserWorkspaces extends StatefulWidget {
  const UserWorkspaces({super.key});

  @override
  State<StatefulWidget> createState() => _UserWorkspacesState();
}

class _UserWorkspacesState extends State<UserWorkspaces> {
  final tableController = PagedDataTableController<String, Workspace>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //tableController.dispose();
    debugPrint("Workspace Dispose Called");
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
      child: PagedDataTable<String, Workspace>(
        controller: tableController,
        initialPageSize: 100,
        configuration: const PagedDataTableConfiguration(),
        pageSizes: const [10, 20, 50, 100],
        fetcher: (pageSize, sortModel, filterModel, pageToken) async {
          final workspaces = await WorkspaceRepository().getWorkspaces();
          return (workspaces.items, workspaces.nextPageToken);
        },
        filters: const [],
        fixedColumnCount: 2,
        filterBarChild: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(
              toolTip: "Create Workspace - Request",
              hoverColor: null,
              onPressed: () {
                context
                    .push(Routes.createWorkspace, rootNavigator: true)
                    .then((value) => tableController.refresh());
              },
              minWidth: 150,
              child: Text(
                "Create Workspace - Request",
                style: Theme.of(context)
                    .textTheme
                    .labelSmall!
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            WhiteSpace.w16,
          ],
        ),
        columns: [
          TableColumn(
            title: const Text("Name"),
            cellBuilder: (context, item, index) => TextButton(
                onPressed: () {
                  if (item.isActive) {
                    WorkspaceRepository().currentWorkspace = item;
                    WorkspaceRepository().getModerations();
                    context
                        .push(Routes.workspace,
                            arguments: {'workspace': item}, rootNavigator: true)
                        .then((value) => tableController.refresh());
                  }
                },
                child: Text(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: AppPalette.pink, fontWeight: FontWeight.w800),
                )),
            size: const FractionalColumnSize(.25),
          ),
          TableColumn(
            title: const Text("Status"),
            cellBuilder: (context, item, index) => BinaryStatusIndicator(
                isActive: item.isActive, labels: ("Active", "Inactive")),
            size: const FractionalColumnSize(.15),
          ),
          TableColumn(
            title: const Text("Access"),
            cellBuilder: (context, item, index) => Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.isAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: AppPalette.brown),
                Text(
                  item.isAdmin ? 'Admin' : 'Member',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppPalette.brown, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            size: const FractionalColumnSize(.18),
          ),
          TableColumn(
            title: const Text("Place"),
            cellBuilder: (context, item, index) => Text(
              "${item.city}, ${item.state}, ${item.country}",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.45),
          ),
          TableColumn(
            title: const Text("Members"),
            cellBuilder: (context, item, index) => UserInitialsAvatar(
              userInitials: _getUserInitials(item.users),
            ),
            size: const RemainingColumnSize(),
          ),
        ],
      ),
    );
  }

  _getUserInitials(users) {
    return users
        .take(4)
        .map((user) {
          return "${user.firstName[0].toUpperCase()}${user.lastName[0].toUpperCase()}";
        })
        .toList()
        .cast<String>();
  }
}
