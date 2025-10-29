import '../custom_exception.dart';

class WorkspaceException {
  static const workspaceNotFound = CustomException(
      code: 400,
      key: "workspace-not-found",
      title: "Workspace not found",
      displayMessage:
          "We couldn't find the workspace. Kindly check your email");
  static const workspaceAlreadyExists = CustomException(
      code: 400,
      key: "workspace-already-exists",
      title: "Workspace already exists",
      displayMessage: "Workspace with that email address already exists");
  static const userNotFoundInWorkspace = CustomException(
      code: 409,
      key: "user-not-in-workspace",
      title: "User not found in workspace",
      displayMessage: "User with that email address is not in this workspace");
  static const defaultUser = CustomException(
      code: 409,
      key: "default-user",
      title: "Default user",
      displayMessage: "Default user cannot be removed from workspace");
}
