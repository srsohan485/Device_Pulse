import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../DatacalectService/DeviceService/activitsecvice.dart';
import '../../DatacalectService/DeviceService/counterservice.dart';
import '../../DatacalectService/DeviceData/batterydata.dart';
import '../../DatacalectService/DeviceData/connectservice.dart';
import '../../DatacalectService/DeviceData/deviceservice.dart';


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

  Color getBatteryColor() {
    if (batteryLevel > 50) return Colors.green;
    if (batteryLevel > 20) return Colors.orange;
    return Colors.red;
  }

  Color getTempColor() {
    if (batteryTemp > 44) return Colors.red;
    if (batteryTemp > 38) return Colors.orange;
    return Colors.green;
  }
}
