part of 'paged_datatable.dart';

final class SortModel {
  final String fieldName;
  final bool descending;

  const SortModel._({required this.fieldName, required this.descending});

  @override
  int get hashCode => Object.hash(fieldName, descending);

  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      (other is SortModel &&
          other.fieldName == fieldName &&
          other.descending == descending);
}
