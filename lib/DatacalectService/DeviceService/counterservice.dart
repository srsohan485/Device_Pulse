import 'package:flutter/services.dart';

class StepCounterService {
  static const MethodChannel _channel =
  MethodChannel('battery_channel');

  static Future<int> getStepCount() async {
    final int steps = await _channel.invokeMethod('getStepCount');
    return steps;
  }
}
