import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../components/white_space.dart';

class UserInitialsAvatar extends StatelessWidget {
  static const numBadges = 4;

  final List<String> userInitials;
  final double size;
  final Color color;

  const UserInitialsAvatar(
      {super.key,
      required this.userInitials,
      this.size = 35,
      this.color = AppPalette.greyC2});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        userInitials.length > numBadges ? numBadges : userInitials.length,
        (index) => Padding(
          padding: WhiteSpace.h1,
          child: CircleAvatar(
            radius: LayoutConfig().setHeight(size) / 2,
            backgroundColor: color,
            child: Text(userInitials[index],
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
