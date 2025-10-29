import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../routing/routes.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/dialogs/dialogs.dart'
    show simpleDialog, DialogType;
import '../../../shared/presentation/form_elements/text_field.dart';
import '../../../shared/presentation/widgets/progress_loader.dart';
import '../domain/signin_form_bloc.dart';

class SigninForm extends StatefulWidget {
  const SigninForm({super.key});

  @override
  State<SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocProvider(
        create: (context) => SigninFormBloc(),
        child: Builder(
          builder: (context) {
            final loginForm = BlocProvider.of<SigninFormBloc>(context);

            return FormBlocListener<SigninFormBloc, String, String>(
              onSubmitting: (context, state) {
                ProgressLoader.show(context);
              },
              onSuccess: (context, state) {
                ProgressLoader.hide(context);
                if (state.hasSuccessResponse) {
                  context.pushReplacement(Routes.home);
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
                        textFieldBloc: loginForm.emailId,
                        label: "Email",
                        icon: Icons.email_outlined),
                    WhiteSpace.b16,
                    FormTextField(
                      textFieldBloc: loginForm.password,
                      label: "Password",
                      icon: Icons.password_outlined,
                      isPasswordField: true,
                      maxLines: null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Button(
                        onPressed: () {
                          context.push(Routes.forgotPassword);
                        },
                        backgroundColor: null,
                        hoverColor: null,
                        padding: WhiteSpace.zero,
                        buttonPadding: WhiteSpace.h5,
                        child: Text(
                          "Forgot password?",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(fontVariations: [
                            const FontVariation("wght", 250)
                          ]),
                        ),
                      ),
                    ),
                    WhiteSpace.b16,
                    Row(
                      children: [
                        Button(
                          hoverColor: null,
                          onPressed: () {
                            _validateForm(loginForm);
                            if (loginForm.state.isValid()) {
                              // ProcessValidator().checkForInternet(context, () {
                              //   loginForm.submit();
                              // });
                              loginForm.submit();
                            }
                          },
                          minWidth: 150,
                          child: Text(
                            "Sign In",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        WhiteSpace.w32,
                        Button(
                          backgroundColor: AppPalette.greyS8,
                          hoverColor: null,
                          onPressed: () {
                            context.push(Routes.signup);
                          },
                          minWidth: 150,
                          child: Text(
                            "Sign up",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
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

  _validateForm(SigninFormBloc loginForm) {
    loginForm.emailId.validate();
    loginForm.password.validate();
  }
}
