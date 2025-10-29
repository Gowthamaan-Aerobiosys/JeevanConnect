import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../data/workspace_repository.dart';

class AnnouncementBanner extends StatefulWidget {
  const AnnouncementBanner({super.key});

  @override
  AnnouncementBannerState createState() => AnnouncementBannerState();
}

class AnnouncementBannerState extends State<AnnouncementBanner> {
  late ScrollController _controller;
  double _offset = 0;

  List announcements = [];
  bool isLoading = true;

  _getAnnouncements() async {
    final data = await WorkspaceRepository().getAnnouncements();
    announcements = data.items;
    isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    _startScrolling();
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _getAnnouncements();
    _controller = ScrollController();
  }

  void _startScrolling() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_controller.hasClients) {
        setState(() {
          _offset += 1;
        });
        _controller.animateTo(
          _offset,
          duration: const Duration(milliseconds: 50),
          curve: Curves.linear,
        );
        if (_offset < _controller.position.maxScrollExtent) {
          _startScrolling();
        } else {
          _resetScrolling();
        }
      }
    });
  }

  void _resetScrolling() {
    _offset = 0;
    _controller.jumpTo(_offset);
    _startScrolling();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: LayoutConfig().setFractionHeight(15),
      child: isLoading
          ? Center(
              child: CupertinoActivityIndicator(
                radius: 20,
                color: Theme.of(context).primaryColorLight,
              ),
            )
          : ListView.builder(
              controller: _controller,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return Center(
                  child: Padding(
                    padding: WhiteSpace.v5,
                    child: Text(
                      announcements[index].content,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                );
              },
              itemCount: announcements.length,
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
