import '../custom_exception.dart';

class ProductException {
  static const productAlreadyExists = CustomException(
      code: 400,
      key: "product-already-exists",
      title: "Product already exists",
      displayMessage: "Product with that serial number already exists");

  static const productDoesnotExists = CustomException(
      code: 400,
      key: "product-doesn't-exists",
      title: "Product doesn't exists",
      displayMessage: "Product with that serial number doesn't exists");
}
