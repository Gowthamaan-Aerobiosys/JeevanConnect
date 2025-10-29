import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../shared/presentation/components/button.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';

class MultiFactorAuthTab extends StatelessWidget {
  const MultiFactorAuthTab({super.key});

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
                children: [
                  ListTile(
                    title: Text("Multi-Factor Authentication",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(color: AppPalette.black)),
                    subtitle: Text(
                        "Use multi-factor authentication (MFA) to add an extra layer of security to your account.",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: AppPalette.greyC2)),
                    trailing: Button(
                      onPressed: () {},
                      backgroundColor: AppPalette.greyC3,
                      toolTip: "Setup MFA",
                      child: Text(
                        'Setup MFA',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                  WhiteSpace.b32,
                  Text(
                    "MFA is been disabled by the service provider",
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: AppPalette.greyC2,
                        ),
                  ),
                  WhiteSpace.b32,
                ],
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
                  ListTile(
                    title: Text(
                      "Trusted browsers",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(color: AppPalette.black),
                    ),
                    subtitle: Text(
                      "Skip MFA verification during sign-in for the next 180 days by trusting your browsers.",
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(color: AppPalette.greyS8),
                    ),
                  ),
                  WhiteSpace.b6,
                  WhiteSpace.b32,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
