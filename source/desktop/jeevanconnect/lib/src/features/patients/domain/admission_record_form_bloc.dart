import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../data/patient_repository.dart';

class AdmissionRecordFormBloc extends FormBloc<String, String> {
  final height = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final weight = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final admissionDate = InputFieldBloc<DateTime?, dynamic>(
      initialValue: null, validators: [FieldBlocValidators.required]);
  final reasonForVentilation =
      TextFieldBloc(validators: [FieldBlocValidators.required]);
  final reasonForAdmission =
      TextFieldBloc(validators: [FieldBlocValidators.required]);
  final tags = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final summary = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final historyOfDiabetes = BooleanFieldBloc();
  final historyOfBp = BooleanFieldBloc();

  AdmissionRecordFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [
        height,
        weight,
        admissionDate,
        reasonForAdmission,
        reasonForVentilation,
        tags,
        summary,
        historyOfDiabetes,
        historyOfBp
      ],
    );
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      final dataDict = {
        'patient_id': PatientRepository().currentPatient.patientId,
        'height': height.value,
        'weight': weight.value,
        'bmi':
            calculateBMI(weight.valueToDouble ?? 0, height.valueToDouble ?? 0)
                .toString(),
        'ibw': calculateIdealWeight(height.valueToDouble ?? 0).toString(),
        'admission_date': admissionDate.value!.toString(),
        'reason_for_admission': reasonForAdmission.value,
        'reason_for_ventilation': reasonForVentilation.value,
        'history_of_diabetes':
            capitalizeFirstLetter(historyOfDiabetes.value.toString()),
        'tags': tags.value,
        'history_of_bp': capitalizeFirstLetter(historyOfBp.value.toString()),
        'current_status': summary.value,
      };
      bool isProductRegistered =
          await PatientRepository().addAdmissionRecord(record: dataDict);
      if (isProductRegistered) {
        _response = {
          'title': 'Success',
          'content': 'Patient registered successfully',
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

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  double calculateBMI(double weightKg, double heightCm) {
    try {
      if (weightKg <= 0 || heightCm <= 0) {
        throw ArgumentError('Weight and height must be positive values');
      }
      double heightM = heightCm / 100;
      return weightKg / (heightM * heightM);
    } catch (e) {
      debugPrint('Error calculating BMI: $e');
      return 0;
    }
  }

  double calculateIdealWeight(double heightCm) {
    String gender = PatientRepository().currentPatient.gender;
    try {
      if (heightCm <= 0) {
        throw ArgumentError('Height must be a positive value');
      }
      if (gender.toLowerCase() != 'male' && gender.toLowerCase() != 'female') {
        throw ArgumentError('Gender must be either "male" or "female"');
      }

      double baseHeight = (gender.toLowerCase() == 'male') ? 152.4 : 152.4;
      double weightFactor = (gender.toLowerCase() == 'male') ? 1.1 : 1.0;
      double heightDifference = heightCm - baseHeight;

      return 45.5 + (0.91 * heightDifference) * weightFactor;
    } catch (e) {
      debugPrint('Error calculating ideal weight: $e');
      return 0;
    }
  }
}
