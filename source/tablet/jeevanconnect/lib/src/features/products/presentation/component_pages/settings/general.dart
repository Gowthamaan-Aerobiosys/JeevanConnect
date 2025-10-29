import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../shared/presentation/components/button.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/components/widget_decoration.dart';
import '../../../../../shared/presentation/dialogs/dialogs.dart'
    show simpleDialog, DialogType;
import '../../../../../shared/presentation/widgets/progress_loader.dart';
import '../../../domain/department_change_form_bloc.dart';

class GeneralTab extends StatefulWidget {
  const GeneralTab({super.key});

  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab> {
  late bool isEditOn;

  @override
  void initState() {
    isEditOn = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.white,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.all10,
      child: BlocProvider(
        create: (BuildContext context) => DepartmentChangeFormBloc(),
        child: Builder(
          builder: (BuildContext context) {
            final moderationForm =
                BlocProvider.of<DepartmentChangeFormBloc>(context);

            return FormBlocListener<DepartmentChangeFormBloc, String, String>(
              onSubmitting: (context, state) {
                ProgressLoader.show(context);
              },
              onSuccess: (context, state) {
                ProgressLoader.hide(context);
                if (state.hasSuccessResponse) {
                  final response = jsonDecode(state.successResponse!);
                  simpleDialog(context,
                          type: DialogType.success,
                          title: response['title'],
                          content: response['content'],
                          buttonName: "Close")
                      .then((value) => setState(() {
                            isEditOn = false;
                          }));
                }
              },
              onFailure: (context, state) {
                ProgressLoader.hide(context);
                ProgressLoader.hide(context);
                final response = jsonDecode(state.failureResponse!);
                simpleDialog(context,
                    type: DialogType.error,
                    title: response['title'],
                    content: response['content'],
                    buttonName: "Close");
              },
              child: SingleChildScrollView(
                padding: WhiteSpace.all15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        WhiteSpace.spacer,
                        if (!isEditOn)
                          Button(
                            onPressed: () {
                              isEditOn = true;
                              setState(() {});
                            },
                            toolTip: "Edit details",
                            child: Text(
                              'Edit',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        if (isEditOn) ...[
                          Button(
                            onPressed: () {
                              if (moderationForm.state.isValid()) {
                                moderationForm.submit();
                              }
                            },
                            backgroundColor: AppPalette.greenC1,
                            toolTip: "Save details",
                            child: Text(
                              'Save',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          WhiteSpace.w12,
                          Button(
                            onPressed: () {
                              isEditOn = false;
                              setState(() {});
                            },
                            backgroundColor: AppPalette.greyC3,
                            toolTip: "Cancel",
                            child: Text(
                              'Cancel',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ],
                      ],
                    ),
                    WorkspacePermission(
                        selectFieldBloc: moderationForm.department,
                        title: "Workspace department",
                        subTitle: "Product department in the workspace",
                        isEnabled: isEditOn),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class WorkspacePermission extends StatelessWidget {
  final String title;
  final String subTitle;
  final SelectFieldBloc selectFieldBloc;
  final bool isEnabled;

  const WorkspacePermission({
    super.key,
    required this.selectFieldBloc,
    required this.title,
    required this.subTitle,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WhiteSpace.all15,
      child: Row(
        children: [
          WhiteSpace.w16,
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title\n',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: AppPalette.black, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: subTitle,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: AppPalette.greyC3),
                ),
              ],
            ),
          ),
          WhiteSpace.spacer,
          SizedBox(
            width: LayoutConfig().setFractionWidth(25),
            child: DropdownFieldBlocBuilder(
              selectFieldBloc: selectFieldBloc,
              showEmptyItem: false,
              isEnabled: isEnabled,
              textStyle: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: AppPalette.black),
              textColor:
                  WidgetStateProperty.resolveWith((states) => AppPalette.black),
              itemBuilder: (context, item) => FieldItem(
                child: Text(item),
              ),
              textAlign: TextAlign.center,
              padding: WhiteSpace.zero,
              decoration: InputDecoration(
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
                        ? const BorderSide(color: AppPalette.grey, width: 1.0)
                        : BorderSide.none,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  contentPadding: WhiteSpace.h10),
            ),
          ),
          WhiteSpace.w32
        ],
      ),
    );
  }
}
