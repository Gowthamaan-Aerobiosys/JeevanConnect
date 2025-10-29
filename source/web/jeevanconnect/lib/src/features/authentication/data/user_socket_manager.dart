import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../../../config/data/urls.dart';
import 'authentication_repository.dart';

class UserSocketManager {
  static WebSocketChannel? _channel;
  static bool _isConnected = false;
  static Stream? _channelData;
  static late StreamController<bool> _updateChatController;

  Future init() async {
    _isConnected = false;
    _updateChatController = StreamController.broadcast();
    return await connect();
  }

  dispose() {
    _updateChatController.close();
  }

  Future connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppUrls.userSocket(
          AuthenticationRepository().currentUser.userId,
          AuthenticationRepository().currentUser.sessionId)));
      if (_channel == null) {
        return false;
      }
      await _channel!.ready;
      _isConnected = true;
      _channelData = _channel!.stream.asBroadcastStream();
      receive();
      return true;
    } catch (exception) {
      debugPrint("Socket-Connect Exception: $exception");
      return false;
    }
  }

  disconnect() async {
    try {
      await _channel?.sink.close(status.goingAway);
      return true;
    } catch (exception) {
      debugPrint("Socket-Disconnect Exception: $exception");
      return false;
    }
  }

  send() {}

  receive() {
    bool sendingData = true;
    _channelData!.listen((event) {
      if (event != null) {
        _updateChatController.sink.add(sendingData);
        sendingData = !sendingData;
      }
    });
  }

  bool get isUserSocketAlive => _isConnected;

  Stream get userSocketData => _channelData!;

  Stream get chatUpdates => _updateChatController.stream;
}
