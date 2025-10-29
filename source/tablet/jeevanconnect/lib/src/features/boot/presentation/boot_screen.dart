import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jeevanconnect/src/routing/routes.dart';

import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/widgets/aerobiosys_logo.dart';
import '../../../shared/presentation/widgets/progress_bar.dart';
import '../../authentication/authentication.dart' show AuthenticationRepository;
import '../data/boot_loader.dart';
import '../domain/ui_controllers.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  StreamSubscription? subscription;

  _nextScreenLoader() {
    subscription =
        BootUIControllers().progressController.stream.listen((event) {
      if (event == 1) {
        subscription?.cancel();
        if (AuthenticationRepository().isSignedIn) {
          context.pushReplacement(Routes.home);
        } else {
          context.pushReplacement(Routes.signin);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    BootUIControllers().init();
    _nextScreenLoader();
    Bootloader().init();
  }

  @override
  void dispose() {
    BootUIControllers().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const AerobiosysLogo(height: 120),
            WhiteSpace.b16,
            Text(
              "Jeevan Connect",
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            WhiteSpace.b56,
            LinearProgressBar(
              progressController: BootUIControllers().progressController,
            ),
          ],
        ),
      ),
    );
  }
}
