import 'package:flutter/material.dart';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../config/presentation/app_palette.dart';

class FormTextField extends StatelessWidget {
  final TextFieldBloc<dynamic> textFieldBloc;
  final String label;
  final IconData? icon;
  final bool isEnabled;
  final bool isPasswordField;
  final Color textColor;
  final int? maxLines;

  const FormTextField(
      {super.key,
      required this.textFieldBloc,
      required this.label,
      this.icon = Icons.text_fields_outlined,
      this.isPasswordField = false,
      this.maxLines,
      this.textColor = AppPalette.white,
      this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    return isPasswordField
        ? TextFieldBlocBuilder(
            textFieldBloc: textFieldBloc,
            readOnly: !isEnabled,
            textStyle: Theme.of(context).textTheme.headlineSmall,
            textColor: WidgetStateProperty.resolveWith((states) => textColor),
            suffixButton: isPasswordField ? SuffixButton.obscureText : null,
            obscureTextTrueIcon: isPasswordField
                ? Icon(Icons.visibility, color: textColor)
                : null,
            obscureTextFalseIcon: isPasswordField
                ? Icon(Icons.visibility_off, color: textColor)
                : null,
            enableInteractiveSelection: !isPasswordField,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderSide: isEnabled
                    ? const BorderSide(color: AppPalette.greyS8, width: 1.0)
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(5.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: isEnabled
                    ? const BorderSide(color: AppPalette.greyS8, width: 1.0)
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: isEnabled
                    ? const BorderSide(color: AppPalette.greyS8, width: 1.0)
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(5.0),
              ),
              labelStyle: isEnabled
                  ? Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w200, color: AppPalette.grey)
                  : Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w500, color: AppPalette.grey),
              prefixIcon:
                  icon != null ? Icon(icon, color: AppPalette.grey) : null,
            ),
          )
        : TextFieldBlocBuilder(
            textFieldBloc: textFieldBloc,
            readOnly: !isEnabled,
            maxLines: maxLines,
            textStyle: Theme.of(context).textTheme.headlineSmall,
            textColor: WidgetStateProperty.resolveWith((states) => textColor),
            suffixButton: isPasswordField ? SuffixButton.obscureText : null,
            obscureTextTrueIcon: isPasswordField
                ? Icon(Icons.visibility, color: textColor)
                : null,
            obscureTextFalseIcon: isPasswordField
                ? Icon(Icons.visibility_off, color: textColor)
                : null,
            enableInteractiveSelection: !isPasswordField,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderSide: isEnabled
                    ? const BorderSide(color: AppPalette.greyS8, width: 1.0)
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(5.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: isEnabled
                    ? const BorderSide(color: AppPalette.greyS8, width: 1.0)
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: isEnabled
                    ? const BorderSide(color: AppPalette.greyS8, width: 1.0)
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(5.0),
              ),
              labelStyle: isEnabled
                  ? Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w200, color: AppPalette.grey)
                  : Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w500, color: AppPalette.grey),
              prefixIcon:
                  icon != null ? Icon(icon, color: AppPalette.grey) : null,
            ),
          );
  }
}
