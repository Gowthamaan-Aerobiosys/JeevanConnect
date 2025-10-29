import 'package:objectbox/objectbox.dart';

@Entity()
class User {
  @Id()
  int id;
  String email;
  bool isConfirmed;
  bool isActive;
  bool isAdmin;
  String firstName;
  String lastName;
  String userId;
  String registeredId;
  String designation;
  String sessionId;
  String csrfToken;
  List<String> emails;
  List<String> phoneNumbers;
  int contact;
  @Property(type: PropertyType.date)
  DateTime createdAt;
  @Property(type: PropertyType.date)
  DateTime lastModified;
  @Property(type: PropertyType.date)
  DateTime? passwordChangedAt;

  User(
      {this.id = 0,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.userId,
      required this.registeredId,
      required this.designation,
      required this.contact,
      required this.isConfirmed,
      required this.isActive,
      required this.isAdmin,
      required this.createdAt,
      required this.sessionId,
      required this.emails,
      required this.phoneNumbers,
      required this.csrfToken,
      required this.lastModified,
      this.passwordChangedAt});

  factory User.fromJson(dynamic json) {
    return User(
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        userId: json["user_id"],
        registeredId: json["registered_id"],
        designation: json["designation"],
        contact: json["contact"] ?? -1,
        isConfirmed: json["confirmed"],
        isActive: json["active"],
        isAdmin: json["admin"],
        emails: json['emails'].cast<String>(),
        phoneNumbers: json['phone_numbers'].cast<String>(),
        csrfToken: json['csrfToken'] ?? "",
        sessionId: json['sessionId'] ?? "",
        createdAt: DateTime.parse(json["created_at"]),
        lastModified: DateTime.parse(json["modified_at"]),
        passwordChangedAt:
            DateTime.tryParse(json['password_changed_at'] ?? ""));
  }

  factory User.update(dynamic json, user) {
    return User(
        firstName: json["first_name"] ?? user.firstName,
        lastName: json["last_name"] ?? user.lastName,
        email: json["email"] ?? user.email,
        userId: json["user_id"] ?? user.userId,
        registeredId: json["registered_id"] ?? user.registeredId,
        designation: json["designation"] ?? user.designation,
        contact: json["contact"] ?? user.contact,
        isConfirmed: json["confirmed"] ?? user.isConfirmed,
        isActive: json["active"] ?? user.isActive,
        isAdmin: json["admin"] ?? user.isAdmin,
        csrfToken: json['csrfToken'] ?? user.csrfToken,
        sessionId: json['sessionId'] ?? user.sessionId,
        emails: json['emails'] ?? user.emails,
        phoneNumbers: json['phone_numbers'] ?? user.phonenumbers,
        createdAt:
            DateTime.tryParse(json["created_at"] ?? "") ?? user.createdAt,
        lastModified:
            DateTime.tryParse(json["modified_at"] ?? "") ?? user.lastModified,
        passwordChangedAt:
            DateTime.tryParse(json['password_changed_at'] ?? '') ??
                user.passwordChangedAt);
  }

  Map toJson() => {
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "user_id": userId,
        "registered_id": registeredId,
        "designation": designation,
        "contact": contact,
        "confirmed": isConfirmed,
        "setup": isActive,
        "staff": isAdmin,
        "created_at": createdAt,
        "modified_at": lastModified
      };

  getFullName() {
    return "$firstName $lastName";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.email == email &&
        other.registeredId == registeredId;
  }

  @override
  int get hashCode => email.hashCode;
}
