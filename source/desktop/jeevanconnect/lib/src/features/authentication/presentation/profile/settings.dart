import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../../routing/routes.dart';
import '../../../../config/presentation/app_palette.dart';
import '../../../../config/presentation/layout_config.dart';
import '../../../../shared/presentation/components/button.dart';
import '../../../../shared/presentation/components/switch_tile.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import '../../../../shared/presentation/dialogs/dialogs.dart'
    show generalDialog, simpleDialog, DialogType;
import '../../../../shared/presentation/form_elements/text_field.dart';
import '../../domain/close_account_form.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            color: AppPalette.white,
            shape: WidgetDecoration.roundedEdge5,
            margin: WhiteSpace.all10,
            child: Padding(
              padding: WhiteSpace.all15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notifications",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: AppPalette.black,
                        ),
                  ),
                  WhiteSpace.b16,
                  ListTile(
                    title: Text("New sign-in to account alert",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppPalette.black)),
                    subtitle: Text(
                        "Receive email alerts whenever your account is signed in from a new device, browser, or location.",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: AppPalette.greyC2)),
                    trailing: SwitchButton(
                      currentValue: false,
                      isEnabled: false,
                      onChanged: (value) {},
                    ),
                  ),
                  WhiteSpace.b16,
                  ListTile(
                    title: Text("Third-party app access alert",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppPalette.black)),
                    subtitle: Text(
                        "Receive email alerts whenever your account is accessed from a new third-party app or location.",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: AppPalette.greyC2)),
                    trailing: SwitchButton(
                      currentValue: false,
                      isEnabled: false,
                      onChanged: (value) {},
                    ),
                  ),
                  WhiteSpace.b16,
                  ListTile(
                    title: Text("Newsletter subscription",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppPalette.black)),
                    subtitle: Text(
                        "Receive marketing communication regarding Zoho's products, services, and events from Zoho and its regional partners.",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: AppPalette.greyC2)),
                    trailing: SwitchButton(
                      currentValue: false,
                      isEnabled: false,
                      onChanged: (value) {},
                    ),
                  ),
                  WhiteSpace.b32,
                ],
              ),
            ),
          ),
          Card(
            color: AppPalette.white,
            shape: WidgetDecoration.roundedEdge5,
            margin: WhiteSpace.all10,
            child: Padding(
              padding: WhiteSpace.all20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      "Linked Accounts",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(color: AppPalette.black),
                    ),
                    subtitle: Text(
                      "View and manage the list of accounts that are linked with your Jeevan account.",
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(color: AppPalette.greyS8),
                    ),
                  ),
                  WhiteSpace.b32,
                  Center(
                    child: Button(
                      onPressed: () {},
                      backgroundColor: null,
                      toolTip: "Link Your Account",
                      child: Text(
                        '+ Link Your Account',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: AppPalette.greyC3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: AppPalette.white,
            shape: WidgetDecoration.roundedEdge5,
            margin: WhiteSpace.all10,
            child: Padding(
              padding: WhiteSpace.all20,
              child: ListTile(
                title: Text(
                  "Close Account",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: AppPalette.black),
                ),
                subtitle: Text(
                  "Permanently delete all the data associated with your account and the apps you use.",
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: AppPalette.greyS8),
                ),
                trailing: Button(
                  onPressed: () {
                    _closeAccountDialog(context).then((value) {
                      if (value ?? false) {
                        context.pushReplacement(Routes.signin,
                            rootNavigator: true);
                      }
                    });
                  },
                  backgroundColor: AppPalette.red,
                  toolTip: "Close Your Account",
                  child: Text(
                    'Close Your Account',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _closeAccountDialog(BuildContext context) {
    return generalDialog(context,
        barrierDismissible: true,
        alignment: Alignment.center,
        child: Card(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SizedBox(
            height: LayoutConfig().setFractionHeight(40),
            width: LayoutConfig().setFractionWidth(40),
            child: BlocProvider(
              create: (BuildContext context) => CloseAccountFormBloc(),
              child: Builder(
                builder: (BuildContext context) {
                  final closeAccountForm =
                      BlocProvider.of<CloseAccountFormBloc>(context);

                  return FormBlocListener<CloseAccountFormBloc, String, String>(
                    onSubmitting: (context, state) {},
                    onSuccess: (context, state) {
                      context.rootPop(true);
                    },
                    onFailure: (context, state) {
                      context.rootPop(false);
                      final response = jsonDecode(state.failureResponse!);
                      simpleDialog(context,
                          type: DialogType.error,
                          title: response['title'],
                          content: response['content'],
                          buttonName: "Close");
                    },
                    child: Column(
                      children: [
                        WhiteSpace.b32,
                        Text(
                          "Close Account",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                  color: AppPalette.red,
                                  fontWeight: FontWeight.bold),
                        ),
                        WhiteSpace.b12,
                        Padding(
                          padding: WhiteSpace.h30,
                          child: Text(
                            "This is a irreversible action and will delete all the data associated with your account. Please enter your password to proceed.",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(color: AppPalette.white),
                          ),
                        ),
                        WhiteSpace.b16,
                        Padding(
                          padding: WhiteSpace.h30,
                          child: FormTextField(
                            textFieldBloc: closeAccountForm.password,
                            label: "Password",
                            icon: Icons.password_outlined,
                            isPasswordField: true,
                          ),
                        ),
                        WhiteSpace.spacer,
                        const Divider(thickness: 0.2, color: AppPalette.greyS8),
                        WhiteSpace.b16,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Button(
                              buttonPadding: WhiteSpace.zero,
                              onPressed: () {
                                context.rootPop(false);
                              },
                              backgroundColor: AppPalette.transparent,
                              child: Text(
                                "Cancel",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                        color: AppPalette.greyC3,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                            WhiteSpace.w32,
                            Button(
                              buttonPadding: WhiteSpace.zero,
                              onPressed: () {
                                closeAccountForm.password.validate();
                                if (closeAccountForm.state.isValid()) {
                                  closeAccountForm.submit();
                                }
                              },
                              backgroundColor: AppPalette.transparent,
                              child: Text(
                                "Proceed",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                        color: AppPalette.green,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                            WhiteSpace.w32,
                          ],
                        ),
                        WhiteSpace.spacer,
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ));
  }
}
