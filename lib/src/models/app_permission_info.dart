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
    required this.isSystemApp,
    this.versionName,
    this.versionCode,
    this.installTime,
  });

  /// Create an [AppPermissionInfo] from a loosely-typed map (from platform channels)
  factory AppPermissionInfo.fromMap(Map map) {
    final rawPerms = map['permissions'] as List? ?? const [];
    final permissionsList = rawPerms.map((p) => PermissionDetail.fromMap(p as Map)).toList();

    return AppPermissionInfo(
      appName: map['appName'] as String? ?? '',
      packageName: map['packageName'] as String? ?? '',
      versionName: map['versionName'] as String?,
      versionCode: (map['versionCode'] is int) ? map['versionCode'] as int : int.tryParse('${map['versionCode']}'),
      permissions: permissionsList,
      isSystemApp: map['isSystemApp'] as bool? ?? false,
      installTime: map['installTime'] != null ? DateTime.fromMillisecondsSinceEpoch((map['installTime'] as num).toInt()) : null,
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

  /// Whether this is a system app
  final bool isSystemApp;

  /// When this app was first installed
  final DateTime? installTime;

  /// Convert this [AppPermissionInfo] to a map
  Map<String, dynamic> toMap() => {
        'appName': appName,
        'packageName': packageName,
        'versionName': versionName,
        'versionCode': versionCode,
        'permissions': permissions.map((p) => p.toMap()).toList(),
        'isSystemApp': isSystemApp,
        'installTime': installTime?.millisecondsSinceEpoch,
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

  /// Check if a specific permission is granted for this app
  bool isPermissionGranted(String permission) => permissions.any((p) => p.permission == permission && p.granted);

  /// Get permissions grouped by category
  Map<String, List<PermissionDetail>> get permissionsByCategory {
    final grouped = <String, List<PermissionDetail>>{};

    for (final permission in permissions) {
      final category = permission.category;
      grouped.putIfAbsent(category, () => []).add(permission);
    }

    return grouped;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is AppPermissionInfo && runtimeType == other.runtimeType && packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;

  @override
  String toString() => 'AppPermissionInfo{appName: $appName, packageName: $packageName, permissions: ${permissions.length}}';
}
