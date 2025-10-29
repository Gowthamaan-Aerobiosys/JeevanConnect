import 'mode.dart';
import 'parameter.dart';

class VentilationConfiguration {
  final _fio = Parameter(title: "FiO2", unit: "%", parameterId: 'fio');
  final _apnea = Parameter(title: "Apnea", unit: "s", parameterId: 'apnea');
  final _peep = Parameter(title: "PEEP", unit: "cmH2O", parameterId: 'peep');
  final _peepMask =
      Parameter(title: "PEEP", unit: "cmH2O", parameterId: 'peep');
  final _cpap = Parameter(title: "CPAP/PEEP", unit: "", parameterId: 'cpap');
  final _pLow = Parameter(title: "Plow", unit: "cmH2O", parameterId: 'plow');
  final _pLowMask =
      Parameter(title: "Plow", unit: "cmH2O", parameterId: 'plow');
  final _pip = Parameter(title: "PIP", unit: "cmH2O", parameterId: 'pip');
  final _pipMask = Parameter(title: "PIP", unit: "cmH2O", parameterId: 'pip');
  final _pHigh = Parameter(title: "Phigh", unit: "cmH2O", parameterId: 'phigh');
  final _pHighMask =
      Parameter(title: "Phigh", unit: "cmH2O", parameterId: 'phigh');
  final _pSupport = Parameter(title: "PS", unit: "cmH2O", parameterId: 'ps');

  final _vti = Parameter(title: "VTI", unit: "ml", parameterId: 'vti');

  final _respiratoryRate = Parameter(
    title: "RR",
    unit: "breathe/min",
    parameterId: 'respiratoryRate',
  );
  final _respiratoryRateBackup = Parameter(
    title: "RR",
    unit: "breathe/min",
    parameterId: 'respiratoryRate',
  );

  final _ti = Parameter(
    title: "Ti",
    unit: "s",
    parameterId: 'ti',
  );
  final _tHighAprv = Parameter(
    title: "Thigh",
    unit: "s",
    parameterId: 'tHighAprv',
  );
  final _tHigh = Parameter(
    title: "Thigh",
    unit: "s",
    parameterId: 'tHigh',
  );

  final _riseTime = Parameter(title: "RT", unit: "s", parameterId: 'riseTime');

  final _flowRate =
      Parameter(title: "Flow rate", unit: "lpm", parameterId: 'flowLimit');
  final _fioFlowLimit =
      Parameter(title: "Flow", unit: "lpm", parameterId: 'fioflowLimit');
  final _pressureTriggerLimit = Parameter(
      title: "Pres.Trig", unit: "cmH2O", parameterId: 'pressureTriggerLimit');

  final _triggerWindow =
      Parameter(title: "Tt", unit: "s", parameterId: 'triggerTime');

  final _tLow = Parameter(
    title: "Tlow",
    unit: "s",
    parameterId: 'tLow',
  );

  Mode get pcCmv => Mode(
      modeName: "PC-CMV",
      modeId: 1,
      parameters: [_fio, _peep, _pip, _ti, _respiratoryRate, _riseTime],
      defaultValues: [21, 10, 30, 1, 20, 0.6],
      displayCardParameters: [
        (_pip, 'pip', false),
        (_peep, 'peep', false),
        (_vti, 'vti', true),
        (_fio, 'fio', false),
        (_respiratoryRate, 'respiratoryRate', false)
      ],
      hasBackupModeSupport: false);
  Mode get vcCmv => Mode(
      modeName: "VC-CMV",
      modeId: 2,
      parameters: [_fio, _peep, _vti, _ti, _respiratoryRate, _flowRate],
      defaultValues: [21, 5, 500, 1, 20, 50],
      hasBackupModeSupport: false,
      displayCardParameters: [
        (_pip, 'pip', true),
        (_peep, 'peep', false),
        (_vti, 'vti', false),
        (_fio, 'fio', false),
        (_respiratoryRate, 'respiratoryRate', false)
      ]);
  Mode get aprvETT => Mode(
      modeName: "APRV",
      modeId: 4,
      parameters: [
        _fio,
        _pLow,
        _pHigh,
        _tHighAprv,
        _tLow,
        _triggerWindow,
        _pressureTriggerLimit
      ],
      defaultValues: [21, 10, 30, 5.5, 0.5, 1, 2, 0],
      hasBackupModeSupport: false,
      displayCardParameters: [
        (_pHigh, 'phigh', false),
        (_pLow, 'plow', false),
        (_vti, 'vti', true),
        (_fio, 'fio', false),
        (_respiratoryRate, 'respiratoryRate', true)
      ]);

  Mode get pcSimv => Mode(
      modeName: "PC-A/SIMV",
      modeId: 5,
      parameters: [
        _fio,
        _peep,
        _pip,
        _ti,
        _respiratoryRate,
        _riseTime,
        _triggerWindow,
        _pressureTriggerLimit,
      ],
      defaultValues: [21, 10, 30, 1, 20, 0.6, 1, 2, 1],
      hasBackupModeSupport: false,
      displayCardParameters: [
        (_pip, 'pip', false),
        (_peep, 'peep', false),
        (_vti, 'vti', true),
        (_fio, 'fio', false),
        (_respiratoryRate, 'respiratoryRate', false)
      ]);
  Mode get vcSimv => Mode(
      modeName: "VC-A/SIMV",
      modeId: 6,
      parameters: [
        _fio,
        _peep,
        _vti,
        _ti,
        _respiratoryRate,
        _flowRate,
        _triggerWindow,
        _pressureTriggerLimit,
      ],
      defaultValues: [21, 5, 500, 1, 20, 50, 1, 2, 1],
      hasBackupModeSupport: false,
      displayCardParameters: [
        (_pip, 'pip', true),
        (_peep, 'peep', false),
        (_vti, 'vti', false),
        (_fio, 'fio', false),
        (_respiratoryRate, 'respiratoryRate', false)
      ]); //PS or PIP
  Mode get psvETT => Mode(
      modeName: "PSV",
      modeId: 7,
      parameters: [
        _fio,
        _peep,
        _pSupport,
        _apnea,
        _triggerWindow,
        _pressureTriggerLimit,
      ],
      defaultValues: [21, 10, 30, 10, 1, 2, 0],
      hasBackupModeSupport: true,
      backupMode: pcCmvBackupETT,
      displayCardParameters: [
        (_pSupport, 'ps', false),
        (_peep, 'peep', false),
        (_vti, 'vti', true),
        (_fio, 'fio', false),
        (_respiratoryRate, 'respiratoryRate', true)
      ]);
  Mode get cpap => Mode(
      modeName: "CPAP",
      modeId: 11,
      parameters: [_fio, _cpap, _apnea, _triggerWindow, _pressureTriggerLimit],
      defaultValues: [21, 20, 10, 1, 2, 1],
      hasBackupModeSupport: true,
      backupMode: pcCmvBackupMask,
      displayCardParameters: [
        (_pip, 'pip', true),
        (_cpap, 'cpap', false),
        (_vti, 'vti', true),
        (_fio, 'fio', false),
        (_respiratoryRate, 'respiratoryRate', true)
      ]);

  Mode get bipapMask => Mode(
      modeName: "Bi-PAP",
      modeId: 12,
      parameters: [
        _fio,
        _pLowMask,
        _pHighMask,
        _tHigh,
        _respiratoryRateBackup,
        _apnea,
        _triggerWindow,
        _pressureTriggerLimit,
      ],
      defaultValues: [21, 10, 20, 1, 20, 10, 1, 2, 1],
      hasBackupModeSupport: true,
      backupMode: pcCmvBackupMask,
      displayCardParameters: [
        (_pHighMask, 'phigh', false),
        (_pLowMask, 'plow', false),
        (_vti, 'vti', true),
        (_fio, 'fio', false),
        (_respiratoryRateBackup, 'respiratoryRate', false)
      ]);

  Mode get hfnc => Mode(
      modeName: "HFNC",
      modeId: 13,
      parameters: [_fio, _fioFlowLimit],
      defaultValues: [100, 40],
      hasBackupModeSupport: false,
      displayCardParameters: [
        (_pip, 'pip', true),
        (_peep, 'peep', true),
        (_vti, 'vti', true),
        (_fio, 'fio', true),
        (_respiratoryRate, 'respiratoryRate', true)
      ]);

  Mode get pcCmvBackupMask => Mode(
      modeName: "PC-CMV (Backup)",
      modeId: 1,
      parameters: [
        _fio,
        _peepMask,
        _pipMask,
        _ti,
        _respiratoryRateBackup,
        _riseTime,
        _triggerWindow
      ],
      defaultValues: [21, 10, 20, 1, 20, 0.6, 1],
      displayCardParameters: [
        (_pipMask, 'pip', false),
        (_peepMask, 'peep', false),
        (_vti, 'vti', true),
        (_fio, 'fio', false),
        (_respiratoryRateBackup, 'respiratoryRate', false)
      ],
      hasBackupModeSupport: false);
  Mode get pcCmvBackupETT => Mode(
      modeName: "PC-CMV (Backup)",
      modeId: 1,
      parameters: [
        _fio,
        _peep,
        _pip,
        _ti,
        _respiratoryRateBackup,
        _riseTime,
        _triggerWindow
      ],
      defaultValues: [21, 10, 30, 1, 20, 0.6, 1],
      displayCardParameters: [
        (_pip, 'pip', false),
        (_peep, 'peep', false),
        (_vti, 'vti', true),
        (_fio, 'fio', false),
        (_respiratoryRateBackup, 'respiratoryRate', false)
      ],
      hasBackupModeSupport: false);

  get modes => {
        1: pcCmv,
        2: vcCmv,
        5: pcSimv,
        6: vcSimv,
        4: aprvETT,
        7: psvETT,
        11: cpap,
        12: bipapMask,
        13: hfnc,
      };
}
