import 'dart:async';
import 'dart:typed_data';

import 'package:async/async.dart';

import 'transformers.dart';
import 'types.dart';

class Transaction<T> {
  late Stream<T> stream;
  late StreamQueue<T> _queue;
  final DisposableStreamTransformer? _transformer;

  static Transaction<Uint8List> magicHeader(
      Stream<Uint8List> stream, List<int> header,
      {int maxLen = 1024}) {
    return Transaction<Uint8List>(
        stream,
        MagicHeaderAndLengthByteTransformer.broadcast(
            header: header, maxLen: maxLen));
  }

  Transaction(Stream<Uint8List> stream,
      DisposableStreamTransformer<Uint8List, T> transformer)
      : stream = stream.transform(transformer),
        _transformer = transformer {
    _queue = StreamQueue<T>(this.stream);
  }

  Future<void> flush() async {
    while (true) {
      var f = _queue.hasNext.timeout(const Duration(microseconds: 1));
      try {
        bool hasNext = await f;
        if (!hasNext) {
          // The stream has closed, bail out!
          return;
        }
        await _queue.next;
        // consume the data and throw it away.
      } on TimeoutException {
        // Timeout occured, we are done, no more data
        // available.
        return;
      }
    }
  }

  Future<T?> getMsg(Duration duration) async {
    try {
      bool b = await _queue.hasNext.timeout(duration);
      if (b) {
        return await _queue.next;
      } else {
        // throw TimeoutException("Port was closed.");
        return null;
      }
    } on TimeoutException {
      return null;
    }
  }

  Future<T?> transaction(
      AsyncDataSinkSource port, Uint8List message, Duration duration) async {
    await flush();
    port.write(message);
    return getMsg(duration);
  }

  void dispose() {
    _queue.cancel();
    _transformer?.dispose();
  }
}
