import 'package:flutter/material.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../shared/presentation/components/switch_tile.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/components/widget_decoration.dart';

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text("Two-factor authentication",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppPalette.black)),
                    subtitle: Text(
                        "Require two-factor authentication for everyone in the Aerobiosys Innovations organization.",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: AppPalette.greyC2)),
                    trailing: SwitchButton(
                      currentValue: false,
                      isEnabled: false,
                      onChanged: (value) {},
                    ),
                  ),
                  WhiteSpace.b32,
                  Padding(
                    padding: WhiteSpace.h20,
                    child: Text(
                        "Note: Members, managers, and outside collaborators who do not have two-factor authentication enabled for their Jeevan account will be removed from the workspace and will receive an email notifying them about the change.",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: AppPalette.greyC2)),
                  ),
                  WhiteSpace.b16,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
