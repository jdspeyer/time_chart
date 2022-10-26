////////////////////////////////////////////////////////////////
/// Updated 10/10/2022 by Jake Speyer
///
/// Time Bar Painter (implementation of BarPainter abstract class) interacts with the canvas and draws the bars to
/// graphically represent the data being passed in.
///
/// There can be multiple bars in one day.
///
/// Only opperates on lists of DateTimeRanges. Doubles are processed
/// by amount_bar_painter.dart.
////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:time_chart/src/components/painter/bar_painter.dart';
import 'package:touchable/touchable.dart';
import '../../utils/time_assistant.dart' as time_assistant;
import '../chart_engine.dart';

class TimeBarPainter extends BarPainter<TimeBarItem> {
  TimeBarPainter({
    required super.scrollController,
    required super.repaint,
    required super.tooltipCallback,
    required super.context,
    required super.dataList,
    required super.topHour,
    required super.useToday,
    required super.bottomHour,
    required super.dayCount,
    required super.viewMode,
    super.barColor,
  });

  void _drawRRect(
    TouchyCanvas canvas,
    Paint paint,
    DateTimeRange data,
    Rect rect,
    Radius topRadius, [
    Radius bottomRadius = Radius.zero,
  ]) {
    callback(_) => tooltipCallback!(
          range: data,
          position: scrollController!.position,
          rect: rect,
          barWidth: barWidth,
        );

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: topRadius,
        topRight: topRadius,
        bottomLeft: bottomRadius,
        bottomRight: bottomRadius,
      ),
      paint,
      onTapUp: callback,
      onLongPressStart: callback,
      onLongPressMoveUpdate: callback,
    );
  }

  void _drawOutRangedBar(
    TouchyCanvas canvas,
    Paint paint,
    Size size,
    Rect rect,
    DateTimeRange data,
  ) {
    if (topHour != bottomHour && (bottomHour - topHour).abs() != 24) return;

    final height = size.height;
    bool topOverflow = rect.top < 0.0;

    final top = topOverflow ? height + rect.top : 0.0;
    final bottom = topOverflow ? height : rect.bottom - height;
    final horizontal = topOverflow ? -blockWidth! : blockWidth!;
    final newRect = Rect.fromLTRB(
      rect.left + horizontal,
      top,
      rect.right + horizontal,
      bottom,
    );

    if (topOverflow) {
      _drawRRect(canvas, paint, data, newRect, barRadius);
    } else {
      _drawRRect(canvas, paint, data, newRect, Radius.zero, barRadius);
    }
  }

  @override
  void drawBar(Canvas canvas, Size size, List<TimeBarItem> coordinates) {
    final touchyCanvas = TouchyCanvas(context, canvas,
        scrollController: scrollController, scrollDirection: AxisDirection.left);
    final paint = Paint()
      ..color = barColor ?? Theme.of(context).colorScheme.secondary
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
    final maxBottom = size.height;

    for (int index = 0; index < coordinates.length; index++) {
      final TimeBarItem offsetRange = coordinates[index];

      final double left = paddingForAlignedBar + offsetRange.dx;
      final double right = paddingForAlignedBar + offsetRange.dx + barWidth;
      double top = offsetRange.topY;
      double bottom = offsetRange.bottomY;

      Radius topRadius = barRadius;
      Radius bottomRadius = barRadius;

      if (top < 0.0) {
        _drawOutRangedBar(
            touchyCanvas, paint, size, Rect.fromLTRB(left, top, right, bottom), offsetRange.data);
        top = 0.0;
        topRadius = Radius.zero;
      } else if (bottom > maxBottom) {
        _drawOutRangedBar(
            touchyCanvas, paint, size, Rect.fromLTRB(left, top, right, bottom), offsetRange.data);
        bottom = maxBottom;
        bottomRadius = Radius.zero;
      }

      _drawRRect(touchyCanvas, paint, offsetRange.data, Rect.fromLTRB(left, top, right, bottom),
          topRadius, bottomRadius);
    }
  }

  /// JS
  /// Converts the time using the reference time.
  /// Other times based on the reference time are listed below.
  /// For example, if 17 o'clock is the standard and 3 o'clock is input, 27 is returned.
  dynamic _convertUsing(var pivot, var value) {
    return value + (value < pivot ? 24 : 0);
  }

  bool _outRangedPivotHour(double sleepTime, double wakeUp) {
    if (sleepTime < 0.0) sleepTime += 24.0;

    /// T
    /// Check whether two standard hours are included in the sleep time.
    var top = _convertUsing(sleepTime, topHour);
    var bottom = _convertUsing(sleepTime, bottomHour);
    var candidateWakeUp = _convertUsing(sleepTime, wakeUp);
    if (sleepTime <= top && bottom <= candidateWakeUp) return false;

    /// T
    /// Check if they do not belong but overlap.
    top = topHour;
    bottom = bottomHour;
    if (top < bottom) {
      sleepTime = _convertUsing(topHour, sleepTime);
      wakeUp = _convertUsing(topHour, wakeUp);
      top += 24;
    }
    if ((bottom < sleepTime && sleepTime < top && bottom < wakeUp && wakeUp < top)) return true;

    return false;
  }

  @override
  List<TimeBarItem> generateCoordinates(Size size) {
    final List<TimeBarItem> coordinates = [];

    if (dataList.isEmpty) return [];
    final double intervalOfBars = size.width / dayCount;

    /// T
    /// If the bar at the bottom is not at the right angle, draw the bar up.
    final int pivotBottom = _convertUsing(topHour, bottomHour);
    final int pivotHeight = pivotBottom > topHour ? pivotBottom - topHour : 24;
    final int length = dataList.length;
    final double height = size.height;
    final int viewLimitDay = viewMode.dayCount;

    final int dayFromScrollOffset = currentDayFromScrollOffset;
    final DateTime startDateTime = getBarRenderStartDateTime(dataList);
    final int startIndex = (dataList as List<DateTimeRange>).getLowerBound(startDateTime);

    for (int index = startIndex; index < length; index++) {
      final wakeUpTimeDouble = (dataList as List<DateTimeRange>)[index].end.toDouble();
      final sleepAmountDouble = (dataList as List<DateTimeRange>)[index].durationInHours;
      final barPosition =
          1 + (dataList as List<DateTimeRange>).first.end.differenceDateInDay(dataList[index].end);

      if (barPosition - dayFromScrollOffset > viewLimitDay + ChartEngine.toleranceDay * 2) break;

      /// T
      /// To express the passage of time as the left label goes down
      /// Find the difference between a large time value and the current time.
      double normalizedBottom =
          (pivotBottom - _convertUsing(topHour, wakeUpTimeDouble)) / pivotHeight;
      double normalizedTop = normalizedBottom + sleepAmountDouble / pivotHeight;

      if (normalizedTop < 0.0 && normalizedBottom < 0.0) {
        normalizedTop += 1.0;
        normalizedBottom += 1.0;
      }

      final double bottom = height - normalizedBottom * height;
      final double top = height - normalizedTop * height;
      final double right = size.width - intervalOfBars * barPosition;

      /// T
      /// Skip if there is no need to draw
      if (top == bottom ||
          _outRangedPivotHour(wakeUpTimeDouble - sleepAmountDouble, wakeUpTimeDouble)) continue;

      coordinates.add(TimeBarItem(right, top, bottom, dataList[index]));
    }
    return coordinates;
  }
}

class TimeBarItem {
  final double dx;
  final double topY;
  final double bottomY;
  final DateTimeRange data;

  TimeBarItem(this.dx, this.topY, this.bottomY, this.data);
}
