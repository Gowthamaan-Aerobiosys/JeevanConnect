import 'package:flutter/material.dart';

enum Routes {
  boot,
  signin,
  signup,
  forgotPassword,
  home,
  createWorkspace,
  workspace,
  registerProduct,
  product,
  patient,
  registerPatient,
  myAccount,
  addAdmissionRecord,
  monitoring,
  userChat,
  ipForm
}

extension NavigationViaContext on BuildContext {
  Future<T?> push<T extends Object?>(Routes route,
      {Object? arguments, rootNavigator = false}) {
    return Navigator.of(this, rootNavigator: rootNavigator)
        .pushNamed(route.name, arguments: arguments);
  }

  Future<T?> pushReplacement<T extends Object?>(Routes route,
      {Object? arguments, rootNavigator = false}) {
    return Navigator.of(this, rootNavigator: rootNavigator)
        .pushNamedAndRemoveUntil(
      route.name,
      arguments: arguments,
      (route) => false,
    );
  }

  Future<T?> replace<T extends Object?>(Routes route,
      {Object? arguments, rootNavigator = false}) {
    return Navigator.of(this, rootNavigator: rootNavigator)
        .pushReplacementNamed(route.name, arguments: arguments);
  }

  pop<T extends Object?>([T? result]) {
    return Navigator.of(this).pop(result);
  }

  rootPop<T extends Object?>([T? result]) {
    return Navigator.of(this, rootNavigator: true).pop(result);
  }
}
