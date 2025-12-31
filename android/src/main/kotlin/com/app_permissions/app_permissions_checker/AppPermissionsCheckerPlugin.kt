package com.app_permissions.app_permissions_checker

import android.os.Build
import android.os.Handler
import android.os.Looper
import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.PermissionInfo
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.Executors
import android.content.pm.ApplicationInfo    

/** AppPermissionsCheckerPlugin */
class AppPermissionsCheckerPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  // Background executor to avoid blocking the main thread
  private val executor = Executors.newFixedThreadPool(2)
  // Lazily initialize to avoid Android Looper dependency during plain JVM unit tests
  private val mainHandler: Handler by lazy { Handler(Looper.getMainLooper()) }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app_permissions_checker")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      // For backward compatibility with the template test
      "getPlatformVersion" -> {
        result.success("Android " + Build.VERSION.RELEASE)
      }
      "checkPermissions" -> {
        val packageNames = call.argument<List<String>>("packageNames") ?: emptyList()
        val includeSystemApps = call.argument<Boolean>("includeSystemApps") ?: false
        runAsync(
          task = { checkPermissions(packageNames, includeSystemApps) },
          onSuccess = { data -> result.success(data) },
          onError = { e -> result.error("PLUGIN_ERROR", e.message, null) }
        )
      }
      "checkSingleAppPermissions" -> {
        val packageName = call.argument<String>("packageName")
        if (packageName != null) {
          runAsync(
            task = { checkSingleAppPermissions(packageName) },
            onSuccess = { data -> result.success(data) },
            onError = { e -> result.error("PLUGIN_ERROR", e.message, null) }
          )
        } else {
          result.error("INVALID_ARGUMENT", "Package name is required", null)
        }
      }
      "getAllAppsPermissions" -> {
        val includeSystemApps = call.argument<Boolean>("includeSystemApps") ?: false
        val onlyUsefulApps = call.argument<Boolean>("onlyUsefulApps") ?: false
        val filterByPermissions = call.argument<List<String>>("filterByPermissions") ?: emptyList()
        runAsync(
          task = { getAllAppsPermissions(includeSystemApps, onlyUsefulApps, filterByPermissions) },
          onSuccess = { data -> result.success(data) },
          onError = { e -> result.error("PLUGIN_ERROR", e.message, null) }
        )
      }
      "isPermissionGranted" -> {
        val packageName = call.argument<String>("packageName")
        val permission = call.argument<String>("permission")
        if (packageName != null && permission != null) {
          runAsync(
            task = { isPermissionGranted(packageName, permission) },
            onSuccess = { data -> result.success(data) },
            onError = { e -> result.error("PLUGIN_ERROR", e.message, null) }
          )
        } else {
          result.error("INVALID_ARGUMENT", "Package name and permission are required", null)
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun <T> runAsync(task: () -> T, onSuccess: (T) -> Unit, onError: (Exception) -> Unit) {
    executor.execute {
      try {
        val r = task()
        postToMain { onSuccess(r) }
      } catch (e: Exception) {
        postToMain { onError(e) }
      }
    }
  }

  // Post to main thread if available; otherwise run immediately (useful for JVM unit tests)
  private fun postToMain(action: () -> Unit) {
    val mainLooper = try { Looper.getMainLooper() } catch (_: Throwable) { null }
    if (mainLooper != null) {
      mainHandler.post(action)
    } else {
      action()
    }
  }

  private fun checkPermissions(packageNames: List<String>, includeSystemApps: Boolean): List<Map<String, Any>> {
    val packageManager = context.packageManager
    val results = mutableListOf<Map<String, Any>>()

    for (packageName in packageNames) {
      try {
        val packageInfo = getPackageInfoCompat(packageName, PackageManager.GET_PERMISSIONS)
        val appInfo = createAppInfoMap(packageInfo, packageManager, includeSystemApps, false)
        if (appInfo != null) {
          results.add(appInfo)
        }
      } catch (e: PackageManager.NameNotFoundException) {
        // Package not found, skip silently
      }
    }

    return results
  }

  private fun checkSingleAppPermissions(packageName: String): Map<String, Any>? {
    return try {
      val packageManager = context.packageManager
      val packageInfo = getPackageInfoCompat(packageName, PackageManager.GET_PERMISSIONS)
      createAppInfoMap(packageInfo, packageManager, true, false)
    } catch (e: PackageManager.NameNotFoundException) {
      null
    }
  }

  private fun getAllAppsPermissions(includeSystemApps: Boolean, onlyUsefulApps: Boolean, filterByPermissions: List<String>): List<Map<String, Any>> {
    val packageManager = context.packageManager
    val apps = getInstalledPackagesCompat(PackageManager.GET_PERMISSIONS)
    val results = mutableListOf<Map<String, Any>>()

    for (packageInfo in apps) {
      val appInfo = createAppInfoMap(packageInfo, packageManager, includeSystemApps, onlyUsefulApps)
      if (appInfo != null) {
        if (filterByPermissions.isEmpty() || hasAnyPermission(packageInfo, filterByPermissions)) {
          results.add(appInfo)
        }
      }
    }

    return results
  }
 
private fun createAppInfoMap(
  packageInfo: PackageInfo,
  packageManager: PackageManager,
  includeSystemApps: Boolean,
  onlyUsefulApps: Boolean = false
): Map<String, Any>? {

  val isSystemApp = ((packageInfo.applicationInfo?.flags ?: 0) and ApplicationInfo.FLAG_SYSTEM) != 0
  val isUpdatedSystemApp = ((packageInfo.applicationInfo?.flags ?: 0) and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
  val isUsefulApp = !isSystemApp || isUpdatedSystemApp

  // Filter logic
  if (!includeSystemApps && isSystemApp) {
    return null
  }
  
  // onlyUsefulApps only works when includeSystemApps is true
  if (includeSystemApps && onlyUsefulApps && isSystemApp && !isUpdatedSystemApp) {
    return null
  }

  val installer = try {
    packageManager.getInstallerPackageName(packageInfo.packageName)
  } catch (_: Exception) { null }

  val permissions = packageInfo.requestedPermissions?.mapIndexed { index, permission ->
    val granted = packageInfo.requestedPermissionsFlags?.get(index)?.let { f ->
      (f and PackageInfo.REQUESTED_PERMISSION_GRANTED) != 0
    } ?: false

    mapOf(
      "permission" to permission,
      "granted" to granted,
      "protectionLevel" to getPermissionProtectionLevel(permission, packageManager),
      "description" to getPermissionDescription(permission, packageManager),
      "readableName" to getReadablePermissionName(permission),
      "category" to getPermissionCategory(permission)
    )
  } ?: emptyList()

  val appName = try {
    packageInfo.applicationInfo?.let { appInfo ->
      packageManager.getApplicationLabel(appInfo).toString()
    } ?: packageInfo.packageName
  } catch (_: Exception) {
    packageInfo.packageName
  }

  return mapOf(
    "appName" to appName,
    "packageName" to packageInfo.packageName,
    "versionName" to (packageInfo.versionName ?: "Unknown"),
    "versionCode" to packageInfo.longVersionCode,
    "isUpdatedSystemApp" to isUpdatedSystemApp,
    "isInternalApp" to isSystemApp,
    "isExternalApp" to !isSystemApp,
    "installerSource" to (installer ?: ""),
    "installTime" to packageInfo.firstInstallTime,
    "permissions" to permissions
  )
}

  

  private fun getPermissionProtectionLevel(permission: String, packageManager: PackageManager): String {
    return try {
      val permissionInfo = packageManager.getPermissionInfo(permission, 0)
      when (permissionInfo.protectionLevel and PermissionInfo.PROTECTION_MASK_BASE) {
        PermissionInfo.PROTECTION_NORMAL -> "normal"
        PermissionInfo.PROTECTION_DANGEROUS -> "dangerous"
        PermissionInfo.PROTECTION_SIGNATURE -> "signature"
        PermissionInfo.PROTECTION_SIGNATURE_OR_SYSTEM -> "signatureOrSystem"
        else -> "unknown"
      }
    } catch (e: Exception) {
      "unknown"
    }
  }

  private fun getPermissionDescription(permission: String, packageManager: PackageManager): String? {
    return try {
      val permissionInfo = packageManager.getPermissionInfo(permission, 0)
      permissionInfo.loadDescription(packageManager)?.toString()
    } catch (e: Exception) {
      null
    }
  }

  private fun getReadablePermissionName(permission: String): String {
    return permission.substringAfterLast(".").split("_")
      .joinToString(" ") { it.lowercase().replaceFirstChar { char -> char.uppercase() } }
  }

  private fun getPermissionCategory(permission: String): String {
    return when {
      permission.contains("CAMERA") -> "Camera"
      permission.contains("LOCATION") -> "Location"
      permission.contains("MICROPHONE") || permission.contains("RECORD_AUDIO") -> "Microphone"
      permission.contains("PHONE") || permission.contains("CALL") -> "Phone"
      permission.contains("SMS") || permission.contains("MESSAGE") -> "SMS"
      permission.contains("CONTACTS") -> "Contacts"
      permission.contains("STORAGE") -> "Storage"
      else -> "Other"
    }
  }

  private fun hasAnyPermission(packageInfo: PackageInfo, permissions: List<String>): Boolean {
    return packageInfo.requestedPermissions?.any { it in permissions } ?: false
  }

  private fun isPermissionGranted(packageName: String, permission: String): Boolean {
    return try {
      val packageManager = context.packageManager
      val packageInfo = getPackageInfoCompat(packageName, PackageManager.GET_PERMISSIONS)
      val index = packageInfo.requestedPermissions?.indexOf(permission) ?: -1
      
      if (index >= 0 && packageInfo.requestedPermissionsFlags != null && index < packageInfo.requestedPermissionsFlags!!.size) {
        (packageInfo.requestedPermissionsFlags!![index] and PackageInfo.REQUESTED_PERMISSION_GRANTED) != 0
      } else {
        false
      }
    } catch (e: Exception) {
      false
    }
  }

  // region Compatibility helpers for API 33+
  private fun getPackageInfoCompat(packageName: String, flags: Int): PackageInfo {
    val pm = context.packageManager
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      pm.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(flags.toLong()))
    } else {
      @Suppress("DEPRECATION")
      pm.getPackageInfo(packageName, flags)
    }
  }

  private fun getInstalledPackagesCompat(flags: Int): List<PackageInfo> {
    val pm = context.packageManager
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      pm.getInstalledPackages(PackageManager.PackageInfoFlags.of(flags.toLong()))
    } else {
      @Suppress("DEPRECATION")
      pm.getInstalledPackages(flags)
    }
  }
  // endregion

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    executor.shutdownNow()
  }
}