import 'dart:convert';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/product_repository.dart';

class RegisterProductFormBloc extends FormBloc<String, String> {
  final productName = TextFieldBloc(
      validators: [FieldBlocValidators.required], initialValue: 'JeevanLite');
  final workspaceName = TextFieldBloc(
      validators: [FieldBlocValidators.required], initialValue: 'Gv');
  final modelName = TextFieldBloc(
      validators: [FieldBlocValidators.required], initialValue: 'JL-LTS-2024');
  final serialNumber = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: 'JL/ABS/24/6/1');
  final lotNumber = TextFieldBloc(
      validators: [FieldBlocValidators.required], initialValue: '2024/6');
  final manufacturingDate = InputFieldBloc<DateTime?, Object>(
    name: 'manufacturingDate',
    initialValue: DateTime.now(),
    toJson: (value) => value!.toUtc().toIso8601String(),
  );

  RegisterProductFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [
        workspaceName,
        productName,
        modelName,
        serialNumber,
        lotNumber,
        manufacturingDate,
      ],
    );
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      bool isProductRegistered = await ProductRepository().registerProduct(
        productData: {
          'serial_number': serialNumber.value,
          'workspace_name': workspaceName.value,
          'product_name': productName.value,
          'model_name': modelName.value,
          'lot_number': lotNumber.value,
          'manufactured_on': manufacturingDate.value!.toUtc().toString()
        },
      );
      if (isProductRegistered) {
        _response = {
          'title': 'Success',
          'content': 'Product created successfully',
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
