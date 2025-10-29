import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/workspace_repository.dart';

class AddDepartmentBloc extends FormBloc<String, String> {
  final departments = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  AddDepartmentBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [departments],
    );
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isAddDepartmentRequest =
          await WorkspaceRepository().addDepartments(departments.value);
      if (isAddDepartmentRequest) {
        _response = {
          'title': 'Success',
          'content': 'Department added successfully',
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
