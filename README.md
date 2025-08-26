<div align="center">
  <h1>🔐 App Permissions Checker</h1>
  <p><strong>A powerful Flutter plugin for comprehensive Android app permission analysis</strong></p>
  
  [![pub package](https://img.shields.io/pub/v/app_permissions_checker.svg)](https://pub.dev/packages/app_permissions_checker)
  [![popularity](https://img.shields.io/pub/popularity/app_permissions_checker?logo=dart)](https://pub.dev/packages/app_permissions_checker/score)
  [![likes](https://img.shields.io/pub/likes/app_permissions_checker?logo=dart)](https://pub.dev/packages/app_permissions_checker/score)
  [![pub points](https://img.shields.io/pub/points/app_permissions_checker?logo=dart)](https://pub.dev/packages/app_permissions_checker/score)
  [![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
  
  <br>
  
  <img src="https://raw.githubusercontent.com/kripadevg-code/app_permissions_checker/main/screenshots/dashboard.png" alt="App Permissions Checker Dashboard" width="300">
</div>

## 📱 Screenshots

<p align="center">
  <img src="https://raw.githubusercontent.com/kripadevg-code/app_permissions_checker/main/screenshots/dashboard.png" width="200" alt="Dashboard" />
  <img src="https://raw.githubusercontent.com/kripadevg-code/app_permissions_checker/main/screenshots/app_list.png" width="200" alt="App List" />
  <img src="https://raw.githubusercontent.com/kripadevg-code/app_permissions_checker/main/screenshots/permission_details.png" width="200" alt="Permission Details" />
  <img src="https://raw.githubusercontent.com/kripadevg-code/app_permissions_checker/main/screenshots/risk_assessment.png" width="200" alt="Risk Assessment" />
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/kripadevg-code/app_permissions_checker/main/screenshots/filters.png" width="200" alt="Filters" />
  <img src="https://raw.githubusercontent.com/kripadevg-code/app_permissions_checker/main/screenshots/search.png" width="200" alt="Search" />
  <img src="https://raw.githubusercontent.com/kripadevg-code/app_permissions_checker/main/screenshots/dark_mode.png" width="200" alt="Dark Mode" />
</p>

---

## 🌟 Overview

**App Permissions Checker** is a comprehensive Flutter plugin that provides deep insights into Android app permissions. Whether you're building a security app, privacy tool, or need to analyze app permissions for compliance, this plugin offers everything you need.

### ✨ Key Features

| Feature                   | Description                                         | Status |
| ------------------------- | --------------------------------------------------- | ------ |
| 🎯 **Targeted Analysis**  | Check permissions for specific apps by package name | ✅     |
| 📱 **Bulk Scanning**      | Get permissions for all installed apps at once      | ✅     |
| 🔍 **Smart Filtering**    | Filter by system apps, permission types, and status | ✅     |
| 🚨 **Risk Assessment**    | Identify dangerous permissions and security risks   | ✅     |
| 📊 **Detailed Insights**  | Protection levels, categories, and grant status     | ✅     |
| 🎨 **Beautiful UI**       | Modern Material 3 example app included              | ✅     |
| 🛡️ **Null Safety**        | Full null safety support for robust apps            | ✅     |
| 📚 **Rich Documentation** | Comprehensive docs with examples                    | ✅     |

---

## 🚀 Quick Start

### 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  app_permissions_checker: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### 🔧 Android Setup

Add the following permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"
    tools:ignore="QueryAllPackagesPermission" />
```

> **Note:** This permission is required to query information about other installed apps.

---

## 💡 Usage Examples

### 🎯 Basic Permission Check

```dart
import 'package:app_permissions_checker/app_permissions_checker.dart';

// Check permissions for specific apps
final apps = await AppPermissionsChecker.checkPermissions([
  'com.whatsapp',
  'com.instagram.android',
  'com.spotify.music'
]);

for (final app in apps) {
  print('${app.appName}: ${app.permissions.length} permissions');
  print('Dangerous: ${app.dangerousPermissions.length}');
  print('Granted: ${app.grantedPermissions.length}');
}
```

### 📱 Scan All Apps

```dart
// Get all installed apps (excluding system apps)
final allApps = await AppPermissionsChecker.getAllAppsPermissions(
  includeSystemApps: false,
);

print('Found ${allApps.length} user apps');

// Find apps with camera permission
final cameraApps = allApps.where((app) =>
  app.hasPermission('android.permission.CAMERA')
).toList();

print('${cameraApps.length} apps request camera access');
```

### 🔍 Advanced Filtering

```dart
// Filter by specific dangerous permissions
final locationApps = await AppPermissionsChecker.getAllAppsPermissions(
  filterByPermissions: [
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.ACCESS_COARSE_LOCATION',
  ],
);

// Analyze permission categories
for (final app in locationApps) {
  final categories = app.permissionsByCategory;
  print('\n${app.appName}:');

  categories.forEach((category, permissions) {
    final granted = permissions.where((p) => p.granted).length;
    print('  $category: $granted/${permissions.length} granted');
  });
}
```

### 🛡️ Security Analysis

```dart
// Identify high-risk apps
final apps = await AppPermissionsChecker.getAllAppsPermissions();

final riskyApps = apps.where((app) {
  final dangerousGranted = app.grantedDangerousPermissions.length;
  return dangerousGranted >= 5; // Apps with 5+ dangerous permissions
}).toList();

// Sort by risk level
riskyApps.sort((a, b) =>
  b.grantedDangerousPermissions.length.compareTo(
    a.grantedDangerousPermissions.length
  )
);

print('🚨 High-risk apps:');
for (final app in riskyApps.take(5)) {
  print('${app.appName}: ${app.grantedDangerousPermissions.length} dangerous permissions');
}
```

### 🎨 UI Integration

```dart
class PermissionsList extends StatelessWidget {
  final AppPermissionInfo app;

  const PermissionsList({Key? key, required this.app}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: app.permissions.length,
      itemBuilder: (context, index) {
        final permission = app.permissions[index];
        return ListTile(
          leading: Icon(
            permission.granted ? Icons.check_circle : Icons.cancel,
            color: permission.granted ? Colors.green : Colors.red,
          ),
          title: Text(permission.readableName),
          subtitle: Text(permission.permission),
          trailing: Chip(
            label: Text(permission.protectionLevel),
            backgroundColor: permission.isDangerous
              ? Colors.red.shade100
              : Colors.blue.shade100,
          ),
        );
      },
    );
  }
}
```

---

## 📚 API Reference

### Core Methods

#### `checkPermissions(List<String> packageNames, {bool includeSystemApps})`

Check permissions for specific apps by package names.

**Parameters:**

- `packageNames`: List of package names to analyze
- `includeSystemApps`: Include system apps in results (default: false)

**Returns:** `Future<List<AppPermissionInfo>>`

#### `checkSingleAppPermissions(String packageName)`

Check permissions for a single app.

**Parameters:**

- `packageName`: Package name to analyze

**Returns:** `Future<AppPermissionInfo?>`

#### `getAllAppsPermissions({bool includeSystemApps, List<String> filterByPermissions})`

Get all installed apps with their permissions.

**Parameters:**

- `includeSystemApps`: Include system apps (default: false)
- `filterByPermissions`: Filter apps by specific permissions

**Returns:** `Future<List<AppPermissionInfo>>`

#### `isPermissionGranted(String packageName, String permission)`

Check if a specific permission is granted.

**Parameters:**

- `packageName`: Package name to check
- `permission`: Permission to verify

**Returns:** `Future<bool>`

### Data Models

#### `AppPermissionInfo`

Comprehensive app information with permissions.

```dart
class AppPermissionInfo {
  final String appName;              // Display name
  final String packageName;          // Package identifier
  final String? versionName;         // Version string
  final int? versionCode;           // Version number
  final List<PermissionDetail> permissions; // All permissions
  final bool isSystemApp;           // System app flag
  final DateTime? installTime;      // Installation date

  // Convenience getters
  List<PermissionDetail> get grantedPermissions;
  List<PermissionDetail> get deniedPermissions;
  List<PermissionDetail> get dangerousPermissions;
  Map<String, List<PermissionDetail>> get permissionsByCategory;
}
```

#### `PermissionDetail`

Detailed permission information.

```dart
class PermissionDetail {
  final String permission;          // Full permission name
  final String readableName;        // Human-readable name
  final bool granted;              // Grant status
  final String protectionLevel;    // Protection level
  final String category;           // Permission category

  // Convenience getters
  bool get isDangerous;
  bool get isNormal;
  bool get isSignature;
}
```

---

## 🎨 Example App

The plugin includes a beautiful Material 3 example app showcasing all features:

- **📊 Dashboard Overview**: Visual insights and statistics
- **📱 App List**: Searchable list with filters
- **🔍 Detailed Analysis**: Per-app permission breakdown
- **🎯 Risk Assessment**: Security scoring and recommendations
- **🌙 Dark Mode**: Full theme support

### Running the Example

```bash
cd example
flutter run
```

---

## 🔒 Privacy & Security

### Permissions Required

- `QUERY_ALL_PACKAGES`: Required to access information about installed apps

### Data Handling

- **No Network Access**: All processing happens locally
- **No Data Collection**: No user data is transmitted
- **Privacy First**: Only accesses publicly available app metadata

### Best Practices

1. **Request Minimal Permissions**: Only check apps you need
2. **User Consent**: Inform users about permission analysis
3. **Secure Storage**: Don't store sensitive permission data
4. **Regular Updates**: Keep the plugin updated for security

---

## 🛠️ Platform Support

| Platform | Support          | Min Version           |
| -------- | ---------------- | --------------------- |
| Android  | ✅ Full          | API 21+ (Android 5.0) |
| iOS      | ❌ Not Available | -                     |
| Web      | ❌ Not Available | -                     |
| Desktop  | ❌ Not Available | -                     |

> **Note:** This plugin is Android-specific due to platform limitations on permission querying.

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### 🐛 Bug Reports

1. Check existing [issues](https://github.com/kripadevg-code/app_permissions_checker/issues)
2. Create detailed bug reports with:
   - Device information
   - Android version
   - Steps to reproduce
   - Expected vs actual behavior

### 💡 Feature Requests

1. Search existing [discussions](https://github.com/kripadevg-code/app_permissions_checker/discussions)
2. Propose new features with use cases
3. Consider implementation complexity

### 🔧 Development

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

### 📝 Documentation

- Improve existing docs
- Add more examples
- Fix typos and clarity issues

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Android team for permission APIs
- Contributors and users of this package
- Open source community

---

## 📞 Support

- 📖 [Documentation](https://pub.dev/documentation/app_permissions_checker/latest/)
- 🐛 [Issue Tracker](https://github.com/kripadevg-code/app_permissions_checker/issues)
- 💬 [Discussions](https://github.com/kripadevg-code/app_permissions_checker/discussions)
- 📧 [Email Support](mailto:kripadev.g@gmail.com)

---

<div align="center">
  <p><strong>Made with ❤️ for the Flutter community</strong></p>
  <p>⭐ Star this repo if you find it helpful!</p>
</div>
