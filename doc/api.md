# API Documentation

## Overview

The App Permissions Checker plugin provides a comprehensive API for analyzing Android app permissions. This document covers all available methods, models, and usage patterns.

## Core Classes

### AppPermissionsChecker

The main class providing static methods for permission analysis.

#### Methods

##### `checkPermissions`

```dart
static Future<List<AppPermissionInfo>> checkPermissions(
  List<String> packageNames, {
  bool includeSystemApps = false,
})
```

Check permissions for specific apps by package names.

**Parameters:**
- `packageNames` (List<String>): Package names to analyze
- `includeSystemApps` (bool): Include system apps in results

**Returns:** List of AppPermissionInfo objects

**Example:**
```dart
final apps = await AppPermissionsChecker.checkPermissions([
  'com.whatsapp',
  'com.instagram.android',
]);
```

---

##### `getAllAppsPermissions`

```dart
static Future<List<AppPermissionInfo>> getAllAppsPermissions({
  bool includeSystemApps = false,
  List<String> filterByPermissions = const [],
})
```

Get all installed apps with their permissions.

**Parameters:**
- `includeSystemApps` (bool): Include system apps
- `filterByPermissions` (List<String>): Filter apps by specific permissions

**Returns:** List of all matching apps

**Example:**
```dart
final allApps = await AppPermissionsChecker.getAllAppsPermissions();
```

## Data Models

### AppPermissionInfo

Comprehensive information about an app and its permissions.

#### Properties

```dart
class AppPermissionInfo {
  final String appName;              // Display name
  final String packageName;          // Package identifier  
  final List<PermissionDetail> permissions; // All permissions
  final bool isSystemApp;           // System app flag
}
```

### PermissionDetail

Detailed information about a specific permission.

#### Properties

```dart
class PermissionDetail {
  final String permission;          // Full permission name
  final String readableName;        // Human-readable name
  final bool granted;              // Grant status
  final String protectionLevel;    // Protection level
  final String category;           // Permission category
}
```

## Usage Examples

### Basic Permission Check

```dart
import 'package:app_permissions_checker/app_permissions_checker.dart';

// Check specific apps
final apps = await AppPermissionsChecker.checkPermissions([
  'com.whatsapp',
  'com.instagram.android',
]);

for (final app in apps) {
  print('${app.appName}: ${app.permissions.length} permissions');
}
```

### Security Analysis

```dart
// Get all apps and analyze risks
final allApps = await AppPermissionsChecker.getAllAppsPermissions();

final riskyApps = allApps.where((app) {
  final dangerousGranted = app.grantedDangerousPermissions.length;
  return dangerousGranted >= 5;
}).toList();

print('Found ${riskyApps.length} high-risk apps');
```