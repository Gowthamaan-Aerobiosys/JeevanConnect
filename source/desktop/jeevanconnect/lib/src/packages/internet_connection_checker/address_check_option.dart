import 'package:http/http.dart' as http;

typedef ResponseStatusFn = bool Function(http.Response response);

class AddressCheckOption {
  AddressCheckOption({
    required this.uri,
    this.timeout = const Duration(seconds: 3),
    this.headers = const {},
    ResponseStatusFn? responseStatusFn,
  }) : responseStatusFn = responseStatusFn ?? defaultResponseStatusFn;

  static ResponseStatusFn defaultResponseStatusFn = (response) {
    return response.statusCode == 200;
  };

  final Uri uri;

  final Duration timeout;

  final Map<String, String> headers;

  final ResponseStatusFn responseStatusFn;

  @override
  String toString() {
    return 'AddressCheckOption(\n'
        '  uri: $uri,\n'
        '  timeout: $timeout,\n'
        '  headers: ${headers.toString()}\n'
        ')';
  }
}
