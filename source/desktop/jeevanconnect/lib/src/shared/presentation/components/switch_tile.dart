import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import 'white_space.dart';

class SwitchButton extends StatefulWidget {
  final bool currentValue;
  final bool isEnabled;
  final void Function(bool) onChanged;

  const SwitchButton({
    super.key,
    required this.currentValue,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  SwitchButtonState createState() => SwitchButtonState();
}

class SwitchButtonState extends State<SwitchButton> {
  late bool _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.currentValue;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !widget.isEnabled,
      child: Padding(
        padding: WhiteSpace.h20,
        child: Switch(
          inactiveThumbColor: AppPalette.grey,
          activeColor: AppPalette.greenC1,
          value: _currentValue,
          onChanged: (value) {
            _currentValue = value;
            setState(() {});
            widget.onChanged(value);
          },
        ),
      ),
    );
  }
}
