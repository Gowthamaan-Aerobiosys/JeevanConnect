class AppUrls {
  static String _ip = "192.168.246.246";

  setIp(ip) {
    _ip = ip;
  }

  static final aerobiosys = Uri.parse("https://www.aerobiosys.com/");
  static final ventilator = Uri.parse("https://www.aerobiosys.com/jevaan-lite");

  static final privacyPolicy = Uri.parse(
      "https://github.com/aerobiosys-sde/Jeevan-ventilators/wiki/Privacy-policy");
  static final updatePolicy = Uri.parse(
      "https://github.com/aerobiosys-sde/Jeevan-ventilators/wiki/Update-policy");
  static final emcTestReport = Uri.parse(
      "https://drive.google.com/file/d/1wzZwy-4U4wByVM5Y835SF8rQr8zSlHm2/view?usp=sharing");
  static final quickGuide = Uri.parse(
      "https://drive.google.com/file/d/1ynmg0bTFx92P_x7nKXkCjxHKS9q6GYHX/view?usp=sharing");

  ///API

  /// Domain
  static final domain = "http://$_ip:80";
  static final socketDomain = "ws://$_ip:80";

  /// Sockets
  static userSocket(userId, sessionId) =>
      "$socketDomain/ws/user/$userId/$sessionId/";
  static venSocket(userId, serialNumber, key) =>
      Uri.parse("$socketDomain/ws/ven/$userId/$serialNumber/$key/");

  /// Accounts
  static final signup = Uri.parse("$domain/api/accounts/auth/signup/");
  static final signin = Uri.parse("$domain/api/accounts/auth/signin/");
  static final signout = Uri.parse("$domain/api/accounts/auth/signout/");
  static final archiveUser =
      Uri.parse("$domain/api/accounts/auth/user/archive/");
  static final validateSession =
      Uri.parse("$domain/api/accounts/auth/validate/");
  static final resetPassword =
      Uri.parse("$domain/api/accounts/auth/password/reset/");
  static final updateUser = Uri.parse("$domain/api/accounts/auth/user/update/");
  static final getUser = Uri.parse("$domain/api/accounts/auth/user/get/");
  static final addContact =
      Uri.parse("$domain/api/accounts/auth/user/contact/add/");
  static getSessions(userId) =>
      Uri.parse("$domain/api/accounts/$userId/sessions/");

  /// Workspaces
  static final createWorkspace =
      Uri.parse("$domain/api/accounts/workspace/create/");
  static final archiveWorkspace =
      Uri.parse("$domain/api/accounts/workspace/archive/");
  static final updateWorkspace =
      Uri.parse("$domain/api/accounts/workspace/update/");
  static final getWorkspace = Uri.parse("$domain/api/accounts/workspace/get/");
  static getWorkspaces(registeredId) =>
      Uri.parse("$domain/api/accounts/$registeredId/workspaces/");
  static getUsers(workspaceId) =>
      Uri.parse("$domain/api/accounts/$workspaceId/users/");
  static final inviteUser =
      Uri.parse("$domain/api/accounts/workspace/user/invite/");
  static final updateUserRole =
      Uri.parse("$domain/api/accounts/workspace/user/update-role/");
  static final removeUser =
      Uri.parse("$domain/api/accounts/workspace/user/remove/");
  static final exitWorkspace =
      Uri.parse("$domain/api/accounts/workspace/user/exit/");
  static getDepartments(workspaceId) =>
      Uri.parse("$domain/api/accounts/workspace/departments/$workspaceId/");
  static final addDepartments =
      Uri.parse("$domain/api/accounts/workspace/departments/add/");
  static final removeDepartments =
      Uri.parse("$domain/api/accounts/workspace/departments/remove/");
  static getModerations(workspaceId) =>
      Uri.parse("$domain/api/accounts/workspace/permissions/$workspaceId/");
  static final editModerations =
      Uri.parse("$domain/api/accounts/workspace/permissions/edit/");
  static final addAnnouncement =
      Uri.parse("$domain/api/accounts/workspace/announcement/create/");
  static final removeAnnouncement =
      Uri.parse("$domain/api/accounts/workspace/announcement/remove/");
  static getAnnouncements(workspaceId) =>
      Uri.parse("$domain/api/accounts/workspace/announcement/$workspaceId/");

  /// Products
  static final registerProduct =
      Uri.parse("$domain/api/products/ven/register/");
  static final getProducts = Uri.parse("$domain/api/products/ven/get_all/");
  static final getProduct = Uri.parse("$domain/api/products/ven/get/");
  static getWorkspaceProducts(workspaceName) =>
      Uri.parse("$domain/api/products/ven/$workspaceName/get/");
  static final editDepartment =
      Uri.parse("$domain/api/products/ven/department/edit/");

  /// Patients
  static final registerPatient = Uri.parse("$domain/api/patients/register/");
  static final getPatients = Uri.parse("$domain/api/patients/get/");
  static final getAdmissionRecords = Uri.parse("$domain/api/patients/amr/get/");
  static final createAdmissionRecord =
      Uri.parse("$domain/api/patients/amr/create/");
  static final removeAdmissionRecords =
      Uri.parse("$domain/api/patients/amr/remove/");
  static getClinicalLog(id) =>
      Uri.parse("$domain/api/patients/amr/logs/get/$id/");
  static final addClinicalLog = Uri.parse("$domain/api/patients/amr/logs/add/");
  static final removeClinicalLog =
      Uri.parse("$domain/api/patients/amr/logs/remove/");
  static getABGLog(id) => Uri.parse("$domain/api/patients/amr/abg/get/$id/");
  static getABGLogGraph(id) =>
      Uri.parse("$domain/api/patients/amr/abg/get/graph/$id/");
  static final addABGLog = Uri.parse("$domain/api/patients/amr/abg/add/");
  static final removeABGLog = Uri.parse("$domain/api/patients/amr/abg/remove/");
  static getWorkspacePatients(workspaceName) =>
      Uri.parse("$domain/api/patients/$workspaceName/get/");

  /// Sessions
  static final getMonitoringSessions =
      Uri.parse("$domain/api/jvsync/monitoring/sessions/get/");
  static final getPatientSessions =
      Uri.parse("$domain/api/jvsync/monitoring/sessions/patient/");
  static getActiveWorkspaceSessions(workspaceId) =>
      Uri.parse("$domain/api/jvsync/monitoring/sessions/active/$workspaceId/");
  static final initMonitoringStream =
      Uri.parse("$domain/api/jvsync/monitoring/sessions/stream/start/");
  static final killMonitoringStream =
      Uri.parse("$domain/api/jvsync/monitoring/sessions/stream/stop/");
  static final requestMonitoringLog =
      Uri.parse("$domain/api/jvsync/monitoring/sessions/log/request/");
  static getMonitoringLog(sessionId, logType) => Uri.parse(
      "$domain/api/jvsync/monitoring/sessions/log/get/$sessionId/$logType/");

  /// Service Ticket
  static final getServiceTickets =
      Uri.parse("$domain/api/products/ven/service/get_ticket/");
  static getServiceTicketLog(ticketId) =>
      Uri.parse("$domain/api/products/ven/service/$ticketId/logs/");

  /// Chat
  static getConversations(userId) =>
      Uri.parse("$domain/api/messaging/conversation/get/$userId/");
  static getMessages(conversationId) =>
      Uri.parse("$domain/api/messaging/$conversationId/messages/");
  static final sendMessage = Uri.parse("$domain/api/messaging/send/message/");
  static final createConversation =
      Uri.parse("$domain/api/messaging/conversation/create/");

  /// Analytics
  static getWorkspaceAnalytics(workspaceId) =>
      Uri.parse("$domain/api/analytics/workspace/$workspaceId/");
  static getWorkspaceSessionAnalytics(workspaceId, year) =>
      Uri.parse("$domain/api/analytics/workspace/sessions/$workspaceId/$year/");
  static getWorkspaceStatistics(workspaceId, section) =>
      Uri.parse("$domain/api/analytics/workspace/$section/$workspaceId/");
  static final getProductSessionAnalytics =
      Uri.parse("$domain/api/analytics/workspace/sessions/device/");
}
