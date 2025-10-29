import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/presentation/layout_config.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import '../../../../shared/presentation/widgets/side_menu_tile.dart';
import 'records/admission_records.dart';
import 'records/media.dart';

class PatientRecords extends StatefulWidget {
  const PatientRecords({super.key});

  @override
  State<PatientRecords> createState() => _PatientRecordsState();
}

class _PatientRecordsState extends State<PatientRecords> {
  final GlobalKey<NavigatorState> patientRecordPageKey =
      GlobalKey<NavigatorState>(debugLabel: "patient_records");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: SideMenu(
              patientRecordNavKey: patientRecordPageKey,
            ),
          ),
          PatientRecordPages(workspaceSettingsPageKey: patientRecordPageKey),
        ],
      ),
    );
  }
}

class PatientRecordPages extends StatelessWidget {
  final GlobalKey<NavigatorState> workspaceSettingsPageKey;

  const PatientRecordPages({super.key, required this.workspaceSettingsPageKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LayoutConfig().setFractionHeight(94),
      width: LayoutConfig().setFractionWidth(80),
      padding: WhiteSpace.all10,
      child: Navigator(
          key: workspaceSettingsPageKey,
          initialRoute: 'admission',
          clipBehavior: Clip.antiAlias,
          onGenerateRoute: (RouteSettings settings) {
            WidgetBuilder builder;
            switch (settings.name) {
              case 'admission':
                builder = (BuildContext _) => const AdmissionRecords();
                break;
              case 'media':
                builder = (BuildContext _) => const PatientMedia();
                break;
              default:
                throw Exception('Invalid route: ${settings.name}');
            }
            return CupertinoPageRoute(
                builder: builder,
                settings: settings,
                fullscreenDialog: true,
                allowSnapshotting: true);
          }),
    );
  }
}

class SideMenu extends StatefulWidget {
  final GlobalKey<NavigatorState> patientRecordNavKey;
  const SideMenu({super.key, required this.patientRecordNavKey});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late List<bool> _selectionIndicator;
  late String _currentPath;

  final numberOfPages = 2;

  @override
  void initState() {
    super.initState();
    _currentPath = 'admission';
    _selectionIndicator = List.generate(numberOfPages, (index) => false);
    _selectionIndicator[0] = true;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      shape: WidgetDecoration.sharpEdge,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: WhiteSpace.h20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WhiteSpace.b12,
            SideMenuTile(
              isSelected: _selectionIndicator[0],
              icon: Icons.airline_seat_flat_outlined,
              label: "Admission Record",
              onTap: () {
                _changePage(0, "admission");
              },
            ),
            SideMenuTile(
              isSelected: _selectionIndicator[1],
              icon: Icons.perm_media_outlined,
              label: "Media",
              onTap: () {
                _changePage(1, "media");
              },
            ),
          ],
        ),
      ),
    );
  }

  _changePage(pageId, pageName) {
    if (_currentPath != pageName) {
      _selectionIndicator = List.generate(numberOfPages, (index) => false);
      _selectionIndicator[pageId] = true;
      widget.patientRecordNavKey.currentState!
          .pushNamedAndRemoveUntil(pageName, (route) => false);
      setState(() {});
      _currentPath = pageName;
    }
  }
}
