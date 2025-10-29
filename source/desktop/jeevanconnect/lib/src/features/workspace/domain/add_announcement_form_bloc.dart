import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/workspace_repository.dart';

class AddAnnouncementFormBloc extends FormBloc<String, String> {
  final announcement = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  AddAnnouncementFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [announcement],
    );
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isAddDepartmentRequest =
          await WorkspaceRepository().addAnnouncement(announcement.value);
      if (isAddDepartmentRequest) {
        _response = {
          'title': 'Success',
          'content': 'Announcement added successfully',
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
