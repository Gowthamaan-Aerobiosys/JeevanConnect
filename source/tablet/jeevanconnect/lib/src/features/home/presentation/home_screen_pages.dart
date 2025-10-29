import 'package:flutter/cupertino.dart';

import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../messages/messages.dart' show Messages;
import '../../patients/patients.dart' show PatientsList;
import '../../products/products.dart' show ProductsList;
import '../../resources/presentation/my_drive.dart';
import '../../resources/resources.dart' show Resources;
import '../../workspace/workspace.dart' show UserWorkspaces;
import 'app_settings.dart';

class HomeScreenPages extends StatefulWidget {
  final GlobalKey<NavigatorState> homePageNavKey;

  const HomeScreenPages({super.key, required this.homePageNavKey});

  @override
  State<HomeScreenPages> createState() => _HomeScreenPagesState();
}

class _HomeScreenPagesState extends State<HomeScreenPages> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: LayoutConfig().layoutUpdates,
        builder: (context, snapshot) {
          return Container(
            height: LayoutConfig().setFractionHeight(94),
            width: LayoutConfig().setFractionWidth(85),
            padding: WhiteSpace.all20,
            child: Navigator(
                key: widget.homePageNavKey,
                initialRoute: 'workspaces',
                clipBehavior: Clip.antiAlias,
                onGenerateRoute: (RouteSettings settings) {
                  WidgetBuilder builder;
                  switch (settings.name) {
                    case 'workspaces':
                      builder = (BuildContext _) => const UserWorkspaces();
                      break;
                    case 'products':
                      builder = (BuildContext _) => const ProductsList();
                      break;
                    case 'patients':
                      builder = (BuildContext _) => const PatientsList();
                      break;
                    case 'messages':
                      builder = (BuildContext _) => const Messages();
                      break;
                    case 'resources':
                      builder = (BuildContext _) => const Resources();
                      break;
                    case 'settings':
                      builder = (BuildContext _) => const ApplicationSettings();
                      break;
                    case 'drive':
                      builder = (BuildContext _) => const MyDriveButton();
                      break;
                    default:
                      throw Exception('Invalid route: ${settings.name}');
                  }
                  return CupertinoPageRoute(
                      builder: builder,
                      settings: settings,
                      fullscreenDialog: true,
                      allowSnapshotting: false);
                }),
          );
        });
  }
}
