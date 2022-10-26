import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'chart_engine.dart';

typedef TooltipCallback = void Function({
  DateTimeRange? range,
  double? amount,
  DateTime? amountDate,
  required ScrollPosition position,
  required Rect rect,
  required double barWidth,
});

abstract class BarPainter<T> extends ChartEngine {
  BarPainter({
    required super.scrollController,
    required super.context,
    required super.dayCount,
    required super.viewMode,
    required super.repaint,
    this.tooltipCallback,
    required this.dataList,
    required this.topHour,
    required this.bottomHour,
    required this.useToday,
    this.widgetMode = false,
    this.barColor,
  }) : super(firstValueDateTime: DateTime.now());

  final TooltipCallback? tooltipCallback;
  final Color? barColor;
  final List dataList;
  final int topHour;
  final int bottomHour;
  final bool useToday;
  final bool widgetMode;

  Radius get barRadius => const Radius.circular(6.0);

  @override
  @nonVirtual
  void paint(Canvas canvas, Size size) {
    setDefaultValue(size);
    drawBar(canvas, size, generateCoordinates(size));
  }

  void drawBar(Canvas canvas, Size size, List<T> coordinates);

  List<T> generateCoordinates(Size size);

  @protected
  // This is for chart.time only
  DateTime getBarRenderStartDateTime(List dataList) {
    print(dataList.first.end.add(Duration(
      days: -currentDayFromScrollOffset + ChartEngine.toleranceDay,
    )));
    return dataList.first.end.add(Duration(
      days: -currentDayFromScrollOffset + ChartEngine.toleranceDay,
    ));
  }

  @override
  @nonVirtual
  bool shouldRepaint(BarPainter oldDelegate) {
    return oldDelegate.dataList != dataList;
  }
}
