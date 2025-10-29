class ABGReport {
  final int id;
  final DateTime createdAt;
  final double pH;
  final double pCO2;
  final double pO2;
  final double hCO3;
  final double baseExcess;
  final double sO2;
  final double lactate;
  final String? comments;

  ABGReport({
    required this.id,
    required this.createdAt,
    required this.pH,
    required this.pCO2,
    required this.pO2,
    required this.hCO3,
    required this.baseExcess,
    required this.sO2,
    required this.lactate,
    this.comments,
  });

  factory ABGReport.fromJson(Map<String, dynamic> json) {
    return ABGReport(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      pH: json['pH'].toDouble(),
      pCO2: json['pCO2'].toDouble(),
      pO2: json['pO2'].toDouble(),
      hCO3: json['hCO3'].toDouble(),
      baseExcess: json['base_excess'].toDouble(),
      sO2: json['sO2'].toDouble(),
      lactate: json['lactate'].toDouble(),
      comments: json['comments'],
    );
  }

  Map<String, dynamic> toJson(recordId) {
    return {
      'amr_id': recordId,
      'created_at': createdAt.toIso8601String(),
      'pH': pH.toString(),
      'pCO2': pCO2.toString(),
      'pO2': pO2.toString(),
      'hCO3': hCO3.toString(),
      'base_excess': baseExcess.toString(),
      'sO2': sO2.toString(),
      'lactate': lactate.toString(),
      'comments': comments.toString(),
    };
  }

  @override
  String toString() {
    return 'ABG Report $id - $createdAt';
  }
}
