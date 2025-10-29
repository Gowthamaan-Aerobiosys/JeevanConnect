import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../../../config/data/urls.dart';
import '../../../exception/exception.dart'
    show AppException, WorkspaceException, AuthenticationException;
import '../../../packages/pagenated_table/src/paginated_list.dart';
import '../../authentication/authentication.dart'
    show AuthenticationRepository, User;
import '../../products/products.dart' show VentilatorSession;
import '../domain/workspace.dart';
import '../domain/workspace_announcement.dart';
import '../domain/workspace_moderation.dart';
import '../domain/workspace_status.dart';

class WorkspaceRepository {
  static Workspace? _workspace;
  static WorkspaceModeration? _workspaceModeration;
  static WorkspaceStatus? _workspaceStatus;

  init() {}

  Future createWorkspace({required workspaceData}) async {
    try {
      final response = await http.post(AppUrls.createWorkspace,
          body: workspaceData, headers: AuthenticationRepository().headers);
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return _handleCreateWorkspaceResponse(getResponse);
      }
      return _handleCreateWorkspaceResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future updateWorkspace({required workspaceData}) async {
    try {
      final response = await http.post(AppUrls.updateWorkspace,
          body: workspaceData, headers: AuthenticationRepository().headers);
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return await _handleUpdateWorkspaceResponse(getResponse);
      }
      return await _handleUpdateWorkspaceResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future<bool> inviteUser({required userEmail, required workspaceId}) async {
    try {
      final response = await http.post(AppUrls.inviteUser,
          body: {
            'admin': AuthenticationRepository().currentUser.userId,
            'user': userEmail,
            'workspace': workspaceId
          },
          headers: AuthenticationRepository().headers);
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return _handleInviteUserResponse(getResponse);
      }
      return _handleInviteUserResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future<bool> updateUserRole(
      {required userId, required workspaceId, required role}) async {
    try {
      final response = await http.post(AppUrls.updateUserRole,
          body: {
            'admin': AuthenticationRepository().currentUser.userId,
            'user': userId,
            'workspace': workspaceId,
            'role': role
          },
          headers: AuthenticationRepository().headers);
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return _handleInviteUserResponse(getResponse);
      }
      return _handleInviteUserResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future<bool> removeUser({required userId, required workspaceId}) async {
    try {
      final response = await http.post(AppUrls.removeUser,
          body: {
            'admin': AuthenticationRepository().currentUser.userId,
            'user': userId,
            'workspace': workspaceId
          },
          headers: AuthenticationRepository().headers);
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return _handleRemoveUserResponse(getResponse);
      }
      return _handleRemoveUserResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future<bool> exitWorkspace(
      {required workspaceId, String? defaultUser}) async {
    try {
      final response = await http.post(AppUrls.exitWorkspace,
          body: {
            'user': AuthenticationRepository().currentUser.userId,
            'workspace': workspaceId,
            if (defaultUser != null) 'default': defaultUser
          },
          headers: AuthenticationRepository().headers);
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return _handleRemoveUserResponse(getResponse);
      }
      return _handleRemoveUserResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future<bool> closeWorkspace(password) async {
    final response = await http.post(AppUrls.archiveWorkspace,
        body: {
          'user': AuthenticationRepository().currentUser.userId,
          'workspace': _workspace!.workspaceId,
          'password': password
        },
        headers: AuthenticationRepository().headers);
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleArchiveWorkspaceResponse(getResponse);
    }
    return _handleArchiveWorkspaceResponse(response);
  }

  Future getWorkspaceData() async {
    final response = await http.post(AppUrls.getWorkspace,
        body: {"workspace_id": _workspace!.workspaceId},
        headers: AuthenticationRepository().headers);
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleGetWorkspaceDataResponse(getResponse);
    }
    return _handleGetWorkspaceDataResponse(response);
  }

  Future<PaginatedList<Workspace>> getWorkspaces() async {
    try {
      final response = await http.get(AppUrls.getWorkspaces(
          AuthenticationRepository().currentUser.registeredId));
      final result = (convert.jsonDecode(response.body))['DATA'];
      final List<Workspace> workspaces = result
          .map((json) => Workspace.fromJson(json))
          .toList()
          .cast<Workspace>();
      return PaginatedList(
          items: workspaces.reversed.toList(), nextPageToken: "Workspaces");
    } catch (exception) {
      rethrow;
    }
  }

  Future<(PaginatedList<(dynamic, dynamic)>, dynamic)> getUsers(
      workspaceId) async {
    try {
      final response = await http.get(
        AppUrls.getUsers(workspaceId),
      );
      final result = (convert.jsonDecode(response.body))['DATA'];
      final users = result['users']
          .map((json) => User.fromJson(json))
          .toList()
          .cast<User>();
      final admins = result['admins']
          .map((json) => User.fromJson(json))
          .toList()
          .cast<User>();
      final adminValidation =
          users.map((user) => admins.contains(user)).toList();
      final userList =
          List.generate(users.length, (i) => (users[i], adminValidation[i]))
              .reversed
              .toList();
      return (PaginatedList(items: userList, nextPageToken: "Users"), users);
    } catch (exception) {
      rethrow;
    }
  }

  Future<List<User>> getWorkspaceUsers(workspaceId) async {
    try {
      final response = await http.get(
        AppUrls.getUsers(workspaceId),
      );
      final result = (convert.jsonDecode(response.body))['DATA'];
      final users = result['users']
          .map((json) => User.fromJson(json))
          .toList()
          .cast<User>();
      return users;
    } catch (exception) {
      rethrow;
    }
  }

  Future<PaginatedList<dynamic>> getDepartments() async {
    try {
      final response = await http.get(
        AppUrls.getDepartments(_workspace!.workspaceId),
      );
      final result = (convert.jsonDecode(response.body))['DATA'];
      final departments = result
          .map((department) => (
                department,
                _workspaceStatus!.departmentWiseDevices[department]
                        ?.toString() ??
                    "0",
                "-"
              ))
          .toList();
      return PaginatedList(items: departments, nextPageToken: "Departments");
    } catch (exception) {
      rethrow;
    }
  }

  Future<bool> addDepartments(departments) async {
    final response = await http.post(AppUrls.addDepartments,
        body: {
          "workspace": _workspace!.workspaceId,
          "department": departments,
        },
        headers: AuthenticationRepository().headers);
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleDepartmentRemoveResponse(getResponse);
    }
    return _handleDepartmentRemoveResponse(response);
  }

  Future<bool> removeDepartments(departments) async {
    final response = await http.post(AppUrls.removeDepartments,
        body: {
          "workspace": _workspace!.workspaceId,
          "department": departments,
        },
        headers: AuthenticationRepository().headers);
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleDepartmentRemoveResponse(getResponse);
    }
    return _handleDepartmentRemoveResponse(response);
  }

  Future<bool> getModerations() async {
    final response = await http.get(
      AppUrls.getModerations(_workspace!.workspaceId),
    );
    final result = (convert.jsonDecode(response.body))['DATA'];
    _workspaceModeration = WorkspaceModeration.fromJson(result);
    return true;
  }

  Future<bool> editModerations(moderationsData) async {
    final response = await http.post(AppUrls.editModerations,
        body: moderationsData, headers: AuthenticationRepository().headers);
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleEditModerationsResponse(getResponse);
    }
    return _handleEditModerationsResponse(response);
  }

  Future<bool> getWorkspaceAnalytics() async {
    final response = await http.get(
      AppUrls.getWorkspaceAnalytics(_workspace!.workspaceId),
    );
    final result = (convert.jsonDecode(response.body))['DATA'];
    _workspaceStatus = WorkspaceStatus.fromJson(result);
    return true;
  }

  Future getWorkspaceSessionAnalytics(year) async {
    final response = await http.get(
      AppUrls.getWorkspaceSessionAnalytics(_workspace!.workspaceId, year),
    );
    final result = (convert.jsonDecode(response.body))['DATA'];

    return result;
  }

  Future<PaginatedList<VentilatorSession>> getActiveWorkspaceSessions() async {
    try {
      final response = await http.get(
        AppUrls.getActiveWorkspaceSessions(_workspace!.workspaceId),
      );
      final result = (convert.jsonDecode(response.body))['DATA'];

      final List<VentilatorSession> ventilatorSessions = result
          .map((json) => VentilatorSession.fromJson(json))
          .toList()
          .cast<VentilatorSession>();
      return Future.value(PaginatedList(
          items: ventilatorSessions, nextPageToken: 'Ventilators sessions'));
    } catch (exception) {
      rethrow;
    }
  }

  Future getStatistics(section) async {
    final response = await http.get(
      AppUrls.getWorkspaceStatistics(_workspace!.workspaceId, section),
    );
    final result = (convert.jsonDecode(response.body))['DATA'];
    return result;
  }

  Future<PaginatedList<WorkspaceAnnouncement>> getAnnouncements() async {
    try {
      final response = await http.get(
        AppUrls.getAnnouncements(_workspace!.workspaceId),
      );
      final result = (convert.jsonDecode(response.body))['DATA'];
      final List<WorkspaceAnnouncement> announcements = result
          .map((json) => WorkspaceAnnouncement.fromJson(json))
          .toList()
          .cast<WorkspaceAnnouncement>();
      return PaginatedList(
          items: announcements, nextPageToken: "Workspace Announcements");
    } catch (exception) {
      rethrow;
    }
  }

  Future<bool> addAnnouncement(announcement) async {
    final response = await http.post(AppUrls.addAnnouncement,
        body: {
          "workspace_id": _workspace!.workspaceId,
          "content": announcement,
        },
        headers: AuthenticationRepository().headers);
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleAddAnnouncementResponse(getResponse);
    }
    return _handleAddAnnouncementResponse(response);
  }

  Future<bool> removeAnnouncements(indices) async {
    final response = await http.post(AppUrls.removeAnnouncement,
        body: {
          "workspace_id": _workspace!.workspaceId,
          "indices": indices,
        },
        headers: AuthenticationRepository().headers);
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleDepartmentRemoveResponse(getResponse);
    }
    return _handleDepartmentRemoveResponse(response);
  }

  _handleCreateWorkspaceResponse(response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw WorkspaceException.workspaceAlreadyExists;
        case 503:
          throw AppException.serviceUnavailable;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleUpdateWorkspaceResponse(http.Response response) async {
    if (response.statusCode == 200) {
      return await getWorkspaceData();
    } else {
      switch (response.statusCode) {
        case 403:
          throw AppException.permissionDenied;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleArchiveWorkspaceResponse(http.Response response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw AuthenticationException.invalidCredentials;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleInviteUserResponse(response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw AppException.noJeevanAccountExists;
        case 409:
          throw AppException.permissionDenied;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleDepartmentRemoveResponse(response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw WorkspaceException.workspaceNotFound;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleAddAnnouncementResponse(response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw WorkspaceException.workspaceNotFound;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleEditModerationsResponse(response) {
    if (response.statusCode == 200) {
      final result = (convert.jsonDecode(response.body))['DATA'];
      _workspaceModeration = WorkspaceModeration.fromJson(result);
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw WorkspaceException.workspaceNotFound;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleRemoveUserResponse(response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 409:
          final info = (convert.jsonDecode(response.body))['INFO'];
          if (info.contains('Default')) {
            throw WorkspaceException.defaultUser;
          } else if (info.contains('permissions')) {
            throw AppException.permissionDenied;
          } else {
            throw WorkspaceException.userNotFoundInWorkspace;
          }
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleGetWorkspaceDataResponse(http.Response response) async {
    if (response.statusCode == 200) {
      var result = convert.jsonDecode(response.body);
      _workspace = Workspace.update(result['DATA'], _workspace);
      return true;
    } else {
      switch (response.statusCode) {
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  set currentWorkspace(workspace) => _workspace = workspace;
  Workspace get currentWorkspace => _workspace!;
  WorkspaceModeration get currentModeration => _workspaceModeration!;
  WorkspaceStatus? get currentAnalytics => _workspaceStatus;
}
