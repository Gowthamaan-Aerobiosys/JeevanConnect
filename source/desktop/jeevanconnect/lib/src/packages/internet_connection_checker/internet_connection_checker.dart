// Dart Packages
import 'dart:async';

// Flutter Packages
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

// Third Party Packages
import 'package:http/http.dart' as http;

import 'address_check_option.dart';
import 'address_check_result.dart';

enum InternetConnectionStatus {
  connected,
  disconnected,
}

class InternetConnectionChecker {
  factory InternetConnectionChecker() => _instance;

  InternetConnectionChecker.createInstance({
    this.checkInterval = const Duration(seconds: 10),
    List<AddressCheckOption>? customCheckOptions,
    bool useDefaultOptions = true,
  }) : assert(
          useDefaultOptions || customCheckOptions?.isNotEmpty == true,
          'You must provide a list of options if you are not using the '
          'default ones.',
        ) {
    _addressCheckOptions = [
      if (useDefaultOptions) ..._defaultCheckOptions,
      if (customCheckOptions != null) ...customCheckOptions,
    ];

    _statusController.onListen = _maybeEmitStatusUpdate;
    _statusController.onCancel = _handleStatusChangeCancel;
  }

  /// The default list of [Uri]s used for checking internet reachability.
  final List<AddressCheckOption> _defaultCheckOptions = [
    AddressCheckOption(uri: Uri.parse('https://one.one.one.one')),
    AddressCheckOption(uri: Uri.parse('https://icanhazip.com/')),
    AddressCheckOption(
      uri: Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
    ),
    AddressCheckOption(uri: Uri.parse('https://reqres.in/api/users/1')),
  ];

  /// The list of [Uri]s used for checking internet reachability.
  late List<AddressCheckOption> _addressCheckOptions;

  /// The controller for the internet connection status stream.
  final _statusController =
      StreamController<InternetConnectionStatus>.broadcast();

  /// The singleton instance of [InternetConnectionChecker].
  static final _instance = InternetConnectionChecker.createInstance();

  /// The duration between consecutive status checks.
  ///
  /// Defaults to 5 seconds.
  final Duration checkInterval;

  /// The last known internet connection status result.
  InternetConnectionStatus? _lastStatus;

  /// The handle for the timer used for periodic status checks.
  Timer? _timerHandle;

  /// Checks if the [Uri] specified in [option] is reachable.
  ///
  /// Returns a [Future] that completes with an [AddressCheckResult] indicating
  /// whether the host is reachable or not.
  Future<AddressCheckResult> _checkReachabilityFor(
    AddressCheckOption option,
  ) async {
    try {
      final response = await compute((_) {
        return http
            .head(option.uri, headers: option.headers)
            .timeout(option.timeout);
      }, null);

      return AddressCheckResult(
        option: option,
        isSuccess: option.responseStatusFn(response),
      );
    } catch (_) {
      return AddressCheckResult(
        option: option,
        isSuccess: false,
      );
    }
  }

  /// Checks if there is internet access by verifying connectivity to the
  /// specified [Uri]s.
  ///
  /// Returns a [Future] that completes with a boolean value indicating
  /// whether internet access is available or not.
  Future<bool> get hasInternetAccess async {
    final completer = Completer<bool>();
    int length = _addressCheckOptions.length;

    for (final option in _addressCheckOptions) {
      unawaited(
        _checkReachabilityFor(option).then((result) {
          length -= 1;

          if (completer.isCompleted) return;

          if (result.isSuccess) {
            completer.complete(true);
          } else if (length == 0) {
            completer.complete(false);
          }
        }),
      );
    }

    return completer.future;
  }

  /// Returns the current internet connection status.
  ///
  /// Returns a [Future] that completes with the [InternetStatus] indicating
  /// the current internet connection status.
  Future<InternetConnectionStatus> get internetStatus async =>
      await hasInternetAccess
          ? InternetConnectionStatus.connected
          : InternetConnectionStatus.disconnected;

  /// Internal method for emitting status updates.
  ///
  /// Updates the status and emits it if there are listeners.
  Future<void> _maybeEmitStatusUpdate() async {
    _startListeningToConnectivityChanges();
    _timerHandle?.cancel();

    final currentStatus = await internetStatus;

    if (!_statusController.hasListener) return;

    if (_lastStatus != currentStatus && _statusController.hasListener) {
      _statusController.add(currentStatus);
    }

    _timerHandle = Timer(checkInterval, _maybeEmitStatusUpdate);

    _lastStatus = currentStatus;
  }

  /// Handles cancellation of status change events.
  ///
  /// Cancels the timer and resets the last status.
  void _handleStatusChangeCancel() {
    if (_statusController.hasListener) return;

    _connectivitySubscription?.cancel().then((_) {
      _connectivitySubscription = null;
    });
    _timerHandle?.cancel();
    _timerHandle = null;
    _lastStatus = null;
  }

  /// The result of the last attempt to check the internet status.
  InternetConnectionStatus? get lastTryResults => _lastStatus;

  /// Stream that emits internet connection status changes.
  Stream<InternetConnectionStatus> get onStatusChange =>
      _statusController.stream;

  /// Connectivity subscription.
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Starts listening to connectivity changes from [connectivity_plus] package
  /// using the [Connectivity.onConnectivityChanged] stream.
  ///
  /// [connectivity_plus]: https://pub.dev/packages/connectivity_plus
  void _startListeningToConnectivityChanges() {
    if (_connectivitySubscription != null) return;
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (_) {
        if (_statusController.hasListener) {
          _maybeEmitStatusUpdate();
        }
      },
    );
  }
}
