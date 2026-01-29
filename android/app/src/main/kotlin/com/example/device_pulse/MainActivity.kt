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
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress

class MainActivity : FlutterActivity(), SensorEventListener {

    private val CHANNEL = "battery_channel"
    private val PERMISSION_REQUEST_CODE = 101

    private lateinit var sensorManager: SensorManager
    private var stepSensor: Sensor? = null
    private var stepCount: Int = 0
    private lateinit var activityClient: ActivityRecognitionClient
    private var multicastLock: WifiManager.MulticastLock? = null

    private var udpThread: Thread? = null
    private var udpRunning = false
    private val UDP_PORT = 8888 // Same port for broadcast & listen

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
        stepSensor?.let { sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL) }

        // Activity Recognition
        activityClient = ActivityRecognition.getClient(this)
        startActivityUpdates()

        // MethodChannel for Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryInfo" -> sendBatteryInfo(result)
                    "getDeviceInfo" -> sendDeviceInfo(result)
                    "getConnectivityInfo" -> sendConnectivityInfo(result)
                    "getStepCount" -> result.success(stepCount)
                    "getActivityStatus" -> result.success(activityStatus)
                    "startDiscovery" -> {
                        startBroadcasting()
                        startListening(flutterEngine)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // Battery / Device / Connectivity
    private fun sendBatteryInfo(result: MethodChannel.Result) {
        val batteryStatus = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val temp = batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0)?.div(10) ?: 0
        val health = when (batteryStatus?.getIntExtra(BatteryManager.EXTRA_HEALTH, 0)) {
            BatteryManager.BATTERY_HEALTH_GOOD -> "Good"
            BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Overheat"
            BatteryManager.BATTERY_HEALTH_DEAD -> "Dead"
            else -> "Unknown"
        }
        result.success(hashMapOf("batteryLevel" to level, "batteryTemperature" to temp, "batteryHealth" to health))
    }

    private fun sendDeviceInfo(result: MethodChannel.Result) {
        result.success(hashMapOf(
            "deviceModel" to Build.MODEL,
            "manufacturer" to Build.MANUFACTURER,
            "androidVersion" to Build.VERSION.RELEASE
        ))
    }

    private fun sendConnectivityInfo(result: MethodChannel.Result) {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
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
            val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
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
            signalLevel = try { tm.signalStrength?.level ?: 0 } catch (e: Exception) {0}
        }

        result.success(hashMapOf(
            "networkType" to networkType,
            "wifiSSID" to wifiSSID,
            "rssi" to rssi,
            "localIp" to localIp,
            "simState" to simState,
            "signalLevel" to signalLevel
        ))
    }

    //  Multicast & Step / Activity
    private fun enableMulticast() {
        val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        multicastLock = wifi.createMulticastLock("device_pulse_multicast")
        multicastLock?.setReferenceCounted(true)
        multicastLock?.acquire()
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_STEP_COUNTER) stepCount = event.values[0].toInt()
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    private fun startActivityUpdates() {
        val intent = Intent(this, ActivityReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this, 0, intent,
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
        val need = permissions.filter { ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED }
        if (need.isNotEmpty()) ActivityCompat.requestPermissions(this, need.toTypedArray(), PERMISSION_REQUEST_CODE)
    }

    // UDP Broadcast
    private fun startBroadcasting() {
        Thread {
            try {
                val socket = DatagramSocket()
                socket.broadcast = true
                val msg = "DEVICE:${Build.MODEL}"
                val data = msg.toByteArray()
                while (true) {
                    val packet = DatagramPacket(data, data.size, InetAddress.getByName("255.255.255.255"), UDP_PORT)
                    socket.send(packet)
                    Thread.sleep(3000) // Broadcast every 3 seconds
                }
            } catch (e: Exception) { e.printStackTrace() }
        }.start()
    }

    // UDP Listen
    private fun startListening(flutterEngine: FlutterEngine) {
        udpRunning = true
        udpThread = Thread {
            try {
                val socket = DatagramSocket(UDP_PORT)
                val buffer = ByteArray(1024)
                while (udpRunning) {
                    val packet = DatagramPacket(buffer, buffer.size)
                    socket.receive(packet)
                    val msg = String(packet.data, 0, packet.length)

                    // Only detect DEVICE messages
                    if (msg.startsWith("DEVICE:")) {
                        val deviceName = msg.replace("DEVICE:", "")
                        val ip = packet.address.hostAddress

                        // Send to Flutter via MethodChannel
                        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                            .invokeMethod("onDeviceFound", mapOf("deviceName" to deviceName, "ip" to ip))
                    }
                }
            } catch (e: Exception) { e.printStackTrace() }
        }
        udpThread?.start()
    }

    override fun onDestroy() {
        super.onDestroy()
        sensorManager.unregisterListener(this)
        multicastLock?.release()
        udpRunning = false
        udpThread?.interrupt()
    }
}

//  Activity Receiver
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
