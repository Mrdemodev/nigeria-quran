package com.nigeriaquran.nigeria_quran

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

// Reschedules prayer notifications after phone reboot.
// Android clears all scheduled alarms on restart; this receiver re-triggers
// the Flutter notification scheduling via a one-time service start.
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        val serviceIntent = Intent(context, ReschedulerService::class.java)
        context.startForegroundService(serviceIntent)
    }
}
