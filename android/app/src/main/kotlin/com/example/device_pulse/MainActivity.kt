package com.example.device_pulse
import android.Manifest
import android.app.PendingIntent
import android.content.*
import android.content.pm.PackageManager
import android.hardware.*
import android.net.*
import android.net.wifi.WifiManager
import android.os.*
import android.telephony.TelephonyManager
import android.text.format.Formatter

import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

import com.google.android.gms.location.*

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), SensorEventListener {

    private val CHANNEL = "battery_channel"
    private val PERMISSION_REQUEST_CODE = 101

    private lateinit var sensorManager: SensorManager

    private var stepSensor: Sensor? = null
    private var stepCount: Int = 0

    private lateinit var activityClient: ActivityRecognitionClient

    private var multicastLock: WifiManager.MulticastLock? = null

    companion object {
        var activityStatus: String = "Unknown"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        enableMulticast()
        requestPermissions()

        // Step Counter
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        stepSensor?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }

        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        multicastLock = wifiManager.createMulticastLock("device_pulse_lock")
        multicastLock?.setReferenceCounted(true)
        multicastLock?.acquire()



        // Activity Recognition
        activityClient = ActivityRecognition.getClient(this)
        startActivityUpdates()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                when (call.method) {

                    // Battery Info
                    "getBatteryInfo" -> {
                        val batteryStatus =
                            registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                        val level =
                            batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
                        val temp =
                            batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0)?.div(10)
                                ?: 0
                        val healthCode =
                            batteryStatus?.getIntExtra(BatteryManager.EXTRA_HEALTH, 0)
                        val health = when (healthCode) {
                            BatteryManager.BATTERY_HEALTH_GOOD -> "Good"
                            BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Overheat"
                            BatteryManager.BATTERY_HEALTH_DEAD -> "Dead"
                            else -> "Unknown"
                        }

                        result.success(
                            hashMapOf(
                                "batteryLevel" to level,
                                "batteryTemperature" to temp,
                                "batteryHealth" to health
                            )
                        )
                    }

                    // Device Info
                    "getDeviceInfo" -> {
                        result.success(
                            hashMapOf(
                                "deviceModel" to Build.MODEL,
                                "manufacturer" to Build.MANUFACTURER,
                                "androidVersion" to Build.VERSION.RELEASE
                            )
                        )
                    }

                    // Connectivity Info (with SIM & Signal)
                    "getConnectivityInfo" -> {
                        val cm =
                            getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                        val network = cm.activeNetwork
                        val cap = cm.getNetworkCapabilities(network)

                        var networkType = "None"
                        var wifiSSID = "N/A"
                        var rssi = 0
                        var localIp = "N/A"
                        var simState = "Unknown"
                        var signalLevel = 0

                        val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

                        if (cap != null && cap.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                            networkType = "WiFi"
                            val wifiManager =
                                applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                            val wifiInfo = wifiManager.connectionInfo
                            wifiSSID = wifiInfo.ssid
                            rssi = wifiInfo.rssi
                            localIp = Formatter.formatIpAddress(wifiInfo.ipAddress)
                        }

                        if (cap != null && cap.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
                            networkType = "Mobile"
                            simState = when (tm.simState) {
                                TelephonyManager.SIM_STATE_READY -> "Ready"
                                TelephonyManager.SIM_STATE_ABSENT -> "Absent"
                                TelephonyManager.SIM_STATE_PIN_REQUIRED -> "PIN Required"
                                TelephonyManager.SIM_STATE_PUK_REQUIRED -> "PUK Required"
                                TelephonyManager.SIM_STATE_NETWORK_LOCKED -> "Network Locked"
                                TelephonyManager.SIM_STATE_NOT_READY -> "Not Ready"
                                TelephonyManager.SIM_STATE_PERM_DISABLED -> "Permanently Disabled"
                                TelephonyManager.SIM_STATE_CARD_IO_ERROR -> "Card IO Error"
                                else -> "Unknown"
                            }
                            try {
                                signalLevel = tm.signalStrength?.level ?: 0
                            } catch (e: Exception) {
                                signalLevel = 0
                            }
                        }

                        result.success(
                            hashMapOf(
                                "networkType" to networkType,
                                "wifiSSID" to wifiSSID,
                                "rssi" to rssi,
                                "localIp" to localIp,
                                "simState" to simState,
                                "signalLevel" to signalLevel
                            )
                        )
                    }

                    // Step Count
                    "getStepCount" -> result.success(stepCount)

                    // Activity Status
                    "getActivityStatus" -> result.success(activityStatus)

                    else -> result.notImplemented()
                }
            }
    }

    private fun enableMulticast() {
        val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        multicastLock = wifi.createMulticastLock("device_pulse_multicast")
        multicastLock?.setReferenceCounted(true)
        multicastLock?.acquire()
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_STEP_COUNTER) {
            stepCount = event.values[0].toInt()
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    private fun startActivityUpdates() {
        val intent = Intent(this, ActivityReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )

        activityClient.requestActivityUpdates(3000, pendingIntent)
    }

    private fun requestPermissions() {
        val permissions = arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.ACTIVITY_RECOGNITION
        )

        val need = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (need.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this,
                need.toTypedArray(),
                PERMISSION_REQUEST_CODE
            )
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        sensorManager.unregisterListener(this)
        multicastLock?.release()
    }
}

// Activity Receiver
class ActivityReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val result = ActivityRecognitionResult.extractResult(intent)
        val activity = result?.mostProbableActivity

        MainActivity.activityStatus = when (activity?.type) {
            DetectedActivity.WALKING -> "Walking"
            DetectedActivity.RUNNING -> "Running"
            DetectedActivity.STILL -> "Still"
            DetectedActivity.ON_BICYCLE -> "Bicycle"
            DetectedActivity.IN_VEHICLE -> "Vehicle"
            else -> "Unknown"
        }
    }
}
