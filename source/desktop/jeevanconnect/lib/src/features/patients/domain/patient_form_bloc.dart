import 'dart:convert';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../workspace/workspace.dart' show WorkspaceRepository;
import '../data/patient_repository.dart';

class RegisterPatientFormBloc extends FormBloc<String, String> {
  final patientId = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final name = TextFieldBloc();
  final age = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final gender = SelectFieldBloc(
      items: ['Male', 'Female', 'Other'],
      validators: [FieldBlocValidators.required]);
  final bloodGroup = SelectFieldBloc(
      items: ['', 'A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-']);
  final contact = TextFieldBloc();
  final aadhar = TextFieldBloc();
  final abha = TextFieldBloc();

  RegisterPatientFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [
        patientId,
        name,
        age,
        gender,
        bloodGroup,
        contact,
        aadhar,
        abha,
      ],
    );
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isProductRegistered =
          await PatientRepository().registerPatient(patientData: {
        'patient_id': patientId.value,
        'workspace_id': WorkspaceRepository().currentWorkspace.workspaceId,
        'name': name.value,
        'age': age.value,
        'gender': gender.value,
        'blood_group': bloodGroup.value,
        'contact': contact.value,
        'aadhar': aadhar.value,
        'abha': abha.value
      });
      if (isProductRegistered) {
        _response = {
          'title': 'Success',
          'content': 'Patient registered successfully',
        };
        emitSuccess(
            successResponse: jsonEncode(_response), canSubmitAgain: false);
      } else {
        emitFailure();
      }
    } catch (exception) {
      _response = {
        'title': (exception as dynamic).title,
        'content': (exception as dynamic).displayMessage,
      };
      emitFailure(failureResponse: jsonEncode(_response));
    }
  }
}
