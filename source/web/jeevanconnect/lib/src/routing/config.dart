import 'package:flutter/cupertino.dart';

import 'screens.dart';

class RoutesConfig {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case 'ipForm':
        return CupertinoPageRoute(builder: (_) => const IpForm());
      case 'boot':
        return CupertinoPageRoute(builder: (_) => const BootScreen());
      case 'signin':
        return CupertinoPageRoute(builder: (_) => const SigninScreen());
      case 'signup':
        return CupertinoPageRoute(builder: (_) => const SignupScreen());
      case 'forgotPassword':
        return CupertinoPageRoute(builder: (_) => const ForgotPasswordScreen());
      case 'myAccount':
        return CupertinoPageRoute(builder: (_) => const AccountPage());
      case 'home':
        return CupertinoPageRoute(builder: (_) => const HomeScreen());
      case 'createWorkspace':
        return CupertinoPageRoute(
            builder: (_) => const CreateWorkspaceScreen());
      case 'workspace':
        return CupertinoPageRoute(
            builder: (_) => WorkspaceMenu(
                  workspace: (settings.arguments as Map)['workspace'],
                ));
      case 'registerProduct':
        return CupertinoPageRoute(
            builder: (_) => const RegisterProductScreen());
      case 'addAdmissionRecord':
        return CupertinoPageRoute(
            builder: (_) => const AddAdmissionRecordScreen());
      case 'monitoring':
        return CupertinoPageRoute(
            builder: (_) => MonitoringScreen(
                  session: (settings.arguments as Map)['session'],
                ));
      case 'product':
        return CupertinoPageRoute(
            builder: (_) => JeevanProduct(
                  product: (settings.arguments as Map)['product'],
                ));
      case 'registerPatient':
        return CupertinoPageRoute(
            builder: (_) => RegisterPatientScreen(
                  workspaceName: (settings.arguments as Map)['workspaceName'],
                ));
      case 'patient':
        return CupertinoPageRoute(
            builder: (_) => JeevanPatient(
                  patient: (settings.arguments as Map)['patient'],
                ));
      case 'userChat':
        final args = (settings.arguments as Map);
        return CupertinoPageRoute(
            builder: (_) => ChatSection(
                  conversation: args["conversation"],
                  isSingleChat: true,
                ));
      default:
        return CupertinoPageRoute(builder: (_) => const Placeholder());
    }
  }
}
