import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/white_space.dart';
import 'signin_form.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: AppPalette.logoBlue,
              child: Center(
                child: Text(
                  'Jeevan Connect©️',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontWeight: FontWeight.w700, color: AppPalette.white),
                ),
              ),
            ),
          ),
          SizedBox(
            height: LayoutConfig().setFractionHeight(100),
            width: LayoutConfig().setFractionWidth(60),
            child: Center(
              child: SingleChildScrollView(
                padding: WhiteSpace.all70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to JeevanConnect',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      '\nPlease sign in to your account',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SigninForm()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
