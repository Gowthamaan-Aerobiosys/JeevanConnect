import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../routing/routes.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/dialogs/dialogs.dart'
    show simpleDialog, DialogType;
import '../../../shared/presentation/form_elements/text_field.dart';
import '../../../shared/presentation/widgets/progress_loader.dart';
import '../domain/signup_form_bloc.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocProvider(
        create: (context) => SignupFormBloc(),
        child: Builder(
          builder: (context) {
            final signupForm = BlocProvider.of<SignupFormBloc>(context);

            return FormBlocListener<SignupFormBloc, String, String>(
              onSubmitting: (context, state) {
                ProgressLoader.show(context);
              },
              onSuccess: (context, state) {
                ProgressLoader.hide(context);
                if (state.hasSuccessResponse) {
                  context.replace(Routes.signin);
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
                padding: WhiteSpace.h50,
                child: Column(
                  children: [
                    WhiteSpace.b16,
                    FormTextField(
                        textFieldBloc: signupForm.emailId,
                        label: "Email*",
                        icon: Icons.email_outlined),
                    WhiteSpace.b16,
                    FormTextField(
                        textFieldBloc: signupForm.contact,
                        label: "Contact*",
                        icon: Icons.call_outlined),
                    WhiteSpace.b16,
                    FormTextField(
                        textFieldBloc: signupForm.firstName,
                        label: "First Name",
                        icon: Icons.text_fields_outlined),
                    FormTextField(
                        textFieldBloc: signupForm.lastName,
                        label: "Last Name",
                        icon: Icons.text_fields_outlined),
                    FormTextField(
                        textFieldBloc: signupForm.designation,
                        label: "Designation",
                        icon: Icons.text_fields_outlined),
                    FormTextField(
                        textFieldBloc: signupForm.registeredId,
                        label: "Registration ID",
                        icon: Icons.text_fields_outlined),
                    WhiteSpace.b16,
                    FormTextField(
                      textFieldBloc: signupForm.password,
                      label: "Password",
                      icon: Icons.password_outlined,
                      isPasswordField: true,
                    ),
                    FormTextField(
                      textFieldBloc: signupForm.confirmPassword,
                      label: "Confirm Password",
                      icon: Icons.password_outlined,
                      isPasswordField: true,
                    ),
                    WhiteSpace.b16,
                    Button(
                      hoverColor: null,
                      onPressed: () {
                        _validateForm(signupForm);
                        if (signupForm.state.isValid()) {
                          // ProcessValidator().checkForInternet(context, () {
                          signupForm.submit();
                          // });
                        }
                      },
                      minWidth: 150,
                      child: Text(
                        "Sign Up",
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

  _validateForm(SignupFormBloc signupForm) {
    signupForm.emailId.validate();
    signupForm.password.validate();
    signupForm.firstName.validate();
    signupForm.lastName.validate();
    signupForm.designation.validate();
    signupForm.registeredId.validate();
  }
}
