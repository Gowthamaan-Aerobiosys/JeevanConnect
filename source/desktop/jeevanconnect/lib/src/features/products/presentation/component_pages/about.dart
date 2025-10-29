import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../../config/data/assets.dart';
import '../../../../config/domain/url_handler.dart';
import '../../../../config/presentation/app_palette.dart';
import '../../../../config/presentation/layout_config.dart';
import '../../../../shared/presentation/components/button.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import '../../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../../../../shared/presentation/widgets/general_status_indicator.dart';
import '../../data/product_repository.dart';
import 'graph_card.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: WhiteSpace.h10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              WhiteSpace.w56,
              SizedBox(
                height: LayoutConfig().setFractionHeight(22),
                child: Image.asset(
                  AppAssets.jl360,
                  cacheHeight: LayoutConfig().setFractionHeight(22).toInt(),
                  fit: BoxFit.contain,
                ),
              ),
              WhiteSpace.w96,
              Expanded(
                child: SizedBox(
                  height: LayoutConfig().setFractionHeight(22),
                  child: Column(
                    children: [
                      Card(
                        color: AppPalette.white,
                        shape: WidgetDecoration.roundedEdge5,
                        margin: WhiteSpace.v10,
                        child: Row(
                          children: [
                            WhiteSpace.w16,
                            Expanded(
                              child: InfoTile(
                                title: "Serial Number",
                                subTitle: ProductRepository()
                                    .currentProduct
                                    .serialNumber,
                              ),
                            ),
                            Expanded(
                              child: InfoTile(
                                title: "Lot Number",
                                subTitle: ProductRepository()
                                    .currentProduct
                                    .lotNumber,
                              ),
                            ),
                            Expanded(
                              child: InfoTile(
                                title: "Product Name",
                                subTitle: ProductRepository()
                                    .currentProduct
                                    .productName,
                              ),
                            ),
                            Expanded(
                              child: InfoTile(
                                title: "Model Number",
                                subTitle: ProductRepository()
                                    .currentProduct
                                    .modelName,
                              ),
                            ),
                            Expanded(
                              child: InfoTile(
                                title: "Software version",
                                subTitle: ProductRepository()
                                    .currentProduct
                                    .softwareVersion,
                              ),
                            ),
                            Expanded(
                              child: InfoTile(
                                title: "Device Status",
                                subTitle: "",
                                subTitleWidget: BinaryStatusIndicator(
                                    isActive: ProductRepository()
                                        .currentProduct
                                        .onlineStatus,
                                    inactiveBackground: AppPalette.greyC3,
                                    inactiveForeground: AppPalette.white,
                                    labels: ("Online", "Offline")),
                              ),
                            ),
                            WhiteSpace.w16,
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // QuickLinkButton(
                            //   icon: Icons.message_outlined,
                            //   label: "Message",
                            //   onPressed: () {},
                            // ),
                            // QuickLinkButton(
                            //   icon: Icons.share_outlined,
                            //   label: "Share access",
                            //   onPressed: () {},
                            // ),
                            QuickLinkButton(
                              icon: Icons.workspace_premium_outlined,
                              label: "Certifications",
                              onPressed: () {
                                UrlHandler()
                                    .launch(AppUrls.emcTestReport, context);
                              },
                            ),
                            QuickLinkButton(
                              icon: Icons.chrome_reader_mode_outlined,
                              label: "Quick guide",
                              onPressed: () {
                                UrlHandler()
                                    .launch(AppUrls.quickGuide, context);
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const BatteryCard(),
              WhiteSpace.w12,
              const Expanded(child: CurrentStatus()),
            ],
          ),
          Row(
            children: [
              LocationCard(url: ProductRepository().currentProduct.location),
              WhiteSpace.w12,
              const GraphCard(),
            ],
          ),
          WhiteSpace.b16,
        ],
      ),
    );
  }
}

class BatteryCard extends StatelessWidget {
  const BatteryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.white,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.v10,
      child: SizedBox(
        width: LayoutConfig().setFractionWidth(30),
        child: Column(
          children: [
            InfoTile(
                title: "Battery Serial Number",
                subTitle:
                    ProductRepository().currentProduct.batterySerialNumber),
            InfoTile(
                title: "Battery Manufactured On",
                subTitle: ProductRepository()
                    .currentProduct
                    .batteryManufacturingDate
                    .toString()
                    .split(" ")[0]),
          ],
        ),
      ),
    );
  }
}

class LocationCard extends StatefulWidget {
  final String? url;
  const LocationCard({super.key, required this.url});

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  WebviewController? _controller;

  Future<void> initPlatformState() async {
    try {
      debugPrint("Webview called");
      _controller = WebviewController();
      await _controller!.initialize();
      await _controller!.setBackgroundColor(Colors.transparent);
      await _controller!.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      final location = widget.url!.split("|")[0];
      await _controller!.loadUrl(location);
      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (exception) {
      debugPrint("Loading Maps Exception: $exception");
    }
  }

  @override
  void initState() {
    if (widget.url != null) {
      initPlatformState();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    try {
      _controller?.dispose();
    } catch (exception) {
      debugPrint("Location Card Print: $exception");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.white,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.zero,
      child: SizedBox(
        height: LayoutConfig().setHeight(350),
        width: LayoutConfig().setFractionWidth(30),
        child: widget.url == null
            ? Center(
                child: Text(
                "JeevanConnect couldn't locate the product",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: AppPalette.black),
              ))
            : ClipRRect(
                borderRadius: WidgetDecoration.borderRadius5,
                child: StreamBuilder(
                  stream: _controller!.loadingState,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != LoadingState.navigationCompleted) {
                      return const Center(
                        child: CupertinoActivityIndicator(
                          radius: 20,
                          color: AppPalette.greyC2,
                        ),
                      );
                    } else {
                      return Webview(_controller!);
                    }
                  },
                ),
              ),
      ),
    );
  }
}

class CurrentStatus extends StatelessWidget {
  const CurrentStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.white,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.v10,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                InfoTile(
                    title: "Activity",
                    subTitle: "",
                    subTitleWidget: GeneralStatusIndicator(
                      currentValue: ProductRepository().currentProduct.status,
                      backGroudColor: const [
                        AppPalette.blueC1,
                        AppPalette.greenC1,
                        AppPalette.redS1,
                        AppPalette.greyC3
                      ],
                      foreGroudColor: const [
                        AppPalette.blueS9,
                        AppPalette.greenS9,
                        AppPalette.redS8,
                        AppPalette.white
                      ],
                      hints: const ["ID", "IU", "RP", "OF"],
                      labels: const [
                        "Idle",
                        "Monitoring",
                        "In Service",
                        "Offline"
                      ],
                    )),
                InfoTile(
                    title: "In Service",
                    subTitle: ProductRepository().currentProduct.serviceStatus
                        ? "Yes"
                        : "No"),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                InfoTile(
                    title: "Workspace",
                    subTitle:
                        ProductRepository().currentProduct.workspace.name),
                InfoTile(
                    title: "Registered On",
                    subTitle: ProductRepository()
                        .currentProduct
                        .createdAt
                        .toString()
                        .split(" ")[0]),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                InfoTile(
                    title: "Department",
                    subTitle: ProductRepository().currentProduct.department ??
                        "Not Assigned"),
                InfoTile(
                    title: "Manufactured On",
                    subTitle: ProductRepository()
                        .currentProduct
                        .manufacturedOn
                        .toString()
                        .split(' ')[0]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget? subTitleWidget;
  const InfoTile(
      {super.key,
      required this.title,
      required this.subTitle,
      this.subTitleWidget});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .labelLarge!
            .copyWith(color: AppPalette.greyC3),
      ),
      subtitle: subTitleWidget ??
          Text(
            subTitle,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: AppPalette.black, fontWeight: FontWeight.w600),
          ),
    );
  }
}

class QuickLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const QuickLinkButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Button(
      padding: WhiteSpace.zero,
      backgroundColor: null,
      onPressed: onPressed,
      child: SizedBox(
        width: LayoutConfig().setFractionWidth(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppPalette.greyC3,
              size: LayoutConfig().setFontSize(35),
            ),
            WhiteSpace.b3,
            Flexible(
              child: Text(
                label,
                //overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
