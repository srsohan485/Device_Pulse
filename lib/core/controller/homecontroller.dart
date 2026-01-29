import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../DatacalectService/DeviceService/activitsecvice.dart';
import '../../DatacalectService/DeviceService/counterservice.dart';
import '../../DatacalectService/DeviceData/batterydata.dart';


// HomeController class - Manages the state and business logic for the Home screen
class HomeController extends GetxController {

  int batteryLevel = 0;
  int batteryTemp = 0;
  String batteryHealth = "Unknown";
  Map<String, dynamic> DeviceInfo = {};
  Map<String, dynamic> connectivityInfo = {};
  int steps = 0;
  String activity = "Loading...";
  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    // Load initial data when controller starts
    loadBattery();
    loadDevice();
    loadConnectivity();
    loadActivity();
    loadSteps();

    timer = Timer.periodic(const Duration(seconds: 3), (t) {
      loadBattery();
      loadConnectivity();
      loadActivity();
      loadSteps();
    });
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  // 🔹 NEW method for manual or pull-to-refresh
  Future<void> refreshAllData() async {
    await loadBattery();
    await loadDevice();
    await loadConnectivity();
    await loadActivity();
    await loadSteps();
    update();
  }

  Future<void> loadActivity() async {
    activity = await ActivityService.getActivity();
    update();
  }

  Future<void> loadSteps() async {
    steps = await StepCounterService.getStepCount();
    update();
  }

  Future<void> loadBattery() async {
    final data = await BatteryService.getBatteryInfo();
    batteryLevel = data["batteryLevel"];
    batteryTemp = data["batteryTemperature"];
    batteryHealth = data["batteryHealth"];
    update();
  }

  Future<void> loadDevice() async {
    DeviceInfo = await DeviceService.getDeviceInfo();
    update();
  }

  Future<void> loadConnectivity() async {
    connectivityInfo = await ConnectivityService.getConnectivityInfo();
    update();
  }
  // Determines color for battery level indicator based on percentage
  Color getBatteryColor() {
    if (batteryLevel >= 80) return Colors.green.shade700;
    if (batteryLevel >= 50) return Colors.lightGreen;
    if (batteryLevel >= 20) return Colors.orange;
    if (batteryLevel >= 10) return Colors.deepOrange;
    return Colors.redAccent;
  }

// Determines color for battery temperature indicator
  Color getTempColor() {
    if (batteryTemp >= 50) return Colors.redAccent;
    if (batteryTemp >= 44) return Colors.red;
    if (batteryTemp >= 40) return Colors.orangeAccent;
    if (batteryTemp >= 38) return Colors.orange;
    return Colors.green.shade600;
  }
}
