import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/receivedcontroller.dart';

class ReceivedData extends StatelessWidget {
  ReceivedData({super.key});
  final controller = Get.put(ReceivedController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Received Data"),
        centerTitle: true,
        backgroundColor: Colors.cyan.withOpacity(0.8),
        shadowColor: Colors.cyanAccent,
      ),
      body: Obx(() {
        final list = controller.receivedList;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 50, color: Colors.teal.shade200),
                SizedBox(height: 10),
                Text(
                  "No data received yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final sender = item['sender'] ?? 'Unknown';
            final message = item['message'] ?? '';
            final time = item['time'] != null
                ? item['time'].toString().split('.')[0]
                : '';
            final id = item['id'] as int;

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8),
              shadowColor: Colors.grey.shade300,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Confirm dialog
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Delete"),
                                content: Text("Are you sure you want to delete this data?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      controller.deleteData(id); // call controller method
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            sender,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade800),
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
