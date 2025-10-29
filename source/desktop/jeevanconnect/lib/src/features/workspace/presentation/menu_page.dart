import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../routing/routes.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/components/widget_decoration.dart';
import '../data/workspace_repository.dart';
import 'component_pages/pages.dart';

class WorkspaceMenu extends StatefulWidget {
  final dynamic workspace;
  const WorkspaceMenu({super.key, required this.workspace});

  @override
  State<WorkspaceMenu> createState() => _WorkspaceMenuState();
}

class _WorkspaceMenuState extends State<WorkspaceMenu>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: LayoutConfig().setHeight(80),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Row(
            children: [
              Text(
                WorkspaceRepository().currentWorkspace.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              WhiteSpace.spacer,
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      color: AppPalette.greyC2,
                      borderRadius: WidgetDecoration.borderRadius40),
                  child: TabBar(
                    controller: _tabController,
                    indicator: const BoxDecoration(
                        color: AppPalette.logoBlue,
                        borderRadius: WidgetDecoration.borderRadius40),
                    indicatorColor: AppPalette.logoBlue,
                    indicatorPadding: WhiteSpace.all1,
                    indicatorWeight: 1.0,
                    splashBorderRadius: WidgetDecoration.borderRadius40,
                    labelColor: AppPalette.white,
                    unselectedLabelColor: AppPalette.greyS8,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Theme.of(context).scaffoldBackgroundColor,
                    labelStyle: Theme.of(context).textTheme.labelMedium,
                    tabs: const [
                      Tab(child: Text('Dashboard')),
                      Tab(child: Text('Devices')),
                      Tab(child: Text('Patients')),
                      Tab(child: Text('Members')),
                      Tab(child: Text('Settings')),
                    ],
                  ),
                ),
              )
            ],
          ),
          leading: Button(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            hoverColor: null,
            padding: WhiteSpace.zero,
            buttonPadding: WhiteSpace.zero,
            child: Icon(
              Icons.chevron_left_rounded,
              color: Theme.of(context).primaryColorLight,
              size: LayoutConfig().setFontSize(40),
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                WorkspaceRepository().currentWorkspace = null;
                context.pop();
              }
            },
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            WorkspaceDashboard(),
            WorkspaceDevices(),
            WorkspacePatients(),
            WorkspaceUsers(),
            WorkspaceSettings(),
          ],
        ),
      ),
    );
  }
}
