import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class ShadedTimeSeriesGraph extends StatefulWidget {
  final List x;
  final List y;
  final int timeFrame;
  final String parameterLabel;

  const ShadedTimeSeriesGraph(
      {super.key,
      required this.x,
      required this.y,
      required this.timeFrame,
      required this.parameterLabel});

  @override
  ShadedTimeSeriesGraphState createState() => ShadedTimeSeriesGraphState();
}

class ShadedTimeSeriesGraphState extends State<ShadedTimeSeriesGraph> {
  final graphGradient = const LinearGradient(
    colors: [
      Color(0xFF6FFF7C),
      Color(0xFF0087FF),
      Color(0xFF5620FF),
    ],
    stops: [0.25, 0.5, 0.75],
    begin: Alignment(0.5, 0),
    end: Alignment(0.5, 1),
  );

  final barAreaGradient = const LinearGradient(
    colors: [
      Color.fromRGBO(111, 255, 124, 0.3),
      Color.fromRGBO(0, 135, 255, 0.3),
      Color.fromRGBO(86, 32, 255, 0.3),
    ],
    stops: [0.25, 0.5, 0.75],
    begin: Alignment(0.5, 0),
    end: Alignment(0.5, 1),
  );

  final int _divider = 25;
  final int _leftLabelsCount = 6;

  List<FlSpot> _plotPoints = [];

  double _minX = 0;
  double _maxX = 0;
  double _minY = 0;
  double _maxY = 0;
  double _leftTitlesInterval = 0;

  @override
  void initState() {
    super.initState();
    _prepareStockData();
  }

  void _prepareStockData() async {
    const samplingOptions = [5, 15, 30, 60, 180, 540, 720, 1440, 2880];
    List<FlSpot> graphPoints = [];
    for (int i = 0; i < widget.x.length; i++) {
      graphPoints.add(FlSpot(widget.x[i], widget.y[i]));
    }

    for (int timeFrameOptions = 0; timeFrameOptions < 9; timeFrameOptions++) {
      if (widget.timeFrame < 0 || widget.timeFrame >= 9) {
        _plotPoints = graphPoints;
        break;
      } else if (widget.timeFrame == timeFrameOptions) {
        double rr = 10;
        try {
          rr = 10.0;
        } catch (exception) {
          rr = 10;
        }
        int length = (rr * samplingOptions[timeFrameOptions]).toInt();
        if (graphPoints.length > length) {
          _plotPoints = graphPoints.sublist(graphPoints.length - length);
        } else {
          _plotPoints = graphPoints;
        }
        break;
      }
    }

    double minY = double.maxFinite;
    double maxY = double.minPositive;

    for (var element in _plotPoints) {
      if (element.y < minY) minY = element.y;
      if (element.y > maxY) maxY = element.y;
    }

    _minX = _plotPoints.first.x;
    _maxX = _plotPoints.last.x;
    _minY = (minY / _divider).floorToDouble() * _divider;
    _maxY = (maxY / _divider).ceilToDouble() * _divider;
    _leftTitlesInterval =
        ((_maxY - _minY) / (_leftLabelsCount - 1)).floorToDouble();

    if (_leftTitlesInterval == 0) {
      _leftTitlesInterval = 5;
    }

    setState(() {});
  }

  LineChartData _mainData() {
    return LineChartData(
      gridData: _gridData(),
      titlesData: FlTitlesData(
        bottomTitles: _bottomTitles(),
        leftTitles: _leftTitles(),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        border: Border.all(color: Colors.white12, width: 1),
      ),
      minX: _minX,
      maxX: _maxX,
      minY: _minY,
      maxY: _maxY,
      lineBarsData: [_lineBarData()],
    );
  }

  LineChartBarData _lineBarData() {
    return LineChartBarData(
        spots: _plotPoints,
        gradient: graphGradient,
        barWidth: 2.5,
        isCurved: true,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        preventCurveOverShooting: true,
        preventCurveOvershootingThreshold: 5,
        belowBarData: BarAreaData(show: true, gradient: barAreaGradient));
  }

  AxisTitles _leftTitles() {
    return AxisTitles(
        axisNameWidget: Text(widget.parameterLabel,
            style: const TextStyle(
                color: Colors.white54, fontSize: 16, letterSpacing: 1.0)),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Padding(
                  padding: const EdgeInsets.only(right: 2.0, bottom: 5.0),
                  child: Text(value.toInt().toString(),
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 16)),
                ));
          },
          interval: _leftTitlesInterval,
        ));
  }

  AxisTitles _bottomTitles() {
    return AxisTitles(
        axisNameWidget: const Text('Time',
            style: TextStyle(
                color: Colors.white54, fontSize: 16, letterSpacing: 1.0)),
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final DateTime date =
                DateTime.fromMillisecondsSinceEpoch(value.toInt());
            final displayValue =
                "${DateFormat.Md().format(date)},${DateFormat.jm().format(date)}";
            return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(displayValue,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)));
          },
          interval: (_maxX - _minX) / 3,
        ));
  }

  FlGridData _gridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (value) {
        return const FlLine(
          color: Colors.white12,
          strokeWidth: 1,
        );
      },
      checkToShowHorizontalLine: (value) {
        return (value - _minY) % _leftTitlesInterval == 0;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3.2,
      child: Padding(
        padding:
            const EdgeInsets.only(right: 30.0, left: 12.0, top: 24, bottom: 12),
        child:
            _plotPoints.isEmpty ? const Placeholder() : LineChart(_mainData()),
      ),
    );
  }
}
