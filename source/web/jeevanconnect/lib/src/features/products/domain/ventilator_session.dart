import '../../patients/patients.dart' show Patient;
import '../../workspace/workspace.dart' show Workspace;
import 'product.dart';

class VentilatorSession {
  String sessionId;
  Product ventilator;
  Workspace workspace;
  Patient? patient;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  VentilatorSession({
    required this.sessionId,
    required this.ventilator,
    required this.workspace,
    required this.patient,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VentilatorSession.fromJson(dynamic json) {
    final workspace = Workspace.fromJson(json['workspace']);
    final patient =
        json['patient'] == null ? null : Patient.fromJson(json['patient']);
    final ventilator = Product.fromJson(json['ventilator']);

    return VentilatorSession(
      sessionId: json['session_id'],
      ventilator: ventilator,
      workspace: workspace,
      patient: patient,
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
