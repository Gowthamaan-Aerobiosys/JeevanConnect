import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:jeevanconnect/src/features/products/products.dart';

import '../../workspace/workspace.dart' show WorkspaceRepository;

class DepartmentChangeFormBloc extends FormBloc<String, String> {
  final department = SelectFieldBloc(
    items: WorkspaceRepository().currentWorkspace.departments,
    initialValue: ProductRepository().currentProduct.department,
    validators: [FieldBlocValidators.required],
  );

  DepartmentChangeFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [
        department,
      ],
    );
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isDepartmentChanged = await ProductRepository().editDepartment({
        "department": department.value ?? "",
        "serial_number": ProductRepository().currentProduct.serialNumber,
      });
      if (isDepartmentChanged) {
        _response = {
          'title': 'Department changed',
          'content':
              'Product added to ${department.value ?? ""} department in the ${WorkspaceRepository().currentWorkspace.name} workspace',
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
