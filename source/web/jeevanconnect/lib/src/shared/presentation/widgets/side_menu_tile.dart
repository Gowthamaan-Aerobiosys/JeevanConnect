import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../components/white_space.dart';
import '../components/widget_decoration.dart';

class SideMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const SideMenuTile(
      {super.key,
      required this.isSelected,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      waitDuration: const Duration(seconds: 1),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: AppPalette.greyC3,
        contentPadding: WhiteSpace.h10,
        shape: WidgetDecoration.roundedEdge5,
        leading: Icon(
          icon,
          size: Theme.of(context).textTheme.headlineSmall!.fontSize,
          color: Theme.of(context).primaryColorLight,
        ),
        onTap: onTap,
        title: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
