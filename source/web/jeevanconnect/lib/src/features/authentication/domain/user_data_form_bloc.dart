import 'dart:convert';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/authentication_repository.dart';

class UserDataFormBloc extends FormBloc<String, String> {
  final firstName = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: AuthenticationRepository().currentUser.firstName);
  final lastName = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: AuthenticationRepository().currentUser.lastName);
  final designation = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: AuthenticationRepository().currentUser.designation);
  final registeredId = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: AuthenticationRepository().currentUser.registeredId);

  UserDataFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [
        firstName,
        lastName,
        designation,
        registeredId,
      ],
    );
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isUserUpdated = await AuthenticationRepository().updateUser(
        userData: {
          "email": AuthenticationRepository().currentUser.email,
          "first_name": firstName.value,
          "last_name": lastName.value,
          "designation": designation.value,
          "registered_id": registeredId.value
        },
      );
      if (isUserUpdated) {
        _response = {
          'title': 'Success',
          'content': 'User updated successfully',
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
