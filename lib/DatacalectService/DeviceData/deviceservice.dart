import 'package:flutter/services.dart';

class DeviceService {
  static const MethodChannel _channel = MethodChannel('battery_channel');

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final result = await _channel.invokeMethod('getDeviceInfo');
    return Map<String, dynamic>.from(result);
  }
}
