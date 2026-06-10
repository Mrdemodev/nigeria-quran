package com.nigeriaquran.nigeria_quran

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat

// Minimal foreground service that launches the Flutter engine just long enough
// to reschedule prayer notifications, then stops itself.
class ReschedulerService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground()
        // Launch the main activity in background mode to re-trigger notification scheduling
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("reschedule_notifications", true)
        }
        if (launchIntent != null) startActivity(launchIntent)
        stopSelf(startId)
        return START_NOT_STICKY
    }

    private fun startForeground() {
        val channelId = "reschedule_channel"
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(channelId, "Prayer Reschedule", NotificationManager.IMPORTANCE_MIN)
        )
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Quran NG")
            .setContentText("Restoring prayer notifications...")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .build()
        startForeground(999, notification)
    }
}
