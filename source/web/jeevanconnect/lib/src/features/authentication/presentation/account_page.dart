import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../routing/routes.dart';
import '../../../config/presentation/layout_config.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import 'profile/tabs.dart';
import 'side_menu.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final GlobalKey<NavigatorState> accountPageKey =
      GlobalKey<NavigatorState>(debugLabel: "My_Account");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "My Account",
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        leading: Button(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          hoverColor: null,
          padding: WhiteSpace.zero,
          buttonPadding: WhiteSpace.zero,
          child: Icon(
            Icons.chevron_left_rounded,
            color: Theme.of(context).primaryColorLight,
            size: LayoutConfig().setFontSize(40),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              context.pop();
            }
          },
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: SideMenu(
              homePageNavKey: accountPageKey,
            ),
          ),
          AccountScreenPages(accountPageKey: accountPageKey),
        ],
      ),
    );
  }
}

class AccountScreenPages extends StatelessWidget {
  final GlobalKey<NavigatorState> accountPageKey;

  const AccountScreenPages({super.key, required this.accountPageKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LayoutConfig().setFractionHeight(94),
      width: LayoutConfig().setFractionWidth(80),
      padding: WhiteSpace.all10,
      child: Navigator(
          key: accountPageKey,
          initialRoute: 'profile',
          clipBehavior: Clip.antiAlias,
          onGenerateRoute: (RouteSettings settings) {
            WidgetBuilder builder;
            switch (settings.name) {
              case 'profile':
                builder = (BuildContext _) => const ProfileTab();
                break;
              case 'security':
                builder = (BuildContext _) => const SecurityTab();
                break;
              case 'multifactorauth':
                builder = (BuildContext _) => const MultiFactorAuthTab();
                break;
              case 'settings':
                builder = (BuildContext _) => const SettingsTab();
                break;
              case 'sessions':
                builder = (BuildContext _) => const SessionsTab();
                break;
              case 'privacy':
                builder = (BuildContext _) => const PrivacyTab();
                break;
              case 'compliance':
                builder = (BuildContext _) => const ComplianceTab();
                break;
              default:
                throw Exception('Invalid route: ${settings.name}');
            }
            return CupertinoPageRoute(
                builder: builder,
                settings: settings,
                fullscreenDialog: true,
                allowSnapshotting: true);
          }),
    );
  }
}
