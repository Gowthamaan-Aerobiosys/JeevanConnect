import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../../../config/data/urls.dart';
import '../../../exception/exception.dart';
import '../../authentication/authentication.dart' show AuthenticationRepository;
import '../../products/products.dart' show ProductRepository;

class MonitoringRepository {
  static Uri? ventilatorSocketUrl;

  Future initMontoring() async {
    final response = await http.post(
      AppUrls.initMonitoringStream,
      body: {"serial_number": ProductRepository().currentProduct.serialNumber},
      headers: AuthenticationRepository().headers,
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleStartMonitoringResponse(getResponse);
    }
    return _handleStartMonitoringResponse(response);
  }

  Future requestMonitoringLog(sessionId) async {
    final response = await http.post(
      AppUrls.requestMonitoringLog,
      body: {
        "serial_number": ProductRepository().currentProduct.serialNumber,
        "session_id": sessionId
      },
      headers: AuthenticationRepository().headers,
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleRequestLogResponse(getResponse);
    }
    return _handleRequestLogResponse(response);
  }

  Future getMonitoringLog(sessionId, logType) async {
    final response = await http.get(
      AppUrls.getMonitoringLog(sessionId, logType),
      headers: AuthenticationRepository().headers,
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleGetMonitoringLogResponse(getResponse);
    }
    return _handleGetMonitoringLogResponse(response);
  }

  _handleGetMonitoringLogResponse(http.Response response) async {
    if (response.statusCode == 200) {
      var result = convert.jsonDecode(response.body)["DATA"];
      return result;
    } else {
      return [];
    }
  }

  _handleStartMonitoringResponse(http.Response response) async {
    if (response.statusCode == 200) {
      var result = convert.jsonDecode(response.body)['DATA'];
      ventilatorSocketUrl = AppUrls.venSocket(
          AuthenticationRepository().currentUser.userId,
          result["serial_number"],
          result["key"]);
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw ProductException.productAlreadyExists;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleRequestLogResponse(http.Response response) async {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw ProductException.productAlreadyExists;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }
}
