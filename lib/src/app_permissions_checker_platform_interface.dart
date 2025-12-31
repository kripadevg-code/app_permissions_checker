import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'app_permissions_checker_method_channel.dart';
import 'models/app_permission_info.dart';

/// Platform interface for AppPermissionsChecker.
///
/// Implementations provide platform-specific permission analysis APIs.
abstract class AppPermissionsCheckerPlatform extends PlatformInterface {
  /// Constructs a AppPermissionsCheckerPlatform.
  AppPermissionsCheckerPlatform() : super(token: _token);

  static final Object _token = Object();
  static AppPermissionsCheckerPlatform _instance = MethodChannelAppPermissionsChecker();

  /// The active platform implementation.
  static AppPermissionsCheckerPlatform get instance => _instance;

  /// Set a custom platform implementation. Verifies token.
  static set instance(AppPermissionsCheckerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Analyze permissions for the given [packageNames].
  ///
  /// Returns a list of [AppPermissionInfo]. When [includeSystemApps] is false,
  /// system apps may be excluded by platform logic.
  Future<List<AppPermissionInfo>> checkPermissions(
    List<String> packageNames, {
    bool includeSystemApps = false,
  }) {
    throw UnimplementedError('checkPermissions() has not been implemented.');
  }

  /// Analyze permissions for a single [packageName].
  Future<AppPermissionInfo?> checkSingleAppPermissions(String packageName) {
    throw UnimplementedError('checkSingleAppPermissions() has not been implemented.');
  }

  /// Retrieve all installed apps and their permissions.
  ///
  /// When [filterByPermissions] is provided, only apps requesting any of the
  /// given permissions should be returned.
  /// When [onlyUsefulApps] is true, only external apps and updated system apps are returned.
  Future<List<AppPermissionInfo>> getAllAppsPermissions({
    bool includeSystemApps = false,
    bool onlyUsefulApps = false,
    List<String> filterByPermissions = const [],
  }) {
    throw UnimplementedError('getAllAppsPermissions() has not been implemented.');
  }

  /// Check whether [permission] is granted for [packageName].
  Future<bool> isPermissionGranted(String packageName, String permission) {
    throw UnimplementedError('isPermissionGranted() has not been implemented.');
  }
}
