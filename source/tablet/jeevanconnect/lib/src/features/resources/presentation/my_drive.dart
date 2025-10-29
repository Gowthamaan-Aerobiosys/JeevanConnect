import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/dialogs/dialogs.dart';

class MyDriveButton extends StatelessWidget {
  const MyDriveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: LayoutConfig().setFractionWidth(25),
        child: Button(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Icon(
                Icons.add_to_drive_outlined,
                color: AppPalette.white,
              ),
              Text(
                "Connect your Google drive",
                style: Theme.of(context).textTheme.labelLarge,
              )
            ],
          ),
          onPressed: () {
            simpleDialog(context,
                type: DialogType.info,
                title: "Integrations support disabled",
                content:
                    "Integrations are disabled for this account. Please contact JeevanConnect team for any queries",
                buttonName: "Close");
          },
        ),
      ),
    );
  }
}
