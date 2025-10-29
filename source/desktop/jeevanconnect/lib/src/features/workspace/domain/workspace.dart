import '../../authentication/authentication.dart'
    show User, AuthenticationRepository;

class Workspace {
  String name;
  String email;
  String workspaceId;
  String registeredId;
  String streetAddress;
  String city;
  String state;
  String country;
  String postalCode;
  String website;
  String contact;
  bool isConfirmed;
  bool isActive;
  bool isAdmin;
  User defaultUser;
  List<String> departments;
  List<User> users;
  List<User> admins;
  DateTime createdAt;
  DateTime modifiedAt;

  Workspace(
      {required this.name,
      required this.email,
      required this.isConfirmed,
      required this.isActive,
      required this.isAdmin,
      required this.defaultUser,
      required this.users,
      required this.admins,
      required this.createdAt,
      required this.modifiedAt,
      required this.workspaceId,
      required this.registeredId,
      required this.streetAddress,
      required this.departments,
      required this.city,
      required this.state,
      required this.country,
      required this.postalCode,
      required this.website,
      required this.contact});

  factory Workspace.fromJson(dynamic json) {
    final users =
        json['users'].map((json) => User.fromJson(json)).toList().cast<User>();
    final admins =
        json['admins'].map((json) => User.fromJson(json)).toList().cast<User>();

    return Workspace(
        name: json['name'],
        email: json['email_id'],
        isConfirmed: json['confirmed'],
        isActive: json['active'],
        defaultUser: User.fromJson(json['default_user']),
        users: users,
        admins: admins,
        isAdmin: AuthenticationRepository().currentUser.isAdmin
            ? true
            : admins.any((user) =>
                user.userId == AuthenticationRepository().currentUser.userId),
        createdAt: DateTime.parse(json['created_at']),
        modifiedAt: DateTime.parse(
          json['modified_at'],
        ),
        workspaceId: json['workspace_id'],
        departments: json['departments'].cast<String>(),
        registeredId: json['registered_id'],
        streetAddress: json['street_address'],
        city: json['city'],
        state: json['state'],
        country: json['country'],
        postalCode: json['postal_code'],
        website: json['website'],
        contact: json['contact']);
  }

  factory Workspace.update(dynamic json, dynamic workspace) {
    return Workspace(
      name: json['name'] ?? workspace.name,
      email: workspace.email,
      isConfirmed: workspace.isConfirmed,
      isActive: workspace.isActive,
      defaultUser: workspace.defaultUser,
      users: workspace.users,
      admins: workspace.admins,
      isAdmin: workspace.isAdmin,
      createdAt: DateTime.parse(json['created_at']),
      modifiedAt: DateTime.parse(json['modified_at']),
      workspaceId: workspace.workspaceId,
      registeredId: workspace.registeredId,
      departments: workspace.departments,
      streetAddress: json['street_address'] ?? workspace.streetAddress,
      city: json['city'] ?? workspace.city,
      state: json['state'] ?? workspace.state,
      country: json['country'] ?? workspace.country,
      postalCode: json['postal_code'] ?? workspace.postalCode,
      website: json['website'] ?? workspace.website,
      contact: workspace.contact,
    );
  }
}
