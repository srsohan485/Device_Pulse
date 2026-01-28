import 'dart:async';
import 'dart:convert';
import 'dart:io';

class NetworkService {
  static const int port = 4040;
  static RawDatagramSocket? _socket;
  static Timer? _broadcastTimer;
  static final List<Map<String, dynamic>> _devices = [];
  static final StreamController<List<Map<String, dynamic>>> deviceStream =
  StreamController.broadcast();
  static final StreamController<Map<String, dynamic>> receiveStream =
  StreamController.broadcast();

  static Future<void> startDiscovery(String deviceName) async {
    if (_socket != null) return;
    _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      port,
      reuseAddress: true,
    );
    _socket!.broadcastEnabled = true;


    _socket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = _socket!.receive();
        if (dg == null) return;
        final message = utf8.decode(dg.data);
        try {
          final data = jsonDecode(message);
          if (data['type'] == 'DISCOVERY') {   // onno device gula o thakbe
            final ip = dg.address.address;

            final alreadyExists = _devices.any((d) => d['ip'] == ip);
            if (!alreadyExists) {
              _devices.add({
                "name": data['deviceName'],
                "ip": ip,
              });
              deviceStream.add(List.from(_devices));
            }
          }
          if (data['type'] == 'PULSE') {
            receiveStream.add(data['data']);
          }
        } catch (e) {}
      }
    });

    final myIp = (await NetworkInterface.list(type: InternetAddressType.IPv4))
        .expand((iface) => iface.addresses)
        .first
        .address;

    if (_devices.every((d) => d['ip'] != myIp)) {
      _devices.add({
        "name": deviceName, // নিজের device name
        "ip": myIp,
      });
      deviceStream.add(List.from(_devices));
    }

    _broadcastTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final discoveryMessage = jsonEncode({
        "type": "DISCOVERY",
        "deviceName": deviceName,
      });
      _socket!.send(
        utf8.encode(discoveryMessage),
        InternetAddress("255.255.255.255"),
        port,
      );
    });
  }


  static void sendPulseData({
    required String targetIp,
    required Map<String, dynamic> pulseData,
  }) {
    if (_socket == null) return;
    final message = jsonEncode({
      "type": "PULSE",
      "data": pulseData,
    });
    _socket!.send(
      utf8.encode(message),
      InternetAddress(targetIp),
      port,
    );
  }

  static void dispose() {
    _broadcastTimer?.cancel();
    _socket?.close();
    _socket = null;
    deviceStream.close();
    receiveStream.close();
  }
}
