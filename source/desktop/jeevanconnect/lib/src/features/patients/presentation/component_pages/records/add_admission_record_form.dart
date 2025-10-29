import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../../../routing/routes.dart';
import '../../../../../shared/presentation/components/button.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/dialogs/dialogs.dart'
    show simpleDialog, DialogType;
import '../../../../../shared/presentation/form_elements/date_field.dart';
import '../../../../../shared/presentation/form_elements/text_field.dart';
import '../../../../../shared/presentation/widgets/progress_loader.dart';
import '../../../domain/admission_record_form_bloc.dart';

class AddAdmissionRecordForm extends StatefulWidget {
  const AddAdmissionRecordForm({super.key});

  @override
  State<AddAdmissionRecordForm> createState() => _AddAdmissionRecordFormState();
}

class _AddAdmissionRecordFormState extends State<AddAdmissionRecordForm> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocProvider(
        create: (context) => AdmissionRecordFormBloc(),
        child: Builder(
          builder: (context) {
            final addRecordForm =
                BlocProvider.of<AdmissionRecordFormBloc>(context);

            return FormBlocListener<AdmissionRecordFormBloc, String, String>(
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
                    FormDateField(
                        dateTimeFieldBloc: addRecordForm.admissionDate,
                        label: "Admitted on*"),
                    Row(
                      children: [
                        Expanded(
                          child: FormTextField(
                              textFieldBloc: addRecordForm.height,
                              label: "Height (cm)*",
                              icon: Icons.numbers),
                        ),
                        WhiteSpace.w12,
                        Expanded(
                          child: FormTextField(
                              textFieldBloc: addRecordForm.weight,
                              label: "Weight (kg)*",
                              icon: Icons.numbers),
                        ),
                      ],
                    ),
                    FormTextField(
                        textFieldBloc: addRecordForm.reasonForVentilation,
                        label: "Reason for Ventilation*",
                        maxLines: 3,
                        icon: Icons.notes),
                    FormTextField(
                        textFieldBloc: addRecordForm.reasonForAdmission,
                        label: "Reason for Admission*",
                        maxLines: 3,
                        icon: Icons.notes_outlined),
                    CheckboxFieldBlocBuilder(
                      booleanFieldBloc: addRecordForm.historyOfDiabetes,
                      body: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'History of Diabetes*',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    CheckboxFieldBlocBuilder(
                      booleanFieldBloc: addRecordForm.historyOfBp,
                      body: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'History of Hyper/hypo tension or Coronary heart disease*',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    FormTextField(
                        textFieldBloc: addRecordForm.tags,
                        label: "Patient Tags*",
                        maxLines: 2,
                        icon: Icons.tag_outlined),
                    WhiteSpace.b32,
                    FormTextField(
                        textFieldBloc: addRecordForm.summary,
                        label: "Current Summary*",
                        maxLines: 10,
                        icon: Icons.notes),
                    WhiteSpace.b32,
                    Button(
                      hoverColor: null,
                      onPressed: () {
                        _validateForm(addRecordForm);
                        if (addRecordForm.state.isValid()) {
                          // ProcessValidator().checkForInternet(context, () {
                          addRecordForm.submit();
                          // });
                        }
                      },
                      minWidth: 150,
                      child: Text(
                        "Add admission record",
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

  _validateForm(AdmissionRecordFormBloc addRecordForm) {
    addRecordForm.height.validate();
    addRecordForm.weight.validate();
    addRecordForm.admissionDate.validate();
    addRecordForm.reasonForAdmission.validate();
    addRecordForm.reasonForVentilation.validate();
    addRecordForm.tags.validate();
    addRecordForm.summary.validate();
    addRecordForm.historyOfDiabetes.validate();
    addRecordForm.historyOfBp.validate();
  }
}
