import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jeevanconnect/src/routing/routes.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../shared/presentation/components/button.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/dialogs/dialogs.dart';
import '../../../data/socket_data_handler.dart';
import '../../../domain/derived_parameters.dart';
import '../../../domain/monitoring_ui_controllers.dart';
import 'live_graph.dart';
import 'loop_graph.dart';

class MonitoringGraph extends StatefulWidget {
  const MonitoringGraph({super.key});

  @override
  State<MonitoringGraph> createState() => _MonitoringGraphState();
}

class _MonitoringGraphState extends State<MonitoringGraph> {
  List<double> pressure = [], flow = [], volume = [], timeStamp = [];
  List<double> loopPressure = [], loopFlow = [], loopVolume = [];
  List<bool> pointType = [];
  DateTime? timeIntercept, inspiratoryTime, expiratoryTime, previousTempTime;
  double currentCycle = -1, previousCycle = -1;
  int? pplat, respiratoryRate, fio, pip, modeType = 0;
  double? minVolume;
  bool isTimingSyncAchieved = false,
      _showLoopGraph = false,
      isDataDecodingStarted = false,
      isPausedDialogShown = false;

  StreamSubscription? graphSubscription, sampleParameterSubscription;

  @override
  void initState() {
    super.initState();
    pressure = [];
    flow = [];
    timeStamp = [];
    loopPressure = [];
    loopFlow = [];
    loopVolume = [];
    modeType = 0;
    _showLoopGraph = false;
    isDataDecodingStarted = false;
    _listenToGraphValues();
    _listenToSampleParameters();
    isPausedDialogShown = false;
  }

  @override
  void dispose() {
    graphSubscription?.cancel();
    sampleParameterSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: WhiteSpace.all10,
      height: double.infinity,
      width: LayoutConfig().setFractionWidth(65),
      child: Stack(
        children: [
          _showLoopGraph
              ? LoopGraph(
                  pressure: loopPressure, flow: loopFlow, volume: loopVolume)
              : LiveGraph(
                  pressure: pressure,
                  flow: flow,
                  timeStamp: timeStamp,
                  volume: volume,
                  pointType: pointType,
                ),
          Align(
            alignment: Alignment.bottomRight,
            child: Button(
              onPressed: () {
                _showLoopGraph = !_showLoopGraph;
              },
              buttonPadding: WhiteSpace.zero,
              padding: WhiteSpace.zero,
              backgroundColor: AppPalette.transparent,
              child: Icon(
                  _showLoopGraph ? Icons.show_chart : Icons.loop_outlined,
                  color: AppPalette.amber,
                  size: 30),
            ),
          ),
        ],
      ),
    );
  }

  _listenToGraphValues() {
    graphSubscription = SocketDataHandler()
        .liveGraphData!
        .timeout(const Duration(seconds: 8), onTimeout: (controller) {
      _showDataErrorDialog();
    }).listen((point) {
      if (point != null) {
        if (!isDataDecodingStarted) {
          timeIntercept = DateTime.now();
          currentCycle = -1;
          previousCycle = -1;
          inspiratoryTime = DateTime.now();
          expiratoryTime = DateTime.now();
          previousTempTime = DateTime.now();
          isDataDecodingStarted = true;
        }
        final duration =
            DateTime.now().difference(timeIntercept!).inMilliseconds;
        if (duration >= 10000) {
          pressure.clear();
          flow.clear();
          pointType.clear();
          volume.clear();
          timeStamp.clear();
          timeIntercept = DateTime.now();
        }

        if (currentCycle != point.last) {
          currentCycle = point.last;
          if (previousCycle == 1 && currentCycle == 0 && isTimingSyncAchieved) {
            expiratoryTime = DateTime.now();
            sampleBreathParameters([loopPressure, loopFlow, loopVolume])
                .then((value) => null);
            loopPressure.clear();
            loopFlow.clear();
            loopVolume.clear();
            isTimingSyncAchieved = false;
          }
          if (previousCycle == 0 &&
              currentCycle == 1 &&
              !isTimingSyncAchieved) {
            isTimingSyncAchieved = true;
            inspiratoryTime = DateTime.now();
            sampleInspiratoryParameters(loopPressure).then((value) => null);
          }
          previousCycle = currentCycle;
        }

        if (-250 < point[1] && point[1] < 250) {
          pressure.add(point[0]);
          flow.add(point[1]);
          volume.add(point[2]);
          loopPressure.add(point[0]);
          loopFlow.add(point[1]);
          loopVolume.add(point[2]);
          pointType.add(point[3] > 0);
          timeStamp.add(
              (DateTime.now().difference(timeIntercept!).inMilliseconds)
                  .toDouble());
          if (mounted) {
            setState(() {});
          }
        }

        MonitoringUIControllers.isVentilationPaused = point[4].toInt() == 1;
        if (MonitoringUIControllers.isVentilationPaused &&
            !isPausedDialogShown) {
          isPausedDialogShown = true;
          _showVentilationPauseDialog();
        } else if (!MonitoringUIControllers.isVentilationPaused &&
            isPausedDialogShown) {
          isPausedDialogShown = false;
        }
      }
    });
  }

  _showDataErrorDialog() {
    simpleDialog(context,
            title: "Data Connection Error",
            type: DialogType.alert,
            content:
                "Host stopped transmitting data. Please check the internet or the connection with the ventilator",
            buttonName: "Exit")
        .then((_) {
      if (Navigator.canPop(context)) {
        SocketDataHandler().disconnectSocket();
        context.pop();
      }
    });
  }

  _showVentilationPauseDialog() {
    simpleDialog(context,
        title: "Ventilation paused",
        type: DialogType.info,
        content:
            "Ventilation paused. You can wait here or come back after some time.",
        buttonName: "Close");
  }

  _listenToSampleParameters() {
    sampleParameterSubscription =
        SocketDataHandler().sampleData!.listen((event) {
      if (event != null) {
        if (event[0] == 1 && modeType == 0) {
          modeType = 1;
          MonitoringUIControllers.isBackupModeRunning = true;
          MonitoringUIControllers.vitalParameterViewController!.sink.add(true);
        } else if (event[0] == 0 && modeType == 1) {
          modeType = 0;
          MonitoringUIControllers.isBackupModeRunning = false;
          MonitoringUIControllers.vitalParameterViewController!.sink.add(false);
        }
        fio = event[1];
        respiratoryRate = event[2];
        minVolume = double.parse("${event[3]}.${event[4]}");
      }
    });
  }

  Future<bool> sampleBreathParameters(List<List<double>> breathSamples) async {
    if (breathSamples[0].isNotEmpty) {
      DerivedParameters parameters = DerivedParameters();

      parameters.pip =
          pip ?? _cleanData(breathSamples[0].reduce(math.max).toInt());
      parameters.peep = _cleanData(breathSamples[0].last.toInt());
      parameters.pif = breathSamples[1].reduce(math.max).toInt();
      parameters.pef = breathSamples[1].reduce(math.min).toInt() * -1;
      parameters.vti = _cleanData(breathSamples[2].reduce(math.max).toInt());
      parameters.vte =
          _cleanData(parameters.vtiValue - breathSamples[2].last.toInt());

      if (parameters.vtiValue >= 1) {
        if (pplat == null) {
          parameters.pplat = parameters.pipValue;
          parameters.cstat = parameters.vtiValue /
              (parameters.pplatValue - parameters.peepValue);
          parameters.rInsp = (parameters.pplatValue - parameters.peepValue) /
              parameters.vtiValue;
        } else {
          parameters.pplat = pplat;
          parameters.cstat = parameters.vtiValue /
              (parameters.pplatValue - parameters.peepValue);
          parameters.rInsp = (parameters.pipValue - parameters.pplatValue) /
              parameters.vtiValue;
        }
        parameters.cplat =
            parameters.vtiValue / (parameters.pipValue - parameters.peepValue);
      } else {
        parameters.cstat = 0.0;
        parameters.cplat = 0.0;
        parameters.rInsp = 0.0;
      }
      parameters.ti =
          inspiratoryTime!.difference(previousTempTime!).inMicroseconds /
              1000000.0;
      parameters.te = (expiratoryTime!
                  .difference(previousTempTime!)
                  .inMicroseconds -
              inspiratoryTime!.difference(previousTempTime!).inMicroseconds) /
          1000000.0;
      previousTempTime = expiratoryTime;

      parameters.i =
          (parameters.tiValue + parameters.teValue) / parameters.teValue;
      parameters.e =
          (parameters.tiValue + parameters.teValue) / parameters.tiValue;

      parameters.minVol = minVolume;
      parameters.fio = fio;
      parameters.rr = respiratoryRate;

      parameters.map = ((parameters.tiValue * parameters.pipValue) +
              (parameters.teValue * parameters.peepValue)) /
          (parameters.tiValue + parameters.teValue);

      // if ((VentilationSettings().settings['ventType'] ?? 0) == 1) {
      //   parameters.vti = null;
      //   parameters.vte = null;
      //   parameters.cstat = null;
      //   parameters.cplat = null;
      //   parameters.rInsp = null;
      //   parameters.minVol = null;
      // }

      MonitoringUIControllers.derivedParametersController?.sink.add(parameters);
    }
    return true;
  }

  Future<bool> sampleInspiratoryParameters(
      List<double> inspiratoryPressure) async {
    if (inspiratoryPressure.isNotEmpty) {
      int samplePip = inspiratoryPressure.reduce(math.max).toInt();
      pip = inspiratoryPressure.last.toInt();
      if (inspiratoryPressure.last.toInt() < (samplePip - 3)) {
        pplat = inspiratoryPressure.last.toInt();
        pip = samplePip;
      } else {
        pplat = null;
      }
    }
    return true;
  }

  _cleanData(value) {
    if (value > 0) {
      return value;
    }
    return null;
  }
}
