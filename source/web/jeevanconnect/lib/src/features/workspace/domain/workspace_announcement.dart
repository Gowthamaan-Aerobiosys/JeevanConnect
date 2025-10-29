import '../../../shared/domain/date_time_formatter.dart';

class WorkspaceAnnouncement {
  int id;
  String content;
  String timeStamp;

  WorkspaceAnnouncement(
      {required this.id, required this.content, required this.timeStamp});

  factory WorkspaceAnnouncement.fromJson(json) {
    return WorkspaceAnnouncement(
        id: json['id'],
        content: json['content'],
        timeStamp:
            DateTimeFormat.getTimeStamp(DateTime.parse(json['created_at'])));
  }
}
