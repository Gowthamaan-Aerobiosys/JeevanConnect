import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../components/button.dart';
import '../components/white_space.dart';
import 'dialog_type.dart';

Future simpleDialog(BuildContext context,
    {required String title,
    required String content,
    required String buttonName,
    DialogType type = DialogType.info}) {
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
                  if (type == DialogType.info)
                    Icon(Icons.info_outline,
                        size: LayoutConfig().setFontSize(70),
                        color: AppPalette.blueS9),
                  if (type == DialogType.alert)
                    Icon(Icons.error_outline,
                        size: LayoutConfig().setFontSize(70),
                        color: AppPalette.red),
                  if (type == DialogType.success)
                    Icon(Icons.check_circle_outline,
                        size: LayoutConfig().setFontSize(70),
                        color: AppPalette.green),
                  if (type == DialogType.error)
                    Icon(Icons.error_outline_outlined,
                        size: LayoutConfig().setFontSize(70),
                        color: AppPalette.red),
                  if (type == DialogType.help)
                    Icon(Icons.help_outline,
                        size: LayoutConfig().setFontSize(70),
                        color: AppPalette.blueS9),
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
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: AppPalette.black),
                    ),
                  ),
                  WhiteSpace.spacer,
                  const Divider(thickness: 0.2, color: AppPalette.greyS8),
                  Button(
                    buttonPadding: WhiteSpace.zero,
                    backgroundColor: AppPalette.greyS2,
                    hoverColor: null,
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          buttonName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  color: AppPalette.greyS8,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
