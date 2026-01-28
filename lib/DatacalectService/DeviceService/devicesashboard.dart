import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceDashboard extends StatefulWidget {
  const DeviceDashboard({Key? key}) : super(key: key);

  @override
  State<DeviceDashboard> createState() => _DeviceDashboardState();
}

class _DeviceDashboardState extends State<DeviceDashboard> {
  Map<String, dynamic> batteryInfo = {};
  Map<String, dynamic> connectivityInfo = {};
  Map<String, dynamic> deviceInfo = {};
  int stepCount = 0;
  String activityStatus = "Unknown";

  static const MethodChannel _channel = MethodChannel('battery_channel');

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      // Battery Info
      final battery = await _channel.invokeMethod('getBatteryInfo');
      // Device Info
      final device = await _channel.invokeMethod('getDeviceInfo');
      // Connectivity Info
      final connectivity = await _channel.invokeMethod('getConnectivityInfo');
      // Step Count
      final steps = await _channel.invokeMethod('getStepCount');
      // Activity Status
      final activity = await _channel.invokeMethod('getActivityStatus');

      setState(() {
        batteryInfo = Map<String, dynamic>.from(battery ?? {});
        deviceInfo = Map<String, dynamic>.from(device ?? {});
        connectivityInfo = Map<String, dynamic>.from(connectivity ?? {});
        stepCount = steps ?? 0;
        activityStatus = activity ?? "Unknown";
      });
    } on PlatformException catch (e) {
      print("Error fetching data: $e");
    }
  }

  Widget _buildInfoCard(String title, Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50, // Card background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...data.entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: TextStyle(fontWeight: FontWeight.w500)),
                    Text("${entry.value}"),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔋 Battery Info Card
            _buildInfoCard("🔋 Battery Info", {
              "Level" : "${batteryInfo['batteryLevel'] ?? 'N/A'}%",
              "Temperature" : "${batteryInfo['batteryTemperature'] ?? 'N/A'}°C",
              "Health" : "${batteryInfo['batteryHealth'] ?? 'N/A'}",
            }),

            // 📱 Device Info Card
            _buildInfoCard("📱 Device Info", {
              "Model" : "${deviceInfo['deviceModel'] ?? 'N/A'}",
              "Manufacturer" : "${deviceInfo['manufacturer'] ?? 'N/A'}",
              "Android Version" : "${deviceInfo['androidVersion'] ?? 'N/A'}",
            }),

            // 🌐 Connectivity Info Card
            _buildInfoCard("🌐 Connectivity Info", {
              "Network Type" : "${connectivityInfo['networkType'] ?? 'N/A'}",
              "WiFi SSID" : "${connectivityInfo['wifiSSID'] ?? 'N/A'}",
              "WiFi RSSI" : "${connectivityInfo['rssi'] ?? 'N/A'}",
              "Local IP" : "${connectivityInfo['localIp'] ?? 'N/A'}",
              "SIM State" : "${connectivityInfo['simState'] ?? 'N/A'}",
              "Signal Level" : "${connectivityInfo['signalLevel'] ?? '0'}",
            }),

            // Step Count Card
            _buildInfoCard("Step Count", {
              "Steps" : "$stepCount",
            }),

            // Detected Activity Card
            _buildInfoCard("Detected Activity", {
              "Activity" : "$activityStatus",
            }),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _loadAllData,
                child: const Text("Refresh Data"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
