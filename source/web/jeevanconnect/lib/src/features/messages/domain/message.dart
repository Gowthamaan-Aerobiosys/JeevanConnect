import 'package:intl/intl.dart';
import 'package:jeevanconnect/src/features/authentication/data/authentication_repository.dart';

import '../../authentication/authentication.dart' show User;
import 'conversation.dart';

class Message {
  String content;
  Conversation conversation;
  User sender;
  User receiver;
  String? id;
  String? fileUrl;
  bool seen;
  DateTime timestamp;
  bool isSentMessage;

  Message(
      {required this.content,
      required this.conversation,
      required this.sender,
      required this.receiver,
      required this.id,
      required this.seen,
      required this.timestamp,
      required this.isSentMessage,
      this.fileUrl});

  factory Message.fromJson(json) {
    final sender = User.fromJson(json["sender"]);
    final receiver = User.fromJson(json["receiver"]);
    final conversation = Conversation.fromJson(json["conversation"]);

    return Message(
      content: json["content"],
      conversation: conversation,
      sender: sender,
      receiver: receiver,
      id: json["id"],
      seen: json["seen"],
      fileUrl: json['file_message_url'],
      isSentMessage: AuthenticationRepository().currentUser == sender,
      timestamp: DateTime.parse(json["timestamp"]),
    );
  }

  getTime() {
    return DateFormat('d/MM/y h:mm a').format(timestamp).toLowerCase();
  }
}
