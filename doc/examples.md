# Usage Examples

This document provides comprehensive examples of how to use the App Permissions Checker plugin effectively.

## Basic Usage

### Check Specific Apps

```dart
import 'package:app_permissions_checker/app_permissions_checker.dart';

Future<void> checkSpecificApps() async {
  try {
    final apps = await AppPermissionsChecker.checkPermissions([
      'com.whatsapp',
      'com.instagram.android',
      'com.spotify.music',
    ]);

    for (final app in apps) {
      print('📱 ${app.appName}');
      print('   Package: ${app.packageName}');
      print('   Total permissions: ${app.permissions.length}');
      print('   Granted: ${app.grantedPermissions.length}');
      print('   Dangerous: ${app.dangerousPermissions.length}');
      print('   System app: ${app.isSystemApp}');
      print('');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Scan All Apps

```dart
Future<void> scanAllApps() async {
  try {
    final apps = await AppPermissionsChecker.getAllAppsPermissions();
    
    print('Found ${apps.length} user-installed apps');
    
    // Sort by number of dangerous permissions
    apps.sort((a, b) => 
      b.grantedDangerousPermissions.length.compareTo(
        a.grantedDangerousPermissions.length
      )
    );
    
    print('\nTop 5 apps with most dangerous permissions:');
    for (final app in apps.take(5)) {
      final dangerous = app.grantedDangerousPermissions.length;
      print('${app.appName}: $dangerous dangerous permissions');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## Security Analysis

### Risk Assessment

```dart
enum RiskLevel { low, medium, high, critical }

class SecurityRisk {
  final AppPermissionInfo app;
  final RiskLevel level;
  final String reason;
  final List<String> recommendations;

  SecurityRisk({
    required this.app,
    required this.level,
    required this.reason,
    required this.recommendations,
  });
}

Future<List<SecurityRisk>> performSecurityAnalysis() async {
  final apps = await AppPermissionsChecker.getAllAppsPermissions();
  final risks = <SecurityRisk>[];

  for (final app in apps) {
    final dangerousGranted = app.grantedDangerousPermissions.length;
    final totalPermissions = app.permissions.length;
    
    // Calculate risk score
    final riskScore = dangerousGranted * 2 + totalPermissions * 0.1;
    
    RiskLevel level;
    List<String> recommendations = [];
    
    if (riskScore >= 20) {
      level = RiskLevel.critical;
      recommendations.addAll([
        'Review all granted permissions',
        'Consider uninstalling if not essential',
        'Check app reviews and reputation',
      ]);
    } else if (riskScore >= 15) {
      level = RiskLevel.high;
      recommendations.addAll([
        'Review dangerous permissions',
        'Disable unnecessary permissions',
      ]);
    } else if (riskScore >= 10) {
      level = RiskLevel.medium;
      recommendations.add('Monitor permission usage');
    } else {
      level = RiskLevel.low;
    }

    if (level != RiskLevel.low) {
      risks.add(SecurityRisk(
        app: app,
        level: level,
        reason: '$dangerousGranted dangerous permissions granted',
        recommendations: recommendations,
      ));
    }
  }

  return risks;
}
```

### Privacy Audit

```dart
class PrivacyReport {
  final int totalApps;
  final Map<String, List<AppPermissionInfo>> permissionGroups;
  final List<String> recommendations;

  PrivacyReport({
    required this.totalApps,
    required this.permissionGroups,
    required this.recommendations,
  });
}

Future<PrivacyReport> generatePrivacyReport() async {
  final apps = await AppPermissionsChecker.getAllAppsPermissions();
  
  final sensitivePermissions = {
    'Location': [
      'android.permission.ACCESS_FINE_LOCATION',
      'android.permission.ACCESS_COARSE_LOCATION',
    ],
    'Camera': ['android.permission.CAMERA'],
    'Microphone': ['android.permission.RECORD_AUDIO'],
    'Contacts': [
      'android.permission.READ_CONTACTS',
      'android.permission.WRITE_CONTACTS',
    ],
    'SMS': [
      'android.permission.SEND_SMS',
      'android.permission.READ_SMS',
    ],
    'Phone': [
      'android.permission.CALL_PHONE',
      'android.permission.READ_PHONE_STATE',
    ],
  };

  final permissionGroups = <String, List<AppPermissionInfo>>{};
  
  for (final category in sensitivePermissions.keys) {
    final permissions = sensitivePermissions[category]!;
    final appsWithPermission = apps.where((app) {
      return permissions.any((perm) => app.isPermissionGranted(perm));
    }).toList();
    
    if (appsWithPermission.isNotEmpty) {
      permissionGroups[category] = appsWithPermission;
    }
  }

  final recommendations = <String>[];
  
  if (permissionGroups['Location']?.length ?? 0 > 5) {
    recommendations.add('Too many apps have location access');
  }
  
  if (permissionGroups['Camera']?.length ?? 0 > 3) {
    recommendations.add('Review camera permissions');
  }

  return PrivacyReport(
    totalApps: apps.length,
    permissionGroups: permissionGroups,
    recommendations: recommendations,
  );
}
```

## Advanced Filtering

### Filter by Permission Categories

```dart
Future<void> analyzeByCategory() async {
  final apps = await AppPermissionsChecker.getAllAppsPermissions();
  
  final categoryStats = <String, int>{};
  
  for (final app in apps) {
    final categories = app.permissionsByCategory;
    
    for (final category in categories.keys) {
      final grantedInCategory = categories[category]!
          .where((p) => p.granted)
          .length;
      
      categoryStats[category] = 
          (categoryStats[category] ?? 0) + grantedInCategory;
    }
  }
  
  print('Permission usage by category:');
  final sortedCategories = categoryStats.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
    
  for (final entry in sortedCategories) {
    print('${entry.key}: ${entry.value} granted permissions');
  }
}
```

### Find Apps with Specific Permissions

```dart
Future<void> findAppsWithPermissions() async {
  // Find apps that can access both camera and microphone
  final suspiciousPermissions = [
    'android.permission.CAMERA',
    'android.permission.RECORD_AUDIO',
  ];
  
  final apps = await AppPermissionsChecker.getAllAppsPermissions(
    filterByPermissions: suspiciousPermissions,
  );
  
  final suspiciousApps = apps.where((app) {
    return suspiciousPermissions.every((perm) => 
      app.isPermissionGranted(perm)
    );
  }).toList();
  
  print('Apps with both camera and microphone access:');
  for (final app in suspiciousApps) {
    print('- ${app.appName} (${app.packageName})');
  }
}
```

## UI Integration

### Permission List Widget

```dart
import 'package:flutter/material.dart';

class PermissionListWidget extends StatelessWidget {
  final AppPermissionInfo app;
  
  const PermissionListWidget({Key? key, required this.app}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final categories = app.permissionsByCategory;
    
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories.keys.elementAt(index);
        final permissions = categories[category]!;
        
        return ExpansionTile(
          title: Text(category),
          subtitle: Text('${permissions.length} permissions'),
          children: permissions.map((permission) {
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
          }).toList(),
        );
      },
    );
  }
}
```

### Security Dashboard

```dart
class SecurityDashboard extends StatefulWidget {
  @override
  _SecurityDashboardState createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard> {
  List<AppPermissionInfo> apps = [];
  bool loading = true;
  
  @override
  void initState() {
    super.initState();
    _loadApps();
  }
  
  Future<void> _loadApps() async {
    try {
      final result = await AppPermissionsChecker.getAllAppsPermissions();
      setState(() {
        apps = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }
    
    final totalApps = apps.length;
    final totalPermissions = apps.fold(0, (sum, app) => sum + app.permissions.length);
    final dangerousPermissions = apps.fold(0, (sum, app) => 
      sum + app.grantedDangerousPermissions.length);
    
    return Column(
      children: [
        Row(
          children: [
            _StatCard(
              title: 'Apps',
              value: totalApps.toString(),
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Permissions',
              value: totalPermissions.toString(),
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Dangerous',
              value: dangerousPermissions.toString(),
              color: Colors.red,
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return ListTile(
                title: Text(app.appName),
                subtitle: Text('${app.grantedPermissions.length}/${app.permissions.length} granted'),
                trailing: app.grantedDangerousPermissions.isNotEmpty
                  ? Icon(Icons.warning, color: Colors.red)
                  : Icon(Icons.check, color: Colors.green),
                onTap: () => _showAppDetails(app),
              );
            },
          ),
        ),
      ],
    );
  }
  
  void _showAppDetails(AppPermissionInfo app) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PermissionListWidget(app: app),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 12)),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Error Handling

### Comprehensive Error Handling

```dart
import 'package:app_permissions_checker/app_permissions_checker.dart';

Future<void> robustPermissionCheck() async {
  try {
    final apps = await AppPermissionsChecker.getAllAppsPermissions();
    
    // Process apps...
    
  } on AppPermissionsException catch (e) {
    switch (e.code) {
      case 'PERMISSION_DENIED':
        print('QUERY_ALL_PACKAGES permission not granted');
        print('Add to AndroidManifest.xml:');
        print('<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />');
        break;
      case 'PACKAGE_NOT_FOUND':
        print('Specified package not found: ${e.message}');
        break;
      case 'SYSTEM_ERROR':
        print('Android system error: ${e.message}');
        break;
      default:
        print('Unknown plugin error: ${e.message}');
    }
  } on PlatformException catch (e) {
    print('Platform error: ${e.message}');
    print('Code: ${e.code}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

## Performance Optimization

### Batch Processing

```dart
Future<void> processLargeDataset() async {
  final allPackages = await _getAllInstalledPackages();
  
  // Process in chunks to avoid memory issues
  const chunkSize = 50;
  final chunks = <List<String>>[];
  
  for (int i = 0; i < allPackages.length; i += chunkSize) {
    final end = (i + chunkSize < allPackages.length) 
        ? i + chunkSize 
        : allPackages.length;
    chunks.add(allPackages.sublist(i, end));
  }
  
  final allApps = <AppPermissionInfo>[];
  
  for (final chunk in chunks) {
    final apps = await AppPermissionsChecker.checkPermissions(chunk);
    allApps.addAll(apps);
    
    // Small delay to prevent system overload
    await Future.delayed(Duration(milliseconds: 100));
  }
  
  print('Processed ${allApps.length} apps');
}
```

### Caching Results

```dart
class PermissionCache {
  static final Map<String, AppPermissionInfo> _cache = {};
  static DateTime? _lastUpdate;
  
  static Future<AppPermissionInfo?> getApp(String packageName) async {
    // Check if cache is still valid (1 hour)
    if (_lastUpdate != null && 
        DateTime.now().difference(_lastUpdate!).inHours < 1) {
      return _cache[packageName];
    }
    
    // Refresh cache
    await _refreshCache();
    return _cache[packageName];
  }
  
  static Future<void> _refreshCache() async {
    final apps = await AppPermissionsChecker.getAllAppsPermissions();
    
    _cache.clear();
    for (final app in apps) {
      _cache[app.packageName] = app;
    }
    
    _lastUpdate = DateTime.now();
  }
}
```

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_permissions_checker/app_permissions_checker.dart';

void main() {
  group('App Permissions Checker', () {
    test('should return valid app info', () async {
      final app = await AppPermissionsChecker.checkSingleAppPermissions(
        'com.android.settings'
      );
      
      expect(app, isNotNull);
      expect(app!.packageName, 'com.android.settings');
      expect(app.appName, isNotEmpty);
      expect(app.permissions, isNotEmpty);
    });
    
    test('should handle invalid package names', () async {
      final app = await AppPermissionsChecker.checkSingleAppPermissions(
        'com.invalid.package.name'
      );
      
      expect(app, isNull);
    });
  });
}
```

This comprehensive guide covers most use cases for the App Permissions Checker plugin. For more specific examples or advanced usage patterns, refer to the API documentation or create custom implementations based on these patterns.