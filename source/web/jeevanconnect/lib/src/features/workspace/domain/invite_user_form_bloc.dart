import 'dart:convert';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/workspace_repository.dart';

class InviteUserFormBloc extends FormBloc<String, String> {
  final emailId = TextFieldBloc(validators: [FieldBlocValidators.required]);

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

  InviteUserFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [emailId],
    );

    emailId.addValidators([_validateEmail()]);
  }

  Map _response = {};
  String workspaceId = "";

  @override
  void onSubmitting() async {
    try {
      bool isUserInvited = await WorkspaceRepository()
          .inviteUser(userEmail: emailId.value, workspaceId: workspaceId);
      if (isUserInvited) {
        _response = {
          'title': 'Invite sent',
          'content': 'Workspace invitation sent to  user - ${emailId.value}',
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
