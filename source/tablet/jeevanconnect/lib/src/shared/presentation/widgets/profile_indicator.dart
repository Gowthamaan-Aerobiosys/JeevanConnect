import 'package:flutter/material.dart';

class CircleAvatarWithStatus extends StatelessWidget {
  final double size;
  final IconData icon;
  final bool isOnline;

  const CircleAvatarWithStatus({
    super.key,
    this.size = 60.0,
    this.icon = Icons.person,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.grey[300],
          child: Icon(
            icon,
            size: size * 0.6,
            color: Colors.grey[700],
          ),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
