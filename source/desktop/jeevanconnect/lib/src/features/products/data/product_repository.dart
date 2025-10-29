import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../../../config/data/urls.dart';
import '../../../exception/exception.dart';

import '../../../packages/pagenated_table/src/paginated_list.dart';
import '../../authentication/authentication.dart' show AuthenticationRepository;
import '../domain/product.dart';
import '../domain/service_log.dart';
import '../domain/service_ticket.dart';
import '../domain/ventilator_session.dart';

class ProductRepository {
  static Product? _product;

  init() {}

  Future<bool> registerProduct({required productData}) async {
    try {
      final response =
          await http.post(AppUrls.registerProduct, body: productData);
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return _handleRegisterProductResponse(getResponse);
      }
      return _handleRegisterProductResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future<PaginatedList<Product>> getProducts() async {
    try {
      final response = await http.get(AppUrls.getProducts,
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];
      final List<Product> products =
          result.map((json) => Product.fromJson(json)).toList().cast<Product>();
      return Future.value(
          PaginatedList(items: products, nextPageToken: 'Ventilators'));
    } catch (exception) {
      rethrow;
    }
  }

  Future getProductData() async {
    final response = await http.post(
      AppUrls.getProduct,
      body: {"serial_number": _product!.serialNumber},
      headers: AuthenticationRepository().headers,
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleGetProductDataResponse(getResponse);
    }
    return _handleGetProductDataResponse(response);
  }

  Future<PaginatedList<Product>> getWorkspaceProducts(workspaceId) async {
    try {
      final response = await http.get(AppUrls.getWorkspaceProducts(workspaceId),
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];

      final List<Product> products =
          result.map((json) => Product.fromJson(json)).toList().cast<Product>();
      return Future.value(PaginatedList(
          items: products, nextPageToken: 'Ventilators'));
    } catch (exception) {
      rethrow;
    }
  }

  Future<PaginatedList<VentilatorSession>> getVentilatorSession() async {
    try {
      final response = await http.post(AppUrls.getMonitoringSessions,
          body: {'serial_number': _product!.serialNumber},
          headers: AuthenticationRepository().headers);
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

  Future<PaginatedList<ServiceTicket>> getServiceTickets() async {
    try {
      final response = await http.post(AppUrls.getServiceTickets,
          body: {'serial_number': _product!.serialNumber},
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];
      final List<ServiceTicket> serviceTickets = result
          .map((json) => ServiceTicket.fromJson(json))
          .toList()
          .cast<ServiceTicket>();
      return Future.value(PaginatedList(
          items: serviceTickets, nextPageToken: 'Service Tickets'));
    } catch (exception) {
      rethrow;
    }
  }

  Future editDepartment(data) async {
    try {
      final response = await http.post(
        AppUrls.editDepartment,
        body: data,
        headers: AuthenticationRepository().headers,
      );
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return await _handleEditDepartmentResponse(getResponse);
      }
      return await _handleEditDepartmentResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future<PaginatedList<ServiceLog>> getServiceLog(ticketId) async {
    try {
      final response = await http.get(AppUrls.getServiceTicketLog(ticketId),
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];
      final List<ServiceLog> logs = result
          .map((json) => ServiceLog.fromJson(json))
          .toList()
          .cast<ServiceLog>();
      return PaginatedList(items: logs, nextPageToken: "Service Logs");
    } catch (exception) {
      rethrow;
    }
  }

  Future getProductSessionAnalytics(year) async {
    final response = await http.post(
      AppUrls.getProductSessionAnalytics,
      body: {"serial_number": _product!.serialNumber, "year": year.toString()},
      headers: AuthenticationRepository().headers,
    );
    final result = (convert.jsonDecode(response.body))['DATA'];

    return result;
  }

  _handleRegisterProductResponse(response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw ProductException.productAlreadyExists;
        case 404:
          throw WorkspaceException.workspaceNotFound;
        case 503:
          throw AppException.serviceUnavailable;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleGetProductDataResponse(http.Response response) async {
    if (response.statusCode == 200) {
      var result = convert.jsonDecode(response.body);
      _product = Product.fromJson(result['DATA']);
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

  _handleEditDepartmentResponse(response) async {
    if (response.statusCode == 200) {
      return await getProductData();
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

  set currentProduct(product) => _product = product;
  Product get currentProduct => _product!;
}
