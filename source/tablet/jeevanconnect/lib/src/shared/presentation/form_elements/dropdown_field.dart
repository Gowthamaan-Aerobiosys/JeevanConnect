import 'package:flutter/material.dart';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../config/presentation/app_palette.dart';

class FormDropDownField extends StatelessWidget {
  final SelectFieldBloc<String, dynamic> selectFieldBloc;
  final String label;
  final IconData icon;
  final bool isEnabled;
  final bool isPasswordField;

  const FormDropDownField(
      {super.key,
      required this.selectFieldBloc,
      required this.label,
      this.icon = Icons.text_fields_outlined,
      this.isPasswordField = false,
      this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    return DropdownFieldBlocBuilder<String>(
      selectFieldBloc: selectFieldBloc,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(fontWeight: FontWeight.w200, color: AppPalette.grey),
        prefixIcon: Icon(icon, color: AppPalette.grey),
      ),
      showEmptyItem: false,
      itemBuilder: (context, value) => FieldItem(
        child: Text(value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: AppPalette.black)),
      ),
      selectedItemBuilder: (context, value) => FieldItem(
        child: Text(value, style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}
