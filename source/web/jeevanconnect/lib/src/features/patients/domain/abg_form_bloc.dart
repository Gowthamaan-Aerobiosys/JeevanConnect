import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:jeevanconnect/src/features/patients/domain/abg.dart';

import '../data/patient_repository.dart';

class ABGReportFormBloc extends FormBloc<String, String> {
  final pH = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final pCO2 = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final pO2 = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final hCO3 = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final baseExcess = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final sO2 = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final lactate = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final comments = TextFieldBloc();

  ABGReportFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [pH, pCO2, pO2, hCO3, baseExcess, sO2, lactate, comments],
    );
  }

  String recordId = "";
  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      final report = ABGReport(
        id: 0,
        pH: double.parse(pH.value),
        pCO2: double.parse(pCO2.value),
        pO2: double.parse(pO2.value),
        hCO3: double.parse(hCO3.value),
        baseExcess: double.parse(baseExcess.value),
        sO2: double.parse(sO2.value),
        lactate: double.parse(lactate.value),
        comments: comments.value,
        createdAt: DateTime.now(),
      );

      bool isABGReportAdded =
          await PatientRepository().addABGRecord(report.toJson(recordId));

      if (isABGReportAdded) {
        _response = {
          'title': 'Success',
          'content': 'ABG Report added successfully',
        };
        emitSuccess(
          successResponse: jsonEncode(_response),
          canSubmitAgain: false,
        );
      }
    } catch (exception) {
      debugPrint("Add ABG Report Exception: $exception");
      _response = {
        'title': (exception as dynamic).title,
        'content': (exception as dynamic).displayMessage,
      };
      emitFailure(failureResponse: jsonEncode(_response));
    }
  }
}
