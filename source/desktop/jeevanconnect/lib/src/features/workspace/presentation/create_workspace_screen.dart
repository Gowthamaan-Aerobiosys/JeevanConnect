import 'package:flutter/material.dart';

import '../../../routing/routes.dart';
import '../../../config/presentation/app_palette.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import 'create_workspace_form.dart';

class CreateWorkspaceScreen extends StatefulWidget {
  const CreateWorkspaceScreen({super.key});

  @override
  State<CreateWorkspaceScreen> createState() => _CreateWorkspaceScreenState();
}

class _CreateWorkspaceScreenState extends State<CreateWorkspaceScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: LayoutConfig().setFractionHeight(100),
              width: LayoutConfig().setFractionWidth(60),
              child: SingleChildScrollView(
                padding: WhiteSpace.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WhiteSpace.b16,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Button(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        minWidth: 50,
                        hoverColor: null,
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: Theme.of(context).primaryColorLight,
                          size: 40,
                        ),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            context.pop();
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: WhiteSpace.h50,
                      child: Text(
                        'JeevanConnect - Workspaces',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    WhiteSpace.b12,
                    Padding(
                      padding: WhiteSpace.h50,
                      child: Text(
                        'Please provide the following details to create a workspace',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    WhiteSpace.b6,
                    const CreateWorkspaceForm()
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: AppPalette.logoBlue,
                child: Center(
                  child: Text(
                    'Jeevan Connect©️ - Workspaces',
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontWeight: FontWeight.w700, color: AppPalette.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
