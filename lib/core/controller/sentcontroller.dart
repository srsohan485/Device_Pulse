import 'package:get/get.dart';
import '../../../../core/helper/servicenetwork.dart';


class GetSendController extends GetxController {
  RxList<Map<String, dynamic>> devices = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    NetworkService.startDiscovery("My Device");
    NetworkService.deviceStream.stream.listen((deviceList) {
      devices.value = deviceList;
    });
  }

  void sendPulse(Map<String, dynamic> pulseData, String targetIp, String deviceName) {
    NetworkService.sendPulseData(targetIp: targetIp, pulseData: pulseData);
    Get.snackbar("Success", "Data sent to $deviceName",
        snackPosition: SnackPosition.BOTTOM);
  }
}
