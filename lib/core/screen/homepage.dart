import 'package:device_pulse/core/screen/receviedata.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/homecontroller.dart';
import 'datasentdevice.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Device Pulse"),
            centerTitle: true,
            backgroundColor: Colors.cyanAccent,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  // Battery Card
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    shadowColor: Colors.grey.shade300,
                    child: Container(
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade50, Colors.teal.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Battery Info",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.battery_full,
                                  color: controller.getBatteryColor()),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.batteryLevel > 19
                                      ? "Charge Level: ${controller.batteryLevel}% (Enough)"
                                      : "Charge Level: ${controller.batteryLevel}% (Low)",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: controller.getBatteryColor()),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.thermostat_outlined,
                                  color: controller.getTempColor()),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.batteryTemp > 44
                                      ? "Battery Temp: ${controller.batteryTemp}°C (Overheat)"
                                      : controller.batteryTemp > 38
                                      ? "Battery Temp: ${controller.batteryTemp}°C (Risky)"
                                      : "Battery Temp: ${controller.batteryTemp}°C (Safe)",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: controller.getTempColor()),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.health_and_safety,
                                  color: Colors.teal.shade700),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Health: ${controller.batteryHealth}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Activity Card
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: Colors.grey.shade300,
                    child: Container(
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade50, Colors.teal.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Activity Info",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.directions_walk, color: Colors.teal),
                              SizedBox(width: 8),
                              Text("Detected Activity: ${controller.activity}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.format_list_numbered,
                                  color: Colors.teal),
                              SizedBox(width: 8),
                              Text("Step Count: ${controller.steps}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Device Info Card
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: Colors.grey.shade300,
                    child: Container(
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade50, Colors.teal.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Device Info",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.phone_iphone, color: Colors.teal),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      "Model: ${controller.DeviceInfo['deviceModel'] ?? 'Loading'}",
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.business, color: Colors.teal),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      "Manufacturer: ${controller.DeviceInfo['manufacturer'] ?? 'Loading'}",
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.android, color: Colors.teal),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      "Android Version: ${controller.DeviceInfo['androidVersion'] ?? 'Loading'}",
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Connectivity Info Card
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: Colors.grey.shade300,
                    child: Container(
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade50, Colors.teal.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Connectivity Info",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.network_check, color: Colors.teal),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      "Network: ${controller.connectivityInfo['networkType'] ?? 'Loading'}",
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.wifi, color: Colors.teal),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      "WiFi SSID: ${controller.connectivityInfo['wifiSSID'] ?? 'N/A'}",
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.signal_cellular_4_bar, color: Colors.teal),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      "Signal Level: ${controller.connectivityInfo['signalStrength'] ?? 0}",
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.sim_card, color: Colors.teal),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      "SIM State: ${controller.connectivityInfo['simState'] ?? 'Loading'}",
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.teal),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      "Local IP: ${controller.connectivityInfo['localIp'] ?? 'N/A'}",
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.to(SendDataScreen()),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.greenAccent.shade100,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              elevation: 5),
                          child: Text(
                            "Share My Pulse",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.to(ReceivedData()),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.blue.shade100,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              elevation: 5),
                          child: Text(
                            "Received Data",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
