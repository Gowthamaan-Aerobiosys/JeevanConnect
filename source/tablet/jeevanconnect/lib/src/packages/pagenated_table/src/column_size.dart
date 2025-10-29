import 'dart:math' as math;

sealed class ColumnSize {
  const ColumnSize();
  double calculateConstraints(double availableWidth);
}

final class FixedColumnSize extends ColumnSize {
  final double size;

  const FixedColumnSize(this.size);

  @override
  int get hashCode => size.hashCode;

  @override
  bool operator ==(Object other) =>
      other is FixedColumnSize && other.size == size;

  @override
  double calculateConstraints(double availableWidth) => size;
}

final class FractionalColumnSize extends ColumnSize {
  final double fraction;

  const FractionalColumnSize(this.fraction)
      : assert(fraction > 0, "Fraction cannot be less than or equal to zero.");

  @override
  int get hashCode => fraction.hashCode;

  @override
  bool operator ==(Object other) =>
      other is FractionalColumnSize && other.fraction == fraction;

  @override
  double calculateConstraints(double availableWidth) =>
      availableWidth * fraction;
}

final class RemainingColumnSize extends ColumnSize {
  const RemainingColumnSize();

  @override
  double calculateConstraints(double availableWidth) =>
      math.max(0.0, availableWidth);
}

final class MaxColumnSize extends ColumnSize {
  final ColumnSize a, b;

  const MaxColumnSize(this.a, this.b);

  @override
  double calculateConstraints(double availableWidth) => math.max(
      a.calculateConstraints(availableWidth),
      b.calculateConstraints(availableWidth));
}
