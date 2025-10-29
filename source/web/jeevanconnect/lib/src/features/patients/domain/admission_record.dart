import '../../../shared/domain/date_time_formatter.dart';

class AdmissionRecord {
  int id;
  int height;
  int weight;
  String ibw;
  String bmi;
  DateTime admissionDate;
  String reasonForAdmission;
  String reasonForVentilation;
  bool historyOfDiabetes;
  List<String> tags;
  bool historyOfBp;
  String currentStatus;
  bool isDischarged;
  DateTime? dischargeDate;
  String createdAt;
  String modifiedAt;

  AdmissionRecord({
    required this.id,
    required this.height,
    required this.weight,
    required this.ibw,
    required this.bmi,
    required this.admissionDate,
    required this.reasonForAdmission,
    required this.reasonForVentilation,
    required this.historyOfDiabetes,
    required this.tags,
    required this.historyOfBp,
    required this.currentStatus,
    required this.isDischarged,
    this.dischargeDate,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory AdmissionRecord.fromJson(Map<String, dynamic> json) {
    return AdmissionRecord(
      id: json['id'],
      height: json['height'],
      weight: json['weight'],
      ibw: json['ibw'],
      bmi: json['bmi'],
      admissionDate: DateTime.parse(json['admission_date']),
      reasonForAdmission: json['reason_for_admission'],
      reasonForVentilation: json['reason_for_ventilation'],
      historyOfDiabetes: json['history_of_diabetes'],
      tags: json['tags'].split(','),
      historyOfBp: json['history_of_bp'],
      currentStatus: json['current_status'],
      isDischarged: json['is_discharged'] ?? false,
      dischargeDate: DateTime.tryParse(json['discharge_date'] ?? ""),
      createdAt:
          DateTimeFormat.getTimeStamp(DateTime.parse(json['created_at'])),
      modifiedAt:
          DateTimeFormat.getTimeStamp(DateTime.parse(json['modified_at'])),
    );
  }

  getITV() {
    double idealWeight = double.parse(ibw);
    return "${(idealWeight * 4).toInt()}-${(idealWeight * 6).toInt()}";
  }
}
