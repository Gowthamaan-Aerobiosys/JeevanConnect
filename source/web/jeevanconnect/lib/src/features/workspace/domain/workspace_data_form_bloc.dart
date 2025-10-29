import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/workspace_repository.dart';

class WorkspaceDataFormBloc extends FormBloc<String, String> {
  final name = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: WorkspaceRepository().currentWorkspace.name);
  final streetAddress1 = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue:
          WorkspaceRepository().currentWorkspace.streetAddress.split('|')[0]);
  final streetAddress2 = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue:
          WorkspaceRepository().currentWorkspace.streetAddress.split('|')[1]);
  final city = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: WorkspaceRepository().currentWorkspace.city);
  final memberState = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: WorkspaceRepository().currentWorkspace.state);
  final country = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: WorkspaceRepository().currentWorkspace.country);
  final postalCode = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: WorkspaceRepository().currentWorkspace.postalCode);
  final website = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: WorkspaceRepository().currentWorkspace.website);

  WorkspaceDataFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [
        name,
        streetAddress1,
        streetAddress2,
        city,
        memberState,
        country,
        postalCode,
        website,
      ],
    );
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isWorkspaceCreated = await WorkspaceRepository().updateWorkspace(
        workspaceData: {
          "workspace_id": WorkspaceRepository().currentWorkspace.workspaceId,
          "name": name.value,
          "street_address": "${streetAddress1.value}|${streetAddress2.value}",
          "city": city.value,
          "state": memberState.value,
          "country": country.value,
          "postal_code": postalCode.value,
          "website": website.value
        },
      );
      if (isWorkspaceCreated) {
        _response = {
          'title': 'Success',
          'content': 'Workspace created successfully',
        };
        emitSuccess(
            successResponse: jsonEncode(_response), canSubmitAgain: false);
      } else {
        emitFailure();
      }
    } catch (exception) {
      debugPrint("Workspace Update $exception");
      _response = {
        'title': (exception as dynamic).title,
        'content': (exception as dynamic).displayMessage,
      };
      emitFailure(failureResponse: jsonEncode(_response));
    }
  }
}
