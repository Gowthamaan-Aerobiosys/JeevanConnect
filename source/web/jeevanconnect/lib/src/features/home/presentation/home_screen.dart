import 'package:flutter/material.dart';

import 'home_screen_pages.dart';
import 'right_side_menu.dart';
import 'side_menu.dart';
import 'top_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> homeNavKey =
        GlobalKey<NavigatorState>(debugLabel: "Home");

    return Scaffold(
      endDrawer: const RightSideMenu(),
      endDrawerEnableOpenDragGesture: false,
      body: Column(
        children: [
          TopNavigationBar(
            homePageNavKey: homeNavKey,
          ),
          Expanded(
            child: Row(
              children: [
                SideMenu(
                  homePageNavKey: homeNavKey,
                ),
                HomeScreenPages(homePageNavKey: homeNavKey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
