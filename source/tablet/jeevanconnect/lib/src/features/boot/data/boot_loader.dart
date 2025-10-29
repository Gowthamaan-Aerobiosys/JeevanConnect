import '../../../config/data/database.dart';
import '../../authentication/authentication.dart' show AuthenticationRepository;
import '../../messages/messages.dart' show MessageRepository;
import '../domain/ui_controllers.dart';

class Bootloader {
  init() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    BootUIControllers().progressController.sink.add(0.25);
    await Database().init();
    BootUIControllers().progressController.sink.add(0.5);
    await AuthenticationRepository().init();
    BootUIControllers().progressController.sink.add(0.75);
    if (AuthenticationRepository().isSignedIn) {
      authRoutine();
    }
    BootUIControllers().progressController.sink.add(1);
    MessageRepository().init();
  }

  authRoutine() async {
    BootUIControllers().progressController.sink.add(0.75);
    await AuthenticationRepository().validateSession();
  }

  dispose() {}
}
