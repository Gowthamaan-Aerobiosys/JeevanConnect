import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/presentation/layout_config.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import '../../../../shared/presentation/widgets/side_menu_tile.dart';
import 'settings/pages.dart';

class ProductSettingsTab extends StatefulWidget {
  const ProductSettingsTab({super.key});

  @override
  State<ProductSettingsTab> createState() => _ProductSettingsTabState();
}

class _ProductSettingsTabState extends State<ProductSettingsTab> {
  final GlobalKey<NavigatorState> workspaceSettings =
      GlobalKey<NavigatorState>(debugLabel: "Workspace_Settings");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: ProductSettingsSideMenu(
              workspaceSettingsNavKey: workspaceSettings,
            ),
          ),
          ProductSettingsPages(workspaceSettingsPageKey: workspaceSettings),
        ],
      ),
    );
  }
}

class ProductSettingsPages extends StatelessWidget {
  final GlobalKey<NavigatorState> workspaceSettingsPageKey;

  const ProductSettingsPages(
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
              case 'sessions':
                builder = (BuildContext _) => const Placeholder();
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

class ProductSettingsSideMenu extends StatefulWidget {
  final GlobalKey<NavigatorState> workspaceSettingsNavKey;
  const ProductSettingsSideMenu(
      {super.key, required this.workspaceSettingsNavKey});

  @override
  State<ProductSettingsSideMenu> createState() =>
      _ProductSettingsSideMenuState();
}

class _ProductSettingsSideMenuState extends State<ProductSettingsSideMenu> {
  late List<bool> _selectionIndicator;
  late String _currentPath;

  final numberOfPages = 2;

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
            // SideMenuTile(
            //   isSelected: _selectionIndicator[1],
            //   icon: Icons.switch_access_shortcut_outlined,
            //   label: "Device access",
            //   onTap: () {
            //     _changePage(1, "sessions");
            //   },
            // ),
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
