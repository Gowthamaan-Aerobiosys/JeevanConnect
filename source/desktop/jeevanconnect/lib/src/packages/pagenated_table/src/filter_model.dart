part of 'paged_datatable.dart';

final class FilterModel extends UnmodifiableMapBase<String, dynamic> {
  final Map<String, dynamic> _inner;

  FilterModel._(this._inner);

  @override
  operator [](Object? key) => _inner[key];

  @override
  Iterable<String> get keys => _inner.keys;

  T valueAs<T>(String filterId, {T Function()? orElse}) {
    final value = _inner[filterId];
    if (value == null) {
      if (orElse != null) return orElse();
      throw StateError("Value for filter $filterId was not found.");
    }

    return value as T;
  }
}
