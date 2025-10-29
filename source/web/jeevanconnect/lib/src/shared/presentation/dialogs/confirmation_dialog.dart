import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../components/button.dart';
import '../components/white_space.dart';
import 'dialog_type.dart';

confirmationDialog(BuildContext context,
    {required String title,
    required IconData icon,
    required String content,
    required VoidCallback onAcceptPressed,
    required VoidCallback onCancelPressed,
    DialogType type = DialogType.error,
    String acceptButtonLabel = "Accept",
    String cancelButtonLabel = "Cancel"}) {
  return showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.center,
          child: Card(
            color: AppPalette.greyS2,
            child: Container(
              height: LayoutConfig().setHeight(280),
              width: LayoutConfig().setWidth(500),
              padding: WhiteSpace.all10,
              child: Column(
                children: [
                  WhiteSpace.spacer,
                  Icon(icon,
                      size: LayoutConfig().setFontSize(70), color: type.color),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: AppPalette.black, fontWeight: FontWeight.bold),
                  ),
                  WhiteSpace.b12,
                  Padding(
                    padding: WhiteSpace.h15,
                    child: Text(
                      content,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: AppPalette.black),
                    ),
                  ),
                  WhiteSpace.spacer,
                  const Divider(thickness: 0.2, color: AppPalette.greyS8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Button(
                        buttonPadding: WhiteSpace.zero,
                        onPressed: onCancelPressed,
                        hoverColor: null,
                        backgroundColor: AppPalette.transparent,
                        child: Text(
                          cancelButtonLabel,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  color: AppPalette.red,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      WhiteSpace.w32,
                      Button(
                        buttonPadding: WhiteSpace.zero,
                        onPressed: onAcceptPressed,
                        hoverColor: null,
                        backgroundColor: AppPalette.transparent,
                        child: Text(
                          acceptButtonLabel,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  color: AppPalette.greenS9,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      WhiteSpace.w32,
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
