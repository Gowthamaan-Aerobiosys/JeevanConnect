import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../routing/routes.dart';
import '../../../shared/domain/text_captcha.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/dialogs/dialogs.dart'
    show simpleDialog, DialogType;
import '../../../shared/presentation/form_elements/text_field.dart';
import '../../../shared/presentation/widgets/progress_loader.dart';
import '../domain/forgot_password_form_bloc.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  late String captcha;

  @override
  void initState() {
    super.initState();
    captcha = TextCaptcha().create();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: WhiteSpace.h50,
      child: BlocProvider(
        create: (context) => ForgotPasswordFormBloc(),
        child: Builder(
          builder: (context) {
            final forgotPasswordForm =
                BlocProvider.of<ForgotPasswordFormBloc>(context);
            forgotPasswordForm.captchaString = captcha;

            return FormBlocListener<ForgotPasswordFormBloc, String, String>(
              onSubmitting: (context, state) {
                ProgressLoader.show(context);
              },
              onSuccess: (context, state) {
                ProgressLoader.hide(context);
                if (state.hasSuccessResponse) {
                  final response = jsonDecode(state.successResponse!);
                  simpleDialog(context,
                          type: DialogType.success,
                          title: response['title'],
                          content: response['content'],
                          buttonName: "Close")
                      .then((value) => context.pop());
                }
              },
              onFailure: (context, state) {
                ProgressLoader.hide(context);
                final response = jsonDecode(state.failureResponse!);
                simpleDialog(context,
                    type: DialogType.error,
                    title: response['title'],
                    content: response['content'],
                    buttonName: "Close");
              },
              child: Padding(
                padding: WhiteSpace.all15,
                child: Column(
                  children: [
                    WhiteSpace.b16,
                    FormTextField(
                        textFieldBloc: forgotPasswordForm.emailId,
                        label: "Email",
                        icon: Icons.email_outlined),
                    WhiteSpace.b16,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Shown Captcha value to user
                        Container(
                            padding: WhiteSpace.all10,
                            decoration: BoxDecoration(
                                border: Border.all(width: 2),
                                color: AppPalette.greenS9,
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(
                              captcha,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.italic),
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        // Regenerate captcha value
                        IconButton(
                            onPressed: () {
                              captcha = TextCaptcha().create();
                              forgotPasswordForm.captchaString = captcha;
                              forgotPasswordForm.captcha.clear();
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: Theme.of(context).primaryColorLight,
                            )),
                      ],
                    ),
                    WhiteSpace.b16,
                    FormTextField(
                      textFieldBloc: forgotPasswordForm.captcha,
                      label: "Captcha",
                      icon: Icons.key_outlined,
                    ),
                    WhiteSpace.b16,
                    Button(
                      hoverColor: null,
                      onPressed: () {
                        _validateForm(forgotPasswordForm);
                        if (forgotPasswordForm.state.isValid()) {
                          // ProcessValidator().checkForInternet(context, () {
                          //   loginForm.submit();
                          // });
                          forgotPasswordForm.submit();
                        }
                      },
                      minWidth: 150,
                      child: Text(
                        "Reset the password",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    WhiteSpace.b16,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _validateForm(ForgotPasswordFormBloc loginForm) {
    loginForm.emailId.validate();
    loginForm.captcha.validate();
  }
}
