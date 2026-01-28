import 'package:get/get.dart';
import 'package:device_pulse/core/helper/databasehelper.dart'; // absolute path
import 'package:device_pulse/core/helper/servicenetwork.dart';


class ReceivedController extends GetxController {
  RxList<Map<String, dynamic>> receivedList = <Map<String, dynamic>>[].obs;
  @override
  void onInit() {
    super.onInit();
    loadAllData();
    NetworkService.receiveStream.stream.listen((data) async {
      await DBHelper.insertData(data['deviceName'] ?? 'Unknown', data.toString());
      loadAllData();
    });
  }
  //refrash data
  void loadAllData() async {
    final allData = await DBHelper.getAllData();
    receivedList.value =
    List<Map<String, dynamic>>.from(allData);
  }

  //Delete function
  Future<void> deleteData(int id) async {
    await DBHelper.deleteData(id);
    receivedList.removeWhere((element) => element['id'] == id); // UI update
  }
}
