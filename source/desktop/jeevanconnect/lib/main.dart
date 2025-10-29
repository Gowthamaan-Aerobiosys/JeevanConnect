import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/shared/data/process_validators.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ProcessValidator().init();
  runApp(const JeevanConnectDesktop());
}
