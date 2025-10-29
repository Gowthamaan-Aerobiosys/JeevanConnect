import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../../../config/data/urls.dart';
import '../../../exception/exception.dart';

import '../../../packages/pagenated_table/src/paginated_list.dart';
import '../../authentication/authentication.dart' show AuthenticationRepository;
import '../../products/products.dart' show VentilatorSession;
import '../../workspace/workspace.dart' show WorkspaceRepository;
import '../domain/abg.dart';
import '../domain/admission_record.dart';
import '../domain/clinical_log.dart';
import '../domain/patient.dart';

class PatientRepository {
  static Patient? _patient;

  init() {}

  Future<bool> registerPatient({required patientData}) async {
    try {
      final response = await http.post(AppUrls.registerPatient,
          body: patientData, headers: AuthenticationRepository().headers);
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return _handleRegisterPatientResponse(getResponse);
      }
      return _handleRegisterPatientResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future<PaginatedList<Patient>> getPatients() async {
    try {
      final response = await http.get(AppUrls.getPatients,
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];
      final List<Patient> patients =
          result.map((json) => Patient.fromJson(json)).toList().cast<Patient>();
      return Future.value(
          PaginatedList(items: patients, nextPageToken: 'Patients'));
    } catch (exception) {
      rethrow;
    }
  }

  Future<PaginatedList<Patient>> getWorkspacePatients() async {
    try {
      final response = await http.get(
          AppUrls.getWorkspacePatients(
              WorkspaceRepository().currentWorkspace.workspaceId),
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];
      final List<Patient> patients =
          result.map((json) => Patient.fromJson(json)).toList().cast<Patient>();
      return Future.value(
          PaginatedList(items: patients, nextPageToken: 'Patients'));
    } catch (exception) {
      rethrow;
    }
  }

  Future<PaginatedList<VentilatorSession>> getPatientSession() async {
    try {
      final response = await http.post(AppUrls.getPatientSessions,
          body: {'patient_id': _patient!.patientId},
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];

      final List<VentilatorSession> ventilatorSessions = result
          .map((json) => VentilatorSession.fromJson(json))
          .toList()
          .cast<VentilatorSession>();
      return Future.value(PaginatedList(
          items: ventilatorSessions, nextPageToken: 'Patient sessions'));
    } catch (exception) {
      rethrow;
    }
  }

  Future<PaginatedList<AdmissionRecord>> getAdmissionRecords() async {
    try {
      final response = await http.post(AppUrls.getAdmissionRecords,
          body: {'patient_id': _patient!.patientId},
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];

      final List<AdmissionRecord> records = result
          .map((json) => AdmissionRecord.fromJson(json))
          .toList()
          .cast<AdmissionRecord>();
      return Future.value(
          PaginatedList(items: records, nextPageToken: 'Admission records'));
    } catch (exception) {
      rethrow;
    }
  }

  Future<bool> addAdmissionRecord({required record}) async {
    try {
      final response = await http.post(AppUrls.createAdmissionRecord,
          body: record, headers: AuthenticationRepository().headers);
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return _handleAddAMRResponse(getResponse);
      }
      return _handleAddAMRResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future<PaginatedList<Clinicallog>> getClinicalLog(recordId) async {
    try {
      final response = await http.get(AppUrls.getClinicalLog(recordId),
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];
      final List<Clinicallog> logs = result
          .map((json) => Clinicallog.fromJson(json))
          .toList()
          .cast<Clinicallog>();
      return PaginatedList(items: logs, nextPageToken: "Clinical Logs");
    } catch (exception) {
      rethrow;
    }
  }

  Future<bool> addClinicalLog(log, id, addedBy) async {
    final response = await http.post(
      AppUrls.addClinicalLog,
      body: {
        "amr_id": id,
        "content": log,
        "added_by": addedBy,
      },
      headers: AuthenticationRepository().headers,
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleLogResponse(getResponse);
    }
    return _handleLogResponse(response);
  }

  Future<bool> removeClinicalLog(index, id) async {
    final response = await http.post(
      AppUrls.removeClinicalLog,
      body: {
        "amr_id": id,
        "index": index,
      },
      headers: AuthenticationRepository().headers,
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleLogResponse(getResponse);
    }
    return _handleLogResponse(response);
  }

  Future<PaginatedList<ABGReport>> getABGRecords(recordId) async {
    try {
      final response = await http.get(AppUrls.getABGLog(recordId),
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];
      final List<ABGReport> records = result
          .map((json) => ABGReport.fromJson(json))
          .toList()
          .cast<ABGReport>();
      return PaginatedList(items: records, nextPageToken: "ABG Records");
    } catch (exception) {
      rethrow;
    }
  }

  Future<bool> addABGRecord(record) async {
    final response = await http.post(
      AppUrls.addABGLog,
      body: record,
      headers: AuthenticationRepository().headers,
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleLogResponse(getResponse);
    }
    return _handleLogResponse(response);
  }

  Future<bool> removeABGRecord(indices, id) async {
    final response = await http.post(
      AppUrls.removeABGLog,
      body: {
        "amr_id": id,
        "indices": indices,
      },
      headers: AuthenticationRepository().headers,
    );
    if (response.statusCode == 302) {
      String url = response.headers['location'] ?? " ";
      final getResponse = await http.get(Uri.parse(url));
      return _handleLogResponse(getResponse);
    }
    return _handleLogResponse(response);
  }

  Future getABGGraph(recordId) async {
    try {
      final response = await http.get(AppUrls.getABGLogGraph(recordId),
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];
      return result;
    } catch (exception) {
      rethrow;
    }
  }

  _handleRegisterPatientResponse(response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw PatientException.patientAlreadyExists;
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

  _handleAddAMRResponse(response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw ProductException.productAlreadyExists;
        case 403:
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

  _handleLogResponse(response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 400:
          throw PatientException.patientNotFound;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  set currentPatient(patient) => _patient = patient;
  Patient get currentPatient => _patient!;
}
