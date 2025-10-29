import 'package:flutter/material.dart';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../config/presentation/app_palette.dart';

class FormDateField extends StatelessWidget {
  final InputFieldBloc<DateTime?, dynamic> dateTimeFieldBloc;
  final String label;
  const FormDateField({
    super.key,
    required this.dateTimeFieldBloc,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DateTimeFieldBlocBuilder(
      dateTimeFieldBloc: dateTimeFieldBloc,
      format: DateFormat('dd-MM-yyyy'),
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      textStyle: Theme.of(context).textTheme.headlineSmall,
      textColor: WidgetStateProperty.resolveWith((states) => AppPalette.white),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppPalette.greyS8, width: 1.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppPalette.greyS8, width: 1.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppPalette.greyS8, width: 1.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        labelStyle: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(color: AppPalette.grey, fontWeight: FontWeight.w200),
        prefixIcon:
            const Icon(Icons.calendar_today_outlined, color: AppPalette.grey),
      ),
    );
  }
}
