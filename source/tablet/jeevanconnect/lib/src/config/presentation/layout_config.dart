import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class LayoutConfig {
  static const _designHeight = 792.8, _designWidth = 1536.0;

  static late double _height, _width, _scaleHeight, _scaleWidth;

  static late StreamController<bool> _layoutUpdateController;

  init() {
    _layoutUpdateController = StreamController<bool>.broadcast();
  }

  dispose(context) {
    _layoutUpdateController.close();
  }

  updateLayout(context) {
    final mediaQueryData = MediaQuery.of(context);
    _height = mediaQueryData.size.height;
    _width = mediaQueryData.size.width;
    _scaleHeight = _height / _designHeight;
    _scaleWidth = _width / _designWidth;
    double? safeAreaHorizontal =
        mediaQueryData.padding.left + mediaQueryData.padding.right;
    double? safeAreaVertical =
        mediaQueryData.padding.top + mediaQueryData.padding.bottom;
    _height = _height - safeAreaVertical;
    _width = _width - safeAreaHorizontal;
    _setScreenOrientation();
    setSystemUIMode();
    _layoutUpdateController.sink.add(true);
  }

  _setScreenOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  setSystemUIMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  setHeight(height) => height * _scaleHeight;

  setWidth(width) => width * _scaleWidth;

  setFontSize(fontSize) => fontSize * _scaleHeight;

  setFractionHeight(fraction) => _height * (fraction / 100);

  setFractionWidth(fraction) => _width * (fraction / 100);

  Stream get layoutUpdates => _layoutUpdateController.stream;
}
