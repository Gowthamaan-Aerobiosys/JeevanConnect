import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';

class ComplianceTab extends StatelessWidget {
  const ComplianceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
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
                  "Certifications",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: AppPalette.black),
                ),
                subtitle: Text(
                  "JeevanConnect©️ is developed in compliance with the following standards.",
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: AppPalette.greyS8),
                ),
              ),
              WhiteSpace.b32,
            ],
          ),
        ),
      ),
    );
  }
}
