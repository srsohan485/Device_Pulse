import 'package:get/get.dart';
import '../../../../core/helper/servicenetwork.dart';


class GetSendController extends GetxController {
  RxList<Map<String, dynamic>> devices = <Map<String, dynamic>>[].obs;
  final String deviceName;
  GetSendController({required this.deviceName});

  @override
  void onInit() {
    super.onInit();
    print("DISCOVERY STARTED");
    NetworkService.startDiscovery(deviceName);
    NetworkService.deviceStream.stream.listen((deviceList) {
      devices.value = deviceList;
      print("Detected decives: $deviceList");
    });
  }

  void sendPulse(Map<String, dynamic> pulseData, String targetIp, String deviceName) {
    NetworkService.sendPulseData(targetIp: targetIp, pulseData: pulseData);
    Get.snackbar("Success", "Data sent to $deviceName",
        snackPosition: SnackPosition.BOTTOM);
  }
}
