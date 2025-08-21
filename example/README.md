# App Permissions Checker

A comprehensive Flutter plugin for Android app permission analysis with beautiful Material 3 UI.

## Features

- 🎯 **Targeted Analysis**: Check permissions for specific apps
- 📱 **Bulk Scanning**: Analyze all installed apps at once  
- 🔍 **Smart Filtering**: Filter by system apps and permission types
- 🚨 **Risk Assessment**: Identify dangerous permissions and security risks
- 📊 **Detailed Insights**: Protection levels, categories, and grant status
- 🎨 **Beautiful UI**: Modern Material 3 example app included
- 🛡️ **Null Safety**: Full null safety support
- 📚 **Rich Documentation**: Comprehensive docs with examples

## Quick Start

```dart
import 'package:app_permissions_checker/app_permissions_checker.dart';

// Check specific apps
final apps = await AppPermissionsChecker.checkPermissions([
  'com.whatsapp',
  'com.instagram.android',
]);

// Get all apps
final allApps = await AppPermissionsChecker.getAllAppsPermissions();

// Check single permission
final hasCamera = await AppPermissionsChecker.isPermissionGranted(
  'com.whatsapp', 
  'android.permission.CAMERA'
);
```

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  app_permissions_checker: ^1.0.0
```

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
```

## Documentation

- [API Reference](https://pub.dev/documentation/app_permissions_checker/latest/)
- [GitHub Repository](https://github.com/kripadevg-code/app_permissions_checker)
- [Example App](https://github.com/kripadevg-code/app_permissions_checker/tree/main/example)

## Support

- 🐛 [Issue Tracker](https://github.com/kripadevg-code/app_permissions_checker/issues)
- 💬 [Discussions](https://github.com/kripadevg-code/app_permissions_checker/discussions)

Made with ❤️ for the Flutter community