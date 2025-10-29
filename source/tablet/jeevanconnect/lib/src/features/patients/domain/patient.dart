import '../../workspace/workspace.dart' show Workspace;

class Patient {
  String patientId;
  String? name;
  String gender;
  int age;
  String? bloodGroup;
  int? contact;
  bool active;
  String? aadhar;
  String? abha;
  Workspace workspace;
  DateTime createdAt;
  DateTime lastModified;

  Patient(
      {required this.patientId,
      required this.name,
      required this.gender,
      required this.age,
      required this.active,
      required this.workspace,
      required this.contact,
      required this.aadhar,
      required this.abha,
      required this.createdAt,
      required this.lastModified});

  factory Patient.fromJson(dynamic json) {
    final workspace = Workspace.fromJson(json['workspace']);

    return Patient(
      patientId: json['patient_id'],
      name: json['name'],
      gender: json['gender'],
      age: json['age'],
      workspace: workspace,
      contact: json['contact'],
      aadhar: json['aadhar'],
      active: json['active'],
      abha: json['abha'],
      createdAt: DateTime.parse(json['created_at']),
      lastModified: DateTime.parse(json['modified_at']),
    );
  }

  bool get isActive => active;
}
