import 'dart:convert';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/authentication_repository.dart';

class SignupFormBloc extends FormBloc<String, String> {
  final emailId = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: "ravigowthamaan@gmail.com");
  final password = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    FieldBlocValidators.passwordMin6Chars
  ], initialValue: "12345678");
  final confirmPassword = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    FieldBlocValidators.passwordMin6Chars
  ], initialValue: "12345678");
  final firstName = TextFieldBloc(
      validators: [FieldBlocValidators.required], initialValue: "Gowthamaan");
  final lastName = TextFieldBloc(
      validators: [FieldBlocValidators.required], initialValue: "Palani");
  final designation = TextFieldBloc(
      validators: [FieldBlocValidators.required], initialValue: "Scholar");
  final registeredId = TextFieldBloc(
      validators: [FieldBlocValidators.required], initialValue: "ED23Z006");
  final contact = TextFieldBloc(
      validators: [FieldBlocValidators.required], initialValue: "9443615348");

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

  Validator<String> _confirmPassword(
    TextFieldBloc passwordTextFieldBloc,
  ) {
    return (String? confirmPassword) {
      if (confirmPassword == passwordTextFieldBloc.value) {
        return null;
      }
      return 'Must be equal to password';
    };
  }

  SignupFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [
        emailId,
        contact,
        firstName,
        lastName,
        designation,
        registeredId,
        password,
        confirmPassword
      ],
    );
    emailId.addValidators([_validateEmail()]);
    confirmPassword
      ..addValidators([_confirmPassword(password)])
      ..subscribeToFieldBlocs([password]);
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isUserCreated = await AuthenticationRepository().signup(
        userData: {
          "email": emailId.value,
          "contact": contact.value,
          "first_name": firstName.value,
          "last_name": lastName.value,
          "designation": designation.value,
          "registered_id": registeredId.value,
          "password": password.value,
        },
      );
      if (isUserCreated) {
        _response = {
          'title': 'Success',
          'content': 'User created successfully',
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
