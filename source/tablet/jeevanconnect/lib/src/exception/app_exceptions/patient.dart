import '../custom_exception.dart';

class PatientException {
  static const patientAlreadyExists = CustomException(
      code: 400,
      key: "patient-already-exists",
      title: "Patient already exists",
      displayMessage: "Patient with that ID already exists");
  static const patientNotFound = CustomException(
      code: 400,
      key: "patient-doesnot-exists",
      title: "Patient doesnot exists",
      displayMessage: "Patient with that ID doesnot exists");
}
