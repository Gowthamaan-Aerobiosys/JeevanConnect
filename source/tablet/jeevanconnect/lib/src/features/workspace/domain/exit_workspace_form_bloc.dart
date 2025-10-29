import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../authentication/authentication.dart' show User;
import '../data/workspace_repository.dart';

class ExitWorkspaceFormBloc extends FormBloc<String, String> {
  final users = SelectFieldBloc<User, User>();

  ExitWorkspaceFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [users],
    );
  }

  Map _response = {};
  String workspaceId = '';
  bool isDefaultUser = false;

  @override
  void onSubmitting() async {
    try {
      bool isUserExited = await WorkspaceRepository().exitWorkspace(
          workspaceId: workspaceId,
          defaultUser: isDefaultUser ? users.value!.userId : null);

      if (isUserExited) {
        _response = {
          'title': 'Exited workspace',
          'content': 'You are removed from this workspace',
        };
        emitSuccess(
            successResponse: jsonEncode(_response), canSubmitAgain: false);
      }
    } catch (exception) {
      debugPrint("Exit Form Exception: $exception");
      _response = {
        'title': (exception as dynamic).title,
        'content': (exception as dynamic).displayMessage,
      };
      emitFailure(failureResponse: jsonEncode(_response));
    }
  }
}
