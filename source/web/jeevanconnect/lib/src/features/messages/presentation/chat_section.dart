import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/components/widget_decoration.dart';
import '../../../shared/presentation/widgets/progress_loader.dart';
import '../../authentication/authentication.dart';
import '../../authentication/data/user_socket_manager.dart';
import '../data/messages_repository.dart';
import '../domain/message.dart';
import 'message_card.dart';

class ChatSection extends StatefulWidget {
  final bool isSingleChat;
  final dynamic conversation;
  const ChatSection(
      {super.key, required this.conversation, this.isSingleChat = false});

  @override
  ChatSectionState createState() => ChatSectionState();
}

class ChatSectionState extends State<ChatSection> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  String conversationId = "";
  StreamSubscription? socketSubscription;

  Future<void> _fetchMessages({isLoaderGiven = false}) async {
    isLoading = true;
    MessageRepository.messages = await MessageRepository().getMessages();
    isLoading = false;
    if (isLoaderGiven && mounted) {
      ProgressLoader.hide(context);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void sendMessage() async {
    MessageRepository.messages.insert(
        0,
        Message(
            content: _controller.text,
            conversation: widget.isSingleChat
                ? widget.conversation
                : MessageRepository.messages.last.conversation,
            sender: widget.isSingleChat
                ? AuthenticationRepository().currentUser
                : MessageRepository.messages.last.sender,
            receiver: widget.isSingleChat
                ? widget.conversation.getOtherUser()
                : MessageRepository.messages.last.receiver,
            id: null,
            seen: false,
            timestamp: DateTime.now(),
            isSentMessage: true));
    MessageRepository().sendMessage(_controller.text);
    MessageRepository.conversationListUpdate!.sink.add(1);
    _controller.clear();
    _focusNode.requestFocus();
    _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (MessageRepository.messages.first.id == null) {
        MessageRepository().getMessages().then((value) {
          MessageRepository.messages = value;
          MessageRepository.conversationListUpdate!.sink.add(3);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });
        });
      }
    });
  }

  sendFileMessage() async {
    try {
      final selectedFile = (await FilePicker.platform.pickFiles(
        compressionQuality: 30,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) => debugPrint("$status"),
      ))
          ?.files;

      if (selectedFile != null && selectedFile.isNotEmpty) {
        // ignore: use_build_context_synchronously
        ProgressLoader.show(context);

        MessageRepository.messages.insert(
          0,
          Message(
              content: getFileName(selectedFile.first.path),
              fileUrl: selectedFile.first.path,
              conversation: widget.isSingleChat
                  ? widget.conversation
                  : MessageRepository.messages.last.conversation,
              sender: widget.isSingleChat
                  ? AuthenticationRepository().currentUser
                  : MessageRepository.messages.last.sender,
              receiver: widget.isSingleChat
                  ? widget.conversation.getOtherUser()
                  : MessageRepository.messages.last.receiver,
              id: null,
              seen: false,
              timestamp: DateTime.now(),
              isSentMessage: true),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }
        });

        await MessageRepository().sendFileMessage(file: selectedFile.first);
        _fetchMessages(isLoaderGiven: true);
      }
    } on PlatformException catch (exception) {
      debugPrint("PlatformException $exception");
    } catch (exception) {
      debugPrint("Exception $exception");
    }
  }

  @override
  void didUpdateWidget(covariant ChatSection oldWidget) {
    if (widget.conversation.id != conversationId) {
      conversationId = widget.conversation.id;
      isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
      MessageRepository.messages = [];
      _fetchMessages();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    conversationId = widget.conversation.id;
    listenToChatChanges();
    MessageRepository.messages = [];
    _fetchMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    socketSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CupertinoActivityIndicator(
              radius: 20,
              color: Theme.of(context).primaryColorLight,
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: const Color(0xFF242424),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(LayoutConfig().setHeight(60)),
              child: AppBar(
                titleSpacing: 0,
                leadingWidth: LayoutConfig()
                    .setFractionWidth(widget.isSingleChat ? 4 : 5),
                leading: Padding(
                  padding:
                      widget.isSingleChat ? WhiteSpace.zero : WhiteSpace.all8,
                  child: Row(
                    children: [
                      if (widget.isSingleChat)
                        IconButton(
                          padding: WhiteSpace.zero,
                          icon: Icon(
                            Icons.chevron_left_rounded,
                            color: AppPalette.black,
                            size: LayoutConfig().setFontSize(40),
                          ),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              MessageRepository().currentConversation = null;
                              Navigator.pop(context);
                            }
                          },
                        ),
                      if (!widget.isSingleChat)
                        CircleAvatar(
                          radius: LayoutConfig().setFontSize(25),
                          backgroundColor: Colors.blueGrey,
                          child: Icon(
                            Icons.person,
                            size: LayoutConfig().setFontSize(25),
                          ),
                        ),
                    ],
                  ),
                ),
                title: Text(
                    MessageRepository().currentConversation!.getDisplayName(),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: AppPalette.black)),
                actions: [
                  PopupMenuButton<String>(
                    padding: WhiteSpace.zero,
                    onSelected: (value) {},
                    icon: const Icon(Icons.more_vert_outlined),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    itemBuilder: (BuildContext contesxt) {
                      return [
                        PopupMenuItem(
                          value: "Media, links, and docs",
                          child: Text(
                            "Media, links, and docs",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ListView.separated(
                      shrinkWrap: true,
                      reverse: true,
                      padding: WhiteSpace.all15,
                      controller: _scrollController,
                      separatorBuilder: (_, __) => WhiteSpace.b12,
                      itemCount: MessageRepository.messages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == MessageRepository.messages.length) {
                          return Container(
                            height: 70,
                          );
                        }
                        if (MessageRepository.messages[index].isSentMessage) {
                          if (MessageRepository.messages[index].fileUrl !=
                              null) {
                            return SentFileMessage(
                              id: MessageRepository.messages[index].id,
                              fileName: getFileName(
                                  MessageRepository.messages[index].fileUrl),
                              fileUrl:
                                  MessageRepository.messages[index].fileUrl,
                              time: MessageRepository.messages[index].getTime(),
                              isSeen: MessageRepository.messages[index].seen,
                            );
                          }

                          return SentMessage(
                            id: MessageRepository.messages[index].id,
                            message: MessageRepository.messages[index].content,
                            time: MessageRepository.messages[index].getTime(),
                            isSeen: MessageRepository.messages[index].seen,
                          );
                        } else {
                          if (MessageRepository.messages[index].fileUrl !=
                              null) {
                            return ReceivedFileMessage(
                              id: MessageRepository.messages[index].id,
                              fileName: getFileName(
                                  MessageRepository.messages[index].fileUrl),
                              fileUrl:
                                  MessageRepository.messages[index].fileUrl,
                              time: MessageRepository.messages[index].getTime(),
                              isSeen: MessageRepository.messages[index].seen,
                            );
                          }

                          return ReceivedMessage(
                            message: MessageRepository.messages[index].content,
                            time: MessageRepository.messages[index].getTime(),
                          );
                        }
                      },
                    ),
                  ),
                ),
                SafeArea(
                  bottom: true,
                  child: Container(
                    constraints: BoxConstraints(
                        minHeight: LayoutConfig().setFractionHeight(7)),
                    child: Row(
                      children: [
                        WhiteSpace.w3,
                        CircleAvatar(
                          radius: LayoutConfig().setFontSize(22),
                          backgroundColor: AppPalette.transparent,
                          child: IconButton(
                            icon: Icon(
                              Icons.attach_file_outlined,
                              color: Colors.white,
                              size: LayoutConfig().setFontSize(22),
                            ),
                            onPressed: () {
                              sendFileMessage();
                            },
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            width: LayoutConfig().setFractionWidth(48),
                            child: Card(
                              color: AppPalette.white,
                              shape: WidgetDecoration.roundedEdge5,
                              margin: WhiteSpace.all5,
                              child: Padding(
                                padding: WhiteSpace.all1,
                                child: TextFormField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: AppPalette.black),
                                  minLines: 1,
                                  onChanged: (value) {},
                                  onFieldSubmitted: (value) {},
                                  decoration: InputDecoration(
                                    contentPadding: WhiteSpace.h15,
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide.none),
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide.none),
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide.none),
                                    hintText: "Message",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(color: AppPalette.greyC3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        WhiteSpace.w3,
                        CircleAvatar(
                          radius: LayoutConfig().setFontSize(22),
                          backgroundColor: AppPalette.logoBlue,
                          child: IconButton(
                            icon: Icon(
                              Icons.send_outlined,
                              color: Colors.white,
                              size: LayoutConfig().setFontSize(22),
                            ),
                            onPressed: () {
                              _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                              if (_controller.text.isNotEmpty) {
                                sendMessage();
                              }
                            },
                          ),
                        ),
                        WhiteSpace.w16,
                      ],
                    ),
                  ),
                ),
                WhiteSpace.b6
              ],
            ),
          );
  }

  getFileName(path) {
    if (path.contains("\\")) {
      return path.split("\\").last;
    } else if (path.contains("/")) {
      return path.split("/").last;
    }

    return "file";
  }

  listenToChatChanges() {
    socketSubscription = UserSocketManager().chatUpdates.listen((event) {
      MessageRepository.conversationListUpdate!.sink.add(3);
      _fetchMessages();
    });
  }
}
