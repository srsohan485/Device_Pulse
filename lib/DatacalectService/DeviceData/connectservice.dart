import 'package:flutter/services.dart';

class ConnectivityService {
  static const MethodChannel _channel = MethodChannel('battery_channel');

  static Future<Map<String, dynamic>> getConnectivityInfo() async {
    final result = await _channel.invokeMethod('getConnectivityInfo');
    return Map<String, dynamic>.from(result);
  }
}




