import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../data/messages_repository.dart';

class ConversationCard extends StatelessWidget {
  final dynamic conversation;
  final int index;
  const ConversationCard(
      {super.key, required this.conversation, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        MessageRepository.currentIndex = index;
        MessageRepository().currentConversation = conversation;
        MessageRepository.conversationViewPort!.sink.add(true);
      },
      contentPadding: WhiteSpace.all10,
      leading: CircleAvatar(
        radius: LayoutConfig().setFontSize(30),
        backgroundColor: Colors.blueGrey,
        child: Icon(
          Icons.person,
          size: LayoutConfig().setFontSize(30),
        ),
      ),
      title: Text(
        conversation.getDisplayName(),
        style: Theme.of(context).textTheme.labelLarge,
      ),
      subtitle: Row(
        children: [
          if (conversation.messageId != null && conversation.isSentMessage)
            Icon(
              Icons.done_all,
              color:
                  conversation.isSeen ? AppPalette.greenC1 : AppPalette.greyC3,
              size: Theme.of(context).textTheme.labelLarge!.fontSize,
            ),
          if (conversation.messageId == null && conversation.isSentMessage)
            Icon(
              Icons.access_time_outlined,
              color: AppPalette.greyC3,
              size: Theme.of(context).textTheme.labelLarge!.fontSize,
            ),
          WhiteSpace.w6,
          Expanded(
            child: Text(
              conversation.content ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.w400, color: AppPalette.greyC3),
            ),
          ),
        ],
      ),
      trailing: Padding(
        padding: WhiteSpace.h10,
        child: Text(
          conversation.getTime(),
          style: Theme.of(context)
              .textTheme
              .labelSmall!
              .copyWith(fontWeight: FontWeight.w100, color: AppPalette.greyC3),
        ),
      ),
    );
  }
}
