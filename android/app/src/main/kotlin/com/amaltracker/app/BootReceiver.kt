package com.amaltracker.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Listens for BOOT_COMPLETED and sets a SharedPreferences flag so that
 * the Dart side can detect the boot and reschedule default rolling-window
 * notifications the next time DailyReminderService.initialize() runs.
 *
 * Note: repeating notifications scheduled with matchDateTimeComponents
 * are already restored automatically by flutter_local_notifications'
 * own ScheduledNotificationBootReceiver. This receiver only handles
 * the one-shot rolling-window defaults that Android wipes on reboot.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != "android.intent.action.QUICKBOOT_POWERON" &&
            intent.action != "com.htc.intent.action.QUICKBOOT_POWERON"
        ) return

        try {
            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE
            )
            prefs.edit()
                .putBoolean("flutter.needs_boot_reschedule", true)
                .apply()

            Log.d("BootReceiver", "Boot detected — flag set for default reminder rescheduling")
        } catch (e: Exception) {
            Log.e("BootReceiver", "Failed to set boot flag: ${e.message}")
        }
    }
}
