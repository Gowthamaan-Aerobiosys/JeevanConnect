import 'package:flutter/material.dart';

import '../../../routing/routes.dart';
import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import 'signup_form.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
              child: Center(
                child: SingleChildScrollView(
                  padding: WhiteSpace.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                          'Welcome to JeevanConnect',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      WhiteSpace.b12,
                      Padding(
                        padding: WhiteSpace.h50,
                        child: Text(
                          'Please provide the following details to sign up for your account',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      WhiteSpace.b6,
                      const SignupForm()
                    ],
                  ),
                ),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
