import 'dart:convert';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/authentication_repository.dart';

class ForgotPasswordFormBloc extends FormBloc<String, String> {
  final emailId = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: 'ravigowthamaan@gmail.com');
  final captcha = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

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

  Validator<String> _validateCaptcha() {
    return (String? captcha) {
      if (captcha == null || captcha.isEmpty || captcha == captchaString) {
        return null;
      }
      return 'Invalid captcha';
    };
  }

  ForgotPasswordFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [emailId, captcha],
    );
    emailId.addValidators([_validateEmail()]);
    captcha.addValidators([_validateCaptcha()]);
  }

  Map _response = {};
  String captchaString = "";

  @override
  void onSubmitting() async {
    try {
      bool isResetProcessInitiated =
          await AuthenticationRepository().resetPassword(email: emailId.value);

      if (isResetProcessInitiated) {
        _response = {
          'title': 'Success',
          'content':
              'Password reset link is sent to the registered email address',
        };
        emitSuccess(
            successResponse: jsonEncode(_response), canSubmitAgain: false);
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
