package com.example.geo_fencing

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.geo_fencing/geofence"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "registerGeofence" -> {
                    val lat = call.argument<Double>("latitude") ?: 12.9328497
                    val lng = call.argument<Double>("longitude") ?: 77.5400525
                    val radius = (call.argument<Double>("radius") ?: 100.0).toFloat()
                    NativeGeofenceHelper.registerGeofence(this, lat, lng, radius)
                    result.success(true)
                }
                "removeGeofence" -> {
                    NativeGeofenceHelper.removeGeofence(this)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
