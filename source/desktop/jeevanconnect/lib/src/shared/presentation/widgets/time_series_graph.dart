import 'dart:math';

import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';

enum GraphStyle { stroke, fill }

class TimeSeriesGraph extends StatelessWidget {
  final List<double> dataSetXValues;
  final List<double> dataSetYValues;
  final List<bool> pointType;
  final String title;
  final double yAxisMin;
  final double yAxisMax;
  final double xAxisMin;
  final double xAxisMax;
  final double fontSize;
  final Color backgroundColor;
  final Color positiveTraceColor;
  final Color negativeTraceColor;
  final Color spontBreathColor;
  final bool showAxes;
  final bool showTicks;
  final double strokeWidth;
  final EdgeInsetsGeometry margin;
  final bool isAutoScaled;
  final GraphStyle graphStyle;

  const TimeSeriesGraph({
    super.key,
    this.positiveTraceColor = AppPalette.white,
    this.negativeTraceColor = AppPalette.white,
    this.backgroundColor = AppPalette.black,
    this.spontBreathColor = AppPalette.white,
    this.margin = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
    this.graphStyle = GraphStyle.stroke,
    this.yAxisMax = 1.0,
    this.yAxisMin = 0.0,
    this.xAxisMax = 10,
    this.fontSize = 12.0,
    this.xAxisMin = -200,
    this.showAxes = true,
    this.showTicks = true,
    this.isAutoScaled = false,
    this.strokeWidth = 1.4,
    required this.title,
    required this.dataSetXValues,
    required this.dataSetYValues,
    required this.pointType,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: margin,
          width: double.infinity,
          height: double.infinity,
          color: backgroundColor,
          child: ClipRect(
            child: CustomPaint(
              painter: _TracePainter(
                xDataSet: dataSetXValues,
                yDataSet: dataSetYValues,
                pointType: pointType,
                xMax: xAxisMax,
                xMin: xAxisMin,
                fontSize: fontSize,
                positiveTraceColor: positiveTraceColor,
                negativeTraceColor: negativeTraceColor,
                spontBreathColor: spontBreathColor,
                isAutoScaled: isAutoScaled,
                yMin: yAxisMin,
                yMax: yAxisMax,
                strokeWidth: strokeWidth,
                showAxes: showAxes,
                showTicks: showTicks,
                graphStyle: graphStyle,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(color: positiveTraceColor),
          ),
        ),
      ],
    );
  }
}

class _TracePainter extends CustomPainter {
  final List<double> xDataSet;
  final List<double> yDataSet;
  final List<bool> pointType;
  final double yMin;
  final double yMax;
  final double xMin;
  final double xMax;
  final double fontSize;
  final Color positiveTraceColor;
  final Color negativeTraceColor;
  final Color spontBreathColor;
  final bool showAxes;
  final bool showTicks;
  final double strokeWidth;
  final bool isAutoScaled;
  final GraphStyle graphStyle;

  _TracePainter(
      {required this.yMin,
      required this.yMax,
      required this.xMin,
      required this.xMax,
      required this.graphStyle,
      required this.xDataSet,
      required this.yDataSet,
      required this.pointType,
      required this.isAutoScaled,
      required this.strokeWidth,
      required this.showAxes,
      required this.showTicks,
      this.fontSize = 12.0,
      required this.spontBreathColor,
      required this.positiveTraceColor,
      required this.negativeTraceColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint positiveTracePaint = Paint()
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..color = positiveTraceColor
      ..style = PaintingStyle.stroke;

    final Paint negativeTracePaint = Paint()
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..color = negativeTraceColor
      ..style = PaintingStyle.stroke;

    final Paint spontBreathPaint = Paint()
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..color = spontBreathColor
      ..style = PaintingStyle.stroke;

    final positionPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppPalette.white;

    final axisPaint = Paint()
      ..strokeWidth = 0.5
      ..color = AppPalette.grey;

    double yMinimum = yMin - (yMax / 6),
        yMaximum = yMax + (yMax / 10),
        xMinimum = xMin * (xMax / 5),
        xMaximum = (xMax * 1000) + 200;

    if (isAutoScaled && xDataSet.isNotEmpty) {
      final autoScaleMinimum = yDataSet.reduce(min) - (yMax / 7);
      final autoScaleMaximum = yDataSet.reduce(max) + (yMax / 10);
      yMaximum = autoScaleMaximum;
      yMinimum = autoScaleMinimum;
    }

    double yScale = (size.height / (yMaximum - yMinimum));
    double xScale = (size.width / (xMaximum - xMinimum));

    if (showAxes) {
      ///X axis
      Offset xAxisStart = Offset(getScaledX(xMinimum, xMinimum, xScale),
          getScaledY(0, size, yMinimum, yScale));
      Offset xAxisEnd = Offset(getScaledX(xMaximum, xMinimum, xScale),
          getScaledY(0, size, yMinimum, yScale));

      ///Y axis
      Offset yAxisStart = Offset(getScaledX(0, xMinimum, xScale),
          getScaledY(yMinimum, size, yMinimum, yScale));
      Offset yAxisEnd = Offset(getScaledX(0, xMinimum, xScale),
          getScaledY(yMaximum, size, yMinimum, yScale));
      canvas.drawLine(xAxisStart, xAxisEnd, axisPaint);
      canvas.drawLine(yAxisStart, yAxisEnd, axisPaint);
    }

    if (showTicks) {
      addYTick('0', -2, canvas, size, xMinimum, yMinimum, xScale, yScale);

      final yPositiveStep = yMax / 2;
      for (int i = 1; i <= 2; i++) {
        final tick = i * yPositiveStep;
        addYTick(tick.toStringAsFixed(0), tick, canvas, size, xMinimum,
            yMinimum, xScale, yScale);
      }

      final yNegativeStep = (yMin < 0 ? -1 : 1) * yMin / 2;
      if (yNegativeStep >= yMax / 2) {
        for (int i = -1; i >= -2; i--) {
          final tick = i * yNegativeStep;
          addYTick(tick.toStringAsFixed(0), tick, canvas, size, xMinimum,
              yMinimum, xScale, yScale);
        }
      } else {
        addYTick(yMin.toStringAsFixed(0), yMin, canvas, size, xMinimum,
            yMinimum, xScale, yScale);
      }
    }

    final zero = getScaledY(0, size, yMinimum, yScale);

    if (xDataSet.isNotEmpty &&
        yDataSet.isNotEmpty &&
        xDataSet.length == yDataSet.length) {
      switch (graphStyle) {
        case GraphStyle.stroke:
          for (int index = 0; index < (xDataSet.length - 1); index++) {
            final y1 = getScaledY(yDataSet[index], size, yMinimum, yScale);
            final y2 = getScaledY(yDataSet[index + 1], size, yMinimum, yScale);
            final x1 = getScaledX(xDataSet[index], xMinimum, xScale);
            final x2 = getScaledX(xDataSet[index + 1], xMinimum, xScale);
            final p1 = Offset(x1, y1);
            final p2 = Offset(x2, y2);
            bool isOutlier =
                (y1 > zero && y2 < zero) || (y1 < zero && y2 > zero);
            if (pointType[index] && pointType[index + 1]) {
              canvas.drawLine(p1, p2, spontBreathPaint);
            } else {
              if (isOutlier) {
                final x3 = (x1 + x2) / 2;
                final p3 = Offset(x3, zero);
                canvas.drawLine(p1, p3,
                    (y1 >= zero) ? negativeTracePaint : positiveTracePaint);
                canvas.drawLine(p3, p2,
                    (y2 >= zero) ? negativeTracePaint : positiveTracePaint);
              } else {
                canvas.drawLine(
                    p1,
                    p2,
                    (y1 >= zero && y2 >= zero)
                        ? negativeTracePaint
                        : positiveTracePaint);
              }
            }
          }
          break;
        case GraphStyle.fill:
          Path trace = Path();
          trace.moveTo(getScaledX(xDataSet[0], xMinimum, xScale),
              getScaledY(yDataSet[0], size, yMinimum, yScale));
          for (int index = 1; index < xDataSet.length; index++) {
            final y1 = getScaledY(yDataSet[index - 1], size, yMinimum, yScale);
            final y2 = getScaledY(yDataSet[index], size, yMinimum, yScale);
            final x1 = getScaledX(xDataSet[index - 1], xMinimum, xScale);
            final x2 = getScaledX(xDataSet[index], xMinimum, xScale);
            Paint tracePaint = positiveTracePaint;
            bool isOutlier =
                (y1 > zero && y2 < zero) || (y1 < zero && y2 > zero);
            if (pointType[index] && pointType[index - 1]) {
              trace.lineTo(x2, y2);
              tracePaint = spontBreathPaint;
            } else {
              if (isOutlier) {
                final x3 = (x1 + x2) / 2;
                trace.lineTo(x3, zero);
                canvas.drawPath(trace,
                    (y1 >= zero) ? negativeTracePaint : positiveTracePaint);
                drawShadow(trace, x1, x3, zero, canvas, tracePaint);
                trace = Path();
                trace.moveTo(x3, zero);
                trace.lineTo(x2, y2);
                tracePaint =
                    (y2 >= zero) ? negativeTracePaint : positiveTracePaint;
              } else {
                trace.lineTo(x2, y2);
                tracePaint = (y1 >= zero && y2 >= zero)
                    ? negativeTracePaint
                    : positiveTracePaint;
              }
            }
            canvas.drawPath(trace, tracePaint);
            drawShadow(trace, x1, x2, zero, canvas, tracePaint);
            trace = Path();
            trace.moveTo(x2, y2);
          }
          break;
      }

      canvas.drawRect(
          Rect.fromLTRB(
              getScaledX(xDataSet.last, xMinimum, xScale),
              getScaledY(yMaximum, size, yMinimum, yScale),
              getScaledX(xDataSet.last + 2, xMinimum, xScale),
              getScaledY(yMinimum, size, yMinimum, yScale)),
          positionPaint);
      TextPainter textMin = TextPainter(
        text: TextSpan(
            text: yDataSet.last.toStringAsFixed(1),
            style: TextStyle(
                color: positiveTraceColor, letterSpacing: 0.5, fontSize: 12)),
        textDirection: TextDirection.ltr,
      );
      textMin.layout(minWidth: 0, maxWidth: size.width);
      textMin.paint(canvas, Offset(size.width * 0.95, 0));
    }
  }

  getScaledX(value, minimum, scale) => (value - minimum) * scale;

  getScaledY(value, size, minimum, scale) =>
      size.height - getScaledX(value, minimum, scale);

  drawShadow(trace, x1, x2, zero, canvas, tracePaint) {
    Path closePathFormGradient = Path();
    closePathFormGradient.addPath(trace, Offset.zero);
    closePathFormGradient.lineTo(x2, zero);
    closePathFormGradient.lineTo(x1, zero);

    canvas.drawPath(
        closePathFormGradient,
        Paint()
          ..style = PaintingStyle.fill
          ..color = tracePaint.color.withOpacity(0.2));
  }

  addYTick(tickLabel, value, canvas, size, xMinimum, yMinimum, xScale, yScale) {
    if (tickLabel != '0') {
      TextPainter markPainter = TextPainter(
        text: const TextSpan(
          text: "--",
          style: TextStyle(
              fontFamily: "MyriadPro", fontSize: 8, color: AppPalette.grey),
        ),
        textDirection: TextDirection.ltr,
      );
      markPainter.layout(minWidth: 0, maxWidth: size.width);
      markPainter.paint(
          canvas,
          Offset(getScaledX(xMinimum * 0.2, xMinimum, xScale),
              getScaledY(value, size, yMinimum, yScale)));
    }
    final xPosition = value == -2
        ? xMinimum * 0.3
        : value > 0
            ? xMinimum
            : xMinimum * 0.9;
    TextPainter labelPainter = TextPainter(
      text: TextSpan(
        text: tickLabel,
        style: TextStyle(
            fontFamily: "MyriadPro",
            fontSize: fontSize,
            color: AppPalette.grey),
      ),
      textDirection: value < 0 ? TextDirection.ltr : TextDirection.rtl,
    );
    labelPainter.layout(minWidth: 0, maxWidth: size.width);
    labelPainter.paint(
        canvas,
        Offset(getScaledX(xPosition, xMinimum, xScale),
            getScaledY(value, size, yMinimum, yScale)));
  }

  @override
  bool shouldRepaint(_TracePainter old) {
    return true;
  }
}
