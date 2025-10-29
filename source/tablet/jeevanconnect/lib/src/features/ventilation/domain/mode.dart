import 'parameter.dart';

class Mode {
  String modeName;
  int modeId;
  List<Parameter> parameters;
  List<double> defaultValues;
  List<(Parameter, String, bool)> displayCardParameters;
  bool hasBackupModeSupport;
  Mode? backupMode;

  Mode(
      {required this.modeName,
      required this.modeId,
      required this.parameters,
      required this.defaultValues,
      required this.hasBackupModeSupport,
      required this.displayCardParameters,
      this.backupMode});

  @override
  bool operator ==(Object other) {
    return other is Mode &&
        other.runtimeType == runtimeType &&
        other.modeName == modeName &&
        other.modeId == modeId;
  }

  @override
  int get hashCode => Object.hash(runtimeType, modeName, modeId);

  @override
  String toString() => "$modeName - $modeId";
}
