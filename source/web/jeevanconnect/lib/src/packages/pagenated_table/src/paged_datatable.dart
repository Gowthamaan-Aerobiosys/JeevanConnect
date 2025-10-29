import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../config/presentation/app_palette.dart';
import '../paged_datatable.dart';
import 'linked_scroll_controller.dart';
import 'table_controller_notifier.dart';

part 'column.dart';
part 'column_widgets.dart';
part 'controller.dart';
part 'double_list_rows.dart';
part 'filter.dart';
part 'filter_bar.dart';
part 'filter_model.dart';
part 'filter_state.dart';
part 'filter_widgets.dart';
part 'footer_widgets.dart';
part 'header.dart';
part 'row.dart';
part 'sort_model.dart';

final class PagedDataTable<K extends Comparable<K>, T> extends StatefulWidget {
  final PagedDataTableController<K, T>? controller;

  final List<ReadOnlyTableColumn<K, T>> columns;

  final int initialPageSize;

  final K? initialPage;

  final List<int>? pageSizes;

  final Fetcher<K, T> fetcher;

  final int fixedColumnCount;

  final PagedDataTableConfiguration configuration;

  final Widget? footer;

  final Widget? filterBarChild;

  final List<TableFilter> filters;

  const PagedDataTable({
    required this.columns,
    required this.fetcher,
    this.initialPage,
    this.initialPageSize = 50,
    this.pageSizes = const [10, 50, 100],
    this.controller,
    this.fixedColumnCount = 0,
    this.configuration = const PagedDataTableConfiguration(),
    this.footer,
    this.filterBarChild,
    this.filters = const <TableFilter>[],
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _PagedDataTableState<K, T>();
}

final class _PagedDataTableState<K extends Comparable<K>, T>
    extends State<PagedDataTable<K, T>> {
  final verticalController = ScrollController();
  final linkedControllers = LinkedScrollControllerGroup();
  late final headerHorizontalController = linkedControllers.addAndGet();
  late final horizontalController = linkedControllers.addAndGet();
  late final PagedDataTableController<K, T> tableController;
  // late FixedTableSpanExtent rowSpanExtent, headerRowSpanExtent;
  late PagedDataTableThemeData theme;
  bool selfConstructedController = false;

  @override
  void initState() {
    super.initState();
    assert(
        widget.pageSizes != null
            ? widget.pageSizes!.contains(widget.initialPageSize)
            : true,
        "initialPageSize must be inside pageSizes. To disable this restriction, set pageSizes to null.");

    if (widget.controller == null) {
      selfConstructedController = true;
      tableController = PagedDataTableController();
    } else {
      tableController = widget.controller!;
    }
    tableController._init(
      columns: widget.columns,
      pageSizes: widget.pageSizes,
      initialPageSize: widget.initialPageSize,
      fetcher: widget.fetcher,
      config: widget.configuration,
      filters: widget.filters,
    );
  }

  @override
  void didUpdateWidget(covariant PagedDataTable<K, T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.columns.length !=
        widget.columns
            .length /*!listEquals(oldWidget.columns, widget.columns)*/) {
      tableController._reset(columns: widget.columns);
      debugPrint("PagedDataTable<$T> changed and rebuilt.");
    }
  }

  @override
  Widget build(BuildContext context) {
    theme = PagedDataTableTheme.of(context);

    return Card(
      color: theme.backgroundColor,
      elevation: theme.elevation,
      shape: RoundedRectangleBorder(borderRadius: theme.borderRadius),
      margin: EdgeInsets.zero,
      child: TableControllerProvider(
        controller: tableController,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sizes = _calculateColumnWidth(constraints.maxWidth);

            return Column(
              children: [
                _FilterBar<K, T>(child: widget.filterBarChild),
                _Header(
                  controller: tableController,
                  configuration: widget.configuration,
                  columns: widget.columns,
                  sizes: sizes,
                  fixedColumnCount: widget.fixedColumnCount,
                  horizontalController: headerHorizontalController,
                ),
                const Divider(height: 0, color: Color(0xFFD6D6D6)),
                Expanded(
                  child: _DoubleListRows(
                    fixedColumnCount: widget.fixedColumnCount,
                    columns: widget.columns,
                    horizontalController: horizontalController,
                    controller: tableController,
                    configuration: widget.configuration,
                    sizes: sizes,
                  ),
                ),
                const Divider(height: 0, color: Color(0xFFD6D6D6)),
                SizedBox(
                  height: theme.footerHeight,
                  child: widget.footer ?? DefaultFooter<K, T>(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    verticalController.dispose();
    horizontalController.dispose();
    headerHorizontalController.dispose();

    if (selfConstructedController) {
      tableController.dispose();
    }
  }

  List<double> _calculateColumnWidth(double maxWidth) {
    final sizes =
        List.generate(widget.columns.length, (index) => 0.0, growable: false);
    double availableWidth = maxWidth;
    for (int i = 0; i < widget.columns.length; i++) {
      final column = widget.columns[i];
      final columnSize = column.size.calculateConstraints(availableWidth);
      availableWidth -= columnSize;
      sizes[i] = columnSize;
    }

    return sizes;
  }
}
