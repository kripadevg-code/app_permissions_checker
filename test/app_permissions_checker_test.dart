import 'package:app_permissions_checker/app_permissions_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppPermissionInfo', () {
    test('should create from map correctly', () {
      final map = {
        'appName': 'Test App',
        'packageName': 'com.test.app',
        'versionName': '1.0.0',
        'versionCode': 1,
        'isSystemApp': false,
        'installTime': 1640995200000, // 2022-01-01
        'permissions': [
          {
            'permission': 'android.permission.CAMERA',
            'readableName': 'Camera',
            'granted': true,
            'protectionLevel': 'dangerous',
            'category': 'Camera',
          }
        ],
      };

      final appInfo = AppPermissionInfo.fromMap(map);

      expect(appInfo.appName, 'Test App');
      expect(appInfo.packageName, 'com.test.app');
      expect(appInfo.versionName, '1.0.0');
      expect(appInfo.versionCode, 1);
      expect(appInfo.isSystemApp, false);
      expect(appInfo.permissions.length, 1);
      expect(appInfo.installTime, DateTime.fromMillisecondsSinceEpoch(1640995200000));
    });

    test('should convert to map correctly', () {
      const permission = PermissionDetail(
        permission: 'android.permission.CAMERA',
        readableName: 'Camera',
        granted: true,
        protectionLevel: 'dangerous',
        category: 'Camera',
      );

      final appInfo = AppPermissionInfo(
        appName: 'Test App',
        packageName: 'com.test.app',
        versionName: '1.0.0',
        versionCode: 1,
        permissions: const [permission],
        isSystemApp: false,
        installTime: DateTime.fromMillisecondsSinceEpoch(1640995200000),
      );

      final map = appInfo.toMap();

      expect(map['appName'], 'Test App');
      expect(map['packageName'], 'com.test.app');
      expect(map['versionName'], '1.0.0');
      expect(map['versionCode'], 1);
      expect(map['isSystemApp'], false);
      expect(map['installTime'], 1640995200000);
      expect(map['permissions'], isA<List<Map<String, dynamic>>>());
    });

    test('should filter granted permissions correctly', () {
      final permissions = [
        const PermissionDetail(
          permission: 'android.permission.CAMERA',
          readableName: 'Camera',
          granted: true,
          protectionLevel: 'dangerous',
          category: 'Camera',
        ),
        const PermissionDetail(
          permission: 'android.permission.LOCATION',
          readableName: 'Location',
          granted: false,
          protectionLevel: 'dangerous',
          category: 'Location',
        ),
      ];

      final appInfo = AppPermissionInfo(
        appName: 'Test App',
        packageName: 'com.test.app',
        permissions: permissions,
        isSystemApp: false,
      );

      expect(appInfo.grantedPermissions.length, 1);
      expect(appInfo.grantedPermissions.first.permission, 'android.permission.CAMERA');
      expect(appInfo.deniedPermissions.length, 1);
      expect(appInfo.deniedPermissions.first.permission, 'android.permission.LOCATION');
    });

    test('should filter dangerous permissions correctly', () {
      final permissions = [
        const PermissionDetail(
          permission: 'android.permission.CAMERA',
          readableName: 'Camera',
          granted: true,
          protectionLevel: 'dangerous',
          category: 'Camera',
        ),
        const PermissionDetail(
          permission: 'android.permission.INTERNET',
          readableName: 'Internet',
          granted: true,
          protectionLevel: 'normal',
          category: 'Network',
        ),
      ];

      final appInfo = AppPermissionInfo(
        appName: 'Test App',
        packageName: 'com.test.app',
        permissions: permissions,
        isSystemApp: false,
      );

      expect(appInfo.dangerousPermissions.length, 1);
      expect(appInfo.dangerousPermissions.first.permission, 'android.permission.CAMERA');
      expect(appInfo.grantedDangerousPermissions.length, 1);
    });

    test('should check permission existence correctly', () {
      final permissions = [
        const PermissionDetail(
          permission: 'android.permission.CAMERA',
          readableName: 'Camera',
          granted: true,
          protectionLevel: 'dangerous',
          category: 'Camera',
        ),
      ];

      final appInfo = AppPermissionInfo(
        appName: 'Test App',
        packageName: 'com.test.app',
        permissions: permissions,
        isSystemApp: false,
      );

      expect(appInfo.hasPermission('android.permission.CAMERA'), true);
      expect(appInfo.hasPermission('android.permission.LOCATION'), false);
      expect(appInfo.isPermissionGranted('android.permission.CAMERA'), true);
    });

    test('should group permissions by category correctly', () {
      final permissions = [
        const PermissionDetail(
          permission: 'android.permission.CAMERA',
          readableName: 'Camera',
          granted: true,
          protectionLevel: 'dangerous',
          category: 'Camera',
        ),
        const PermissionDetail(
          permission: 'android.permission.RECORD_AUDIO',
          readableName: 'Microphone',
          granted: false,
          protectionLevel: 'dangerous',
          category: 'Microphone',
        ),
        const PermissionDetail(
          permission: 'android.permission.ACCESS_FINE_LOCATION',
          readableName: 'Fine Location',
          granted: true,
          protectionLevel: 'dangerous',
          category: 'Location',
        ),
      ];

      final appInfo = AppPermissionInfo(
        appName: 'Test App',
        packageName: 'com.test.app',
        permissions: permissions,
        isSystemApp: false,
      );

      final grouped = appInfo.permissionsByCategory;

      expect(grouped.keys.length, 3);
      expect(grouped['Camera']?.length, 1);
      expect(grouped['Microphone']?.length, 1);
      expect(grouped['Location']?.length, 1);
    });

    test('should handle equality correctly', () {
      const appInfo1 = AppPermissionInfo(
        appName: 'Test App',
        packageName: 'com.test.app',
        permissions: [],
        isSystemApp: false,
      );

      const appInfo2 = AppPermissionInfo(
        appName: 'Different Name',
        packageName: 'com.test.app',
        permissions: [],
        isSystemApp: true,
      );

      const appInfo3 = AppPermissionInfo(
        appName: 'Test App',
        packageName: 'com.different.app',
        permissions: [],
        isSystemApp: false,
      );

      expect(appInfo1 == appInfo2, true); // Same package name
      expect(appInfo1 == appInfo3, false); // Different package name
      expect(appInfo1.hashCode, appInfo2.hashCode);
    });
  });

  group('PermissionDetail', () {
    test('should create from map correctly', () {
      final map = {
        'permission': 'android.permission.CAMERA',
        'readableName': 'Camera',
        'granted': true,
        'protectionLevel': 'dangerous',
        'category': 'Camera',
      };

      final permission = PermissionDetail.fromMap(map);

      expect(permission.permission, 'android.permission.CAMERA');
      expect(permission.readableName, 'Camera');
      expect(permission.granted, true);
      expect(permission.protectionLevel, 'dangerous');
      expect(permission.category, 'Camera');
    });

    test('should convert to map correctly', () {
      const permission = PermissionDetail(
        permission: 'android.permission.CAMERA',
        readableName: 'Camera',
        granted: true,
        protectionLevel: 'dangerous',
        category: 'Camera',
      );

      final map = permission.toMap();

      expect(map['permission'], 'android.permission.CAMERA');
      expect(map['readableName'], 'Camera');
      expect(map['granted'], true);
      expect(map['protectionLevel'], 'dangerous');
      expect(map['category'], 'Camera');
    });

    test('should identify protection levels correctly', () {
      const dangerousPermission = PermissionDetail(
        permission: 'android.permission.CAMERA',
        readableName: 'Camera',
        granted: true,
        protectionLevel: 'dangerous',
        category: 'Camera',
      );

      const normalPermission = PermissionDetail(
        permission: 'android.permission.INTERNET',
        readableName: 'Internet',
        granted: true,
        protectionLevel: 'normal',
        category: 'Network',
      );

      const signaturePermission = PermissionDetail(
        permission: 'android.permission.SYSTEM_ALERT_WINDOW',
        readableName: 'System Alert',
        granted: false,
        protectionLevel: 'signature',
        category: 'System',
      );

      expect(dangerousPermission.isDangerous, true);
      expect(dangerousPermission.isNormal, false);
      expect(dangerousPermission.isSignature, false);

      expect(normalPermission.isDangerous, false);
      expect(normalPermission.isNormal, true);
      expect(normalPermission.isSignature, false);

      expect(signaturePermission.isDangerous, false);
      expect(signaturePermission.isNormal, false);
      expect(signaturePermission.isSignature, true);
    });

    test('should handle equality correctly', () {
      const permission1 = PermissionDetail(
        permission: 'android.permission.CAMERA',
        readableName: 'Camera',
        granted: true,
        protectionLevel: 'dangerous',
        category: 'Camera',
      );

      const permission2 = PermissionDetail(
        permission: 'android.permission.CAMERA',
        readableName: 'Different Name',
        granted: false,
        protectionLevel: 'normal',
        category: 'Different',
      );

      const permission3 = PermissionDetail(
        permission: 'android.permission.LOCATION',
        readableName: 'Camera',
        granted: true,
        protectionLevel: 'dangerous',
        category: 'Camera',
      );

      expect(permission1 == permission2, true); // Same permission name
      expect(permission1 == permission3, false); // Different permission name
      expect(permission1.hashCode, permission2.hashCode);
    });

    test('should generate readable string representation', () {
      const permission = PermissionDetail(
        permission: 'android.permission.CAMERA',
        readableName: 'Camera',
        granted: true,
        protectionLevel: 'dangerous',
        category: 'Camera',
      );

      final string = permission.toString();
      expect(string, contains('Camera'));
      expect(string, contains('android.permission.CAMERA'));
      expect(string, contains('true'));
    });
  });
}
