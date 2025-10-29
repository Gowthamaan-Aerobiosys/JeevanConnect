// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../exception/custom_exception.dart';
import '../../../routing/routes.dart';
import '../../../shared/domain/date_time_formatter.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/dialogs/dialogs.dart';
import '../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../../../shared/presentation/widgets/progress_loader.dart';
import '../../patients/patients.dart' show PatientRepository;
import '../../products/products.dart' show ProductRepository;
import '../data/monitoring_repository.dart';
import '../data/socket_data_handler.dart';
import '../domain/monitoring_ui_controllers.dart';
import 'session/pages.dart';

class VentilationSessionDetails extends StatefulWidget {
  final dynamic session;
  const VentilationSessionDetails({super.key, required this.session});

  @override
  State<VentilationSessionDetails> createState() =>
      _VentilationSessionDetailsState();
}

class _VentilationSessionDetailsState extends State<VentilationSessionDetails> {
  @override
  Widget build(BuildContext context) {
    bool isSessionReady = ProductRepository().currentProduct.onlineStatus &&
        widget.session.isActive;
    bool canRefresh = ProductRepository().currentProduct.onlineStatus;

    return Scaffold(
      backgroundColor: AppPalette.greyC2,
      body: SingleChildScrollView(
        padding: WhiteSpace.all30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Monitoring session - ${widget.session.sessionId}",
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            WhiteSpace.b32,
            Row(
              children: [
                WhiteSpace.w56,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Status",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: AppPalette.greyC3),
                    ),
                    WhiteSpace.b32,
                    Text(
                      "Patient",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: AppPalette.greyC3),
                    ),
                    WhiteSpace.b32,
                    Text(
                      "Added on",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: AppPalette.greyC3),
                    ),
                    WhiteSpace.b32,
                    Text(
                      "Last updated on",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: AppPalette.greyC3),
                    ),
                  ],
                ),
                WhiteSpace.w56,
                Column(
                  children: [
                    BinaryStatusIndicator(
                        isActive: widget.session.isActive,
                        labels: ("Active", "Inactive")),
                    WhiteSpace.b32,
                    TextButton(
                      onPressed: () {
                        if (widget.session.patient != null) {
                          PatientRepository().currentPatient =
                              widget.session.patient!;
                          context.push(Routes.patient,
                              arguments: {'patient': widget.session.patient},
                              rootNavigator: true);
                        }
                      },
                      child: Text(
                        widget.session.patient?.patientId ?? "Not Assigned",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    WhiteSpace.b32,
                    Text(
                      DateTimeFormat.getTimeStamp(widget.session.createdAt),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    WhiteSpace.b32,
                    Text(
                      DateTimeFormat.getTimeStamp(widget.session.updatedAt),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            WhiteSpace.b32,
            const Divider(),
            WhiteSpace.b32,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: WhiteSpace.zero,
                  icon: Icon(
                    Icons.play_arrow_outlined,
                    color:
                        isSessionReady ? AppPalette.green : AppPalette.greyC3,
                    size: Theme.of(context).textTheme.displayMedium!.fontSize,
                  ),
                  onPressed: () {
                    if (isSessionReady) {
                      _viewLiveMonitoringData();
                    }
                  },
                ),
                WhiteSpace.w32,
                IconButton(
                  padding: WhiteSpace.zero,
                  icon: Icon(
                    Icons.refresh_outlined,
                    color: canRefresh ? AppPalette.blueS9 : AppPalette.greyC3,
                    size: Theme.of(context).textTheme.displaySmall!.fontSize,
                  ),
                  onPressed: () async {
                    ProgressLoader.show(context);
                    try {
                      final isDataRequested = await MonitoringRepository()
                          .requestMonitoringLog(widget.session.sessionId);
                      if (isDataRequested) {
                        ProgressLoader.hide(context);
                        simpleDialog(context,
                            type: DialogType.success,
                            title: "Monitoring data request successful",
                            content:
                                "This may take a while. We will notify you, once we receive the data",
                            buttonName: "Close");
                      }
                    } catch (exception) {
                      if (context.mounted) {
                        ProgressLoader.hide(context);
                        simpleDialog(context,
                            type: DialogType.error,
                            title: (exception as CustomException).title,
                            content: exception.displayMessage,
                            buttonName: "Close");
                      }
                    }
                  },
                )
              ],
            ),
            WhiteSpace.b32,
            Text(
              "Monitoring trend",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            MonitoringTrend(session: widget.session),
            WhiteSpace.b32,
            Text(
              "Alerts",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            MonitoringAlerts(session: widget.session),
            WhiteSpace.b32,
            Text(
              "Events",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            MonitoringEvents(session: widget.session),
            WhiteSpace.b32,
          ],
        ),
      ),
    );
  }

  _viewLiveMonitoringData() async {
    try {
      ProgressLoader.show(context);
      bool isMonitoringInitiated = await MonitoringRepository().initMontoring();
      if (isMonitoringInitiated) {
        bool isSocketConnected = await SocketDataHandler()
            .connectToSocket(MonitoringRepository.ventilatorSocketUrl);
        if (isSocketConnected) {
          ProgressLoader.hide(context);
          MonitoringUIControllers().init();
          context
              .push(Routes.monitoring, arguments: {'session': widget.session});
        }
      }
    } catch (exception) {
      debugPrint("Exception $exception");
      simpleDialog(context,
          type: DialogType.success,
          title: (exception as dynamic).title,
          content: (exception as dynamic).displayMessage,
          buttonName: "Close");
    }
  }
}
