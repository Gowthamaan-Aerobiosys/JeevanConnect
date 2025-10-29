import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../routing/routes.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/dialogs/dialogs.dart'
    show simpleDialog, DialogType;
import '../../../shared/presentation/form_elements/dropdown_field.dart';
import '../../../shared/presentation/form_elements/text_field.dart';
import '../../../shared/presentation/widgets/progress_loader.dart';
import '../domain/patient_form_bloc.dart';

class RegisterPatientForm extends StatefulWidget {
  final String workspaceName;
  const RegisterPatientForm({super.key, required this.workspaceName});

  @override
  State<RegisterPatientForm> createState() => _RegisterPatientFormState();
}

class _RegisterPatientFormState extends State<RegisterPatientForm> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocProvider(
        create: (context) => RegisterPatientFormBloc(),
        child: Builder(
          builder: (context) {
            final registerPatientForm =
                BlocProvider.of<RegisterPatientFormBloc>(context);

            return FormBlocListener<RegisterPatientFormBloc, String, String>(
              onSubmitting: (context, state) {
                ProgressLoader.show(context);
              },
              onSuccess: (context, state) {
                ProgressLoader.hide(context);
                if (Navigator.canPop(context)) {
                  context.pop();
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
                        textFieldBloc: registerPatientForm.patientId,
                        label: "Patient ID",
                        icon: Icons.perm_identity_outlined),
                    FormTextField(
                        textFieldBloc: registerPatientForm.age,
                        label: "Age",
                        icon: Icons.text_fields_outlined),
                    FormDropDownField(
                        selectFieldBloc: registerPatientForm.gender,
                        label: "Gender",
                        icon: Icons.arrow_drop_down_circle_outlined),
                    WhiteSpace.b16,
                    FormTextField(
                        textFieldBloc: registerPatientForm.name,
                        label: "Name",
                        icon: Icons.text_fields_outlined),
                    FormDropDownField(
                        selectFieldBloc: registerPatientForm.bloodGroup,
                        label: "Blood group",
                        icon: Icons.arrow_drop_down_circle_outlined),
                    FormTextField(
                        textFieldBloc: registerPatientForm.contact,
                        label: "Contact",
                        icon: Icons.numbers_outlined),
                    WhiteSpace.b16,
                    FormTextField(
                        textFieldBloc: registerPatientForm.aadhar,
                        label: "Aadhar Number",
                        icon: Icons.numbers_outlined),
                    FormTextField(
                        textFieldBloc: registerPatientForm.abha,
                        label: "Abha Number",
                        icon: Icons.text_fields_outlined),
                    WhiteSpace.b16,
                    Button(
                      hoverColor: null,
                      onPressed: () {
                        _validateForm(registerPatientForm);
                        if (registerPatientForm.state.isValid()) {
                          // ProcessValidator().checkForInternet(context, () {
                          registerPatientForm.submit();
                          // });
                        }
                      },
                      minWidth: 150,
                      child: Text(
                        "Register Patient",
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

  _validateForm(RegisterPatientFormBloc registerPatientForm) {
    registerPatientForm.patientId.validate();
    registerPatientForm.gender.validate();
    registerPatientForm.age.validate();
  }
}
