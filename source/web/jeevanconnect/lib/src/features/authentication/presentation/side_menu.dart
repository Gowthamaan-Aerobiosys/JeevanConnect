import 'package:flutter/material.dart';

import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/components/widget_decoration.dart';
import '../../../shared/presentation/widgets/side_menu_tile.dart';
import '../data/authentication_repository.dart';

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
    _currentPath = 'profile';
    _selectionIndicator = List.generate(7, (index) => false);
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
              icon: Icons.person,
              label: "Account",
              onTap: () {
                _changePage(0, "profile");
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
              icon: Icons.security_outlined,
              label: "Multi-factor Authentication",
              onTap: () {
                _changePage(2, "multifactorauth");
              },
            ),
            SideMenuTile(
              isSelected: _selectionIndicator[3],
              icon: Icons.settings_outlined,
              label: "Settings",
              onTap: () {
                _changePage(3, "settings");
              },
            ),
            SideMenuTile(
              isSelected: _selectionIndicator[4],
              icon: Icons.message_outlined,
              label: "Sessions",
              onTap: () {
                _changePage(4, "sessions");
              },
            ),
            if (AuthenticationRepository().isAdminUser)
              SideMenuTile(
                isSelected: _selectionIndicator[5],
                icon: Icons.lock_outline,
                label: "Privacy",
                onTap: () {
                  _changePage(5, "privacy");
                },
              ),
            SideMenuTile(
              isSelected: _selectionIndicator[6],
              icon: Icons.badge_outlined,
              label: "Compliance",
              onTap: () {
                _changePage(6, "compliance");
              },
            ),
          ],
        ),
      ),
    );
  }

  _changePage(pageId, pageName) {
    if (_currentPath != pageName) {
      _selectionIndicator = List.generate(7, (index) => false);
      _selectionIndicator[pageId] = true;
      widget.homePageNavKey.currentState!
          .pushNamedAndRemoveUntil(pageName, (route) => false);
      setState(() {});
      _currentPath = pageName;
    }
  }
}
