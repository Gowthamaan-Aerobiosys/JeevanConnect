import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:jeevanconnect/src/routing/routes.dart';
import 'package:jeevanconnect/src/shared/presentation/dialogs/dialogs.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/form_elements/text_field.dart';
import '../domain/ip_config_form.dart';

class IpForm extends StatelessWidget {
  const IpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: LayoutConfig().setFractionHeight(33),
          width: LayoutConfig().setFractionWidth(40),
          child: BlocProvider(
            create: (BuildContext context) => IpAddressFormBloc(),
            child: Builder(
              builder: (BuildContext context) {
                final registerIpForm =
                    BlocProvider.of<IpAddressFormBloc>(context);

                return FormBlocListener<IpAddressFormBloc, String, String>(
                  onSubmitting: (context, state) {},
                  onSuccess: (context, state) {
                    final response = jsonDecode(state.successResponse!);
                    simpleDialog(context,
                            type: DialogType.success,
                            title: response['title'],
                            content: response['content'],
                            buttonName: "Close")
                        .then((_) => context.pushReplacement(Routes.boot));
                  },
                  onFailure: (context, state) {
                    final response = jsonDecode(state.failureResponse!);
                    simpleDialog(context,
                        type: DialogType.error,
                        title: response['title'],
                        content: response['content'],
                        buttonName: "Close");
                  },
                  child: Column(
                    children: [
                      WhiteSpace.b16,
                      Text(
                        "Register Domain",
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge!
                            .copyWith(
                                color: AppPalette.white,
                                fontWeight: FontWeight.bold),
                      ),
                      WhiteSpace.b12,
                      Padding(
                        padding: WhiteSpace.h30,
                        child: FormTextField(
                            textFieldBloc: registerIpForm.ipAddress,
                            label: "IPv4 Address",
                            icon: Icons.location_searching_outlined),
                      ),
                      WhiteSpace.spacer,
                      const Divider(thickness: 0.2, color: AppPalette.greyS8),
                      Button(
                        buttonPadding: WhiteSpace.zero,
                        onPressed: () {
                          registerIpForm.ipAddress.validate();
                          if (registerIpForm.state.isValid()) {
                            registerIpForm.submit();
                          }
                        },
                        backgroundColor: AppPalette.transparent,
                        child: Text(
                          "Register",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                  color: AppPalette.green,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      WhiteSpace.w32,
                      WhiteSpace.b6,
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
