import 'dart:async';

class BootUIControllers {
  static late StreamController<double> _progressController;

  init() {
    _progressController = StreamController<double>.broadcast();
  }

  dispose() {
    _progressController.close();
  }

  StreamController<double> get progressController => _progressController;
}
