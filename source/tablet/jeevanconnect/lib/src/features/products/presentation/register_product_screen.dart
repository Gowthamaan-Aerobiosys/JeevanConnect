import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../routing/routes.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import 'register_product_form.dart';

class RegisterProductScreen extends StatefulWidget {
  const RegisterProductScreen({super.key});

  @override
  State<RegisterProductScreen> createState() => _RegisterProductScreenState();
}

class _RegisterProductScreenState extends State<RegisterProductScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: LayoutConfig().setFractionHeight(100),
              width: LayoutConfig().setFractionWidth(60),
              child: SingleChildScrollView(
                padding: WhiteSpace.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WhiteSpace.b32,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Button(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        minWidth: 50,
                        hoverColor: null,
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: Theme.of(context).primaryColorLight,
                          size: 40,
                        ),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            context.pop();
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: WhiteSpace.h50,
                      child: Text(
                        'JeevanConnect - Products',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    WhiteSpace.b12,
                    Padding(
                      padding: WhiteSpace.h50,
                      child: Text(
                        'Please provide the following details to register a product',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    WhiteSpace.b6,
                    const RegisterProductForm(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: AppPalette.logoBlue,
                child: Center(
                  child: Text(
                    'Jeevan Connect©️ - Products',
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontWeight: FontWeight.w700, color: AppPalette.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
