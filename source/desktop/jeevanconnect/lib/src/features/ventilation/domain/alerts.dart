import 'monitoring_alert.dart';

/// A class that contains static constants representing various alerts.
///
/// The `DeviceAlerts` class provides static constants for system alerts,
/// clinical alerts, parameter alerts, and a reserved alert.
/// Each constant is an instance of the `MonitoringAlert` class, with a specific
/// priority and alert label.

class Alerts {
  /// System alerts

  /// Represents the "Plugged in" system alert.
  static const _pluggedIn = MonitoringAlert(priority: 4, alertLabel: "Plugged in");

  /// Represents the "On battery" system alert.
  static const _onBattery = MonitoringAlert(priority: 4, alertLabel: "On battery");

  /// Represents the "Battery drain" system alert.
  static const _batteryDrain =
  MonitoringAlert(priority: 4, alertLabel: "Battery drain");

  /// Represents the "O₂ supply failed" system alert.
  static const _oxygenSupplyFailed =
  MonitoringAlert(priority: 3, alertLabel: "O₂ supply failed");

  /// Represents the "Patient circuit disconnected" system alert.
  static const _patientCircuitDisconnected =
  MonitoringAlert(priority: 3, alertLabel: "Patient circuit disconnected");

  /// Represents the "Check flow sensor" system alert.
  static const _flowSensorConnectionError =
  MonitoringAlert(priority: 3, alertLabel: "Check flow sensor");

  /// Represents the "Nebulizer ON" system alert.
  static const _nebulizerOn =
  MonitoringAlert(priority: 3, alertLabel: "Nebulizer ON");

  /// Represents the "Nebulizer OFF" system alert.
  static const _nebulizerOff =
  MonitoringAlert(priority: 3, alertLabel: "Nebulizer OFF");

  /// Clinical alerts

  /// Represents the "Apnea" clinical alert.
  static const _apnea = MonitoringAlert(priority: 4, alertLabel: "Apnea");

  /// Represents the "Low SpO₂" clinical alert.
  static const _lowSpO = MonitoringAlert(priority: 4, alertLabel: "Low SpO₂");

  /// Represents the "Pressure limitation" clinical alert.
  static const _pressureLimitation =
  MonitoringAlert(priority: 2, alertLabel: "Pressure limitation");

  /// Represents the "Leak" clinical alert.
  static const _leak = MonitoringAlert(priority: 2, alertLabel: "Leak");

  /// Parameter alerts

  /// Represents the "High PIP" parameter alert.
  static const _pipHigh = MonitoringAlert(priority: 3, alertLabel: "High PIP");

  /// Represents the "Low PIP" parameter alert.
  static const _pipLow = MonitoringAlert(priority: 2, alertLabel: "Low PIP");

  /// Represents the "High PEEP" parameter alert.
  static const _peepHigh = MonitoringAlert(priority: 2, alertLabel: "High PEEP");

  /// Represents the "Low PEEP" parameter alert.
  static const _peepLow = MonitoringAlert(priority: 3, alertLabel: "Low PEEP");

  /// Represents the "High VTI" parameter alert.
  static const _volumeHigh = MonitoringAlert(priority: 2, alertLabel: "High VTI");

  /// Represents the "Low VTI" parameter alert.
  static const _volumeLow = MonitoringAlert(priority: 2, alertLabel: "Low VTI");

  /// Represents the "High minuteVol" parameter alert.
  static const _minuteVolumeHigh =
  MonitoringAlert(priority: 2, alertLabel: "High minuteVol");

  /// Represents the "Low minuteVol" parameter alert.
  static const _minuteVolumeLow =
  MonitoringAlert(priority: 2, alertLabel: "Low minuteVol");

  /// Represents the "High FiO₂" parameter alert.
  static const _fioHigh = MonitoringAlert(priority: 2, alertLabel: "High FiO₂");

  /// Represents the "Low FiO₂" parameter alert.
  static const _fioLow = MonitoringAlert(priority: 2, alertLabel: "Low FiO₂");

  /// Represents the "High flow" parameter alert.
  static const _flowHigh = MonitoringAlert(priority: 1, alertLabel: "High flow");

  /// Represents the "Low flow" parameter alert.
  static const _flowLow = MonitoringAlert(priority: 1, alertLabel: "Low flow");

  /// Represents the "High Pulse" parameter alert.
  static const _pulseHigh = MonitoringAlert(priority: 2, alertLabel: "High Pulse");

  /// Represents the "Low Pulse" parameter alert.
  static const _pulseLow = MonitoringAlert(priority: 4, alertLabel: "Low Pulse");

  /// Represents the "High RR" parameter alert.
  static const _rrHigh = MonitoringAlert(priority: 2, alertLabel: "High RR");

  /// Represents the "Low RR" parameter alert.
  static const _rrLow = MonitoringAlert(priority: 4, alertLabel: "Low RR");

  /// Reserved alert

  /// Represents a reserved alert.
  static const _reserved = MonitoringAlert(priority: 0, alertLabel: "");

  /// A list of all available alerts.
  static const monitoringAlerts = [
    /// Byte-1
    _nebulizerOff,
    _nebulizerOn,
    _flowSensorConnectionError,
    _patientCircuitDisconnected,
    _oxygenSupplyFailed,
    _batteryDrain,
    _pluggedIn,
    _onBattery,

    /// Byte-2
    _reserved,
    _reserved,
    _reserved,
    _reserved,
    _leak,
    _pressureLimitation,
    _lowSpO,
    _apnea,

    /// Byte-3
    _minuteVolumeLow,
    _minuteVolumeHigh,
    _volumeLow,
    _volumeHigh,
    _peepLow,
    _peepHigh,
    _pipLow,
    _pipHigh,

    /// Byte-4
    _rrLow,
    _rrHigh,
    _pulseLow,
    _pulseHigh,
    _flowLow,
    _flowHigh,
    _fioLow,
    _fioHigh,
  ];
}