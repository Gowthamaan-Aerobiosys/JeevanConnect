class CustomException implements Exception {
  final int code;
  final String key;
  final String title;
  final String displayMessage;
  final Map<String, Object>? args;
  const CustomException(
      {required this.code,
      required this.key,
      required this.title,
      required this.displayMessage,
      this.args});

  @override
  bool operator ==(Object other) {
    return other is CustomException &&
        other.runtimeType == runtimeType &&
        other.key == key &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(runtimeType, key);

  @override
  String toString() => "$code Exception: $key";
}
