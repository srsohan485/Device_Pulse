import 'package:flutter/services.dart';

class ActivityService {
  static const MethodChannel _channel = MethodChannel('battery_channel');

  static Future<String> getActivity() async {
    final result = await _channel.invokeMethod('getActivityStatus');
    return result ?? "Unknown";
  }
}
