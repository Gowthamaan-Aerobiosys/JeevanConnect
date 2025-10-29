class MonitoringAlert {
  final int priority;
  final String alertLabel;
  const MonitoringAlert({required this.priority, required this.alertLabel});

  @override
  bool operator ==(Object other) {
    return other is MonitoringAlert &&
        other.runtimeType == runtimeType &&
        other.priority == priority &&
        other.alertLabel == alertLabel;
  }

  @override
  int get hashCode => Object.hash(runtimeType, priority, alertLabel);

  @override
  String toString() => "Alert: $alertLabel - Priority $priority";
}