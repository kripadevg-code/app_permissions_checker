/// A comprehensive Flutter plugin for Android app permission analysis.
///
/// This library provides powerful tools for analyzing Android app permissions,
/// including security risk assessment, permission categorization, and detailed
/// insights into app behavior.
///
/// ## Features
///
/// - 🎯 **Targeted Analysis**: Check permissions for specific apps
/// - 📱 **Bulk Scanning**: Analyze all installed apps at once
/// - 🔍 **Smart Filtering**: Filter by system apps and permission types
/// - 🚨 **Risk Assessment**: Identify dangerous permissions and security risks
/// - 📊 **Detailed Insights**: Protection levels, categories, and grant status
/// - 🛡️ **Null Safety**: Full null safety support
///
/// ## Quick Start
///
/// ```dart
/// import 'package:app_permissions_checker/app_permissions_checker.dart';
///
/// // Check specific apps
/// final apps = await AppPermissionsChecker.checkPermissions([
///   'com.whatsapp',
///   'com.instagram.android',
/// ]);
///
/// // Get all apps
/// final allApps = await AppPermissionsChecker.getAllAppsPermissions();
///
/// // Check single permission
/// final hasCamera = await AppPermissionsChecker.isPermissionGranted(
///   'com.whatsapp',
///   'android.permission.CAMERA'
/// );
/// ```
///
/// ## Android Setup
///
/// Add to your `android/app/src/main/AndroidManifest.xml`:
///
/// ```xml
/// <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
/// ```
///
/// ## Security & Privacy
///
/// - **Local Processing**: All analysis happens on-device
/// - **No Network Access**: No data transmission to external servers
/// - **Privacy First**: Only accesses publicly available app metadata
///
/// See also:
/// - [AppPermissionInfo] for detailed app information
/// - [PermissionDetail] for individual permission details
/// - [AppPermissionsException] for error handling
library app_permissions_checker;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_permissions_checker.dart';
import 'src/app_permissions_checker_platform_interface.dart';

export 'errors/app_permissions_exceptions.dart';
export 'src/models/app_permission_info.dart';
export 'src/models/permission_detail.dart';

/// The main class providing comprehensive Android app permission analysis.
///
/// This class offers static methods for querying and analyzing permissions
/// of installed Android applications. All methods are asynchronous and
/// return detailed information about app permissions, including grant status,
/// protection levels, and categorization.
///
/// ## Usage Examples
///
/// ### Basic Permission Check
/// ```dart
/// final apps = await AppPermissionsChecker.checkPermissions([
///   'com.whatsapp',
///   'com.instagram.android',
/// ]);
///
/// for (final app in apps) {
///   print('${app.appName}: ${app.permissions.length} permissions');
/// }
/// ```
///
/// ### Security Analysis
/// ```dart
/// final allApps = await AppPermissionsChecker.getAllAppsPermissions();
/// final riskyApps = allApps.where((app) =>
///   app.grantedDangerousPermissions.length >= 5
/// ).toList();
/// ```
///
/// ### Permission Filtering
/// ```dart
/// final cameraApps = await AppPermissionsChecker.getAllAppsPermissions(
///   filterByPermissions: ['android.permission.CAMERA'],
/// );
/// ```
class AppPermissionsChecker {
  /// Analyzes permissions for specific apps by their package names.
  ///
  /// This method queries the Android system for detailed permission information
  /// about the specified applications. It returns comprehensive data including
  /// permission grant status, protection levels, and categorization.
  ///
  /// ## Parameters
  ///
  /// - [packageNames]: List of Android package names to analyze
  ///   (e.g., 'com.whatsapp', 'com.instagram.android')
  /// - [includeSystemApps]: Whether to include system apps in results.
  ///   Defaults to `false` to focus on user-installed apps.
  ///
  /// ## Returns
  ///
  /// A [Future] that completes with a [List] of [AppPermissionInfo] objects,
  /// one for each found app. Apps that don't exist or can't be accessed
  /// are silently omitted from the results.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final apps = await AppPermissionsChecker.checkPermissions([
  ///   'com.whatsapp',
  ///   'com.instagram.android',
  ///   'com.spotify.music'
  /// ]);
  ///
  /// for (final app in apps) {
  ///   print('${app.appName}:');
  ///   print('  Total permissions: ${app.permissions.length}');
  ///   print('  Dangerous permissions: ${app.dangerousPermissions.length}');
  ///   print('  Granted permissions: ${app.grantedPermissions.length}');
  /// }
  /// ```
  ///
  /// ## Throws
  ///
  /// - [AppPermissionsException]: When the QUERY_ALL_PACKAGES permission
  ///   is not granted or when a system error occurs.
  ///
  /// See also:
  /// - [checkSingleAppPermissions] for analyzing a single app
  /// - [getAllAppsPermissions] for analyzing all installed apps
  static Future<List<AppPermissionInfo>> checkPermissions(
    List<String> packageNames, {
    bool includeSystemApps = false,
  }) =>
      AppPermissionsCheckerPlatform.instance.checkPermissions(
        packageNames,
        includeSystemApps: includeSystemApps,
      );

  /// Analyzes permissions for a single app by package name.
  ///
  /// This is a convenience method for checking a single app's permissions.
  /// It's equivalent to calling [checkPermissions] with a single package name
  /// but returns the result directly or null if the app is not found.
  ///
  /// ## Parameters
  ///
  /// - [packageName]: The Android package name to analyze
  ///   (e.g., 'com.whatsapp')
  ///
  /// ## Returns
  ///
  /// A [Future] that completes with an [AppPermissionInfo] object if the
  /// app is found, or `null` if the app doesn't exist or can't be accessed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final app = await AppPermissionsChecker.checkSingleAppPermissions(
  ///   'com.whatsapp'
  /// );
  ///
  /// if (app != null) {
  ///   print('${app.appName} has ${app.permissions.length} permissions');
  ///
  ///   // Check for specific dangerous permissions
  ///   final dangerousCount = app.grantedDangerousPermissions.length;
  ///   if (dangerousCount > 0) {
  ///     print('Warning: $dangerousCount dangerous permissions granted');
  ///   }
  /// } else {
  ///   print('App not found or inaccessible');
  /// }
  /// ```
  ///
  /// ## Throws
  ///
  /// - [AppPermissionsException]: When system errors occur
  ///
  /// See also:
  /// - [checkPermissions] for analyzing multiple apps
  /// - [isPermissionGranted] for checking specific permissions
  static Future<AppPermissionInfo?> checkSingleAppPermissions(
    String packageName,
  ) =>
      AppPermissionsCheckerPlatform.instance.checkSingleAppPermissions(packageName);

  /// Retrieves all installed apps with comprehensive permission analysis.
  ///
  /// This method performs a system-wide scan of all installed applications
  /// and returns detailed permission information for each app. It's the most
  /// comprehensive analysis method available.
  ///
  /// ## Parameters
  ///
  /// - [includeSystemApps]: Whether to include system apps in the results.
  ///   Defaults to `false` to focus on user-installed apps. System apps
  ///   typically have many permissions and may not be relevant for most
  ///   security analyses.
  ///
  /// - [filterByPermissions]: Optional list of specific permissions to filter by.
  ///   When provided, only apps that request at least one of these permissions
  ///   will be included in the results. Useful for targeted security analysis.
  ///
  /// ## Returns
  ///
  /// A [Future] that completes with a [List] of [AppPermissionInfo] objects
  /// representing all matching installed applications.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Get all user-installed apps
  /// final allApps = await AppPermissionsChecker.getAllAppsPermissions();
  /// print('Found ${allApps.length} user apps');
  ///
  /// // Include system apps for comprehensive analysis
  /// final allAppsIncludingSystem = await AppPermissionsChecker.getAllAppsPermissions(
  ///   includeSystemApps: true,
  /// );
  ///
  /// // Filter apps that request location permissions
  /// final locationApps = await AppPermissionsChecker.getAllAppsPermissions(
  ///   filterByPermissions: [
  ///     'android.permission.ACCESS_FINE_LOCATION',
  ///     'android.permission.ACCESS_COARSE_LOCATION',
  ///   ],
  /// );
  ///
  /// // Security analysis example
  /// final riskyApps = allApps.where((app) {
  ///   final dangerousCount = app.grantedDangerousPermissions.length;
  ///   return dangerousCount >= 5; // Apps with many dangerous permissions
  /// }).toList();
  /// ```
  ///
  /// ## Performance Considerations
  ///
  /// This method can be resource-intensive as it queries all installed apps.
  /// Consider:
  /// - Running in a background isolate for large datasets
  /// - Using [filterByPermissions] to reduce processing time
  /// - Caching results when appropriate
  ///
  /// ## Throws
  ///
  /// - [AppPermissionsException]: When the QUERY_ALL_PACKAGES permission
  ///   is not granted or when system errors occur
  ///
  /// See also:
  /// - [checkPermissions] for analyzing specific apps
  /// - [checkSingleAppPermissions] for single app analysis
  static Future<List<AppPermissionInfo>> getAllAppsPermissions({
    bool includeSystemApps = false,
    List<String> filterByPermissions = const [],
  }) =>
      AppPermissionsCheckerPlatform.instance.getAllAppsPermissions(
        includeSystemApps: includeSystemApps,
        filterByPermissions: filterByPermissions,
      );

  /// Checks if a specific permission is granted for an app.
  ///
  /// This is a lightweight method for checking the grant status of a single
  /// permission for a specific app. It's more efficient than retrieving all
  /// permissions when you only need to check one.
  ///
  /// ## Parameters
  ///
  /// - [packageName]: The Android package name to check
  ///   (e.g., 'com.whatsapp')
  /// - [permission]: The full Android permission name to verify
  ///   (e.g., 'android.permission.CAMERA')
  ///
  /// ## Returns
  ///
  /// A [Future] that completes with `true` if the permission is granted,
  /// `false` if it's denied or not requested by the app.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Check camera permission for WhatsApp
  /// final hasCamera = await AppPermissionsChecker.isPermissionGranted(
  ///   'com.whatsapp',
  ///   'android.permission.CAMERA',
  /// );
  ///
  /// if (hasCamera) {
  ///   print('WhatsApp can access the camera');
  /// } else {
  ///   print('WhatsApp cannot access the camera');
  /// }
  ///
  /// // Check multiple permissions
  /// final permissions = [
  ///   'android.permission.CAMERA',
  ///   'android.permission.RECORD_AUDIO',
  ///   'android.permission.ACCESS_FINE_LOCATION',
  /// ];
  ///
  /// for (final permission in permissions) {
  ///   final granted = await AppPermissionsChecker.isPermissionGranted(
  ///     'com.whatsapp',
  ///     permission,
  ///   );
  ///   print('$permission: ${granted ? 'Granted' : 'Denied'}');
  /// }
  /// ```
  ///
  /// ## Performance
  ///
  /// This method is optimized for single permission checks. For checking
  /// multiple permissions, consider using [checkSingleAppPermissions] which
  /// provides all permissions in a single call.
  ///
  /// ## Throws
  ///
  /// - [AppPermissionsException]: When the app is not found or system errors occur
  ///
  /// See also:
  /// - [checkSingleAppPermissions] for comprehensive app analysis
  /// - [AppPermissionInfo.isPermissionGranted] for checking permissions
  ///   from existing app data
  static Future<bool> isPermissionGranted(
    String packageName,
    String permission,
  ) =>
      AppPermissionsCheckerPlatform.instance.isPermissionGranted(packageName, permission);

  /// Retrieves all installed apps in a background isolate to prevent UI blocking.
  ///
  /// This method runs the heavy permission scanning operation in a background
  /// isolate, preventing the main UI thread from being blocked. Recommended
  /// for apps that need to maintain smooth UI performance during scanning.
  ///
  /// ## Parameters
  ///
  /// Same as [getAllAppsPermissions].
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Scan without blocking UI
  /// final apps = await AppPermissionsChecker.getAllAppsPermissionsInBackground();
  /// ```
  static Future<List<AppPermissionInfo>> getAllAppsPermissionsInBackground({
    bool includeSystemApps = false,
    List<String> filterByPermissions = const [],
  }) async {
    // Capture the root isolate token to allow platform messages from the background isolate
    final token = RootIsolateToken.instance;
    return compute(_getAllAppsIsolate, {
      'includeSystemApps': includeSystemApps,
      'filterByPermissions': filterByPermissions,
      'rootIsolateToken': token,
    });
  }

  static Future<List<AppPermissionInfo>> _getAllAppsIsolate(
    Map<String, dynamic> params,
  ) async {
    // Ensure the background isolate can talk to platform channels
    final token = params['rootIsolateToken'] as RootIsolateToken?;
    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }

    return AppPermissionsCheckerPlatform.instance.getAllAppsPermissions(
      includeSystemApps: params['includeSystemApps'] as bool,
      filterByPermissions: (params['filterByPermissions'] as List).cast<String>(),
    );
  }
}
