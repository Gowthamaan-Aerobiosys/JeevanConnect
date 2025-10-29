import '../../../shared/domain/date_time_formatter.dart';

class Clinicallog {
  int id;
  String content;
  String addedBy;
  String timeStamp;

  Clinicallog(
      {required this.id,
      required this.content,
      required this.timeStamp,
      required this.addedBy});

  factory Clinicallog.fromJson(json) {
    return Clinicallog(
        id: json['id'],
        addedBy: json['added_by'],
        content: json['content'],
        timeStamp:
            DateTimeFormat.getTimeStamp(DateTime.parse(json['created_at'])));
  }
}
