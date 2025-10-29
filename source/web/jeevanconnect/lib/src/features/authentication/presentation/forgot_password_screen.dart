import 'package:flutter/material.dart';

import '../../../routing/routes.dart';
import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import 'forgot_password_form.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: LayoutConfig().setFractionHeight(100),
            width: LayoutConfig().setFractionWidth(60),
            child: SingleChildScrollView(
              padding: WhiteSpace.v30,
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
                        context.pop();
                      },
                    ),
                  ),
                  WhiteSpace.b12,
                  Padding(
                    padding: WhiteSpace.h50,
                    child: Text(
                      'Reset your password',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  WhiteSpace.b12,
                  Padding(
                    padding: WhiteSpace.h50,
                    child: Text(
                      'Please provide the email address that you used when you signed up for your account',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  WhiteSpace.b12,
                  const ForgotPasswordForm()
                ],
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
    );
  }
}
