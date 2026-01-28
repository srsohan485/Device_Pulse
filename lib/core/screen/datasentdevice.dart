import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/homecontroller.dart';
import '../controller/sentcontroller.dart';

class SendDataScreen extends StatelessWidget {
  SendDataScreen({super.key});

  final sendController = Get.put(GetSendController());
  final homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Device to Send"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Obx(() {
        final devices = sendController.devices;
        if (devices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.teal),
                SizedBox(height: 10),
                Text(
                  "Searching for devices...",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8),
              shadowColor: Colors.grey.shade300,
              child: ListTile(
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.teal.shade50,
                  child: Icon(Icons.phone_android, color: Colors.teal),
                ),
                title: Text(
                  device['name'],
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800),
                ),
                subtitle: Text(
                  device['ip'],
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    final pulseData = {
                      "deviceName": "My Android Device",
                      "battery": homeController.batteryLevel,
                      "temperature": homeController.batteryTemp,
                      "health": homeController.batteryHealth,
                      "steps": homeController.steps,
                      "activity": homeController.activity,
                      "deviceInfo": homeController.DeviceInfo,
                      "connectivity": homeController.connectivityInfo,
                      "time": DateTime.now().toString(),
                    };

                    sendController.sendPulse(
                      pulseData,
                      device['ip'],
                      device['name'],
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: Icon(Icons.send, color: Colors.teal.shade900),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
