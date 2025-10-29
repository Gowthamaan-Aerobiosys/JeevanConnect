import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../routing/routes.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/components/widget_decoration.dart';
import '../../authentication/authentication.dart' show AuthenticationRepository;
import '../../../shared/presentation/widgets/profile_indicator.dart';

class RightSideMenu extends StatelessWidget {
  const RightSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: WidgetDecoration.sharpEdge,
      width: LayoutConfig().setFractionWidth(28),
      backgroundColor: AppPalette.blackC1,
      child: Padding(
        padding: WhiteSpace.all20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  Scaffold.of(context).closeEndDrawer();
                },
                padding: WhiteSpace.zero,
                alignment: Alignment.topRight,
                iconSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
            ),
            Row(
              children: [
                CircleAvatarWithStatus(
                  size: LayoutConfig().setFractionHeight(8),
                  icon: Icons.person,
                  isOnline: true,
                ),
                WhiteSpace.w16,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AuthenticationRepository().currentUser.getFullName(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    WhiteSpace.b6,
                    Text(
                      AuthenticationRepository().currentUser.email,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    WhiteSpace.b6,
                    Text(
                      'User ID: ${AuthenticationRepository().currentUser.userId}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
            WhiteSpace.b32,
            Card(
              color: AppPalette.greyC4,
              margin: WhiteSpace.zero,
              shape: WidgetDecoration.roundedEdge5,
              child: Padding(
                padding: WhiteSpace.v15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Button(
                      onPressed: () {
                        context.push(Routes.myAccount);
                      },
                      toolTip: "My Account",
                      backgroundColor: null,
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_2,
                            size: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .fontSize,
                            color: Theme.of(context).primaryColorLight,
                          ),
                          WhiteSpace.w12,
                          Text(
                            'My Account',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                    Button(
                      onPressed: () {
                        AuthenticationRepository()
                            .signout()
                            .then((value) => context.replace(Routes.signin));
                      },
                      backgroundColor: null,
                      toolTip: 'Sign out',
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_outlined,
                            size: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .fontSize,
                            color: AppPalette.red,
                          ),
                          WhiteSpace.w12,
                          Text(
                            'Sign out',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(color: AppPalette.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
