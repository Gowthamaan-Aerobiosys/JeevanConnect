import 'package:flutter/material.dart';

abstract interface class ColumnFormat {
  const ColumnFormat();

  Widget transform(Widget cell);
}

class NumericColumnFormat implements ColumnFormat {
  const NumericColumnFormat();

  @override
  Widget transform(Widget cell) =>
      Align(alignment: Alignment.centerRight, child: cell);
}

class AlignColumnFormat implements ColumnFormat {
  final AlignmentGeometry alignment;

  const AlignColumnFormat({required this.alignment});

  @override
  Widget transform(Widget cell) => Align(alignment: alignment, child: cell);
}
