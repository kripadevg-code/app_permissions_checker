import 'package:flutter/foundation.dart';

/// Represents a single permission with its status and metadata
@immutable
class PermissionDetail {
  /// Creates a new [PermissionDetail] instance.
  const PermissionDetail({
    required this.permission,
    required this.granted,
    required this.protectionLevel,
    this.description,
    String? readableName,
    String? category,
  })  : _readableName = readableName,
        _category = category;

  /// Create a [PermissionDetail] from a loosely-typed map (from platform channels)
  factory PermissionDetail.fromMap(Map map) => PermissionDetail(
        permission: map['permission'] as String? ?? '',
        granted: map['granted'] as bool? ?? false,
        protectionLevel: map['protectionLevel'] as String? ?? 'unknown',
        description: map['description'] as String?,
        readableName: map['readableName'] as String?,
        category: map['category'] as String?,
      );

  /// The full permission string (e.g., 'android.permission.CAMERA')
  final String permission;

  /// Whether this permission is currently granted
  final bool granted;

  /// The protection level of this permission ('normal', 'dangerous', etc.)
  final String protectionLevel;

  /// Human-readable description of the permission (if available)
  final String? description;

  // Optional override fields for readability and category grouping
  final String? _readableName;
  final String? _category;

  /// Convert this [PermissionDetail] to a map
  Map<String, dynamic> toMap() => {
        'permission': permission,
        'granted': granted,
        'protectionLevel': protectionLevel,
        'description': description,
        'readableName': readableName,
        'category': category,
      };

  /// Get a human-readable name for this permission (computed if not provided)
  String get readableName {
    if (_readableName != null && _readableName!.trim().isNotEmpty) {
      return _readableName!;
    }
    return permission.split('.').last.replaceAll('_', ' ').toLowerCase().split(' ').map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
  }

  /// Get the category this permission belongs to (computed if not provided)
  String get category {
    if (_category != null && _category!.trim().isNotEmpty) {
      return _category!;
    }

    final permissionLower = permission.toLowerCase();

    if (permissionLower.contains('camera')) {
      return 'Camera';
    }
    if (permissionLower.contains('location') || permissionLower.contains('gps')) {
      return 'Location';
    }
    if (permissionLower.contains('microphone') || permissionLower.contains('record_audio')) {
      return 'Microphone';
    }
    if (permissionLower.contains('storage') || permissionLower.contains('external_storage')) {
      return 'Storage';
    }
    if (permissionLower.contains('contacts')) {
      return 'Contacts';
    }
    if (permissionLower.contains('phone') || permissionLower.contains('call')) {
      return 'Phone';
    }
    if (permissionLower.contains('sms') || permissionLower.contains('message')) {
      return 'SMS';
    }
    if (permissionLower.contains('calendar')) {
      return 'Calendar';
    }
    if (permissionLower.contains('bluetooth')) {
      return 'Bluetooth';
    }

    return 'Other';
  }

  /// Whether this is a dangerous permission
  bool get isDangerous => protectionLevel == 'dangerous';

  /// Whether this is a normal permission
  bool get isNormal => protectionLevel == 'normal';

  /// Whether this is a signature permission
  bool get isSignature => protectionLevel == 'signature';

  // ----- Genuine sensitivity heuristics (to avoid scaring users) -----

  /// Lowercased permission string for checks
  String get _p => permission.toLowerCase();

  /// Permissions that are typically benign/expected and should not be flagged as risky.
  bool get isRoutineOperational => _containsAny([
        'internet',
        'vibrate',
        'wake_lock',
        'access_network_state',
        'change_network_state',
        'post_notifications',
        'foreground_service',
        'receive_boot_completed',
        'schedule_exact_alarm',
      ]);

  /// Heuristic for genuinely sensitive permissions that impact user privacy/safety.
  /// We only consider them when they are actually granted.
  bool get isGenuineRisk {
    if (!granted) {
      return false;
    }
    if (!isDangerous) {
      return false; // start from Android classification
    }
    if (isRoutineOperational) {
      return false; // filter out benign cases
    }

    return _containsAny([
      'camera',
      'record_audio',
      'microphone',
      'access_fine_location',
      'access_coarse_location',
      'precise_location',
      'background_location',
      'location',
      'read_contacts',
      'write_contacts',
      'contacts',
      'read_sms',
      'send_sms',
      'receive_sms',
      'sms',
      'read_call_log',
      'write_call_log',
      'call_log',
      'process_outgoing_calls',
      'read_phone_state',
      'phone',
      'read_calendar',
      'write_calendar',
      'calendar',
      'body_sensors',
      'activity_recognition',
      'health',
      'read_external_storage',
      'write_external_storage',
      'manage_external_storage',
      'media_location',
    ]);
  }

  bool _containsAny(List<String> parts) => parts.any((k) => _p.contains(k));

  @override
  bool operator ==(Object other) => identical(this, other) || other is PermissionDetail && runtimeType == other.runtimeType && permission == other.permission;

  @override
  int get hashCode => permission.hashCode;

  @override
  String toString() => 'PermissionDetail{permission: $permission, readableName: $readableName, granted: $granted, protectionLevel: $protectionLevel, category: $category}';
}
