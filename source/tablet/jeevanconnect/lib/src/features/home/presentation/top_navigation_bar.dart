import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/widgets/profile_indicator.dart';
import 'logo_header.dart';

class TopNavigationBar extends StatefulWidget {
  final GlobalKey<NavigatorState> homePageNavKey;
  const TopNavigationBar({super.key, required this.homePageNavKey});

  @override
  State<TopNavigationBar> createState() => _TopNavigationBarState();
}

class _TopNavigationBarState extends State<TopNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.greyC2,
      height: LayoutConfig().setFractionHeight(6),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          WhiteSpace.w16,
          WhiteSpace.w12,
          const LogoHeader(),
          WhiteSpace.spacer,
          Button(
            onPressed: () {},
            minWidth: (2.5 *
                Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .fontSize!
                    .toDouble()),
            backgroundColor: null,
            toolTip: 'Enable offline',
            padding: WhiteSpace.zero,
            child: Icon(
              Icons.cloud_off_outlined,
              size: Theme.of(context).textTheme.headlineSmall!.fontSize,
              color: AppPalette.greyS4,
            ),
          ),
          Button(
            onPressed: () {},
            backgroundColor: null,
            minWidth: (2.5 *
                Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .fontSize!
                    .toDouble()),
            toolTip: 'Notifications',
            padding: WhiteSpace.zero,
            child: Icon(
              Icons.notifications_none_outlined,
              size: Theme.of(context).textTheme.headlineSmall!.fontSize,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          WhiteSpace.w12,
          Tooltip(
            message: 'My profile',
            waitDuration: const Duration(seconds: 1),
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: CircleAvatarWithStatus(
                size: LayoutConfig().setFractionHeight(3.5),
                icon: Icons.person,
                isOnline: true,
              ),
            ),
          ),
          WhiteSpace.w12,
          // Button(
          //   onPressed: () {},
          //   backgroundColor: null,
          //   minWidth: (2.5 *
          //       Theme.of(context)
          //           .textTheme
          //           .headlineSmall!
          //           .fontSize!
          //           .toDouble()),
          //   padding: WhiteSpace.zero,
          //   toolTip: 'Jeevan Apps',
          //   child: Icon(
          //     Icons.apps_rounded,
          //     size: Theme.of(context).textTheme.headlineSmall!.fontSize,
          //     color: Theme.of(context).primaryColorLight,
          //   ),
          // ),
          WhiteSpace.w16,
        ],
      ),
    );
  }
}
