import 'package:intl/intl.dart';

class DateTimeFormat {
  static const Duration durationToAdd = Duration(hours: 5, minutes: 30);

  static get12HTime(timeStamp) {
    if (timeStamp == null) {
      return "";
    }
    timeStamp = timeStamp.add(durationToAdd);
    return DateFormat('h:mm a').format(timeStamp).toLowerCase();
  }

  static getDate(timeStamp) {
    if (timeStamp == null) {
      return "";
    }
    timeStamp = timeStamp.add(durationToAdd);
    return DateFormat('d MMM y').format(timeStamp);
  }

  static getTimeStamp(timeStamp) {
    if (timeStamp == null) {
      return "";
    }
    timeStamp = timeStamp.add(durationToAdd);
    return DateFormat('d/MM/y h:mm a').format(timeStamp).toLowerCase();
  }

  static getGraphStamp(timeStamp) {
    if (timeStamp == null) {
      return "";
    }
    timeStamp = timeStamp.add(durationToAdd);
    return DateFormat('d/MM/y\nh:mm a').format(timeStamp).toLowerCase();
  }
}
