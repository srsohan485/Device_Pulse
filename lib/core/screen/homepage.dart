import 'package:device_pulse/core/screen/infocard.dart';
import 'package:device_pulse/core/screen/receviedata.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/homecontroller.dart';
import '../controller/sentcontroller.dart';
import 'datasentdevice.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (_) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 10,
          backgroundColor: Colors.cyan.withOpacity(0.8),
          shadowColor: Colors.cyanAccent,
          title: const Text(
            "Device Pulse",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: 1,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.refreshAllData,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                InfoCard(
                  title: "Battery Info",
                  color: Colors.orange.shade800,
                  content: Column(
                    children: [
                      InfoRow(
                        icon: Icons.battery_full,
                        label: controller.batteryLevel > 19
                            ? "Charge Level: ${controller.batteryLevel}% (Enough)"
                            : "Charge Level: ${controller.batteryLevel}% (Low)",
                        valueColor: controller.getBatteryColor(),
                      ),
                      InfoRow(
                        icon: Icons.thermostat_outlined,
                        label: controller.batteryTemp > 44
                            ? "Battery Temp: ${controller.batteryTemp}°C (Overheat)"
                            : controller.batteryTemp > 38
                            ? "Battery Temp: ${controller.batteryTemp}°C (Risky)"
                            : "Battery Temp: ${controller.batteryTemp}°C (Safe)",
                        valueColor: controller.getTempColor(),
                      ),
                      InfoRow(
                        icon: Icons.health_and_safety,
                        label: "Health: ${controller.batteryHealth}",
                      ),
                    ],
                  ),
                ),
                InfoCard(
                  title: "Activity Info",
                  color: Colors.orange.shade800,
                  content: Column(
                    children: [
                      InfoRow(icon: Icons.directions_walk, label: "Detected Activity: ${controller.activity}"),
                      InfoRow(icon: Icons.format_list_numbered, label: "Step Count: ${controller.steps}"),
                    ],
                  ),
                ),
                InfoCard(
                  title: "Device Info",
                  color: Colors.orange.shade800,
                  content: Column(
                    children: [
                      InfoRow(icon: Icons.phone_iphone, label: "Model: ${controller.DeviceInfo['deviceModel'] ?? 'Loading'}"),
                      InfoRow(icon: Icons.business, label: "Manufacturer: ${controller.DeviceInfo['manufacturer'] ?? 'Loading'}"),
                      InfoRow(icon: Icons.android, label: "Android Version: ${controller.DeviceInfo['androidVersion'] ?? 'Loading'}"),
                    ],
                  ),
                ),
                InfoCard(
                  title: "Connectivity Info",
                  color: Colors.orange.shade800,
                  content: Column(
                    children: [
                      InfoRow(icon: Icons.network_check, label: "Network: ${controller.connectivityInfo['networkType'] ?? 'Loading'}"),
                      InfoRow(icon: Icons.wifi, label: "WiFi SSID: ${controller.connectivityInfo['wifiSSID'] ?? 'N/A'}"),
                      InfoRow(icon: Icons.signal_cellular_4_bar, label: "Signal Level: ${controller.connectivityInfo['signalStrength'] ?? 0}"),
                      InfoRow(icon: Icons.sim_card, label: "SIM State: ${controller.connectivityInfo['simState'] ?? 'Loading'}"),
                      InfoRow(icon: Icons.location_on, label: "Local IP: ${controller.connectivityInfo['localIp'] ?? 'N/A'}"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // HomeController থেকে device model নেওয়া
                          final deviceModel = controller.DeviceInfo['deviceModel'] ?? 'My Android Device';

                          // GetSendController inject করা real device name দিয়ে
                          Get.put(GetSendController(deviceName: deviceModel));

                          // Datasentdevice page এ যাওয়া
                          Get.to(Datasentdevice());
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.greenAccent.shade100,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Share My Pulse",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),

                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.to(ReceivedData()),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blue.shade100,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 5,
                        ),
                        child: const Text("Received Data", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- Reusable Widgets -----------------

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? valueColor;

  const InfoRow({super.key, required this.icon, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: valueColor ?? Colors.teal),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: valueColor))),
        ],
      ),
    );
  }
}
