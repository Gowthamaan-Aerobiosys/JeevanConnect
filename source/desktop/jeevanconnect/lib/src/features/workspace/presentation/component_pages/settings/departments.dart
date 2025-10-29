import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../packages/pagenated_table/paged_datatable.dart';
import '../../../../../shared/presentation/components/button.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/dialogs/dialogs.dart'
    show simpleDialog, DialogType, generalDialog;
import '../../../../../shared/presentation/form_elements/text_field.dart';
import '../../../../../shared/presentation/widgets/progress_loader.dart';
import '../../../data/workspace_repository.dart';
import '../../../domain/add_department_form_bloc.dart';

class DepartmentsTab extends StatefulWidget {
  const DepartmentsTab({super.key});

  @override
  State<StatefulWidget> createState() => _DepartmentsTabState();
}

class _DepartmentsTabState extends State<DepartmentsTab> {
  final tableController = PagedDataTableController<String, dynamic>();

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
      child: PagedDataTable<String, dynamic>(
        controller: tableController,
        initialPageSize: 100,
        configuration: const PagedDataTableConfiguration(),
        pageSizes: const [10, 20, 50, 100],
        fetcher: (pageSize, sortModel, filterModel, pageToken) async {
          final workspaces = await WorkspaceRepository().getDepartments();
          return (workspaces.items, workspaces.nextPageToken);
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
            title: const Text("Department"),
            cellBuilder: (context, item, index) => Text(
              item.$1,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.4),
          ),
          TableColumn(
            title: const Text("Number of Products"),
            cellBuilder: (context, item, index) => Text(
              item.$2,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.5),
          ),
          TableColumn(
            title: const Text("Number of Users"),
            cellBuilder: (context, item, index) => Text(
              item.$3,
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
            String departments = "";
            for (var element in items) {
              departments = "${departments + element.$1},";
            }
            await WorkspaceRepository().removeDepartments(departments);
          }
          if (mounted) {
            ProgressLoader.hide(context);
          }
          break;
        case 'add-new':
          await _addDepartment(context);
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

  _addDepartment(BuildContext context) {
    return generalDialog(
      context,
      barrierDismissible: true,
      alignment: Alignment.topCenter,
      child: Card(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          height: LayoutConfig().setFractionHeight(35),
          width: LayoutConfig().setFractionWidth(40),
          child: BlocProvider(
            create: (BuildContext context) => AddDepartmentBloc(),
            child: Builder(
              builder: (BuildContext context) {
                final addDepartmentForm =
                    BlocProvider.of<AddDepartmentBloc>(context);

                return FormBlocListener<AddDepartmentBloc, String, String>(
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
                      Text("Add Department",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontWeight: FontWeight.w700)),
                      WhiteSpace.b12,
                      Padding(
                        padding: WhiteSpace.h30,
                        child: Text(
                          "To add multiple department at once, separate them with comma.",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      WhiteSpace.b12,
                      Padding(
                        padding: WhiteSpace.h50,
                        child: FormTextField(
                          textFieldBloc: addDepartmentForm.departments,
                          label: "Department",
                          icon: Icons.group_add_outlined,
                        ),
                      ),
                      WhiteSpace.spacer,
                      const Divider(thickness: 0.2, color: AppPalette.greyS8),
                      WhiteSpace.b6,
                      Button(
                        onPressed: () {
                          addDepartmentForm.departments.validate();
                          if (addDepartmentForm.state.isValid()) {
                            addDepartmentForm.submit();
                          }
                        },
                        buttonPadding: WhiteSpace.all8,
                        hoverColor: null,
                        backgroundColor: AppPalette.greenS8,
                        child: Text(
                          "Add Department",
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
    );
  }
}
