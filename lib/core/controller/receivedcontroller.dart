import 'package:get/get.dart';
import '../../../../core/helper/databasehelper.dart';
import '../../../../core/helper/servicenetwork.dart';


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
  void loadAllData() async {
    final allData = await DBHelper.getAllData();
    receivedList.value = allData;
  }
}
