// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:typed_data';

int wildcardFind(dynamic needle, dynamic haystack) {
  final int? hl = haystack.length;
  final int? nl = needle.length;

  if (nl == 0) {
    return 0;
  }

  if (hl! < nl!) {
    return -1;
  }

  for (int i = 0; i <= (hl - nl); i++) {
    bool found = true;
    for (int j = 0; j < nl; j++) {
      if (needle[j] != null && (haystack[i + j] != needle[j])) {
        found = false;
        break;
      }
    }
    if (found) {
      return i;
    }
  }
  return -1;
}

abstract class DisposableStreamTransformer<T, R>
    implements StreamTransformer<T, R> {
  void dispose();
}

class MagicHeaderAndLengthByteTransformer
    implements DisposableStreamTransformer<Uint8List, Uint8List> {
  final List<int?>? header;
  final Duration clearTimeout;
  late List<int> _partial;
  Timer? _timer;
  late bool _dataSinceLastTick;
  bool? cancelOnError;
  final int
      maxLen; // maximum length the partial buffer will hold before it starts flushing.

  late StreamController _controller;
  StreamSubscription? _subscription;
  late Stream<Uint8List> _stream;

  MagicHeaderAndLengthByteTransformer(
      {bool sync = false,
      this.cancelOnError,
      this.header,
      this.maxLen = 1024,
      this.clearTimeout = const Duration(seconds: 1)}) {
    _partial = [];
    _controller = StreamController<Uint8List>(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () {
          _subscription!.pause();
        },
        onResume: () {
          _subscription!.resume();
        },
        sync: sync);
  }

  MagicHeaderAndLengthByteTransformer.broadcast(
      {bool sync = false,
      this.cancelOnError,
      this.header,
      this.maxLen = 1024,
      this.clearTimeout = const Duration(seconds: 1)}) {
    _partial = [];
    _controller = StreamController<Uint8List>.broadcast(
        onListen: _onListen, onCancel: _onCancel, sync: sync);
  }

  void _onListen() {
    _startTimer();
    _subscription = _stream.listen(onData,
        onError: _controller.addError,
        onDone: _controller.close,
        cancelOnError: cancelOnError);
  }

  void _onCancel() {
    _stopTimer();
    _subscription!.cancel();
    _subscription = null;
  }

  void onData(Uint8List data) {
    _dataSinceLastTick = true;
    if (_partial.length > maxLen) {
      _partial = _partial.sublist(_partial.length - maxLen);
    }

    _partial.addAll(data);

    while (_partial.isNotEmpty) {
      int index = wildcardFind(header, _partial);
      if (index < 0) {
        return;
      }

      if (index > 0) {
        _partial = _partial.sublist(index);
      }

      if (_partial.length < header!.length + 1) {
        // not completely arrived yet.
        return;
      }

      int len = _partial[header!.length];
      if (_partial.length < len + header!.length + 1) {
        // not completely arrived yet.
        return;
      }

      _controller.add(
          Uint8List.fromList(_partial.sublist(0, len + header!.length + 1)));
      _partial = _partial.sublist(len + header!.length + 1);
    }
  }

  @override
  Stream<Uint8List> bind(Stream<Uint8List> stream) {
    _stream = stream;
    return _controller.stream as Stream<Uint8List>;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() =>
      StreamTransformer.castFrom<Uint8List, Uint8List, RS, RT>(this);

  void _onTimer(Timer timer) {
    if (_partial.isNotEmpty && !_dataSinceLastTick) {
      _partial.clear();
    }
    _dataSinceLastTick = false;
  }

  void _stopTimer() {
    _timer!.cancel();
    _timer = null;
  }

  void _startTimer() {
    _dataSinceLastTick = false;
    _timer = Timer.periodic(clearTimeout, _onTimer);
  }

  @override
  void dispose() {
    _controller.close();
  }
}
