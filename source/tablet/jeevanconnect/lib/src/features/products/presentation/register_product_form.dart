import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../routing/routes.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/dialogs/dialogs.dart'
    show simpleDialog, DialogType;
import '../../../shared/presentation/form_elements/text_field.dart';
import '../../../shared/presentation/form_elements/date_field.dart';
import '../../../shared/presentation/widgets/progress_loader.dart';
import '../domain/product_form_bloc.dart';

class RegisterProductForm extends StatefulWidget {
  const RegisterProductForm({super.key});

  @override
  State<RegisterProductForm> createState() => _RegisterProductFormState();
}

class _RegisterProductFormState extends State<RegisterProductForm> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocProvider(
        create: (context) => RegisterProductFormBloc(),
        child: Builder(
          builder: (context) {
            final registerProductForm =
                BlocProvider.of<RegisterProductFormBloc>(context);

            return FormBlocListener<RegisterProductFormBloc, String, String>(
              onSubmitting: (context, state) {
                ProgressLoader.show(context);
              },
              onSuccess: (context, state) {
                ProgressLoader.hide(context);
                if (Navigator.canPop(context)) {
                  context.pop();
                }
              },
              onFailure: (context, state) {
                ProgressLoader.hide(context);
                final response = jsonDecode(state.failureResponse!);
                simpleDialog(context,
                    type: DialogType.error,
                    title: response['title'],
                    content: response['content'],
                    buttonName: "Close");
              },
              child: Padding(
                padding: WhiteSpace.h50,
                child: Column(
                  children: [
                    WhiteSpace.b16,
                    FormTextField(
                        textFieldBloc: registerProductForm.workspaceName,
                        label: "Workspace Name",
                        icon: Icons.perm_identity_outlined),
                    WhiteSpace.b16,
                    FormTextField(
                        textFieldBloc: registerProductForm.productName,
                        label: "Product Name",
                        icon: Icons.text_fields_outlined),
                    FormTextField(
                        textFieldBloc: registerProductForm.modelName,
                        label: "Model Name",
                        icon: Icons.text_fields_outlined),
                    FormTextField(
                        textFieldBloc: registerProductForm.serialNumber,
                        label: "Serial Number",
                        icon: Icons.numbers_outlined),
                    FormTextField(
                        textFieldBloc: registerProductForm.lotNumber,
                        label: "Lot Number",
                        icon: Icons.numbers_outlined),
                    WhiteSpace.b16,
                    FormDateField(
                        dateTimeFieldBloc:
                            registerProductForm.manufacturingDate,
                        label: "Manufacturing Date"),
                    WhiteSpace.b16,
                    Button(
                      hoverColor: null,
                      onPressed: () {
                        _validateForm(registerProductForm);
                        if (registerProductForm.state.isValid()) {
                          // ProcessValidator().checkForInternet(context, () {
                          registerProductForm.submit();
                          // });
                        }
                      },
                      minWidth: 150,
                      child: Text(
                        "Register Product",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    WhiteSpace.b16,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _validateForm(RegisterProductFormBloc registerProductForm) {
    registerProductForm.workspaceName.validate();
    registerProductForm.productName.validate();
    registerProductForm.modelName.validate();
    registerProductForm.serialNumber.validate();
    registerProductForm.lotNumber.validate();
    registerProductForm.manufacturingDate.validate();
  }
}
