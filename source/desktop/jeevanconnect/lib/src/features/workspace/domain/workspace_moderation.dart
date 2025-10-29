class WorkspaceModeration {
  static const _options = {"AD": "ADMIN", "AN": "ANYONE", "OW": "OWNER"};

  String inviteMember;
  String editDepartment;
  String addPatient;
  String editProduct;
  String downloadInformation;
  String workspaceDetails;
  String shareDevice;

  WorkspaceModeration({
    required this.inviteMember,
    required this.editDepartment,
    required this.addPatient,
    required this.editProduct,
    required this.downloadInformation,
    required this.workspaceDetails,
    required this.shareDevice,
  });

  factory WorkspaceModeration.fromJson(dynamic json) {
    return WorkspaceModeration(
      inviteMember: _options[json['invite_member']] ?? "OWNER",
      editDepartment: _options[json['edit_department']] ?? "OWNER",
      addPatient: _options[json['add_patient']] ?? "OWNER",
      editProduct: _options[json['edit_product']] ?? "OWNER",
      downloadInformation: _options[json['download_information']] ?? "OWNER",
      workspaceDetails: _options[json['workspace_details']] ?? "OWNER",
      shareDevice: _options[json['share_device']] ?? "OWNER",
    );
  }
}
