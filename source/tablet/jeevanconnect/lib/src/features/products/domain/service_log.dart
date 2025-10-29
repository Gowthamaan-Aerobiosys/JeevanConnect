import '../../../shared/domain/date_time_formatter.dart';

class ServiceLog {
  int id;
  String content;
  String timeStamp;

  ServiceLog(
      {required this.id, required this.content, required this.timeStamp});

  factory ServiceLog.fromJson(json) {
    return ServiceLog(
        id: json['id'],
        content: json['content'],
        timeStamp:
            DateTimeFormat.getTimeStamp(DateTime.parse(json['created_at'])));
  }
}
