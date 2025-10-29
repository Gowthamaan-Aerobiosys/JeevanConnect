import 'dart:async';
import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../components/widget_decoration.dart';

class LinearProgressBar extends StatefulWidget {
  final StreamController<double> progressController;

  const LinearProgressBar({super.key, required this.progressController});

  @override
  LinearProgressBarState createState() => LinearProgressBarState();
}

class LinearProgressBarState extends State<LinearProgressBar> {
  late StreamSubscription _subscription;
  late double _progress;

  @override
  void initState() {
    super.initState();
    _progress = 0.0;
    _subscription = widget.progressController.stream.listen((progress) {
      _progress = progress;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: LinearProgressIndicator(
        value: _progress,
        semanticsLabel: "JeevanConnect Setup Progress",
        color: AppPalette.logoBlue,
        backgroundColor: AppPalette.grey,
        borderRadius: WidgetDecoration.borderRadius20,
      ),
    );
  }
}
