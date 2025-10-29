import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/authentication_repository.dart';

class CloseAccountFormBloc extends FormBloc<String, String> {
  final password = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  CloseAccountFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [password],
    );
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isAccountClosed =
          await AuthenticationRepository().closeAccount(password.value);
      if (isAccountClosed) {
        _response = {
          'title': 'Success',
          'content': 'Account closed successfully',
        };
        emitSuccess(
            successResponse: jsonEncode(_response), canSubmitAgain: false);
      }
    } catch (exception) {
      debugPrint("Close account Exception: $exception");
      _response = {
        'title': (exception as dynamic).title,
        'content': (exception as dynamic).displayMessage,
      };
      emitFailure(failureResponse: jsonEncode(_response));
    }
  }
}
