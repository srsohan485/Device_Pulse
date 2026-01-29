import 'package:flutter/services.dart';

class BatteryService {
  static const MethodChannel _channel = MethodChannel('battery_channel');

  static Future<Map<String, dynamic>> getBatteryInfo() async {
    final result = await _channel.invokeMethod('getBatteryInfo');
    return Map<String, dynamic>.from(result);
  }
}

class ConnectivityService {
  static const MethodChannel _channel = MethodChannel('battery_channel');

  static Future<Map<String, dynamic>> getConnectivityInfo() async {
    final result = await _channel.invokeMethod('getConnectivityInfo');
    return Map<String, dynamic>.from(result);
  }
}

class DeviceService {
  static const MethodChannel _channel = MethodChannel('battery_channel');

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final result = await _channel.invokeMethod('getDeviceInfo');
    return Map<String, dynamic>.from(result);
  }
}