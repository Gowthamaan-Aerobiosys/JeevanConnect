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
import '../domain/workspace_form_bloc.dart';

class CreateWorkspaceForm extends StatefulWidget {
  const CreateWorkspaceForm({super.key});

  @override
  State<CreateWorkspaceForm> createState() => _CreateWorkspaceFormState();
}

class _CreateWorkspaceFormState extends State<CreateWorkspaceForm> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocProvider(
        create: (context) => WorkspaceFormBloc(),
        child: Builder(
          builder: (context) {
            final createWorkspaceForm =
                BlocProvider.of<WorkspaceFormBloc>(context);

            return FormBlocListener<WorkspaceFormBloc, String, String>(
              onSubmitting: (context, state) {
                ProgressLoader.show(context);
              },
              onSuccess: (context, state) {
                ProgressLoader.hide(context);
                if (state.hasSuccessResponse) {
                  if (Navigator.canPop(context)) {
                    context.pop();
                  }
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
                        textFieldBloc: createWorkspaceForm.name,
                        label: "Workspace Name",
                        icon: Icons.email_outlined),
                    WhiteSpace.b16,
                    FormTextField(
                        textFieldBloc: createWorkspaceForm.emailId,
                        label: "Email",
                        icon: Icons.email_outlined),
                    WhiteSpace.b16,
                    FormTextField(
                        textFieldBloc: createWorkspaceForm.registeredId,
                        label: "Registration ID",
                        icon: Icons.text_fields_outlined),
                    WhiteSpace.b16,
                    Row(
                      children: [
                        Expanded(
                          child: FormTextField(
                              textFieldBloc: createWorkspaceForm.streetAddress1,
                              label: "Address Line 1",
                              icon: Icons.add_location_outlined),
                        ),
                        WhiteSpace.w16,
                        Expanded(
                          child: FormTextField(
                              textFieldBloc: createWorkspaceForm.streetAddress2,
                              label: "Address Line 2",
                              icon: Icons.add_location_outlined),
                        ),
                      ],
                    ),
                    WhiteSpace.b16,
                    Row(
                      children: [
                        Expanded(
                          child: FormTextField(
                              textFieldBloc: createWorkspaceForm.city,
                              label: "City",
                              icon: Icons.location_city_outlined),
                        ),
                        WhiteSpace.w16,
                        Expanded(
                          child: FormTextField(
                              textFieldBloc: createWorkspaceForm.memberState,
                              label: "State",
                              icon: Icons.location_on_outlined),
                        ),
                      ],
                    ),
                    WhiteSpace.b16,
                    Row(
                      children: [
                        Expanded(
                          child: FormTextField(
                              textFieldBloc: createWorkspaceForm.country,
                              label: "Country",
                              icon: Icons.location_on_outlined),
                        ),
                        WhiteSpace.w16,
                        Expanded(
                          child: FormTextField(
                              textFieldBloc: createWorkspaceForm.postalCode,
                              label: "Postal Code",
                              icon: Icons.pin_outlined),
                        ),
                      ],
                    ),
                    WhiteSpace.b16,
                    FormTextField(
                        textFieldBloc: createWorkspaceForm.website,
                        label: "Website",
                        icon: Icons.web_outlined),
                    WhiteSpace.b16,
                    FormTextField(
                        textFieldBloc: createWorkspaceForm.contact,
                        label: "Contact",
                        icon: Icons.contact_phone_outlined),
                    WhiteSpace.b16,
                    WhiteSpace.b16,
                    Button(
                      hoverColor: null,
                      onPressed: () {
                        _validateForm(createWorkspaceForm);
                        if (createWorkspaceForm.state.isValid()) {
                          // ProcessValidator().checkForInternet(context, () {
                          createWorkspaceForm.submit();
                          // });
                        }
                      },
                      minWidth: 150,
                      child: Text(
                        "Request Workspace",
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

  _validateForm(WorkspaceFormBloc workspaceForm) {
    workspaceForm.name.validate();
    workspaceForm.emailId.validate();
    workspaceForm.registeredId.validate();
  }
}
