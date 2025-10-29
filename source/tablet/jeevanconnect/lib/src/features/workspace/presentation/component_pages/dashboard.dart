import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../config/presentation/layout_config.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import '../../data/workspace_repository.dart';
import 'dashboard/auto_scrolling_announcements.dart';
import 'dashboard/pages.dart';

class WorkspaceDashboard extends StatefulWidget {
  const WorkspaceDashboard({super.key});

  @override
  State<WorkspaceDashboard> createState() => _WorkspaceDashboardState();
}

class _WorkspaceDashboardState extends State<WorkspaceDashboard> {
  @override
  void initState() {
    _onRefresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: WorkspaceRepository().currentAnalytics != null
          ? SingleChildScrollView(
              padding: WhiteSpace.h20,
              child: Column(
                children: [
                  Row(
                    children: [
                      CountCard(
                        count: WorkspaceRepository()
                            .currentAnalytics!
                            .activeDevices,
                        label: "Active devices",
                      ),
                      WhiteSpace.w6,
                      CountCard(
                        count: WorkspaceRepository()
                            .currentAnalytics!
                            .patientsUnderVentilation,
                        label: "Patients under ventilation",
                      ),
                      WhiteSpace.w6,
                      CountCard(
                        count: WorkspaceRepository()
                            .currentAnalytics!
                            .treatedPatients,
                        label: "Treated patients",
                      ),
                      WhiteSpace.w6,
                      CountCard(
                        count: WorkspaceRepository()
                            .currentAnalytics!
                            .offlineDevices,
                        label: "Offline devices",
                      ),
                      WhiteSpace.w6,
                      CountCard(
                        count: WorkspaceRepository()
                            .currentAnalytics!
                            .departmentCount,
                        label: "Departments",
                      ),
                    ],
                  ),
                  WhiteSpace.b6,
                  Row(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: LayoutConfig().setFractionHeight(22),
                            width: LayoutConfig().setFractionWidth(50),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    color: AppPalette.greyC5,
                                    elevation: 5,
                                    shape: WidgetDecoration.roundedEdge5,
                                    margin: WhiteSpace.zero,
                                    child: Padding(
                                      padding: WhiteSpace.h10,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          WhiteSpace.b6,
                                          Text(
                                            "Announcements",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const Divider(),
                                          SizedBox(
                                            height: LayoutConfig()
                                                .setFractionHeight(15),
                                            child: const AnnouncementBanner(),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                WhiteSpace.w16,
                                UserActivityChart(
                                  activeUsers: WorkspaceRepository()
                                      .currentAnalytics!
                                      .activeUsers,
                                  inactiveUsers: WorkspaceRepository()
                                          .currentAnalytics!
                                          .totalUsers -
                                      WorkspaceRepository()
                                          .currentAnalytics!
                                          .activeUsers,
                                ),
                                DeviceActivityChart(
                                  activeDevices: WorkspaceRepository()
                                      .currentAnalytics!
                                      .activeDevices,
                                  offlineDevices: WorkspaceRepository()
                                      .currentAnalytics!
                                      .offlineDevices,
                                  idleDevices: WorkspaceRepository()
                                      .currentAnalytics!
                                      .idleDevices,
                                  repairDevices: WorkspaceRepository()
                                      .currentAnalytics!
                                      .repairDevices,
                                ),
                                WhiteSpace.w12,
                              ],
                            ),
                          ),
                          WhiteSpace.b6,
                          SizedBox(
                            height: LayoutConfig().setFractionHeight(50),
                            width: LayoutConfig().setFractionWidth(50),
                            child: const ActiveWorkspaceSessions(),
                          ),
                        ],
                      ),
                      WhiteSpace.w6,
                      Column(
                        children: [
                          SizedBox(
                            height: LayoutConfig().setFractionHeight(36.1),
                            width: LayoutConfig().setFractionWidth(47),
                            child: Card(
                              color: AppPalette.greyC5,
                              elevation: 5,
                              shape: WidgetDecoration.roundedEdge5,
                              margin: WhiteSpace.zero,
                              child: Padding(
                                padding: WhiteSpace.all10,
                                child: Column(
                                  children: [
                                    Text(
                                      "Department wise Device Statistics",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    WhiteSpace.b12,
                                    Expanded(
                                        child: DepartmentDeviceStatistics(
                                            analytics: WorkspaceRepository()
                                                .currentAnalytics)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          WhiteSpace.b6,
                          SizedBox(
                            height: LayoutConfig().setFractionHeight(36.1),
                            width: LayoutConfig().setFractionWidth(47),
                            child: Card(
                              color: AppPalette.greyC5,
                              shape: WidgetDecoration.roundedEdge5,
                              margin: WhiteSpace.zero,
                              child: Padding(
                                padding: WhiteSpace.all10,
                                child: Column(
                                  children: [
                                    Text(
                                      "Ventilation session statistics - ${DateTime.now().year}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    WhiteSpace.b12,
                                    Expanded(
                                        child: Padding(
                                      padding: WhiteSpace.onlyRight15,
                                      child: VentilationSessionStatistics(
                                        year: DateTime.now().year,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          WhiteSpace.w6,
                        ],
                      )
                    ],
                  ),
                ],
              ),
            )
          : Center(
              child: CupertinoActivityIndicator(
                radius: 20,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
    );
  }

  Future<void> _onRefresh() async {
    debugPrint("Workspace Analytics:Refreshed");
    await WorkspaceRepository().getWorkspaceAnalytics();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }
}

class CountCard extends StatelessWidget {
  final String label;
  final int count;
  const CountCard({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: LayoutConfig().setFractionHeight(15),
      width: LayoutConfig().setFractionWidth(19.15),
      child: Card(
        color: AppPalette.white,
        shape: WidgetDecoration.roundedEdge5,
        margin: WhiteSpace.zero,
        child: Padding(
          padding: WhiteSpace.all5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: AppPalette.black,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: AppPalette.greyS8,
                      fontWeight: FontWeight.w600,
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
