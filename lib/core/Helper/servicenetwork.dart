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

    final myIp = await _getLocalIp();

    _socket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = _socket!.receive();
        if (dg == null) return;

        final ip = dg.address.address;


        if (ip == myIp) return;

        final message = utf8.decode(dg.data);

        try {
          final data = jsonDecode(message);

          print('UDP received from $ip: $message');

          if (data['type'] == 'DISCOVERY') {
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
        } catch (_) {}
      }
    });

    // নিজের ডিভাইস লিস্টে
    _devices.add({
      "name": deviceName,
      "ip": myIp,
    });
    deviceStream.add(List.from(_devices));

    final subnetBroadcast = _getBroadcastIp(myIp);

    _broadcastTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final discoveryMessage = jsonEncode({
        "type": "DISCOVERY",
        "deviceName": deviceName,
      });

      _socket!.send(
        utf8.encode(discoveryMessage),
        InternetAddress(subnetBroadcast),
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

  static Future<String> _getLocalIp() async {
    final interfaces =
    await NetworkInterface.list(type: InternetAddressType.IPv4);

    for (var iface in interfaces) {
      for (var addr in iface.addresses) {
        if (!addr.isLoopback && addr.address.startsWith("192.")) {
          return addr.address;
        }
      }
    }
    return interfaces.first.addresses.first.address;
  }

  static String _getBroadcastIp(String ip) {
    final parts = ip.split(".");
    parts[3] = "255";
    return parts.join(".");
  }

  static void dispose() {
    _broadcastTimer?.cancel();
    _socket?.close();
    _socket = null;
    deviceStream.close();
    receiveStream.close();
  }
}
