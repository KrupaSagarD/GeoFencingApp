package com.example.geo_fencing

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingEvent
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class NativeGeofenceReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "NativeGeofenceReceiver"
        private const val CHANNEL_ID = "attendance_notifications"
        private const val NOTIFICATION_ID = 1001
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Native geofence broadcast received with action: ${intent.action}")

        // Handle reboot
        if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
            Log.d(TAG, "Boot completed received. Re-registering geofence if configured...")
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val lat = prefs.getString("flutter.office_lat", null)?.toDoubleOrNull() ?: 12.9328497
            val lng = prefs.getString("flutter.office_lng", null)?.toDoubleOrNull() ?: 77.5400525
            NativeGeofenceHelper.registerGeofence(context, lat, lng, 100f)
            return
        }

        val geofencingEvent = GeofencingEvent.fromIntent(intent)
        if (geofencingEvent == null) {
            Log.w(TAG, "GeofencingEvent is null")
            return
        }

        if (geofencingEvent.hasError()) {
            Log.e(TAG, "GeofencingEvent error code: ${geofencingEvent.errorCode}")
            return
        }

        val transition = geofencingEvent.geofenceTransition
        Log.d(TAG, "Geofence transition: $transition")

        if (transition == Geofence.GEOFENCE_TRANSITION_EXIT) {
            handleExit(context)
        }
    }

    private fun handleExit(context: Context) {
        Log.d(TAG, "Handling office EXIT in native receiver...")

        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isCheckedIn = prefs.getBoolean("flutter.officecheck_checked_in", false)

        Log.d(TAG, "Current checked in status in native receiver: $isCheckedIn")

        if (!isCheckedIn) {
            Log.d(TAG, "User is not checked in. Ignoring EXIT event.")
            return
        }

        val now = Date()
        val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US)
        val dateKeyFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US)
        val nowIso = isoFormat.format(now)
        val today = dateKeyFormat.format(now)

        try {
            val rawHistory = prefs.getString("flutter.officecheck_attendance_history", null)
            val records = if (rawHistory != null) JSONArray(rawHistory) else JSONArray()

            var todayRecord: JSONObject? = null
            for (i in 0 until records.length()) {
                val record = records.getJSONObject(i)
                if (record.optString("date") == today) {
                    todayRecord = record
                    break
                }
            }

            if (todayRecord != null) {
                val sessions = todayRecord.optJSONArray("sessions") ?: JSONArray()
                for (i in sessions.length() - 1 downTo 0) {
                    val session = sessions.getJSONObject(i)
                    if (session.has("checkInTime") && (!session.has("checkOutTime") || session.isNull("checkOutTime"))) {
                        session.put("checkOutTime", nowIso)
                        session.put("checkOutType", "geofence")
                        Log.d(TAG, "Updated session $i with checkout time: $nowIso")
                        break
                    }
                }
                todayRecord.put("sessions", sessions)
            }

            prefs.edit()
                .putBoolean("flutter.officecheck_checked_in", false)
                .putString("flutter.officecheck_check_out_time", nowIso)
                .putString("flutter.officecheck_attendance_history", records.toString())
                .apply()

            Log.d(TAG, "Successfully recorded auto-checkout in SharedPreferences from native receiver")

        } catch (e: Exception) {
            Log.e(TAG, "Error updating SharedPreferences: ${e.message}", e)
            prefs.edit()
                .putBoolean("flutter.officecheck_checked_in", false)
                .putString("flutter.officecheck_check_out_time", nowIso)
                .apply()
        }

        // Show immediate system notification
        showNotification(context)
    }

    private fun showNotification(context: Context) {
        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Attendance Notifications",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Office check-in and checkout alerts"
                    enableVibration(true)
                    setShowBadge(true)
                }
                notificationManager.createNotificationChannel(channel)
            }

            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntent = if (launchIntent != null) {
                val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
                PendingIntent.getActivity(context, 0, launchIntent, flags)
            } else null

            val notification = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("Automatic Checkout Successful")
                .setContentText("You have been checked out because you left the office area.")
                .setStyle(NotificationCompat.BigTextStyle().bigText("You have been checked out because you left the office area."))
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)
                .build()

            NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification)
            Log.d(TAG, "Notification successfully posted from native receiver!")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to show notification from native receiver: ${e.message}", e)
        }
    }
}
