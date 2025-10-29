import 'package:flutter/material.dart';

import 'config/presentation/app_palette.dart';
import 'config/presentation/layout_config.dart';
import 'routing/config.dart';

class JeevanConnectTablet extends StatefulWidget {
  const JeevanConnectTablet({super.key});

  @override
  State<JeevanConnectTablet> createState() => _JeevanConnectTabletState();
}

class _JeevanConnectTabletState extends State<JeevanConnectTablet>
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
