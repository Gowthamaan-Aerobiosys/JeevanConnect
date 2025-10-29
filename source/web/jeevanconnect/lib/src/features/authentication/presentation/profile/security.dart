import 'package:flutter/material.dart';

import '../../../../routing/routes.dart';
import '../../../../config/presentation/app_palette.dart';
import '../../../../shared/presentation/components/button.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';

class SecurityTab extends StatelessWidget {
  const SecurityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            color: AppPalette.white,
            shape: WidgetDecoration.roundedEdge5,
            margin: WhiteSpace.all10,
            child: Padding(
              padding: WhiteSpace.all15,
              child: ListTile(
                title: Text("Password",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppPalette.black)),
                subtitle: Text("Last Changed ",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(color: AppPalette.greyC2)),
                trailing: Button(
                  onPressed: () {
                    context.push(Routes.forgotPassword, rootNavigator: true);
                  },
                  toolTip: "Change password",
                  child: Text(
                    'Change password',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
          ),
          Card(
            color: AppPalette.white,
            shape: WidgetDecoration.roundedEdge5,
            margin: WhiteSpace.all10,
            child: Padding(
              padding: WhiteSpace.all20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Geo-fencing",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppPalette.black),
                  ),
                  WhiteSpace.b6,
                  Text(
                    "Secure your account by allowing access only from the countries you want.",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(color: AppPalette.greyS8),
                  ),
                  WhiteSpace.b16,
                  WhiteSpace.b32,
                  Center(
                    child: Button(
                      onPressed: () {},
                      backgroundColor: AppPalette.greyC3,
                      toolTip: "Set up Geo-fencing",
                      child: Text(
                        'Set up Geo-fencing',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
