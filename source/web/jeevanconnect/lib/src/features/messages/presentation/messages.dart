import 'package:flutter/material.dart';

import '../../../config/presentation/layout_config.dart';
import '../data/messages_repository.dart';
import 'chat_section.dart';
import 'conversation_list.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ConversationList(),
        SizedBox(
          width: LayoutConfig().setFractionWidth(52),
          child: StreamBuilder(
            initialData: MessageRepository().currentConversation != null,
            stream: MessageRepository().conversationViewPortChanges,
            builder: (context, snapshot) {
              final loading = snapshot.data;
              if (loading) {
                return ChatSection(
                    conversation: MessageRepository().currentConversation);
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }
}
