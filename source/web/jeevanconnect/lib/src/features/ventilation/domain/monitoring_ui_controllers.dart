import 'dart:async';

import 'derived_parameters.dart';
import 'mode.dart';
import 'ventilation_config.dart';

class MonitoringUIControllers {
  static bool isBackupModeRunning = false;
  static bool isVentilationPaused = true;
  static int modeIndex = -1;
  static late Mode currentMode;
  static Map settings = {};
  static StreamController<bool>? vitalParameterViewController;
  static StreamController<DerivedParameters>? derivedParametersController;

  init() {
    currentMode = VentilationConfiguration().modes[1];
    isBackupModeRunning = false;
    isVentilationPaused = false;
    derivedParametersController = StreamController.broadcast();
    vitalParameterViewController = StreamController.broadcast();
  }

  dispose() {
    derivedParametersController?.close();
    vitalParameterViewController?.close();
  }

  resetMode() {
    final mode = VentilationConfiguration().modes[modeIndex];
    if (mode != null) {
      currentMode = mode;
    }
  }

  rebuildSettings(data) {
    settings['assist'] = data[0] >> 7;
    settings['flowTrigger'] = ((data[0] & 0x40) >> 6) == 1;
    settings['isBackup'] = ((data[0] & 0x40) >> 5) == 1;
    settings['mode'] = data[0] & 0x0F;
    modeIndex = settings['mode'];
    resetMode();
    settings['pip'] = data[1];
    settings['peep'] = data[2];
    int volume = (data[4] << 8) | data[3];
    settings['vti'] = volume;
    settings['fio'] = data[5];
    settings['respiratoryRate'] = data[6];
    settings['ti'] = data[7] / 10.0;
    settings['tLow'] = data[8] / 10.0;
    settings['riseTime'] = data[9] / 10.0;
    settings['flowLimit'] = data[10];
    settings['apnea'] = data[11];
    settings['triggerTime'] = data[12] / 10.0;
    settings['flowTriggerLimit'] = data[13] / 10.0;
    settings['ventType'] = data[14] >> 7;
    settings['ps'] = settings['pip'];
    settings['phigh'] = settings['pip'];
    settings['cpap'] = settings['peep'];
    settings['plow'] = settings['peep'];
    settings['vs'] = settings['vti'];
    settings['tHigh'] = settings['ti'];
    settings['tHighAprv'] = settings['ti'];
    settings['fioflowLimit'] = settings['flowLimit'];
    settings['pressureTriggerLimit'] = settings['flowTriggerLimit'];
    return settings;
  }

  Stream? get derivedParameters => derivedParametersController?.stream;
  Stream get vitalParameterViewUpdates => vitalParameterViewController!.stream;
}
