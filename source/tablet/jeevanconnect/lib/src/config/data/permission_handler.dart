import 'package:permission_handler/permission_handler.dart';

class PermissionConfig {
  static bool _permissionGranted = true;

  /// A list of app-specific permissions required by the application.
  static const _appPermissions = [Permission.storage];

  /// Requests user permissions for the app.
  ///
  /// The [requestUserPermission] method iterates through the list of app-specific
  /// permissions and requests each one from the user. It returns `true` once all
  /// permissions are granted, otherwise, it returns `false`.
  Future<bool> requestUserPermission() async {
    for (Permission permission in _appPermissions) {
      _permissionGranted =
          (await permission.request()) == PermissionStatus.granted &&
              _permissionGranted;
    }
    return _permissionGranted;
  }

  /// Indicates whether all required permissions have been granted.
  ///
  /// The [permissionGranted] property returns `true` if all the required
  /// permissions have been granted by the user, otherwise, it returns `false`.
  bool get permissionGranted => _permissionGranted;
}
