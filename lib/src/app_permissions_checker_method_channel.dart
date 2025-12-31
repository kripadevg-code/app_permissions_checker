import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../errors/app_permissions_exceptions.dart';
import 'app_permissions_checker_platform_interface.dart';
import 'models/app_permission_info.dart';

/// MethodChannel implementation of the AppPermissionsChecker platform API.
class MethodChannelAppPermissionsChecker extends AppPermissionsCheckerPlatform {
  /// Underlying method channel name: 'app_permissions_checker'.
  @visibleForTesting
  final methodChannel = const MethodChannel('app_permissions_checker');

  @override
  Future<List<AppPermissionInfo>> checkPermissions(
    List<String> packageNames, {
    bool includeSystemApps = false,
  }) async {
    try {
      final result = await methodChannel.invokeMethod(
        'checkPermissions',
        {
          'packageNames': packageNames,
          'includeSystemApps': includeSystemApps,
        },
      );

      final apps = (result as List).cast<dynamic>();
      return apps.map((app) => AppPermissionInfo.fromMap(app as Map)).toList();
    } on PlatformException catch (e) {
      throw AppPermissionsException(
        'Failed to check permissions: ${e.message}',
        e.code,
      );
    }
  }

  @override
  Future<AppPermissionInfo?> checkSingleAppPermissions(String packageName) async {
    try {
      final result = await methodChannel.invokeMethod(
        'checkSingleAppPermissions',
        {'packageName': packageName},
      );

      if (result == null || (result is List && result.isEmpty)) {
        return null;
      }

      return AppPermissionInfo.fromMap(result as Map<String, dynamic>);
    } on PlatformException catch (e) {
      throw AppPermissionsException(
        'Failed to check permissions for $packageName: ${e.message}',
        e.code,
      );
    }
  }

  @override
  Future<List<AppPermissionInfo>> getAllAppsPermissions({
    bool includeSystemApps = false,
    bool onlyUsefulApps = false,
    List<String> filterByPermissions = const [],
  }) async {
    try {
      final result = await methodChannel.invokeMethod(
        'getAllAppsPermissions',
        {
          'includeSystemApps': includeSystemApps,
          'onlyUsefulApps': onlyUsefulApps,
          'filterByPermissions': filterByPermissions,
        },
      );

      final apps = (result as List).cast<dynamic>();
      return apps.map((app) => AppPermissionInfo.fromMap(app as Map)).toList();
    } on PlatformException catch (e) {
      throw AppPermissionsException(
        'Failed to get all apps permissions: ${e.message}',
        e.code,
      );
    }
  }

  @override
  Future<bool> isPermissionGranted(String packageName, String permission) async {
    try {
      final result = await methodChannel.invokeMethod('isPermissionGranted', {
        'packageName': packageName,
        'permission': permission,
      });
      return result as bool;
    } on PlatformException catch (e) {
      throw AppPermissionsException(
        'Failed to check permission $permission for $packageName: ${e.message}',
        e.code,
      );
    }
  }
}
