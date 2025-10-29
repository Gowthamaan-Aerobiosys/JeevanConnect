import 'address_check_option.dart';

class AddressCheckResult {
  AddressCheckResult({
    required this.option,
    required this.isSuccess,
  });

  final AddressCheckOption option;
  final bool isSuccess;

  @override
  String toString() => 'AddressCheckResult($option, $isSuccess)';
}
