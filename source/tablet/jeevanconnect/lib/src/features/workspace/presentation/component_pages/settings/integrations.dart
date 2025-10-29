import 'package:flutter/material.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/components/widget_decoration.dart';

class IntegrationsTab extends StatelessWidget {
  const IntegrationsTab({super.key});

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
                  "Integrations",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: AppPalette.black),
                ),
              ),
              WhiteSpace.b32,
              Center(
                child: Text(
                  "No integrated applications",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
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
