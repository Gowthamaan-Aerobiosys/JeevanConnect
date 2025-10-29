import 'package:flutter/material.dart';
import 'package:jeevanconnect/src/config/presentation/app_palette.dart';
import 'package:jeevanconnect/src/shared/presentation/components/white_space.dart';

import '../../../config/domain/url_handler.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/widget_decoration.dart';
import '../../../shared/presentation/dialogs/dialogs.dart';

class SentMessage extends StatelessWidget {
  const SentMessage(
      {super.key,
      required this.message,
      required this.time,
      required this.id,
      required this.isSeen});
  final String message;
  final String time;
  final bool isSeen;
  final String? id;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: LayoutConfig().setFractionWidth(48),
          minWidth: LayoutConfig().setFractionWidth(12),
        ),
        child: Card(
          elevation: 1,
          shape: WidgetDecoration.roundedEdge5,
          color: AppPalette.blueC1,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 30,
                  top: 5,
                  bottom: 20,
                ),
                child: Text(
                  message,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: AppPalette.black),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 10,
                child: Row(
                  children: [
                    Text(
                      time,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: AppPalette.black),
                    ),
                    WhiteSpace.w6,
                    if (id != null)
                      Icon(
                        Icons.done_all,
                        color: isSeen ? AppPalette.greenC1 : AppPalette.greyC3,
                        size: Theme.of(context).textTheme.labelLarge!.fontSize,
                      ),
                    if (id == null)
                      Icon(
                        Icons.access_time_outlined,
                        color: AppPalette.greyC3,
                        size: Theme.of(context).textTheme.labelLarge!.fontSize,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceivedMessage extends StatelessWidget {
  const ReceivedMessage({super.key, required this.message, required this.time});
  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: LayoutConfig().setFractionWidth(48),
          minWidth: LayoutConfig().setFractionWidth(12),
        ),
        child: Card(
          elevation: 1,
          shape: WidgetDecoration.roundedEdge5,
          color: AppPalette.greyC3,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 50,
                  top: 5,
                  bottom: 20,
                ),
                child: Text(
                  message,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: AppPalette.black),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 10,
                child: Text(
                  time,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: AppPalette.blackC1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SentFileMessage extends StatelessWidget {
  const SentFileMessage(
      {super.key,
      required this.fileName,
      required this.fileUrl,
      required this.time,
      required this.id,
      required this.isSeen});

  final String fileName;
  final String fileUrl;
  final String time;
  final bool isSeen;
  final String? id;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: LayoutConfig().setFractionWidth(25),
          minWidth: LayoutConfig().setFractionWidth(7),
        ),
        child: Card(
          elevation: 1,
          shape: WidgetDecoration.roundedEdge5,
          color: AppPalette.blueC1,
          child: InkWell(
            onTap: () {
              if (fileName.contains(".png") ||
                  fileName.contains(".jpg") ||
                  fileName.contains(".jpeg")) {
                _showImage(fileUrl, fileName, context);
              } else {
                UrlHandler().launch(Uri.parse(fileUrl), context);
              }
            },
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 30,
                    top: 10,
                    bottom: 25,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.file_present_outlined,
                        color: AppPalette.black,
                        size: 30,
                      ),
                      WhiteSpace.w6,
                      Expanded(
                        child: Text(
                          fileName,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                  color: AppPalette.black,
                                  overflow: TextOverflow.ellipsis),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text(
                        time,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: AppPalette.black),
                      ),
                      WhiteSpace.w6,
                      if (id != null)
                        Icon(
                          Icons.done_all,
                          color:
                              isSeen ? AppPalette.greenC1 : AppPalette.greyC3,
                          size:
                              Theme.of(context).textTheme.labelLarge!.fontSize,
                        ),
                      if (id == null)
                        Icon(
                          Icons.access_time_outlined,
                          color: AppPalette.greyC3,
                          size:
                              Theme.of(context).textTheme.labelLarge!.fontSize,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showImage(imageUrl, fileName, context) {
    generalDialog(context,
        barrierDismissible: true,
        child: Card(
          color: AppPalette.greyS2,
          child: Padding(
            padding: WhiteSpace.all10,
            child: Column(
              children: [
                WhiteSpace.b16,
                Row(
                  children: [
                    Text(
                      "   $fileName",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color: AppPalette.black,
                              fontWeight: FontWeight.bold),
                    ),
                    WhiteSpace.spacer,
                    Button(
                      backgroundColor: AppPalette.transparent,
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: AppPalette.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                WhiteSpace.b16,
                Expanded(child: Image.network(imageUrl)),
                WhiteSpace.b32,
              ],
            ),
          ),
        ));
  }
}

class ReceivedFileMessage extends StatelessWidget {
  const ReceivedFileMessage(
      {super.key,
      required this.fileName,
      required this.fileUrl,
      required this.time,
      required this.id,
      required this.isSeen});

  final String fileName;
  final String fileUrl;
  final String time;
  final bool isSeen;
  final String? id;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: LayoutConfig().setFractionWidth(25),
          minWidth: LayoutConfig().setFractionWidth(7),
        ),
        child: Card(
          elevation: 1,
          shape: WidgetDecoration.roundedEdge5,
          color: AppPalette.greyC3,
          child: InkWell(
            onTap: () {
              if (fileName.contains(".png") ||
                  fileName.contains(".jpg") ||
                  fileName.contains(".jpeg")) {
                _showImage(fileUrl, fileName, context);
              } else {
                UrlHandler().launch(Uri.parse(fileUrl), context);
              }
            },
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 50,
                    top: 5,
                    bottom: 20,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.file_present_outlined,
                        color: AppPalette.black,
                        size: 30,
                      ),
                      WhiteSpace.w6,
                      Expanded(
                        child: Text(
                          fileName,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                  color: AppPalette.black,
                                  overflow: TextOverflow.ellipsis),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text(
                        time,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: AppPalette.blackC1),
                      ),
                      WhiteSpace.w6,
                      if (id != null)
                        Icon(
                          Icons.done_all,
                          color:
                              isSeen ? AppPalette.greenC1 : AppPalette.greyC3,
                          size:
                              Theme.of(context).textTheme.labelLarge!.fontSize,
                        ),
                      if (id == null)
                        Icon(
                          Icons.access_time_outlined,
                          color: AppPalette.greyC3,
                          size:
                              Theme.of(context).textTheme.labelLarge!.fontSize,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showImage(imageUrl, fileName, context) {
    generalDialog(context,
        barrierDismissible: true,
        child: Card(
          color: AppPalette.greyS2,
          child: Padding(
            padding: WhiteSpace.all10,
            child: Column(
              children: [
                WhiteSpace.b16,
                Row(
                  children: [
                    Text(
                      "   $fileName",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color: AppPalette.black,
                              fontWeight: FontWeight.bold),
                    ),
                    WhiteSpace.spacer,
                    Button(
                      backgroundColor: AppPalette.transparent,
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: AppPalette.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                WhiteSpace.b16,
                Expanded(child: Image.network(imageUrl)),
                WhiteSpace.b32,
              ],
            ),
          ),
        ));
  }
}
