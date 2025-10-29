import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../../routing/routes.dart';
import '../../../../config/presentation/layout_config.dart';
import '../../../../config/presentation/app_palette.dart';
import '../../../../packages/pagenated_table/paged_datatable.dart';
import '../../../../shared/presentation/components/button.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/dialogs/dialogs.dart'
    show generalDialog, simpleDialog, DialogType;
import '../../../../shared/presentation/form_elements/text_field.dart';
import '../../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../../../../shared/presentation/widgets/progress_loader.dart';
import '../../../authentication/authentication.dart'
    show AuthenticationRepository, User;
import '../../../messages/messages.dart' show MessageRepository;
import '../../data/workspace_repository.dart';
import '../../domain/exit_workspace_form_bloc.dart';
import '../../domain/invite_user_form_bloc.dart';
import 'display_statisctics_widget.dart';

class WorkspaceUsers extends StatefulWidget {
  const WorkspaceUsers({super.key});

  @override
  State<StatefulWidget> createState() => _WorkspaceUsersState();
}

class _WorkspaceUsersState extends State<WorkspaceUsers> {
  bool _hasAdminPermissions = false;
  final tableController =
      PagedDataTableController<String, (dynamic, dynamic)>();

  List<User> workspaceUsers = [];

  @override
  void initState() {
    _hasAdminPermissions = WorkspaceRepository()
            .currentWorkspace
            .admins
            .contains(AuthenticationRepository().currentUser) ||
        AuthenticationRepository().isAdminUser;
    super.initState();
  }

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
        child: PagedDataTable<String, (dynamic, dynamic)>(
          controller: tableController,
          initialPageSize: 100,
          configuration: const PagedDataTableConfiguration(),
          pageSizes: const [10, 20, 50, 100],
          fetcher: (pageSize, sortModel, filterModel, pageToken) async {
            final workspaces = await WorkspaceRepository()
                .getUsers(WorkspaceRepository().currentWorkspace.workspaceId);
            workspaceUsers = workspaces.$2;
            return (
              workspaces.$1.items.reversed.toList(),
              workspaces.$1.nextPageToken
            );
          },
          filters: const [],
          fixedColumnCount: 2,
          filterBarChild: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_hasAdminPermissions)
                Button(
                  hoverColor: null,
                  onPressed: () {
                    _inviteUser(context);
                  },
                  minWidth: 150,
                  toolTip: "Invite member",
                  child: Text(
                    "Invite member",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              WhiteSpace.w6,
              if (_hasAdminPermissions)
                Button(
                  hoverColor: null,
                  backgroundColor: AppPalette.greyC3,
                  onPressed: () {
                    //_inviteUser(context);
                  },
                  minWidth: 150,
                  child: Text(
                    "Invite via link",
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
                  ),
                  PopupMenuItem(
                    value: 'exit-workspace',
                    child: Text(
                      'Exit workspace',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
              WhiteSpace.w6,
            ],
          ),
          columns: [
            TableColumn(
              title: const Text(""),
              cellBuilder: (context, item, index) => Padding(
                padding: WhiteSpace.h1,
                child: CircleAvatar(
                  radius: LayoutConfig().setHeight(35) / 2,
                  backgroundColor: AppPalette.brown,
                  child: Text(_getUserInitials(item.$1),
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
              size: const FractionalColumnSize(.1),
            ),
            TableColumn(
              title: const Text("Name"),
              cellBuilder: (context, item, index) => PopupMenuButton(
                tooltip: "",
                position: PopupMenuPosition.under,
                enabled: item.$1 != AuthenticationRepository().currentUser,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Text(
                  _getName(item.$1),
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: AppPalette.black),
                ),
                onSelected: (option) {
                  _userPopActionCallback(option, item);
                },
                itemBuilder: (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 'message',
                    child: Text(
                      'Message',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  if (_hasAdminPermissions && !item.$2)
                    PopupMenuItem(
                      value: 'make-admin',
                      child: Text(
                        'Make workspace admin',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  if (_hasAdminPermissions && item.$2)
                    PopupMenuItem(
                      value: 'dismiss-admin',
                      child: Text(
                        'Dismiss as admin',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  if (_hasAdminPermissions)
                    PopupMenuItem(
                      value: 'remove-user',
                      child: Text(
                        'Remove from workspace',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                ],
              ),
              size: const FractionalColumnSize(.2),
            ),
            TableColumn(
              title: const Text("Email"),
              cellBuilder: (context, item, index) => Text(
                item.$1.email,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppPalette.black),
              ),
              size: const FractionalColumnSize(.35),
            ),
            TableColumn(
              title: const Text("Contact"),
              cellBuilder: (context, item, index) => Text(
                "+91-${item.$1.contact}",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppPalette.black),
              ),
              size: const FractionalColumnSize(.3),
            ),
            TableColumn(
              title: const Text("Designation"),
              cellBuilder: (context, item, index) => Text(
                item.$1.designation,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppPalette.black),
              ),
              size: const FractionalColumnSize(.6),
            ),
            TableColumn(
              title: const Text(""),
              cellBuilder: (context, item, index) => Padding(
                padding: WhiteSpace.h1,
                child: BinaryStatusIndicator(
                  isActive: item.$2,
                  labels: ("Admin", ""),
                  inactiveBackground: null,
                  inactiveForeground: null,
                ),
              ),
              size: const RemainingColumnSize(),
            ),
          ],
        ),
      ),
    );
  }

  _getUserInitials(user) {
    return "${user.firstName[0].toUpperCase()}${user.lastName[0].toUpperCase()}";
  }

  _getName(user) {
    return user == AuthenticationRepository().currentUser
        ? "You"
        : user.getFullName();
  }

  _inviteUser(BuildContext context) {
    generalDialog(
      context,
      barrierDismissible: true,
      alignment: Alignment.topCenter,
      child: Card(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          height: LayoutConfig().setFractionHeight(35),
          width: LayoutConfig().setFractionWidth(40),
          child: BlocProvider(
            create: (BuildContext context) => InviteUserFormBloc(),
            child: Builder(
              builder: (BuildContext context) {
                final inviteUserForm =
                    BlocProvider.of<InviteUserFormBloc>(context);
                inviteUserForm.workspaceId =
                    WorkspaceRepository().currentWorkspace.workspaceId;

                return FormBlocListener<InviteUserFormBloc, String, String>(
                  onSubmitting: (context, state) {
                    ProgressLoader.show(context);
                  },
                  onSuccess: (context, state) {
                    ProgressLoader.hide(context);
                    ProgressLoader.hide(context);
                    if (state.hasSuccessResponse) {
                      final response = jsonDecode(state.successResponse!);
                      simpleDialog(context,
                          type: DialogType.success,
                          title: response['title'],
                          content: response['content'],
                          buttonName: "Close");
                    }
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
                      Text("Add User",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontWeight: FontWeight.w700)),
                      WhiteSpace.b12,
                      Padding(
                        padding: WhiteSpace.h30,
                        child: Text(
                          "Enter the email address or the registered id of the user",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      WhiteSpace.b12,
                      Padding(
                        padding: WhiteSpace.h50,
                        child: FormTextField(
                          textFieldBloc: inviteUserForm.emailId,
                          label: "Email ID",
                          icon: Icons.email,
                        ),
                      ),
                      WhiteSpace.spacer,
                      const Divider(thickness: 0.2, color: AppPalette.greyS8),
                      WhiteSpace.b6,
                      Button(
                        onPressed: () {
                          inviteUserForm.emailId.validate();
                          if (inviteUserForm.state.isValid()) {
                            inviteUserForm.submit();
                          }
                        },
                        buttonPadding: WhiteSpace.all8,
                        hoverColor: null,
                        backgroundColor: AppPalette.greenS8,
                        child: Text(
                          "Send invitation",
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

  _pagePopActionCallback(option) async {
    try {
      switch (option) {
        case 'view-statistics':
          ProgressLoader.show(context);
          final sampleStats = await WorkspaceRepository().getStatistics("user");
          if (mounted) {
            ProgressLoader.hide(context);
            _showStatisticsDialog(context, sampleStats);
          }
          break;
        case 'exit-workspace':
          _exitWorkspace(context);
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
        title: 'Members',
      ),
    );
  }

  _userPopActionCallback(option, lineItem) async {
    try {
      ProgressLoader.show(context);
      switch (option) {
        case 'make-admin':
          await WorkspaceRepository().updateUserRole(
              userId: lineItem.$1.userId,
              workspaceId: WorkspaceRepository().currentWorkspace.workspaceId,
              role: "admin");
          if (mounted) {
            ProgressLoader.hide(context);
            tableController.refresh();
          }
          break;
        case 'dismiss-admin':
          await WorkspaceRepository().updateUserRole(
              userId: lineItem.$1.userId,
              workspaceId: WorkspaceRepository().currentWorkspace.workspaceId,
              role: "user");
          if (mounted) {
            ProgressLoader.hide(context);
            tableController.refresh();
          }
          break;
        case 'remove-user':
          await WorkspaceRepository().removeUser(
              userId: lineItem.$1.userId,
              workspaceId: WorkspaceRepository().currentWorkspace.workspaceId);
          if (mounted) {
            ProgressLoader.hide(context);
            tableController.refresh();
          }
          break;
        case 'message':
          final conversation =
              await MessageRepository().createConversation(lineItem.$1.userId);
          if (mounted) {
            ProgressLoader.hide(context);
            context.push(Routes.userChat,
                arguments: {"conversation": conversation});
          }
          break;
      }
    } catch (exception) {
      if (mounted) {
        ProgressLoader.hide(context);
        simpleDialog(context,
            type: DialogType.error,
            title: (exception as dynamic).title,
            content: (exception as dynamic).displayMessage,
            buttonName: "Close");
      }
    }
  }

  _exitWorkspace(BuildContext context) {
    final numUsers = tableController.totalItems;
    if (numUsers == 1) {
      return simpleDialog(context,
          type: DialogType.info,
          title: "Request denied",
          content: "The default user cannot exit the workspace",
          buttonName: "Close");
    } else {
      final isDefaultUser =
          WorkspaceRepository().currentWorkspace.defaultUser ==
              AuthenticationRepository().currentUser;
      return generalDialog(
        context,
        barrierDismissible: true,
        alignment: Alignment.center,
        child: Card(
          color: AppPalette.bgColorLight,
          child: SizedBox(
            height: LayoutConfig().setFractionHeight(isDefaultUser ? 35 : 30),
            width: LayoutConfig().setFractionWidth(35),
            child: BlocProvider(
              create: (BuildContext context) => ExitWorkspaceFormBloc(),
              child: Builder(
                builder: (BuildContext context) {
                  final exitUserForm =
                      BlocProvider.of<ExitWorkspaceFormBloc>(context);

                  exitUserForm.workspaceId =
                      WorkspaceRepository().currentWorkspace.workspaceId;
                  List<User> users = workspaceUsers;
                  users.remove(AuthenticationRepository().currentUser);
                  exitUserForm.users.updateItems(users);
                  exitUserForm.isDefaultUser = isDefaultUser;
                  if (isDefaultUser) {
                    exitUserForm.users
                        .addValidators([FieldBlocValidators.required]);
                  }
                  return FormBlocListener<ExitWorkspaceFormBloc, String,
                      String>(
                    onSubmitting: (context, state) {
                      ProgressLoader.show(context);
                    },
                    onSuccess: (context, state) {
                      ProgressLoader.hide(context);
                      ProgressLoader.hide(context);
                      if (state.hasSuccessResponse) {
                        final response = jsonDecode(state.successResponse!);
                        simpleDialog(context,
                                type: DialogType.success,
                                title: response['title'],
                                content: response['content'],
                                buttonName: "Close")
                            .then((value) {
                          _exitWindow();
                        });
                      }
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
                        WhiteSpace.b32,
                        Text("Exit Workspace",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppPalette.black)),
                        WhiteSpace.b12,
                        if (isDefaultUser)
                          Padding(
                            padding: WhiteSpace.h30,
                            child: Text(
                              "Are you sure you want to exit the workspace?",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(color: AppPalette.black),
                            ),
                          ),
                        if (!isDefaultUser)
                          Padding(
                            padding: WhiteSpace.h30,
                            child: Text(
                              "This action is irreversible. You will lose all the data you have with this workspace. Do you want to proceed further?",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(color: AppPalette.black),
                            ),
                          ),
                        WhiteSpace.b12,
                        if (isDefaultUser)
                          Padding(
                            padding: WhiteSpace.h50,
                            child: DropdownFieldBlocBuilder<User>(
                              selectFieldBloc: exitUserForm.users,
                              showEmptyItem: false,
                              textStyle:
                                  Theme.of(context).textTheme.headlineSmall,
                              textColor: WidgetStateProperty.resolveWith(
                                  (states) => AppPalette.black),
                              itemBuilder: (context, item) => FieldItem(
                                child: Text(item.getFullName()),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Select a user',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                        fontWeight: FontWeight.w200,
                                        color: AppPalette.greyS8),
                                prefixIcon: const Icon(Icons.person_2),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppPalette.greyS8, width: 1.0),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ),
                          ),
                        WhiteSpace.spacer,
                        const Divider(thickness: 0.2, color: AppPalette.greyS8),
                        WhiteSpace.b12,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Button(
                              onPressed: () {
                                exitUserForm.users.validate();
                                if (exitUserForm.state.isValid()) {
                                  exitUserForm.submit();
                                }
                              },
                              buttonPadding: WhiteSpace.all8,
                              hoverColor: null,
                              backgroundColor: AppPalette.greenC1,
                              child: Text(
                                "Proceed",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            WhiteSpace.w16,
                            Button(
                              onPressed: () {
                                ProgressLoader.hide(context);
                              },
                              buttonPadding: WhiteSpace.all8,
                              hoverColor: null,
                              backgroundColor: AppPalette.greyC3,
                              child: Text(
                                "Cancel",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            WhiteSpace.w56,
                          ],
                        ),
                        WhiteSpace.b16,
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

  _exitWindow() {
    context.pushReplacement(Routes.home, rootNavigator: true);
  }
}
