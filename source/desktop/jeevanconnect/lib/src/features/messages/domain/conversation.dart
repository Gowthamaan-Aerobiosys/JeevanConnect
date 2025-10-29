import 'package:intl/intl.dart';

import '../../authentication/authentication.dart'
    show User, AuthenticationRepository;

getAttribute(object, id, defaultValue) {
  if (object != null) {
    return object[id];
  }
  return defaultValue;
}

class Conversation {
  User userOne;
  User userTwo;
  String id;
  DateTime lastModified;
  String? content;
  String? messageId;
  bool isSentMessage;
  bool isSeen;
  bool isUserOne;

  Conversation(
      {required this.id,
      required this.userOne,
      required this.userTwo,
      required this.isUserOne,
      required this.lastModified,
      this.isSeen = false,
      this.isSentMessage = false,
      this.content,
      this.messageId});

  factory Conversation.fromJson(json) {
    final userOne = User.fromJson(json["user1"]);
    final userTwo = User.fromJson(json["user2"]);

    return Conversation(
        id: json["id"],
        userOne: userOne,
        userTwo: userTwo,
        content: getAttribute(json['last_message'], 'content', ""),
        messageId: getAttribute(json['last_message'], 'id', null),
        isSeen: getAttribute(json['last_message'], 'seen', false),
        isSentMessage:
            getAttribute(json['last_message'], 'sender_user_id', "") ==
                AuthenticationRepository().currentUser.userId,
        isUserOne: userOne == AuthenticationRepository().currentUser,
        lastModified: DateTime.parse(
          getAttribute(
              json['last_message'], 'timestamp', json["last_modified"]),
        ));
  }

  getDisplayName() {
    return isUserOne ? userTwo.getFullName() : userOne.getFullName();
  }

  getOtherUserId() {
    return isUserOne ? userTwo.userId : userOne.userId;
  }

  getOtherUser() {
    if (isUserOne) {
      return userTwo;
    } else {
      return userOne;
    }
  }

  getTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCompare =
        DateTime(lastModified.year, lastModified.month, lastModified.day);
    if (dateToCompare == today) {
      return DateFormat('h:mm a').format(lastModified).toLowerCase();
    } else if (dateToCompare == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('d/MM/y').format(lastModified);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
