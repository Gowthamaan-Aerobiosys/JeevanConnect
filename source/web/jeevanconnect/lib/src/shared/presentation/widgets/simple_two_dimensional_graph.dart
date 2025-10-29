import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';

class SimpleTwoDimensionalGraph extends StatelessWidget {
  final List<double> dataSetXValues;
  final List<double> dataSetYValues;
  final String title;
  final double yAxisMin;
  final double yAxisMax;
  final double xAxisMin;
  final double xAxisMax;
  final Color backgroundColor;
  final Color traceColor;
  final bool showAxis;
  final bool showTicks;
  final double strokeWidth;
  final (double, double) xTickScaling;
  final (double, double) yTickScaling;
  final EdgeInsetsGeometry margin;
  final bool isAutoScaled;

  const SimpleTwoDimensionalGraph(
      {super.key,
      this.traceColor = AppPalette.white,
      this.backgroundColor = AppPalette.black,
      this.margin = const EdgeInsets.all(20.0),
      this.yAxisMax = 1.0,
      this.yAxisMin = 0.0,
      this.xAxisMax = 1.0,
      this.xAxisMin = 0.0,
      this.showAxis = true,
      this.showTicks = true,
      this.xTickScaling = (1, 1),
      this.yTickScaling = (1, 1),
      this.isAutoScaled = false,
      this.strokeWidth = 2.5,
      required this.title,
      required this.dataSetXValues,
      required this.dataSetYValues});

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
                  showAxes: showAxis,
                  xDataSet: dataSetXValues,
                  yDataSet: dataSetYValues,
                  xMax: xAxisMax,
                  xMin: xAxisMin,
                  traceColor: traceColor,
                  isAutoScaled: isAutoScaled,
                  yMin: yAxisMin,
                  yMax: yAxisMax,
                  strokeWidth: strokeWidth,
                  showTicks: showTicks,
                  xTickScaling: xTickScaling,
                  yTickScaling: yTickScaling),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: traceColor),
          ),
        ),
      ],
    );
  }
}

class _TracePainter extends CustomPainter {
  final List<double> xDataSet;
  final List<double> yDataSet;
  final (double, double) xTickScaling;
  final (double, double) yTickScaling;
  final double yMin;
  final double yMax;
  final double xMin;
  final double xMax;
  final Color traceColor;
  final bool showAxes;
  final bool showTicks;
  final double? strokeWidth;
  final bool isAutoScaled;

  _TracePainter(
      {required this.showAxes,
      required this.showTicks,
      required this.xTickScaling,
      required this.yTickScaling,
      required this.yMin,
      required this.yMax,
      required this.xMin,
      required this.xMax,
      required this.xDataSet,
      required this.yDataSet,
      required this.isAutoScaled,
      this.strokeWidth,
      this.traceColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final tracePaint = Paint()
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.5
      ..color = traceColor
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..strokeWidth = 0.6
      ..color = AppPalette.grey;

    double yMinimum = yMin - (yMax / 10),
        yMaximum = yMax,
        xMinimum = xMin - (xMax / 10),
        xMaximum = xMax + (xMax / 10);
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
      ///Zero
      addXTick('0', -2, canvas, size, xMinimum, yMinimum, xScale, yScale);

      ///X Ticks
      addXTick(xMin.toStringAsFixed(0), xMin, canvas, size, xMinimum, yMinimum,
          xScale, yScale);
      final xStep = xMax / 4;
      for (int i = 1; i <= 4; i++) {
        final tick = i * xStep;
        addXTick(tick.toStringAsFixed(0), tick, canvas, size, xMinimum,
            yMinimum, xScale, yScale);
      }

      ///Y Ticks
      final yPositiveStep = yMax / 5;
      for (int i = 1; i <= 5; i++) {
        final tick = i * yPositiveStep;
        addYTick(tick.toStringAsFixed(0).padLeft(4, " "), tick, canvas, size,
            xMinimum, yMinimum, xScale, yScale);
      }

      final yNegativeStep = (yMin < 0 ? -1 : 1) * yMin / 5;
      if (yNegativeStep >= yMax / 5) {
        for (int i = -1; i >= -5; i--) {
          final tick = i * yNegativeStep;
          addYTick(tick.toStringAsFixed(0).padLeft(4, " "), tick, canvas, size,
              xMinimum, yMinimum, xScale, yScale);
        }
      } else {
        addYTick(yMin.toStringAsFixed(0), yMin, canvas, size, xMinimum,
            yMinimum, xScale, yScale);
      }
    }

    if (xDataSet.isNotEmpty && yDataSet.isNotEmpty) {
      Path trace = Path();

      trace.moveTo(getScaledX(xDataSet[0], xMinimum, xScale),
          getScaledY(yDataSet[0], size, yMinimum, yScale));

      for (int pointIndex = 0; pointIndex < xDataSet.length - 1; pointIndex++) {
        trace.lineTo(getScaledX(xDataSet[pointIndex], xMinimum, xScale),
            getScaledY(yDataSet[pointIndex], size, yMinimum, yScale));
      }
      canvas.drawPath(trace, tracePaint);
    }
  }

  getScaledX(value, minimum, scale) => (value - minimum) * scale;

  getScaledY(value, size, minimum, scale) =>
      size.height - getScaledX(value, minimum, scale);

  addXTick(tickLabel, value, canvas, size, xMinimum, yMinimum, xScale, yScale) {
    if (tickLabel != '0') {
      TextPainter markPainter = TextPainter(
        text: const TextSpan(
          text: "|",
          style: TextStyle(
              fontFamily: "MyriadPro", fontSize: 5, color: AppPalette.grey),
        ),
        textDirection: TextDirection.ltr,
      );
      markPainter.layout(minWidth: 0, maxWidth: size.width);
      markPainter.paint(
          canvas,
          Offset(getScaledX(value, xMinimum, xScale),
              getScaledY(0, size, yMinimum, yScale)));
    }
    TextPainter labelPainter = TextPainter(
      text: TextSpan(
        text: tickLabel,
        style: const TextStyle(
            fontFamily: "MyriadPro", fontSize: 12, color: AppPalette.grey),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout(minWidth: 0, maxWidth: size.width);
    labelPainter.paint(
        canvas,
        Offset(getScaledX(value - xTickScaling.$1, xMinimum, xScale),
            getScaledY(xTickScaling.$2 * -5 * yScale, size, yMinimum, yScale)));
  }

  addYTick(tickLabel, value, canvas, size, xMinimum, yMinimum, xScale, yScale) {
    if (tickLabel != '0') {
      TextPainter markPainter = TextPainter(
        text: const TextSpan(
          text: "---",
          style: TextStyle(
              fontFamily: "MyriadPro", fontSize: 8, color: AppPalette.grey),
        ),
        textDirection: TextDirection.ltr,
      );
      markPainter.layout(minWidth: 0, maxWidth: size.width);
      markPainter.paint(
          canvas,
          Offset(getScaledX(-2 * yTickScaling.$1, xMinimum, xScale),
              getScaledY(value, size, yMinimum, yScale)));
    }
    TextPainter labelPainter = TextPainter(
      text: TextSpan(
        text: tickLabel,
        style: const TextStyle(
            fontFamily: "MyriadPro", fontSize: 12, color: AppPalette.grey),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout(minWidth: 0, maxWidth: size.width);
    labelPainter.paint(
        canvas,
        Offset(getScaledX(-8 * yTickScaling.$1, xMinimum, xScale),
            getScaledY(value, size, yMinimum, yScale)));
  }

  @override
  bool shouldRepaint(_TracePainter old) {
    return true;
  }
}
