package com.example.geo_fencing

import android.Manifest
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices

object NativeGeofenceHelper {

    private const val TAG = "NativeGeofenceHelper"
    private const val GEOFENCE_REQUEST_ID = "office_geofence_native"
    private const val PENDING_INTENT_REQ_CODE = 9991

    fun registerGeofence(
        context: Context,
        latitude: Double,
        longitude: Double,
        radiusMeters: Float
    ) {
        if (ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.e(TAG, "Cannot register native geofence: ACCESS_FINE_LOCATION not granted")
            return
        }

        try {
            val geofencingClient = LocationServices.getGeofencingClient(context)

            val geofence = Geofence.Builder()
                .setRequestId(GEOFENCE_REQUEST_ID)
                .setCircularRegion(latitude, longitude, radiusMeters)
                .setExpirationDuration(Geofence.NEVER_EXPIRE)
                .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER or Geofence.GEOFENCE_TRANSITION_EXIT)
                .build()

            val request = GeofencingRequest.Builder()
                .setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER)
                .addGeofence(geofence)
                .build()

            val pendingIntent = getPendingIntent(context)

            geofencingClient.addGeofences(request, pendingIntent).run {
                addOnSuccessListener {
                    Log.d(TAG, "Native Google Play Services geofence active at ($latitude, $longitude), radius ${radiusMeters}m")
                }
                addOnFailureListener { e ->
                    Log.e(TAG, "Failed to register native Google Play Services geofence: ${e.message}", e)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Exception while registering native geofence: ${e.message}", e)
        }
    }

    fun removeGeofence(context: Context) {
        try {
            val geofencingClient = LocationServices.getGeofencingClient(context)
            geofencingClient.removeGeofences(getPendingIntent(context)).run {
                addOnSuccessListener {
                    Log.d(TAG, "Native geofence removed successfully")
                }
                addOnFailureListener { e ->
                    Log.w(TAG, "Failed to remove native geofence: ${e.message}")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Exception while removing native geofence: ${e.message}", e)
        }
    }

    private fun getPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, NativeGeofenceReceiver::class.java)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getBroadcast(context, PENDING_INTENT_REQ_CODE, intent, flags)
    }
}
