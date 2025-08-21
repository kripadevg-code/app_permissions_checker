# Installation Guide

## Prerequisites

- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 3.0.0 or higher  
- **Android**: API level 21+ (Android 5.0+)
- **Android Studio**: Latest version recommended

## Step 1: Add Dependency

Add the plugin to your `pubspec.yaml`:

```yaml
dependencies:
  app_permissions_checker: ^1.0.0
```

Run the following command:

```bash
flutter pub get
```

## Step 2: Android Configuration

### Add Permission to Manifest

Add the following permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    
    <!-- Required for querying installed apps -->
    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" 
        tools:ignore="QueryAllPackagesPermission" />
    
    <application>
        <!-- Your app configuration -->
    </application>
</manifest>
```

### Minimum SDK Version

Ensure your `android/app/build.gradle` has minimum SDK 21:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21  // Required minimum
        targetSdkVersion 34
    }
}
```

## Step 3: Import and Use

```dart
import 'package:app_permissions_checker/app_permissions_checker.dart';

// Check permissions for specific apps
final apps = await AppPermissionsChecker.checkPermissions([
  'com.whatsapp',
  'com.instagram.android',
]);

// Get all installed apps
final allApps = await AppPermissionsChecker.getAllAppsPermissions();
```

## Step 4: Handle Permissions (Optional)

For apps targeting Android 11+ (API 30+), you may need to handle the QUERY_ALL_PACKAGES permission:

```dart
// Check if permission is available
try {
  final apps = await AppPermissionsChecker.getAllAppsPermissions();
  // Permission is granted
} catch (e) {
  // Handle permission denied
  print('Permission denied: $e');
}
```

## Troubleshooting

### Common Issues

1. **Permission Denied Error**
   - Ensure QUERY_ALL_PACKAGES is in AndroidManifest.xml
   - Check that tools:ignore attribute is present

2. **Empty Results**
   - Try setting `includeSystemApps: true`
   - Verify target device has apps installed

3. **Build Errors**
   - Clean and rebuild: `flutter clean && flutter pub get`
   - Check minimum SDK version is 21+

### Verification

Test the installation with this simple example:

```dart
import 'package:flutter/material.dart';
import 'package:app_permissions_checker/app_permissions_checker.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<AppPermissionInfo> apps = [];
  
  @override
  void initState() {
    super.initState();
    _loadApps();
  }
  
  Future<void> _loadApps() async {
    try {
      final result = await AppPermissionsChecker.getAllAppsPermissions();
      setState(() => apps = result);
    } catch (e) {
      print('Error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test App Permissions')),
      body: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return ListTile(
            title: Text(app.appName),
            subtitle: Text('${app.permissions.length} permissions'),
          );
        },
      ),
    );
  }
}
```

## Next Steps

- Check out the [API Documentation](api.md)
- Run the [Example App](../example/)
- Read the [Usage Guide](usage.md)