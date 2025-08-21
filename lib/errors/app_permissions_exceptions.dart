/// Exception thrown when app permissions checking fails
class AppPermissionsException implements Exception {
  /// Creates a new [AppPermissionsException].
  const AppPermissionsException(this.message, [this.code]);

  /// The error message describing what went wrong.
  final String message;

  /// An optional error code providing additional context.
  final String? code;

  @override
  String toString() => 'AppPermissionsException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when a package is not found
class PackageNotFoundException extends AppPermissionsException {
  /// Creates a new [PackageNotFoundException].

  const PackageNotFoundException(String packageName) : super('Package not found: $packageName', 'PACKAGE_NOT_FOUND');
}

/// Exception thrown when permission checking is not supported on the platform
class PlatformNotSupportedException extends AppPermissionsException {
  /// Creates a new [PlatformNotSupportedException].
  const PlatformNotSupportedException() : super('Permission checking is not supported on this platform', 'PLATFORM_NOT_SUPPORTED');
}
