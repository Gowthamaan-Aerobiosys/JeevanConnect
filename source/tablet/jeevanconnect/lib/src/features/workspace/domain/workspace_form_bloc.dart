import 'dart:convert';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../authentication/authentication.dart' show AuthenticationRepository;
import '../data/workspace_repository.dart';

class WorkspaceFormBloc extends FormBloc<String, String> {
  final name = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final emailId = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: "ravigowthamaan@gmail.com");
  final registeredId = TextFieldBloc(
      validators: [FieldBlocValidators.required], initialValue: "ED23Z006");
  final streetAddress1 =
      TextFieldBloc(validators: [FieldBlocValidators.required]);
  final streetAddress2 =
      TextFieldBloc(validators: [FieldBlocValidators.required]);
  final city = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final memberState = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final country = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final postalCode = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final website = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final contact = TextFieldBloc(validators: [FieldBlocValidators.required]);

  Validator<String> _validateEmail() {
    final emailRegExp =
        RegExp(r'^[a-zA-Z\d_.+-]+@[a-zA-Z\d-]+\.[a-zA-Z\d-.]+$');
    return (String? email) {
      if (email == null || email.isEmpty || emailRegExp.hasMatch(email)) {
        return null;
      }
      return 'Invalid Email';
    };
  }

  WorkspaceFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [
        name,
        emailId,
        registeredId,
        streetAddress1,
        streetAddress2,
        city,
        memberState,
        country,
        postalCode,
        website,
        contact
      ],
    );
    emailId.addValidators([_validateEmail()]);
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isWorkspaceCreated = await WorkspaceRepository().createWorkspace(
        workspaceData: {
          "name": name.value,
          "email": emailId.value,
          "registered_id": registeredId.value,
          "street_address": "${streetAddress1.value},|${streetAddress2.value}",
          "city": city.value,
          "state": memberState.value,
          "country": country.value,
          "postal_code": postalCode.value,
          "website": website.value,
          "contact": contact.value,
          "user_id": AuthenticationRepository().currentUser.userId
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
      _response = {
        'title': (exception as dynamic).title,
        'content': (exception as dynamic).displayMessage,
      };
      emitFailure(failureResponse: jsonEncode(_response));
    }
  }
}
