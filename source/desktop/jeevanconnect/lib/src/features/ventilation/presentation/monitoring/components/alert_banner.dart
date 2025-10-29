import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../../../../config/data/assets.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../data/socket_data_handler.dart';
import '../../../domain/monitoring_ui_controllers.dart';
import 'alert_text.dart';

class AlertBanner extends StatefulWidget {
  const AlertBanner({super.key});

  @override
  State<AlertBanner> createState() => _AlertBannerState();
}

class _AlertBannerState extends State<AlertBanner> {
  Timer? loopTimer;
  StreamSubscription? alertStreamSubscription;
  bool isAlertDisplayRunning = false, showAlert = false;
  final productName = "Lite";
  PriorityQueue alertQueue =
      PriorityQueue((a, b) => b.priority.compareTo(a.priority));

  @override
  void initState() {
    alertQueue.clear();
    _listenToAlerts();
    super.initState();
  }

  @override
  void dispose() {
    alertStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LayoutConfig().setFractionWidth(55),
      alignment: Alignment.center,
      padding: WhiteSpace.v5,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: ResizeImage(
                  showAlert
                      ? const AssetImage(AppAssets.alertBanner)
                      : const AssetImage(AppAssets.liveBanner),
                  height: 58,
                  width: 500),
              fit: BoxFit.contain)),
      child: showAlert
          ? AlertBannerText(message: _alertMessage() ?? "Jeevan Lite")
          : AlertBannerText(message: 'Jeevan $productName'),
    );
  }

  _alertMessage() {
    try {
      if (alertQueue.isEmpty) {
        return null;
      }
      return alertQueue.first?.alertLabel;
    } catch (exception) {
      return null;
    }
  }

  _listenToAlerts() {
    alertStreamSubscription =
        SocketDataHandler().alertData!.listen((alertList) {
      if (alertList != null && alertList.isNotEmpty) {
        List alerts = alertQueue.toList();
        alerts.addAll(alertList);
        alertQueue.clear();
        alertQueue.addAll(alerts.toSet().toList());
        if (alerts.isNotEmpty && !isAlertDisplayRunning) {
          _displayAlerts();
        }
      }
    });
  }

  _displayAlerts() async {
    isAlertDisplayRunning = true;
    while (alertQueue.isNotEmpty) {
      if (!MonitoringUIControllers.isVentilationPaused) {
        showAlert = true;
        if (mounted) {
          setState(() {});
        }

        await Future.delayed(const Duration(seconds: 1), () {});
        if (alertQueue.isNotEmpty) {
          try {
            alertQueue.removeFirst();
          } catch (exception) {
            debugPrint("Alert Banner $exception");
          }
        }
        showAlert = false;
        if (mounted) {
          setState(() {});
        }
        await Future.delayed(const Duration(milliseconds: 500), () {});
      } else {
        showAlert = false;
        if (mounted) {
          setState(() {});
        }
        break;
      }
    }
    isAlertDisplayRunning = false;
  }
}
