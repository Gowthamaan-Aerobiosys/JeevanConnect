import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/patient_repository.dart';

class AddLogFormBloc extends FormBloc<String, String> {
  final clinicalLog = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);
  final addedBy = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  AddLogFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [clinicalLog, addedBy],
    );
  }

  String recordId = "";
  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isAddDepartmentRequest = await PatientRepository()
          .addClinicalLog(clinicalLog.value, recordId, addedBy.value);
      if (isAddDepartmentRequest) {
        _response = {
          'title': 'Success',
          'content': 'Log added successfully',
        };
        emitSuccess(
            successResponse: jsonEncode(_response), canSubmitAgain: false);
      }
    } catch (exception) {
      debugPrint("Add department Exception: $exception");
      _response = {
        'title': (exception as dynamic).title,
        'content': (exception as dynamic).displayMessage,
      };
      emitFailure(failureResponse: jsonEncode(_response));
    }
  }
}
