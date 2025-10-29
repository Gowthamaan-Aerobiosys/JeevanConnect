import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/config/data/permission_handler.dart';
import 'src/shared/data/process_validators.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ProcessValidator().init();
  PermissionConfig().requestUserPermission().then((_) {
    runApp(const JeevanConnectTablet());
  });
}
