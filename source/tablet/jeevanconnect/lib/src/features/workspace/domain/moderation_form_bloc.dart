import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/workspace_repository.dart';

class ModerationFormBloc extends FormBloc<String, String> {
  static const _labels = ["ANYONE", "ADMIN", "OWNER"];
  static const _hintMaps = {"ADMIN": "AD", "ANYONE": "AN", "OWNER": "OW"};

  final inviteMember = SelectFieldBloc(
    items: _labels,
    initialValue: WorkspaceRepository().currentModeration.inviteMember,
    validators: [FieldBlocValidators.required],
  );
  final editDepartment = SelectFieldBloc(
    items: _labels,
    initialValue: WorkspaceRepository().currentModeration.editDepartment,
    validators: [FieldBlocValidators.required],
  );
  final addPatient = SelectFieldBloc(
    items: _labels,
    initialValue: WorkspaceRepository().currentModeration.addPatient,
    validators: [FieldBlocValidators.required],
  );
  final editProduct = SelectFieldBloc(
    items: _labels,
    initialValue: WorkspaceRepository().currentModeration.editProduct,
    validators: [FieldBlocValidators.required],
  );
  final downloadInformation = SelectFieldBloc(
    items: _labels,
    initialValue: WorkspaceRepository().currentModeration.downloadInformation,
    validators: [FieldBlocValidators.required],
  );
  final workspaceDetails = SelectFieldBloc(
    items: _labels,
    initialValue: WorkspaceRepository().currentModeration.workspaceDetails,
    validators: [FieldBlocValidators.required],
  );
  final shareDevice = SelectFieldBloc(
    items: _labels,
    initialValue: WorkspaceRepository().currentModeration.shareDevice,
    validators: [FieldBlocValidators.required],
  );

  ModerationFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [
        inviteMember,
        editDepartment,
        addPatient,
        editProduct,
        downloadInformation,
        workspaceDetails,
        shareDevice,
      ],
    );
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isPermissionsEditted = await WorkspaceRepository().editModerations({
        "workspace": WorkspaceRepository().currentWorkspace.workspaceId,
        "invite_member": _hintMaps[inviteMember.value],
        "edit_department": _hintMaps[editDepartment.value],
        "add_patient": _hintMaps[addPatient.value],
        "edit_product": _hintMaps[editProduct.value],
        "download_information": _hintMaps[downloadInformation.value],
        "workspace_details": _hintMaps[workspaceDetails.value],
        "share_device": _hintMaps[shareDevice.value],
      });
      if (isPermissionsEditted) {
        _response = {
          'title': 'Permissions Editted',
          'content': 'Workspace permissions are updated',
        };
        emitSuccess(
            successResponse: jsonEncode(_response), canSubmitAgain: false);
      }
    } catch (exception) {
      debugPrint("Workspace Permission Edit: $exception");
      _response = {
        'title': (exception as dynamic).title,
        'content': (exception as dynamic).displayMessage,
      };
      emitFailure(failureResponse: jsonEncode(_response));
    }
  }
}
