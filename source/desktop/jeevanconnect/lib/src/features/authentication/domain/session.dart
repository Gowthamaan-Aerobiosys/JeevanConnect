class Session {
  int id;
  String deviceType;
  String browser;
  String os;
  String country;
  String city;
  DateTime loginTime;

  Session({
    required this.id,
    required this.deviceType,
    required this.browser,
    required this.os,
    required this.country,
    required this.city,
    required this.loginTime,
  });

  factory Session.fromJson(dynamic json) {
    return Session(
      id: json['id'],
      deviceType: json['device_type'],
      browser: json['browser'],
      os: json['os'],
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      loginTime: DateTime.parse(json['login_time']),
    );
  }
}
