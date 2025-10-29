import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/components/widget_decoration.dart';
import '../../authentication/authentication.dart' show AuthenticationRepository;
import '../../../shared/presentation/widgets/side_menu_tile.dart';

class SideMenu extends StatefulWidget {
  final GlobalKey<NavigatorState> homePageNavKey;
  const SideMenu({super.key, required this.homePageNavKey});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late List<bool> _selectionIndicator;
  late String _currentPath;

  @override
  void initState() {
    super.initState();
    _currentPath = 'workspaces';
    _selectionIndicator = List.generate(8, (index) => false);
    _selectionIndicator[1] = true;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppPalette.greyC2,
      shape: WidgetDecoration.sharpEdge,
      margin: WhiteSpace.zero,
      child: SizedBox(
        height: LayoutConfig().setFractionHeight(94),
        width: LayoutConfig().setFractionWidth(15),
        child: SingleChildScrollView(
          padding: WhiteSpace.h15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WhiteSpace.b12,
              // SideMenuTile(
              //   isSelected: _selectionIndicator[0],
              //   icon: Icons.dashboard_outlined,
              //   label: "Dashboard",
              //   onTap: () {
              //     _changePage(0, "dashboard");
              //   },
              // ),
              SideMenuTile(
                isSelected: _selectionIndicator[1],
                icon: Icons.workspaces_outlined,
                label: "Workspaces",
                onTap: () {
                  _changePage(1, "workspaces");
                },
              ),
              if (AuthenticationRepository().currentUser.isAdmin)
                SideMenuTile(
                  isSelected: _selectionIndicator[2],
                  icon: Icons.precision_manufacturing_outlined,
                  label: "Products",
                  onTap: () {
                    _changePage(2, "products");
                  },
                ),
              if (AuthenticationRepository().currentUser.isAdmin)
                SideMenuTile(
                  isSelected: _selectionIndicator[3],
                  icon: Icons.perm_identity_outlined,
                  label: "Patients",
                  onTap: () {
                    _changePage(3, "patients");
                  },
                ),
              WhiteSpace.b6,
              const Divider(),
              WhiteSpace.b6,
              Text('General',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(fontWeight: FontWeight.w900)),
              SideMenuTile(
                isSelected: _selectionIndicator[4],
                icon: Icons.message_outlined,
                label: "Messages",
                onTap: () {
                  _changePage(4, "messages");
                },
              ),
              SideMenuTile(
                isSelected: _selectionIndicator[5],
                icon: Icons.folder_shared_outlined,
                label: "Resources",
                onTap: () {
                  _changePage(5, "resources");
                },
              ),
              // SideMenuTile(
              //   isSelected: _selectionIndicator[6],
              //   icon: Icons.settings,
              //   label: "Settings",
              //   onTap: () {
              //     _changePage(6, "settings");
              //   },
              // ),
              const Divider(),
              WhiteSpace.b6,
              Text('Others',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(fontWeight: FontWeight.w900)),
              SideMenuTile(
                isSelected: _selectionIndicator[7],
                icon: Icons.storage_rounded,
                label: "My drive",
                onTap: () {
                  _changePage(7, "drive");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _changePage(pageId, pageName) {
    if (_currentPath != pageName) {
      _selectionIndicator = List.generate(8, (index) => false);
      _selectionIndicator[pageId] = true;
      widget.homePageNavKey.currentState!
          .pushNamedAndRemoveUntil(pageName, (route) => false);
      setState(() {});
      _currentPath = pageName;
    }
  }
}
