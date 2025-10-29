import 'dart:async';
import 'dart:convert' as convert;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../config/data/urls.dart';
import '../../../exception/exception.dart' show AppException;
import '../../authentication/authentication.dart' show AuthenticationRepository;
import '../domain/conversation.dart';
import '../domain/message.dart';

class MessageRepository {
  static Conversation? _conversation;
  static StreamController<bool>? conversationViewPort;
  static StreamController<int>? conversationListUpdate;
  static int currentIndex = -1;

  static List conversations = [], messages = [];

  init() {
    conversationViewPort = StreamController.broadcast();
    conversationListUpdate = StreamController.broadcast();
    currentIndex = -1;
  }

  dispose() {
    conversationViewPort?.close();
  }

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await http.get(
          AppUrls.getConversations(
              AuthenticationRepository().currentUser.userId),
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];
      final newConversations = result
          .map((json) => Conversation.fromJson(json))
          .toList()
          .cast<Conversation>();
      conversations = newConversations;
      if (currentIndex != -1 && _conversation != null) {
        currentIndex = newConversations.indexOf(_conversation!);
      }
      return newConversations;
    } catch (exception) {
      rethrow;
    }
  }

  Future createConversation(receiverId) async {
    try {
      final response = await http.post(AppUrls.createConversation,
          headers: AuthenticationRepository().headers,
          body: {
            "sender": AuthenticationRepository().currentUser.userId,
            "receiver": receiverId
          });
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return _handleCreateConversationResponse(getResponse);
      }
      return _handleCreateConversationResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await http.get(AppUrls.getMessages(_conversation!.id),
          headers: AuthenticationRepository().headers);
      final result = (convert.jsonDecode(response.body))['DATA'];
      final messages =
          result.map((json) => Message.fromJson(json)).toList().cast<Message>();
      return messages.reversed.toList();
    } catch (exception) {
      rethrow;
    }
  }

  Future<bool> sendMessage(message) async {
    try {
      final response = await http.post(AppUrls.sendMessage,
          headers: AuthenticationRepository().headers,
          body: {
            if (_conversation != null) "conversation_id": _conversation!.id,
            "sender": AuthenticationRepository().currentUser.userId,
            "receiver":
                _conversation != null ? _conversation!.getOtherUserId() : "",
            "content": message
          });
      if (response.statusCode == 302) {
        String url = response.headers['location'] ?? " ";
        final getResponse = await http.get(Uri.parse(url));
        return _handleSendMessageResponse(getResponse);
      }
      return _handleSendMessageResponse(response);
    } catch (exception) {
      rethrow;
    }
  }

  Future<void> sendFileMessage({PlatformFile? file}) async {
    try {
      var request = http.MultipartRequest('POST', AppUrls.sendMessage);
      request.headers['Cookie'] = AuthenticationRepository().headers['Cookie']!;
      request.headers['X-CSRFToken'] =
          AuthenticationRepository().headers['X-CSRFToken']!;
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields['conversation_id'] = _conversation!.id;
      request.fields['content'] = "";
      request.fields['receiver'] = _conversation!.getOtherUserId();
      request.fields['sender'] = AuthenticationRepository().currentUser.userId;
      if (file != null) {
        request.files
            .add(await http.MultipartFile.fromPath('file', file.path!));
      }
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = convert.jsonDecode(responseBody);

      if (response.statusCode == 200) {
        debugPrint('Message sent successfully');
        // Handle success scenario
      } else {
        debugPrint(
            'Failed to send message. Status code: ${response.statusCode}');
        debugPrint('Error: ${decodedResponse['message']}');
        // Handle error scenario
      }
    } catch (e) {
      debugPrint('Exception occurred: $e');
      // Handle exception
    }
  }

  _handleSendMessageResponse(http.Response response) {
    if (response.statusCode == 200) {
      return true;
    } else {
      switch (response.statusCode) {
        case 409:
          throw AppException.permissionDenied;
        case 503:
          throw AppException.serviceUnavailable;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  _handleCreateConversationResponse(http.Response response) {
    if (response.statusCode == 200) {
      final result = (convert.jsonDecode(response.body))['DATA'];
      _conversation = Conversation.fromJson(result);
      return _conversation;
    } else {
      switch (response.statusCode) {
        case 409:
          throw AppException.permissionDenied;
        case 503:
          throw AppException.serviceUnavailable;
        case 500:
          throw AppException.serverError;
        default:
          throw AppException.localError;
      }
    }
  }

  set currentConversation(newConversation) => _conversation = newConversation;
  Conversation? get currentConversation => _conversation;
  Stream get conversationViewPortChanges => conversationViewPort!.stream;
  Stream get conversationListUpdates => conversationListUpdate!.stream;
}
