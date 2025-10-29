import 'package:flutter/material.dart';

import '../../../routing/routes.dart';
import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/components/widget_decoration.dart';
import '../data/product_repository.dart';
import 'component_pages/pages.dart';

class JeevanProduct extends StatefulWidget {
  final dynamic product;
  const JeevanProduct({super.key, required this.product});

  @override
  State<JeevanProduct> createState() => _JeevanProductState();
}

class _JeevanProductState extends State<JeevanProduct>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    ProductRepository().currentProduct = widget.product;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    ProductRepository().currentProduct = null;
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: LayoutConfig().setHeight(80),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  widget.product.serialNumber,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              WhiteSpace.spacer,
              Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                      color: AppPalette.greyC2,
                      borderRadius: WidgetDecoration.borderRadius40),
                  child: TabBar(
                    controller: _tabController,
                    indicator: const BoxDecoration(
                        color: AppPalette.logoBlue,
                        borderRadius: WidgetDecoration.borderRadius40),
                    indicatorColor: AppPalette.logoBlue,
                    indicatorPadding: WhiteSpace.all1,
                    indicatorWeight: 1.0,
                    splashBorderRadius: WidgetDecoration.borderRadius40,
                    labelColor: AppPalette.white,
                    unselectedLabelColor: AppPalette.greyS8,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Theme.of(context).scaffoldBackgroundColor,
                    labelStyle: Theme.of(context).textTheme.labelMedium,
                    tabs: const [
                      Tab(
                          child: Text(
                        'Sessions',
                        textAlign: TextAlign.center,
                      )),
                      Tab(child: Text('About')),
                      Tab(child: Text('Service History')),
                      Tab(child: Text('Settings')),
                    ],
                  ),
                ),
              )
            ],
          ),
          leading: Button(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            hoverColor: null,
            padding: WhiteSpace.zero,
            buttonPadding: WhiteSpace.zero,
            child: Icon(
              Icons.chevron_left_rounded,
              color: Theme.of(context).primaryColorLight,
              size: LayoutConfig().setFontSize(40),
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                context.pop();
              }
            },
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            MonitoringSessionsTab(),
            AboutTab(),
            ServiceTicketsTab(),
            ProductSettingsTab(),
          ],
        ),
      ),
    );
  }
}
