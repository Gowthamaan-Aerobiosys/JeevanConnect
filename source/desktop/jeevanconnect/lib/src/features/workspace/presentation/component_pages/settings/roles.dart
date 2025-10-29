import 'package:flutter/material.dart';

import '../../../../../config/presentation/app_palette.dart';
import '../../../../../config/presentation/layout_config.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/components/widget_decoration.dart';

class RoleInfo {
  final String name;
  final String description;
  final IconData icon;

  RoleInfo(this.name, this.description, this.icon);
}

class WorkspaceRoles extends StatelessWidget {
  const WorkspaceRoles({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: WhiteSpace.zero,
      child: Column(
        children: [
          RepositoryRolesScreen(),
          CustomRoles(),
        ],
      ),
    );
  }
}

class RepositoryRolesScreen extends StatelessWidget {
  const RepositoryRolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<RoleInfo> predefinedRoles = [
      RoleInfo(
          'View',
          'Read and clone repositories. Open and comment on issues and pull requests.',
          Icons.book),
      RoleInfo(
          'Admin',
          'Full access to repositories including sensitive and destructive actions.',
          Icons.admin_panel_settings),
    ];

    return Card(
      color: AppPalette.white,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.h10,
      child: Padding(
        padding: WhiteSpace.h20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WhiteSpace.b16,
            Text('Workspace roles',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w700, color: AppPalette.black)),
            WhiteSpace.b12,
            Text(
              'Roles are used to grant access and permissions for departments and members. In addition to the available pre-defined roles, you can create up to 0 custom roles to fit your needs.',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: AppPalette.grey),
            ),
            const Divider(),
            WhiteSpace.b16,
            Text('Pre-defined roles',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: AppPalette.black)),
            Text(
                'You can set the base role for this organization from one of these roles.',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: AppPalette.grey)),
            WhiteSpace.b16,
            ...predefinedRoles.map((role) => RoleCard(role)),
            WhiteSpace.b16
          ],
        ),
      ),
    );
  }
}

class CustomRoles extends StatelessWidget {
  const CustomRoles({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WhiteSpace.all10,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppPalette.redS8,
            width: 1.5,
          ),
          borderRadius: WidgetDecoration.borderRadius5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppPalette.white,
              shape: WidgetDecoration.roundedEdgeT5,
              margin: WhiteSpace.zero,
              child: Padding(
                padding: WhiteSpace.h20,
                child: Column(
                  children: [
                    WhiteSpace.b12,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Custom roles',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                color: AppPalette.black,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    WhiteSpace.b12,
                  ],
                ),
              ),
            ),
            Padding(
              padding: WhiteSpace.h10,
              child: Column(
                children: [
                  WhiteSpace.b6,
                  Text(
                    'Create custom roles with Jeevan Plus',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  WhiteSpace.b12,
                  Text(
                    'Plus accounts offer workspaces more granular control over permissions by allowing you to configure up to three custom workspace roles. This enables greater control over who and how your users access products and data in your workspace.',
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                  WhiteSpace.b12,
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Try Jeevan Plus'),
                  ),
                ],
              ),
            ),
            WhiteSpace.b16
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final RoleInfo role;

  const RoleCard(this.role, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.greyS8,
      child: Padding(
        padding: WhiteSpace.all15,
        child: Row(
          children: [
            Icon(role.icon,
                size: LayoutConfig().setFontSize(30), color: AppPalette.greyC4),
            WhiteSpace.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role.name,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(fontWeight: FontWeight.w700)),
                  WhiteSpace.b6,
                  Text(role.description,
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
