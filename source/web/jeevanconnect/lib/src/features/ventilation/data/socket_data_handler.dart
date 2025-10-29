import 'dart:async';
import 'dart:convert' as convert;
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../packages/data_transmission/transaction.dart';
import '../domain/data_decoder.dart';
import '../domain/monitoring_alert.dart';

class SocketDataHandler {
  static WebSocketChannel? _channel;
  static bool _isConnected = false;
  static Stream? _channelData;
  static Stream<List<double>?>? _liveGraphData;
  static Stream<List<MonitoringAlert>?>? _alertData;
  static Stream<List<int>?>? _sampleData;
  static Stream<List<int>?>? _modeData;

  Stream<List<double>?>? get liveGraphData => _liveGraphData;
  Stream<List<MonitoringAlert>?>? get alertData => _alertData;
  Stream<List<int>?>? get sampleData => _sampleData;
  Stream<List<int>?>? get modeData => _modeData;

  Future connectToSocket(url) async {
    try {
      _channel = WebSocketChannel.connect(url);
      if (_channel == null) {
        return;
      }
      await _channel!.ready;
      _channel!.sink.add(convert
          .jsonEncode({"type": "connect_request", "data": "monitoring_data"}));
      _isConnected = true;
      _channelData = _channel!.stream.asBroadcastStream();
      _initChannels();
      return true;
    } catch (exception) {
      debugPrint("Socket Exception: $exception");
      return false;
    }
  }

  disconnectSocket() async {
    try {
      await _channel?.sink.close(status.goingAway);
      return true;
    } catch (exception) {
      debugPrint("Socket-Disconnect Exception: $exception");
      return false;
    }
  }

  Future _initChannels() async {
    _liveGraphData = Transaction.magicHeader(
        _channelData!.map((list) => _convertStringToList(list)),
        [0X2A, 0X4C]).stream.map(DataDecoder().decodeLiveGraphPacket);

    _alertData = Transaction.magicHeader(
        _channelData!
            .asBroadcastStream()
            .map((list) => _convertStringToList(list)),
        [0X2A, 0X4D]).stream.map(DataDecoder().decodeAlertPacket);

    _sampleData = Transaction.magicHeader(
        _channelData!
            .asBroadcastStream()
            .map((list) => _convertStringToList(list)),
        [0X2A, 0X53]).stream.map(DataDecoder().decodeSamplePacket);

    _modeData = Transaction.magicHeader(
        _channelData!
            .asBroadcastStream()
            .map((list) => _convertStringToList(list)),
        [0X2B, 0X4D]).stream.map(DataDecoder().decodeModePacket);

    return Future.value(true);
  }

  _convertStringToList(event) {
    if (event != null &&
        event.contains("{") &&
        event.contains("data") &&
        event.contains("[")) {
      String data = event.split("data:")[1];
      data = data.substring(0, data.length - 1);
      return Uint8List.fromList(
          List<int>.from(convert.jsonDecode(data).map((e) => e as int)));
    }
    return Uint8List.fromList([]);
  }

  bool get isSocketConnected => _isConnected;
}
