import 'package:flutter/foundation.dart';
import 'permission_detail.dart';

/// Contains comprehensive information about an app and its permissions
@immutable
class AppPermissionInfo {
  /// Creates a new [AppPermissionInfo].
  const AppPermissionInfo({
    required this.appName,
    required this.packageName,
    required this.permissions,
    required this.isUpdatedSystemApp,
    required this.isInternalApp,
    required this.isExternalApp,
    required this.installerSource,
    this.versionName,
    this.versionCode,
    this.installTime,
  });

  /// Create an [AppPermissionInfo] from a loosely-typed platform map
  factory AppPermissionInfo.fromMap(Map map) {
    final rawPerms = map['permissions'] as List? ?? const [];
    final permissionsList = rawPerms.map((p) => PermissionDetail.fromMap(p as Map)).toList();

    return AppPermissionInfo(
      appName: map['appName'] as String? ?? '',
      packageName: map['packageName'] as String? ?? '',
      versionName: map['versionName'] as String?,
      versionCode: (map['versionCode'] is int) ? map['versionCode'] as int : int.tryParse('${map['versionCode']}'),
      isUpdatedSystemApp: map['isUpdatedSystemApp'] as bool? ?? false,
      isInternalApp: map['isInternalApp'] as bool? ?? false,
      isExternalApp: map['isExternalApp'] as bool? ?? false,
      installerSource: map['installerSource'] as String? ?? '',
      installTime: map['installTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['installTime'] as num).toInt(),
            )
          : null,
      permissions: permissionsList,
    );
  }

  /// The display name of the app
  final String appName;

  /// The package name of the app
  final String packageName;

  /// The version name of the app
  final String? versionName;

  /// The version code of the app
  final int? versionCode;

  /// List of all permissions requested by this app
  final List<PermissionDetail> permissions;

  /// Whether this system app has been updated by the user
  final bool isUpdatedSystemApp;

  /// Whether this app is installed internally (system app)
  final bool isInternalApp;

  /// Whether this app is installed externally (user-installed)
  final bool isExternalApp;

  /// The source from which this app was installed
  final String installerSource;

  /// When this app was first installed
  final DateTime? installTime;

  /// Convert this [AppPermissionInfo] to a map
  Map<String, dynamic> toMap() => {
        'appName': appName,
        'packageName': packageName,
        'versionName': versionName,
        'versionCode': versionCode,
        'isUpdatedSystemApp': isUpdatedSystemApp,
        'isInternalApp': isInternalApp,
        'isExternalApp': isExternalApp,
        'installerSource': installerSource,
        'installTime': installTime?.millisecondsSinceEpoch,
        'permissions': permissions.map((p) => p.toMap()).toList(),
      };

  /// Get only the permissions that are currently granted
  List<PermissionDetail> get grantedPermissions => permissions.where((p) => p.granted).toList();

  /// Get only the permissions that are denied
  List<PermissionDetail> get deniedPermissions => permissions.where((p) => !p.granted).toList();

  /// Get only the dangerous permissions
  List<PermissionDetail> get dangerousPermissions => permissions.where((p) => p.isDangerous).toList();

  /// Get only the granted dangerous permissions
  List<PermissionDetail> get grantedDangerousPermissions => permissions.where((p) => p.isDangerous && p.granted).toList();

  /// Check if this app has requested a specific permission
  bool hasPermission(String permission) => permissions.any((p) => p.permission == permission);

  /// Check if a specific permission is granted
  bool isPermissionGranted(String permission) => permissions.any((p) => p.permission == permission && p.granted);

  /// Group permissions by category
  Map<String, List<PermissionDetail>> get permissionsByCategory {
    final grouped = <String, List<PermissionDetail>>{};

    for (final permission in permissions) {
      grouped.putIfAbsent(permission.category, () => []).add(permission);
    }

    return grouped;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is AppPermissionInfo && runtimeType == other.runtimeType && packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;

  @override
  String toString() =>
      ' AppPermissionInfo{appName: $appName, packageName: $packageName, versionName: $versionName, versionCode: $versionCode, isUpdatedSystemApp: $isUpdatedSystemApp, isInternalApp: $isInternalApp, isExternalApp: $isExternalApp, installerSource: $installerSource, installTime: $installTime, permissions: $permissions}';
}
