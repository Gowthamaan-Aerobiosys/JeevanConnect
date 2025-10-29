import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/authentication_repository.dart';

class AddContactFormBloc extends FormBloc<String, String> {
  final contact = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  AddContactFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [contact],
    );
  }

  bool isEmailContact = true;
  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isContactRequestSent = await AuthenticationRepository().addContact({
        'email': AuthenticationRepository().currentUser.email,
        'contact': contact.value,
        'type': isEmailContact ? 'email' : 'phone'
      });
      if (isContactRequestSent) {
        _response = {
          'title': 'Success',
          'content': 'Request sent successfully',
        };
        emitSuccess(
            successResponse: jsonEncode(_response), canSubmitAgain: false);
      }
    } catch (exception) {
      debugPrint("Add contact Exception: $exception");
      _response = {
        'title': (exception as dynamic).title,
        'content': (exception as dynamic).displayMessage,
      };
      emitFailure(failureResponse: jsonEncode(_response));
    }
  }
}
