import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../shared/presentation/components/button.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/dialogs/dialogs.dart'
    show simpleDialog, DialogType;
import '../../../../../shared/presentation/form_elements/text_field.dart';
import '../../../../../shared/presentation/widgets/progress_loader.dart';
import '../../../domain/workspace_data_form_bloc.dart';

class WorkspaceDataForm extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback saveCallback;
  final VoidCallback cancelCallback;
  const WorkspaceDataForm(
      {super.key,
      required this.isEnabled,
      required this.saveCallback,
      required this.cancelCallback});

  @override
  State<WorkspaceDataForm> createState() => _WorkspaceDataFormState();
}

class _WorkspaceDataFormState extends State<WorkspaceDataForm> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkspaceDataFormBloc(),
      child: Builder(
        builder: (context) {
          final workspaceForm = BlocProvider.of<WorkspaceDataFormBloc>(context);

          return FormBlocListener<WorkspaceDataFormBloc, String, String>(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FormTextField(
                          isEnabled: widget.isEnabled,
                          textFieldBloc: workspaceForm.name,
                          textColor: AppPalette.black,
                          label: "Workspace Name",
                          icon: null,
                        ),
                      ),
                      WhiteSpace.w32,
                      Expanded(
                        child: FormTextField(
                          isEnabled: widget.isEnabled,
                          textFieldBloc: workspaceForm.website,
                          textColor: AppPalette.black,
                          label: "Website",
                          icon: null,
                        ),
                      ),
                      WhiteSpace.w96
                    ],
                  ),
                  WhiteSpace.b16,
                  Row(
                    children: [
                      Expanded(
                        child: FormTextField(
                          isEnabled: widget.isEnabled,
                          textFieldBloc: workspaceForm.streetAddress1,
                          textColor: AppPalette.black,
                          label: "Address Line - 1",
                          icon: null,
                        ),
                      ),
                      WhiteSpace.w32,
                      Expanded(
                        child: FormTextField(
                          isEnabled: widget.isEnabled,
                          textFieldBloc: workspaceForm.streetAddress2,
                          textColor: AppPalette.black,
                          label: "Address Line - 2",
                          icon: null,
                        ),
                      ),
                      WhiteSpace.w96
                    ],
                  ),
                  WhiteSpace.b16,
                  Row(
                    children: [
                      Expanded(
                        child: FormTextField(
                          isEnabled: widget.isEnabled,
                          textFieldBloc: workspaceForm.city,
                          textColor: AppPalette.black,
                          label: "City",
                          icon: null,
                        ),
                      ),
                      WhiteSpace.w32,
                      Expanded(
                        child: FormTextField(
                          isEnabled: widget.isEnabled,
                          textFieldBloc: workspaceForm.memberState,
                          textColor: AppPalette.black,
                          label: "State",
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
                          textFieldBloc: workspaceForm.country,
                          textColor: AppPalette.black,
                          label: "Country",
                          icon: null,
                        ),
                      ),
                      WhiteSpace.w32,
                      Expanded(
                        child: FormTextField(
                          isEnabled: widget.isEnabled,
                          textFieldBloc: workspaceForm.postalCode,
                          textColor: AppPalette.black,
                          label: "Postal code",
                          icon: null,
                        ),
                      ),
                      WhiteSpace.w96
                    ],
                  ),
                  WhiteSpace.b16,
                  if (widget.isEnabled)
                    Text(
                      "*Reopen the workspace for the changes to take effect globally.",
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(color: AppPalette.blackC1),
                    ),
                  WhiteSpace.b16,
                  if (widget.isEnabled)
                    Row(
                      children: [
                        Button(
                          onPressed: () {
                            _validateForm(workspaceForm);
                            if (workspaceForm.state.isValid()) {
                              workspaceForm.submit();
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

  _validateForm(WorkspaceDataFormBloc workspaceDataForm) {
    workspaceDataForm.name.validate();
    workspaceDataForm.website.validate();
    workspaceDataForm.streetAddress1.validate();
    workspaceDataForm.streetAddress2.validate();
    workspaceDataForm.city.validate();
    workspaceDataForm.country.validate();
    workspaceDataForm.memberState.validate();
    workspaceDataForm.postalCode.validate();
  }
}
