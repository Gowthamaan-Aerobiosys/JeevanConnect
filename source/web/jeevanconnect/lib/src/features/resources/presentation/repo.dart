import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jeevanconnect/src/shared/presentation/components/white_space.dart';
import 'dart:convert';

import '../../../config/domain/url_handler.dart';
import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/button.dart';

class ResourcesRepoExplorer extends StatefulWidget {
  final String owner;
  final String repo;

  const ResourcesRepoExplorer(
      {super.key, required this.owner, required this.repo});

  @override
  ResourcesRepoExplorerState createState() => ResourcesRepoExplorerState();
}

class ResourcesRepoExplorerState extends State<ResourcesRepoExplorer> {
  List<GitHubItem> currentItems = [];
  List<String> navigationStack = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchContents('');
  }

  Future<void> fetchContents(String path) async {
    setState(() => isLoading = true);
    final url =
        'https://api.github.com/repos/${widget.owner}/${widget.repo}/contents/$path';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        currentItems = data.map((item) => GitHubItem.fromJson(item)).toList();
        currentItems.removeWhere((element) => element.name.startsWith("."));
        isLoading = false;
      });
    } else {
      setState(() {
        currentItems = [];
        isLoading = false;
      });
    }
  }

  void navigateToFolder(String path) {
    navigationStack.add(path);
    fetchContents(path);
  }

  void navigateBack() {
    if (navigationStack.isNotEmpty) {
      navigationStack.removeLast();
      String path = navigationStack.isEmpty ? '' : navigationStack.last;
      fetchContents(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          getBreadCrumbs(),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.w700),
        ),
        leading: navigationStack.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.chevron_left_outlined,
                  color: AppPalette.white,
                  size: Theme.of(context).textTheme.headlineLarge!.fontSize,
                ),
                onPressed: navigateBack,
              )
            : null,
      ),
      body: isLoading
          ? Center(
              child: CupertinoActivityIndicator(
                radius: 20,
                color: Theme.of(context).primaryColorLight,
              ),
            )
          : GridView.builder(
              padding: WhiteSpace.all15,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: currentItems.length,
              itemBuilder: (context, index) {
                final item = currentItems[index];
                return Button(
                  backgroundColor: null,
                  onPressed: () {
                    if (item.type == 'dir') {
                      navigateToFolder(item.path);
                    } else {
                      UrlHandler().launch(Uri.parse(item.gitUrl), context);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.type == 'dir'
                            ? Icons.folder
                            : _getFileIcon(item.name),
                        size: LayoutConfig().setFontSize(80),
                        color: item.type == 'dir' ? Colors.blue : Colors.grey,
                      ),
                      WhiteSpace.b6,
                      Text(
                        item.name,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: AppPalette.white),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.endsWith('.md')) return Icons.description;
    if (fileName.endsWith('.png') ||
        fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg')) return Icons.image;
    if (fileName.endsWith('.pdf')) return Icons.picture_as_pdf;
    return Icons.insert_drive_file;
  }

  getBreadCrumbs() {
    if (navigationStack.isEmpty) {
      return "Resources";
    } else {
      String breadCrumb = "Resources";
      for (var element in navigationStack) {
        String name = element;
        if (element.contains("/")) {
          name = element.split("/").last;
        }
        breadCrumb = "$breadCrumb > $name";
      }
      return breadCrumb;
    }
  }
}

class GitHubItem {
  final String name;
  final String path;
  final String type;
  final String downloadUrl;
  final String gitUrl;

  GitHubItem({
    required this.name,
    required this.path,
    required this.type,
    required this.downloadUrl,
    required this.gitUrl,
  });

  factory GitHubItem.fromJson(Map<String, dynamic> json) {
    return GitHubItem(
      name: json['name'],
      path: json['path'],
      type: json['type'],
      downloadUrl: json['download_url'] ?? '',
      gitUrl: json['html_url'] ?? '',
    );
  }
}
