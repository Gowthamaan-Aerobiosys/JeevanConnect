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
import '../../../domain/add_announcement_form_bloc.dart';
import '../../../domain/workspace_announcement.dart';

class AnnouncementTab extends StatefulWidget {
  const AnnouncementTab({super.key});

  @override
  State<StatefulWidget> createState() => _AnnouncementTabState();
}

class _AnnouncementTabState extends State<AnnouncementTab> {
  final tableController =
      PagedDataTableController<String, WorkspaceAnnouncement>();

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
      child: PagedDataTable<String, WorkspaceAnnouncement>(
        controller: tableController,
        initialPageSize: 100,
        configuration: const PagedDataTableConfiguration(),
        pageSizes: const [10, 20, 50, 100],
        fetcher: (pageSize, sortModel, filterModel, pageToken) async {
          final announcements = await WorkspaceRepository().getAnnouncements();
          return (announcements.items, announcements.nextPageToken);
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
            title: const Text("Posted On"),
            cellBuilder: (context, item, index) => Text(
              item.timeStamp,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.4),
          ),
          TableColumn(
            title: const Text("Announcement"),
            cellBuilder: (context, item, index) => Text(
              item.content,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.justify,
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
            List index = [];
            for (var element in items) {
              index.add(element.id);
            }
            String indices = index.toString();
            indices = indices.substring(1, indices.length - 1);
            await WorkspaceRepository().removeAnnouncements(indices);
          }
          if (mounted) {
            ProgressLoader.hide(context);
          }
          break;
        case 'add-new':
          await _addAnnouncement(context);
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
                buttonName: "Close")
            .then((value) => ProgressLoader.hide(context));
      }
    }
  }

  _addAnnouncement(BuildContext context) {
    return generalDialog(
      context,
      barrierDismissible: true,
      alignment: Alignment.topCenter,
      child: Card(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          height: LayoutConfig().setFractionHeight(50),
          width: LayoutConfig().setFractionWidth(40),
          child: BlocProvider(
            create: (BuildContext context) => AddAnnouncementFormBloc(),
            child: Builder(
              builder: (BuildContext context) {
                final addAnnouncement =
                    BlocProvider.of<AddAnnouncementFormBloc>(context);

                return FormBlocListener<AddAnnouncementFormBloc, String,
                    String>(
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
                      Text("Add Announcement",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontWeight: FontWeight.w700)),
                      WhiteSpace.b12,
                      Padding(
                        padding: WhiteSpace.h30,
                        child: Text(
                          "A maximum of 5 lines is allowed",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      WhiteSpace.b12,
                      Padding(
                        padding: WhiteSpace.h50,
                        child: FormTextField(
                          maxLines: 5,
                          textFieldBloc: addAnnouncement.announcement,
                          label: "Announcement",
                          icon: Icons.announcement_outlined,
                        ),
                      ),
                      WhiteSpace.spacer,
                      const Divider(thickness: 0.2, color: AppPalette.greyS8),
                      WhiteSpace.b6,
                      Button(
                        onPressed: () {
                          addAnnouncement.announcement.validate();
                          if (addAnnouncement.state.isValid()) {
                            addAnnouncement.submit();
                          }
                        },
                        buttonPadding: WhiteSpace.all8,
                        hoverColor: null,
                        backgroundColor: AppPalette.greenS8,
                        child: Text(
                          "Add Announcement",
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
