import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../config/presentation/layout_config.dart';
import '../data/messages_repository.dart';
import 'conversation_card.dart';

class ConversationList extends StatefulWidget {
  const ConversationList({super.key});

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  bool isLoading = false;

  Future<void> _fetchConversations() async {
    isLoading = true;
    MessageRepository.conversations =
        await MessageRepository().getConversations();
    isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void initState() {
    super.initState();
    MessageRepository.conversations = [];
    _fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: LayoutConfig().setFractionWidth(30),
      child: isLoading
          ? Center(
              child: CupertinoActivityIndicator(
                radius: 20,
                color: Theme.of(context).primaryColorLight,
              ),
            )
          : StreamBuilder(
              stream: MessageRepository().conversationListUpdates,
              builder: (context, snapshot) {
                final event = snapshot.data;
                _updateConversationList(event);

                if (MessageRepository.conversations.isEmpty) {
                  return Center(
                    child: Text(
                      "No active conversation",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: MessageRepository.conversations.length,
                  itemBuilder: (context, index) {
                    return ConversationCard(
                        index: index,
                        conversation: MessageRepository.conversations[index]);
                  },
                );
              }),
    );
  }

  _updateConversationList(event) {
    if (event != null) {
      switch (event) {
        case 1:
          MessageRepository.conversations[MessageRepository.currentIndex]
              .lastModified = DateTime.now();
          MessageRepository.conversations[MessageRepository.currentIndex]
              .content = MessageRepository.messages.first.content;
          MessageRepository
              .conversations[MessageRepository.currentIndex].messageId = null;
          MessageRepository.conversations[MessageRepository.currentIndex]
              .isSentMessage = true;
          MessageRepository.conversations
              .sort((a, b) => b.lastModified.compareTo(a.lastModified));
          MessageRepository.currentIndex = MessageRepository.conversations
              .indexOf(MessageRepository().currentConversation!);
          MessageRepository.conversationListUpdate!.sink.add(0);
          break;
        case 2:
          break;
        case 3:
          MessageRepository().getConversations().then((value) {
            MessageRepository.conversationListUpdate!.sink.add(0);
          });
          break;
        default:
          break;
      }
    }
  }
}
