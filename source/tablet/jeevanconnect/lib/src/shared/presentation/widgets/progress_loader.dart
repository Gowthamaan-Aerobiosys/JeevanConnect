import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressLoader extends StatefulWidget {
  static void show(BuildContext context, {Key? key}) => showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => ProgressLoader(key: key),
      ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  const ProgressLoader({super.key});

  @override
  ProgressLoaderState createState() => ProgressLoaderState();
}

class ProgressLoaderState extends State<ProgressLoader> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: CupertinoActivityIndicator(
          radius: 20,
          color: Theme.of(context).primaryColorLight,
        ),
      ),
    );
  }
}
