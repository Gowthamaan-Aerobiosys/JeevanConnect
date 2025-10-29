class WorkspaceStatus {
  int activeDevices;
  int patientsUnderVentilation;
  int treatedPatients;
  int offlineDevices;
  int idleDevices;
  int repairDevices;
  int departmentCount;
  Map departmentWiseDevices;
  List<String> departments;
  int activeUsers;
  int totalUsers;
  int activePatients;

  WorkspaceStatus({
    required this.activeDevices,
    required this.patientsUnderVentilation,
    required this.treatedPatients,
    required this.offlineDevices,
    required this.idleDevices,
    required this.repairDevices,
    required this.departmentCount,
    required this.departments,
    required this.departmentWiseDevices,
    required this.totalUsers,
    required this.activeUsers,
    required this.activePatients,
  });

  factory WorkspaceStatus.fromJson(dynamic json) {
    return WorkspaceStatus(
        activeDevices: json["active_devices"],
        patientsUnderVentilation: json["patients_under_ventilation"],
        treatedPatients: json["treated_patients"],
        offlineDevices: json["offline_devices"],
        idleDevices: json["idle_devices"],
        repairDevices: json["repair_devices"],
        departmentCount: json["department_count"],
        departments: json["departments"].cast<String>(),
        departmentWiseDevices: json["department_wise_devices"],
        activeUsers: json["active_users"],
        totalUsers: json["total_users"],
        activePatients: json["active_patients"]);
  }
}
