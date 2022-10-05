import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'chart_engine.dart';

typedef TooltipCallback = void Function({
  // JP -- Changed
  // double? range,
  DateTimeRange? range,
  double? amount,
  // JP -- Changed
  // double? amountDate,
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
    //JP -- Changed
    // required this.tooltipCallback,
    required this.dataList,
    required this.topHour,
    required this.bottomHour,
    this.barColor,
  }) :
        // JP -- Changed
        super(firstValueDateTime: DateTime.now());
  // super(
  //   firstValueDateTime: dataList.isEmpty ? DateTime.now() : dataList[0],
  // );

  // final TooltipCallback tooltipCallback;
  final Color? barColor;
  // JP -- Changed
  final List<double> dataList;
  // final List<DateTimeRange> dataList;
  final int topHour;
  final int bottomHour;

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
  // DateTime getBarRenderStartDateTime(List<DateTimeRange> dataList) {
  //   print(dataList.first.end.add(Duration(
  //     days: -currentDayFromScrollOffset + ChartEngine.toleranceDay,
  //   )));
  //   return dataList.first.end.add(Duration(
  //     days: -currentDayFromScrollOffset + ChartEngine.toleranceDay,
  //   ));
  // }

  @override
  @nonVirtual
  bool shouldRepaint(BarPainter oldDelegate) {
    return oldDelegate.dataList != dataList;
  }
}
