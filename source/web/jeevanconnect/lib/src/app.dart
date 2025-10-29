import 'package:flutter/material.dart';

import 'config/presentation/app_palette.dart';
import 'config/presentation/layout_config.dart';
import 'routing/config.dart';

class JeevanConnectDesktop extends StatefulWidget {
  const JeevanConnectDesktop({super.key});

  @override
  State<JeevanConnectDesktop> createState() => _JeevanConnectDesktopState();
}

class _JeevanConnectDesktopState extends State<JeevanConnectDesktop>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    LayoutConfig().init();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        LayoutConfig().updateLayout(context);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppThemeData().lightTheme,
          darkTheme: AppThemeData().darkTheme,
          themeMode: ThemeMode.dark,
          title: 'JeevanConnect',
          restorationScopeId: "jeevanConnect",
          onGenerateRoute: RoutesConfig().onGenerateRoute,
          initialRoute: "ipForm",
        );
      }),
    );
  }
}
