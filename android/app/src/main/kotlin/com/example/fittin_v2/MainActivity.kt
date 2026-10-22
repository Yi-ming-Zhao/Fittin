package com.example.fittin_v2

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat

class MainActivity : FlutterActivity() {
    private var notificationReply: MethodChannel.Result? = null

    private fun backgroundStatus(): Map<String, Boolean> {
        val power = getSystemService(POWER_SERVICE) as PowerManager
        return mapOf(
            "notificationsEnabled" to NotificationManagerCompat.from(this).areNotificationsEnabled(),
            "batteryUnrestricted" to (Build.VERSION.SDK_INT < 23 || power.isIgnoringBatteryOptimizations(packageName)),
            "powerSaveMode" to power.isPowerSaveMode
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fittin/cardio-background")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "status" -> result.success(backgroundStatus())
                    "requestNotification" -> {
                        if (Build.VERSION.SDK_INT >= 33 &&
                            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED &&
                            notificationReply == null) {
                            notificationReply = result
                            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 7412)
                        } else {
                            result.success(backgroundStatus())
                        }
                    }
                    "openSettings" -> {
                        try {
                            startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                Uri.parse("package:$packageName")))
                            result.success(true)
                        } catch (_: Exception) {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 7412) {
            notificationReply?.success(backgroundStatus())
            notificationReply = null
        }
    }

    override fun onDestroy() {
        notificationReply?.success(null)
        notificationReply = null
        super.onDestroy()
    }
}
