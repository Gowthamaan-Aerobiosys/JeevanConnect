import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/authentication_repository.dart';

class SigninFormBloc extends FormBloc<String, String> {
  final emailId = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: 'ravigowthamaan@gmail.com');
  final password = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    FieldBlocValidators.passwordMin6Chars
  ], initialValue: '12345678');

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

  SigninFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [emailId, password],
    );
    emailId.addValidators([_validateEmail()]);
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      await AuthenticationRepository()
          .signin(email: emailId.value, password: password.value);
      if (AuthenticationRepository().isSignedIn) {
        _response = {
          'title': 'Success',
          'content': 'Login successful',
        };
        emitSuccess(
            successResponse: jsonEncode(_response), canSubmitAgain: false);
      }
    } catch (exception) {
      debugPrint("Signin Exception: $exception");
      _response = {
        'title': (exception as dynamic).title,
        'content': (exception as dynamic).displayMessage,
      };
      emitFailure(failureResponse: jsonEncode(_response));
    }
  }
}
