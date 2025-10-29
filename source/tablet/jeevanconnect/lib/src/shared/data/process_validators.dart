import 'dart:async';

import '../../features/authentication/authentication.dart'
    show AuthenticationRepository;
import '../../packages/internet_connection_checker/internet_connection_checker.dart';
import '../presentation/dialogs/dialogs.dart' show simpleDialog, DialogType;

class ProcessValidator {
  static StreamSubscription<InternetConnectionStatus>? _internetChecker;
  static bool isNetworkAvailable = false;

  init() {
    _initiateInternetCheckerService();
  }

  dispose() {
    _internetChecker?.cancel();
  }

  _initiateInternetCheckerService() {
    _internetChecker =
        InternetConnectionChecker().onStatusChange.listen((event) {
      switch (event) {
        case InternetConnectionStatus.connected:
          isNetworkAvailable = true;
          break;
        case InternetConnectionStatus.disconnected:
          isNetworkAvailable = false;
          break;
      }
    });
  }

  checkInternet(callback) {
    if (isNetworkAvailable) {
      callback();
    }
  }

  checkLogin(callback) {
    if (AuthenticationRepository().isSignedIn) {
      callback();
    }
  }

  checkForInternet(context, callback) {
    if (isNetworkAvailable) {
      callback();
    } else {
      simpleDialog(context,
          type: DialogType.error,
          title: "No internet",
          content:
              "Your are not connected to the internet. Please reconnect and try again",
          buttonName: "Close");
    }
  }

  checkForLogin(context, callback) {
    if (AuthenticationRepository().isSignedIn) {
      callback();
    } else {
      simpleDialog(context,
          type: DialogType.error,
          title: "Login required",
          content: "Login with your Jeevan account to access this service",
          buttonName: "Close");
    }
  }
}
