import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../shared/presentation/components/button.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/dialogs/dialogs.dart'
    show simpleDialog, DialogType;
import '../../../../shared/presentation/form_elements/text_field.dart';
import '../../../../shared/presentation/widgets/progress_loader.dart';
import '../../domain/user_data_form_bloc.dart';

class AccountForm extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback saveCallback;
  final VoidCallback cancelCallback;
  const AccountForm(
      {super.key,
      required this.isEnabled,
      required this.saveCallback,
      required this.cancelCallback});

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserDataFormBloc(),
      child: Builder(
        builder: (context) {
          final accountForm = BlocProvider.of<UserDataFormBloc>(context);

          return FormBlocListener<UserDataFormBloc, String, String>(
            onSubmitting: (context, state) {
              ProgressLoader.show(context);
            },
            onSuccess: (context, state) {
              ProgressLoader.hide(context);
              if (state.hasSuccessResponse) {
                widget.saveCallback();
              }
            },
            onFailure: (context, state) {
              ProgressLoader.hide(context);
              widget.saveCallback();
              final response = jsonDecode(state.failureResponse!);
              simpleDialog(context,
                  type: DialogType.error,
                  title: response['title'],
                  content: response['content'],
                  buttonName: "Close");
            },
            child: Padding(
              padding: WhiteSpace.h20,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FormTextField(
                          isEnabled: widget.isEnabled,
                          textFieldBloc: accountForm.firstName,
                          textColor: AppPalette.black,
                          label: "First Name",
                          icon: null,
                        ),
                      ),
                      WhiteSpace.w32,
                      Expanded(
                        child: FormTextField(
                          isEnabled: widget.isEnabled,
                          textFieldBloc: accountForm.lastName,
                          textColor: AppPalette.black,
                          label: "Last Name",
                          icon: null,
                        ),
                      ),
                      WhiteSpace.w96
                    ],
                  ),
                  WhiteSpace.b32,
                  Row(
                    children: [
                      Expanded(
                        child: FormTextField(
                          isEnabled: widget.isEnabled,
                          textFieldBloc: accountForm.designation,
                          textColor: AppPalette.black,
                          label: "Designation",
                          icon: null,
                        ),
                      ),
                      WhiteSpace.w32,
                      Expanded(
                        child: FormTextField(
                          isEnabled: widget.isEnabled,
                          textFieldBloc: accountForm.registeredId,
                          textColor: AppPalette.black,
                          label: "Registered ID",
                          icon: null,
                        ),
                      ),
                      WhiteSpace.w96
                    ],
                  ),
                  WhiteSpace.b16,
                  if (widget.isEnabled)
                    Row(
                      children: [
                        Button(
                          onPressed: () {
                            _validateForm(accountForm);
                            if (accountForm.state.isValid()) {
                              accountForm.submit();
                            }
                          },
                          backgroundColor: AppPalette.greenC1,
                          toolTip: "Save details",
                          child: Text(
                            'Save',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        WhiteSpace.w12,
                        Button(
                          onPressed: () {
                            widget.cancelCallback();
                          },
                          backgroundColor: AppPalette.greyC3,
                          toolTip: "Cancel",
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _validateForm(UserDataFormBloc accountForm) {
    accountForm.firstName.validate();
    accountForm.lastName.validate();
    accountForm.designation.validate();
    accountForm.registeredId.validate();
  }
}
