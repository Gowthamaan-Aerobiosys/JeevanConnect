import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import '../../../config/data/urls.dart';
import '../../../exception/exception.dart'
    show AuthenticationException, AppException;
import '../../../packages/pagenated_table/src/paginated_list.dart';
import '../domain/session.dart';
import '../domain/user.dart';
import 'user_socket_manager.dart';

class AuthenticationRepository {
  static User? _user;
  static bool _isSignedIn = false;
  static final Map<String, String> _headers = {
    'content-type': 'application/json'
  };

  init() {
    _isSignedIn = false;
    return;
  }

  Future<void> validateSession() async {
    try {
      final response = await http.get(
        AppUrls.validateSession,
      );
      await _handleValidateSessionResponse(response);
    } catch (exception) {
      _isSignedIn = false;
      rethrow;
    }
  }

  Future<bool> signup({required userData}) async {
    try {
      final response = await http.post(
        AppUrls.signup,
        body: userData,
      );
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return _handleSignupResponse(getResponse);
      }
      return _handleSignupResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future<bool> signin({required String email, required String password}) async {
    final response = await http.post(
      AppUrls.signin,
      body: _cleanBodyData(email, password),
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return await _handleSigninResponse(getResponse);
    }
    return await _handleSigninResponse(response);
  }

  Future<bool> signout() async {
    final response = await http.post(
      AppUrls.signout,
      body: _cleanBodyData(_user!.email, ""),
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleSignoutResponse(getResponse);
    }
    return _handleSignoutResponse(response);
  }

  Future<bool> updateUser({required userData}) async {
    final response = await http.post(
      AppUrls.updateUser,
      body: userData,
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return await _handleUpdateResponse(getResponse);
    }
    return await _handleUpdateResponse(response);
  }

  Future<bool> getUserData() async {
    final response = await http.post(
      AppUrls.getUser,
      body: _cleanBodyData(_user!.userId, ""),
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleGetDataResponse(getResponse);
    }
    return _handleGetDataResponse(response);
  }

  Future<bool> addContact(data) async {
    final response = await http.post(
      AppUrls.addContact,
      body: data,
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleGeneralResponse(getResponse);
    }
    return _handleGeneralResponse(response);
  }

  Future<bool> resetPassword({required String email}) async {
    final response = await http.post(
      AppUrls.resetPassword,
      body: _cleanBodyData(email, ""),
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleResetPasswordResponse(getResponse);
    }
    return _handleResetPasswordResponse(response);
  }

  Future<bool> closeAccount(password) async {
    final response = await http.post(
      AppUrls.archiveUser,
      body: _cleanBodyData(_user!.email, password),
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleArchiveResponse(getResponse);
    }
    return _handleArchiveResponse(response);
  }

  Future<PaginatedList<Session>> getSessions() async {
    try {
      final response = await http.get(
        AppUrls.getSessions(AuthenticationRepository().currentUser.userId),
      );
      final result = (convert.jsonDecode(response.body))['DATA'];
      final List<Session> sessions =
          result.map((json) => Session.fromJson(json)).toList().cast<Session>();
      return PaginatedList(items: sessions, nextPageToken: "Sessions");
    } catch (exception) {
      rethrow;
    }
  }

  _handleSigninResponse(http.Response response) async {
    if (response.statusCode == 200) {
      var result = convert.jsonDecode(response.body);
      _user = User.fromJson(result['DATA']);
      _isSignedIn = true;
      return await UserSocketManager().init();
    } else {
      _isSignedIn = false;
      switch (response.statusCode) {
        case 400:
          throw AuthenticationException.invalidCredentials;
        case 401:
          throw AuthenticationException.confirmUser;
        case 404:
          throw AuthenticationException.userNotFound;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleGetDataResponse(http.Response response) {
    if (response.statusCode == 200) {
      var result = convert.jsonDecode(response.body);
      _user = User.update(result['DATA'], _user);
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

  _handleSignoutResponse(http.Response response) {
    if (response.statusCode == 200) {
      _isSignedIn = false;
      UserSocketManager().disconnect();
      return true;
    } else {
      throw AppException.serverError;
    }
  }

  _handleArchiveResponse(http.Response response) {
    if (response.statusCode == 200) {
      _isSignedIn = false;
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

  _handleSignupResponse(http.Response response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw AuthenticationException.userAlreadyExists;
        case 503:
          throw AppException.serviceUnavailable;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleUpdateResponse(http.Response response) async {
    if (response.statusCode == 200) {
      return await getUserData();
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

  _handleValidateSessionResponse(http.Response response) async {
    if (response.statusCode == 200) {
      return await UserSocketManager().init();
    } else {
      switch (response.statusCode) {
        case 403:
          _isSignedIn = false;
          break;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleResetPasswordResponse(http.Response response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw AuthenticationException.userNotFound;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleGeneralResponse(http.Response response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      throw AppException.serverError;
    }
  }

  _cleanBodyData(email, data, {String key = 'password'}) =>
      {"email": email.trim(), key: data.trim()};

  bool get isSignedIn => _isSignedIn;
  bool get isAdminUser => _user!.isAdmin;
  Map<String, String> get headers => _headers;
  User get currentUser => _user!;
}
