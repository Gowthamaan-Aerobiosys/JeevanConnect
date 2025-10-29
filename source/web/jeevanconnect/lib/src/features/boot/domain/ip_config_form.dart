import 'dart:convert';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../config/data/urls.dart';

class IpAddressFormBloc extends FormBloc<String, String> {
  final ipAddress = TextFieldBloc(
      validators: [FieldBlocValidators.required],
      initialValue: "192.168.127.221");

  Validator<String> _validateIPv4Address() {
    final ipv4RegExp = RegExp(
        r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    return (String? ipAddress) {
      if (ipAddress == null || ipAddress.isEmpty) {
        return 'IP address cannot be empty';
      }
      if (!ipv4RegExp.hasMatch(ipAddress)) {
        return 'Invalid IPv4 address';
      }
      return null;
    };
  }

  IpAddressFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [ipAddress],
    );

    ipAddress.addValidators([_validateIPv4Address()]);
  }

  Map _response = {};

  @override
  void onSubmitting() async {
    try {
      AppUrls().setIp(ipAddress.value);
      _response = {
        'title': 'Domain Registered',
        'content': '${ipAddress.value} is the domain for JeevanConnect',
      };
      emitSuccess(
          successResponse: jsonEncode(_response), canSubmitAgain: false);
    } catch (exception) {
      _response = {
        'title': (exception as dynamic).title,
        'content': (exception as dynamic).displayMessage,
      };
      emitFailure(failureResponse: jsonEncode(_response));
    }
  }
}
