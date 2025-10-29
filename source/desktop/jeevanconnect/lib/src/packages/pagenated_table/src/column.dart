part of 'paged_datatable.dart';

typedef Setter<T, V> = FutureOr<bool> Function(T item, V value, int rowIndex);
typedef Getter<T, V> = V? Function(T item, int rowIndex);
typedef CellBuilder<T> = Widget Function(
    BuildContext context, T item, int rowIndex);

abstract class ReadOnlyTableColumn<K extends Comparable<K>, T> {
  final Widget title;

  final String? tooltip;

  final String? id;

  final ColumnSize size;

  final ColumnFormat format;

  final bool sortable;

  const ReadOnlyTableColumn({
    required this.id,
    required this.title,
    required this.size,
    required this.format,
    required this.tooltip,
    required this.sortable,
  }) : assert(sortable ? id != null : true,
            "When column is sortable, id must be set.");

  Widget build(BuildContext context, T item, int index);

  @override
  int get hashCode => Object.hash(id, size, title, format);

  @override
  bool operator ==(Object other) =>
      other is ReadOnlyTableColumn<K, T> &&
      other.title == title &&
      other.id == id &&
      other.size == size &&
      other.format == format;
}

abstract class EditableTableColumn<K extends Comparable<K>, T, V>
    extends ReadOnlyTableColumn<K, T> {
  final Setter<T, V> setter;

  final Getter<T, V> getter;

  const EditableTableColumn({
    required super.id,
    required super.title,
    required super.size,
    required super.format,
    required super.tooltip,
    required super.sortable,
    required this.setter,
    required this.getter,
  });
}

final class TableColumn<K extends Comparable<K>, T>
    extends ReadOnlyTableColumn<K, T> {
  final CellBuilder<T> cellBuilder;

  const TableColumn({
    required this.cellBuilder,
    required super.title,
    super.id,
    super.size = const FractionalColumnSize(.1),
    super.format = const AlignColumnFormat(alignment: Alignment.center),
    super.tooltip,
    super.sortable = false,
  });

  @override
  Widget build(BuildContext context, T item, int index) =>
      cellBuilder(context, item, index);

  @override
  int get hashCode => Object.hash(id, size, title, cellBuilder, format);

  @override
  bool operator ==(Object other) =>
      other is TableColumn<K, T> &&
      other.cellBuilder ==
          cellBuilder && // todo: this will always return false, fix a better way to compare those
      other.title == title &&
      other.id == id &&
      other.size == size &&
      other.format == format;
}

final class DropdownTableColumn<K extends Comparable<K>, T, V>
    extends EditableTableColumn<K, T, V> {
  final InputDecoration inputDecoration;
  final List<DropdownMenuItem<V>> items;

  const DropdownTableColumn({
    required super.title,
    super.id,
    super.size = const FractionalColumnSize(.1),
    super.format = const AlignColumnFormat(alignment: Alignment.centerLeft),
    super.tooltip,
    super.sortable = false,
    required super.setter,
    required super.getter,
    required this.items,
    this.inputDecoration = const InputDecoration(isDense: true),
  });

  @override
  Widget build(BuildContext context, T item, int index) => _DropdownCell<T, V>(
        getter: getter,
        setter: setter,
        index: index,
        item: item,
        items: items,
        inputDecoration: inputDecoration,
        key: ValueKey(item),
      );
}

final class TextTableColumn<K extends Comparable<K>, T>
    extends EditableTableColumn<K, T, String> {
  final InputDecoration inputDecoration;
  final List<TextInputFormatter>? inputFormatters;

  const TextTableColumn({
    required super.title,
    super.id,
    super.size = const FractionalColumnSize(.1),
    super.format = const AlignColumnFormat(alignment: Alignment.centerLeft),
    super.tooltip,
    super.sortable = false,
    required super.setter,
    required super.getter,
    this.inputDecoration = const InputDecoration(isDense: true),
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context, T item, int index) => _TextFieldCell<T>(
        getter: getter,
        setter: setter,
        index: index,
        item: item,
        key: ValueKey(item),
        isDialog: false,
        inputDecoration: inputDecoration,
        inputFormatters: inputFormatters,
      );
}

final class LargeTextTableColumn<K extends Comparable<K>, T>
    extends EditableTableColumn<K, T, String> {
  final InputDecoration inputDecoration;
  final List<TextInputFormatter>? inputFormatters;

  final bool showTooltip;

  final FormFieldValidator? validator;

  final String fieldLabel;

  final TextStyle tooltipStyle;

  final BoxConstraints? tooltipConstraints;

  final double bottomSheetBreakpoint;

  const LargeTextTableColumn({
    required super.title,
    super.id,
    super.size = const FractionalColumnSize(.1),
    super.format = const AlignColumnFormat(alignment: Alignment.centerLeft),
    super.tooltip,
    super.sortable = false,
    required super.setter,
    required super.getter,
    required this.fieldLabel,
    this.inputDecoration =
        const InputDecoration(isDense: true, border: OutlineInputBorder()),
    this.inputFormatters,
    this.validator,
    this.showTooltip = true,
    this.tooltipStyle = const TextStyle(color: Colors.white),
    this.tooltipConstraints,
    this.bottomSheetBreakpoint = 1000,
  });

  @override
  Widget build(BuildContext context, T item, int index) =>
      _LargeTextFieldCell<T>(
        getter: getter,
        setter: setter,
        index: index,
        item: item,
        key: ValueKey(item),
        isDialog: false,
        inputDecoration: inputDecoration,
        inputFormatters: inputFormatters,
        label: fieldLabel,
        tooltipText: showTooltip,
        validator: validator,
        tooltipStyle: tooltipStyle,
        tooltipConstraints: tooltipConstraints,
        bottomSheetBreakpoint: bottomSheetBreakpoint,
      );
}

final class RowSelectorColumn<K extends Comparable<K>, T>
    extends ReadOnlyTableColumn<K, T> {
  RowSelectorColumn()
      : super(
          format: const AlignColumnFormat(alignment: Alignment.center),
          id: null,
          size: const FixedColumnSize(80),
          sortable: false,
          tooltip: "Select rows",
          title: _SelectAllRowsCheckbox<K, T>(),
        );

  @override
  Widget build(BuildContext context, T item, int index) {
    return _SelectRowCheckbox<K, T>(index: index);
  }
}
