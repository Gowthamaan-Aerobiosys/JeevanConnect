import '../custom_exception.dart';

class AuthenticationException {
  static const userNotFound = CustomException(
      code: 400,
      key: "user-not-found",
      title: "User not found",
      displayMessage:
          "We couldn't find your Jeevan account. Kindly check your email.");
  static const userAlreadyExists = CustomException(
      code: 400,
      key: "user-already-exists",
      title: "User already exists",
      displayMessage:
          "User with that email address already exists. Try sign in.");
  static const invalidCredentials = CustomException(
      code: 400,
      key: "wrong-password",
      title: "Invalid credentials",
      displayMessage:
          "Either the email or password is incorrect. Try again or reset password.");
  static const confirmUser = CustomException(
      code: 401,
      key: "confirm-user",
      title: "Account not activated",
      displayMessage: "Kindly verify your email to activate your account.");
}
