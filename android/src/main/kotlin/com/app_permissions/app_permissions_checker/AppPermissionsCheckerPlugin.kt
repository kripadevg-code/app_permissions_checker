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

/** AppPermissionsCheckerPlugin */
class AppPermissionsCheckerPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  // Background executor to avoid blocking the main thread
  private val executor = Executors.newFixedThreadPool(2)
  private val mainHandler = Handler(Looper.getMainLooper())

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app_permissions_checker")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
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
        val filterByPermissions = call.argument<List<String>>("filterByPermissions") ?: emptyList()
        runAsync(
          task = { getAllAppsPermissions(includeSystemApps, filterByPermissions) },
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
        mainHandler.post { onSuccess(r) }
      } catch (e: Exception) {
        mainHandler.post { onError(e) }
      }
    }
  }

  private fun checkPermissions(packageNames: List<String>, includeSystemApps: Boolean): List<Map<String, Any>> {
    val packageManager = context.packageManager
    val results = mutableListOf<Map<String, Any>>()

    for (packageName in packageNames) {
      try {
        val packageInfo = getPackageInfoCompat(packageName, PackageManager.GET_PERMISSIONS)
        val appInfo = createAppInfoMap(packageInfo, packageManager, includeSystemApps)
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
      createAppInfoMap(packageInfo, packageManager, true)
    } catch (e: PackageManager.NameNotFoundException) {
      null
    }
  }

  private fun getAllAppsPermissions(includeSystemApps: Boolean, filterByPermissions: List<String>): List<Map<String, Any>> {
    val packageManager = context.packageManager
    val apps = getInstalledPackagesCompat(PackageManager.GET_PERMISSIONS)
    val results = mutableListOf<Map<String, Any>>()

    for (packageInfo in apps) {
      val appInfo = createAppInfoMap(packageInfo, packageManager, includeSystemApps)
      if (appInfo != null) {
        if (filterByPermissions.isEmpty() || hasAnyPermission(packageInfo, filterByPermissions)) {
          results.add(appInfo)
        }
      }
    }

    return results
  }

  private fun createAppInfoMap(packageInfo: PackageInfo, packageManager: PackageManager, includeSystemApps: Boolean): Map<String, Any>? {
    val ai = packageInfo.applicationInfo
    val isSystemApp = (((ai?.flags) ?: 0) and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0
    
    if (!includeSystemApps && isSystemApp) {
      return null
    }

    val appName = try {
      val appInfo = packageInfo.applicationInfo
      if (appInfo != null) packageManager.getApplicationLabel(appInfo).toString() else packageInfo.packageName
    } catch (e: Exception) {
      packageInfo.packageName
    }

    val permissions = packageInfo.requestedPermissions?.mapIndexed { index, permission ->
      val isGranted = packageInfo.requestedPermissionsFlags?.get(index)?.let { flags ->
        (flags and PackageInfo.REQUESTED_PERMISSION_GRANTED) != 0
      } ?: false

      mapOf(
        "permission" to permission,
        "granted" to isGranted,
        "protectionLevel" to getPermissionProtectionLevel(permission, packageManager),
        "description" to getPermissionDescription(permission, packageManager)
      )
    } ?: emptyList()

    return mapOf(
      "appName" to appName,
      "packageName" to packageInfo.packageName,
      "versionName" to (packageInfo.versionName ?: "Unknown"),
      "versionCode" to packageInfo.longVersionCode,
      "permissions" to permissions,
      "isSystemApp" to isSystemApp,
      "installTime" to packageInfo.firstInstallTime
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