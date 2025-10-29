import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/presentation/layout_config.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import '../../../../shared/presentation/widgets/side_menu_tile.dart';
import 'settings/pages.dart';

class WorkspaceSettings extends StatefulWidget {
  const WorkspaceSettings({super.key});

  @override
  State<WorkspaceSettings> createState() => _WorkspaceSettingsState();
}

class _WorkspaceSettingsState extends State<WorkspaceSettings> {
  final GlobalKey<NavigatorState> workspaceSettings =
      GlobalKey<NavigatorState>(debugLabel: "Workspace_Settings");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: SideMenu(
              workspaceSettingsNavKey: workspaceSettings,
            ),
          ),
          WorkspaceSettingsPages(workspaceSettingsPageKey: workspaceSettings),
        ],
      ),
    );
  }
}

class WorkspaceSettingsPages extends StatelessWidget {
  final GlobalKey<NavigatorState> workspaceSettingsPageKey;

  const WorkspaceSettingsPages(
      {super.key, required this.workspaceSettingsPageKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LayoutConfig().setFractionHeight(94),
      width: LayoutConfig().setFractionWidth(80),
      padding: WhiteSpace.all10,
      child: Navigator(
          key: workspaceSettingsPageKey,
          initialRoute: 'general',
          clipBehavior: Clip.antiAlias,
          onGenerateRoute: (RouteSettings settings) {
            WidgetBuilder builder;
            switch (settings.name) {
              case 'general':
                builder = (BuildContext _) => const GeneralTab();
                break;
              case 'security':
                builder = (BuildContext _) => const SecurityTab();
                break;
              case 'moderation':
                builder = (BuildContext _) => const WorkspaceModerations();
                break;
              case 'announcements':
                builder = (BuildContext _) => const AnnouncementTab();
                break;
              case 'settings':
                builder = (BuildContext _) => const SettingsTab();
                break;
              case 'billing':
                builder = (BuildContext _) => const Placeholder();
                break;
              case 'privacy':
                builder = (BuildContext _) => const Placeholder();
                break;
              case 'integrations':
                builder = (BuildContext _) => const IntegrationsTab();
                break;
              case 'departments':
                builder = (BuildContext _) => const DepartmentsTab();
                break;
              default:
                throw Exception('Invalid route: ${settings.name}');
            }
            return CupertinoPageRoute(
                builder: builder,
                settings: settings,
                fullscreenDialog: true,
                allowSnapshotting: true);
          }),
    );
  }
}

class SideMenu extends StatefulWidget {
  final GlobalKey<NavigatorState> workspaceSettingsNavKey;
  const SideMenu({super.key, required this.workspaceSettingsNavKey});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late List<bool> _selectionIndicator;
  late String _currentPath;

  final numberOfPages = 9;

  @override
  void initState() {
    super.initState();
    _currentPath = 'general';
    _selectionIndicator = List.generate(numberOfPages, (index) => false);
    _selectionIndicator[0] = true;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      shape: WidgetDecoration.sharpEdge,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: WhiteSpace.h20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WhiteSpace.b12,
            SideMenuTile(
              isSelected: _selectionIndicator[0],
              icon: Icons.account_tree_outlined,
              label: "General",
              onTap: () {
                _changePage(0, "general");
              },
            ),
            SideMenuTile(
              isSelected: _selectionIndicator[1],
              icon: Icons.shield_outlined,
              label: "Security",
              onTap: () {
                _changePage(1, "security");
              },
            ),
            SideMenuTile(
              isSelected: _selectionIndicator[2],
              icon: Icons.announcement_outlined,
              label: "Workspace Announcements",
              onTap: () {
                _changePage(2, "announcements");
              },
            ),
            SideMenuTile(
              isSelected: _selectionIndicator[3],
              icon: Icons.supervisor_account_outlined,
              label: "Member Privileges",
              onTap: () {
                _changePage(3, "moderation");
              },
            ),
            SideMenuTile(
              isSelected: _selectionIndicator[4],
              icon: Icons.settings_outlined,
              label: "Settings",
              onTap: () {
                _changePage(4, "settings");
              },
            ),
            // SideMenuTile(
            //   isSelected: _selectionIndicator[5],
            //   icon: Icons.attach_money_outlined,
            //   label: "Billing and Plans",
            //   onTap: () {
            //     _changePage(5, "billing");
            //   },
            // ),
            // SideMenuTile(
            //   isSelected: _selectionIndicator[6],
            //   icon: Icons.lock_outline,
            //   label: "Privacy",
            //   onTap: () {
            //     _changePage(6, "privacy");
            //   },
            // ),
            SideMenuTile(
              isSelected: _selectionIndicator[7],
              icon: Icons.extension_outlined,
              label: "Integrations",
              onTap: () {
                _changePage(7, "integrations");
              },
            ),
            SideMenuTile(
              isSelected: _selectionIndicator[8],
              icon: Icons.groups_3_outlined,
              label: "Departments",
              onTap: () {
                _changePage(8, "departments");
              },
            ),
          ],
        ),
      ),
    );
  }

  _changePage(pageId, pageName) {
    if (_currentPath != pageName) {
      _selectionIndicator = List.generate(numberOfPages, (index) => false);
      _selectionIndicator[pageId] = true;
      widget.workspaceSettingsNavKey.currentState!
          .pushNamedAndRemoveUntil(pageName, (route) => false);
      setState(() {});
      _currentPath = pageName;
    }
  }
}
