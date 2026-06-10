package com.nigeriaquran.nigeria_quran

import android.content.Context
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.nigeriaquran/prefs"
        ).setMethodCallHandler { call, result ->
            if (call.method == "clearScheduledNotifications") {
                // Clear the named SharedPreferences file used by flutter_local_notifications
                val prefs = getSharedPreferences("scheduled_notifications", Context.MODE_PRIVATE)
                prefs.edit().clear().apply()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
