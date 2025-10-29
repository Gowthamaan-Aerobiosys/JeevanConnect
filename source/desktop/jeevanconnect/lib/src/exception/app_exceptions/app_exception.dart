import '../custom_exception.dart';

class AppException {
  static const serverError = CustomException(
      code: 500,
      key: "server-error",
      title: "Server error",
      displayMessage:
          "We couldn't process your request. Please try again after later");

  static const serviceUnavailable = CustomException(
      code: 503,
      key: "service-unavailable",
      title: "Service unavailable",
      displayMessage:
          "The requested service is unavailable now. Please try again later");

  static const localError = CustomException(
      code: 600,
      key: "local-error",
      title: "Internal error",
      displayMessage:
          "An unexpected error occurred. We couldn't process your request. Please try again after later");

  static const noJeevanAccountExists = CustomException(
      code: 400,
      key: "no-jeevan-account",
      title: "No Jeevan Account Exists",
      displayMessage:
          "The user doesn't have a Jeevan account. Kindly invite the user to sign up for Jeevan Connect and then add them to the workspace");

  static const permissionDenied = CustomException(
      code: 409,
      key: "permission-denied",
      title: "Permission Denied",
      displayMessage: "You need admin previleges for this request");
}
